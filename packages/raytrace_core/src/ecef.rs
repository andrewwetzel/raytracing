//! ECEF ↔ spherical coordinate transformations.
//!
//! Provides conversions between Earth-Centered Earth-Fixed (ECEF) Cartesian
//! coordinates `(x, y, z)` and the geocentric spherical coordinates `(r, θ, φ)`
//! used by the physics models. Also provides wave-vector and gradient Jacobian
//! transforms needed by [`hamiltonian_ecef`](crate::hamiltonian_ecef).



// ============================================================
// Position conversions
// ============================================================

/// Convert spherical geocentric `(r, θ, φ)` to ECEF Cartesian `(x, y, z)`.
///
/// Convention: θ = colatitude (0 at north pole), φ = longitude (east-positive).
pub fn spherical_to_ecef(r: f64, theta: f64, phi: f64) -> (f64, f64, f64) {
    let st = theta.sin();
    let ct = theta.cos();
    let sp = phi.sin();
    let cp = phi.cos();
    (r * st * cp, r * st * sp, r * ct)
}

/// Convert ECEF Cartesian `(x, y, z)` to spherical geocentric `(r, θ, φ)`.
///
/// Returns `(r, theta, phi)` where theta ∈ [0, π] and phi ∈ [−π, π].
pub fn ecef_to_spherical(x: f64, y: f64, z: f64) -> (f64, f64, f64) {
    let r = (x * x + y * y + z * z).sqrt();
    if r < 1.0e-15 {
        return (0.0, 0.0, 0.0);
    }
    let theta = (z / r).clamp(-1.0, 1.0).acos();
    let phi = y.atan2(x);
    (r, theta, phi)
}

// ============================================================
// Wave-vector conversions
// ============================================================

/// Transform a wave vector from spherical `(kr, kθ, kφ)` to ECEF `(kx, ky, kz)`.
///
/// The transform uses the rotation matrix from the local spherical basis
/// `(r̂, θ̂, φ̂)` to the Cartesian basis `(x̂, ŷ, ẑ)`.
pub fn k_spherical_to_ecef(kr: f64, kth: f64, kph: f64, theta: f64, phi: f64) -> (f64, f64, f64) {
    let st = theta.sin();
    let ct = theta.cos();
    let sp = phi.sin();
    let cp = phi.cos();

    // Rotation matrix: [r̂, θ̂, φ̂] → [x̂, ŷ, ẑ]
    //   r̂  = ( sin θ cos φ,  sin θ sin φ,  cos θ )
    //   θ̂  = ( cos θ cos φ,  cos θ sin φ, −sin θ )
    //   φ̂  = (−sin φ,        cos φ,        0      )
    let kx = st * cp * kr + ct * cp * kth - sp * kph;
    let ky = st * sp * kr + ct * sp * kth + cp * kph;
    let kz = ct * kr - st * kth;

    (kx, ky, kz)
}

/// Transform a wave vector from ECEF `(kx, ky, kz)` to spherical `(kr, kθ, kφ)`.
///
/// Inverse of [`k_spherical_to_ecef`].
pub fn k_ecef_to_spherical(kx: f64, ky: f64, kz: f64, theta: f64, phi: f64) -> (f64, f64, f64) {
    let st = theta.sin();
    let ct = theta.cos();
    let sp = phi.sin();
    let cp = phi.cos();

    // Transpose of the rotation matrix
    let kr = st * cp * kx + st * sp * ky + ct * kz;
    let kth = ct * cp * kx + ct * sp * ky - st * kz;
    let kph = -sp * kx + cp * ky;

    (kr, kth, kph)
}

// ============================================================
// Gradient (Jacobian) transforms
// ============================================================

/// Transform Hamiltonian spatial gradients from spherical to ECEF.
///
/// Given `(∂H/∂r, ∂H/∂θ, ∂H/∂φ)`, compute `(∂H/∂x, ∂H/∂y, ∂H/∂z)` using
/// the chain rule and the Jacobian `∂(r,θ,φ)/∂(x,y,z)`.
///
/// The Jacobian elements are:
/// ```text
///   ∂r/∂x = sin θ cos φ     ∂r/∂y = sin θ sin φ     ∂r/∂z = cos θ
///   ∂θ/∂x = cos θ cos φ / r  ∂θ/∂y = cos θ sin φ / r  ∂θ/∂z = −sin θ / r
///   ∂φ/∂x = −sin φ / (r sin θ)  ∂φ/∂y = cos φ / (r sin θ)  ∂φ/∂z = 0
/// ```
pub fn gradient_spherical_to_ecef(
    dh_dr: f64,
    dh_dth: f64,
    dh_dph: f64,
    r: f64,
    theta: f64,
    phi: f64,
) -> (f64, f64, f64) {
    let st = theta.sin();
    let ct = theta.cos();
    let sp = phi.sin();
    let cp = phi.cos();

    let r_inv = if r.abs() > 1.0e-15 { 1.0 / r } else { 0.0 };
    let rst_inv = if (r * st).abs() > 1.0e-15 {
        1.0 / (r * st)
    } else {
        0.0
    };

    // ∂H/∂x = (∂H/∂r)(∂r/∂x) + (∂H/∂θ)(∂θ/∂x) + (∂H/∂φ)(∂φ/∂x)
    let dh_dx = dh_dr * st * cp + dh_dth * ct * cp * r_inv - dh_dph * sp * rst_inv;
    let dh_dy = dh_dr * st * sp + dh_dth * ct * sp * r_inv + dh_dph * cp * rst_inv;
    let dh_dz = dh_dr * ct - dh_dth * st * r_inv;

    (dh_dx, dh_dy, dh_dz)
}

/// Transform Hamiltonian k-gradients from spherical to ECEF.
///
/// Given `(∂H/∂kr, ∂H/∂kθ, ∂H/∂kφ)`, compute `(∂H/∂kx, ∂H/∂ky, ∂H/∂kz)`.
///
/// Since the k-components transform like the position basis vectors (contra-variant),
/// the k-gradient transform is simply the same rotation matrix as positions.
pub fn k_gradient_spherical_to_ecef(
    dh_dkr: f64,
    dh_dkth: f64,
    dh_dkph: f64,
    theta: f64,
    phi: f64,
) -> (f64, f64, f64) {
    // Same rotation as k_spherical_to_ecef
    k_spherical_to_ecef(dh_dkr, dh_dkth, dh_dkph, theta, phi)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::params::EARTH_RADIUS;
    use std::f64::consts::PI;

    const EPS: f64 = 1.0e-10;

    #[test]
    fn test_spherical_ecef_roundtrip() {
        let cases = [
            (EARTH_RADIUS + 300.0, 0.5, 1.0), // mid-latitude
            (EARTH_RADIUS, PI / 2.0, 0.0),    // equator, prime meridian
            (EARTH_RADIUS, 0.01, 0.5),        // near north pole
            (EARTH_RADIUS, PI - 0.01, -1.0),  // near south pole
        ];
        for (r, theta, phi) in cases {
            let (x, y, z) = spherical_to_ecef(r, theta, phi);
            let (r2, theta2, phi2) = ecef_to_spherical(x, y, z);
            assert!((r2 - r).abs() < EPS, "r roundtrip: {r} → {r2}");
            assert!(
                (theta2 - theta).abs() < EPS,
                "theta roundtrip: {theta} → {theta2}"
            );
            // phi may wrap, compare via sin/cos
            assert!(
                (phi2.sin() - phi.sin()).abs() < EPS && (phi2.cos() - phi.cos()).abs() < EPS,
                "phi roundtrip: {phi} → {phi2}"
            );
        }
    }

    #[test]
    fn test_k_vector_roundtrip() {
        let theta = 1.0;
        let phi = 0.5;
        let kr = 0.342;
        let kth = -0.664;
        let kph = 0.3;

        let (kx, ky, kz) = k_spherical_to_ecef(kr, kth, kph, theta, phi);
        let (kr2, kth2, kph2) = k_ecef_to_spherical(kx, ky, kz, theta, phi);

        assert!((kr2 - kr).abs() < EPS, "kr roundtrip: {kr} → {kr2}");
        assert!((kth2 - kth).abs() < EPS, "kth roundtrip: {kth} → {kth2}");
        assert!((kph2 - kph).abs() < EPS, "kph roundtrip: {kph} → {kph2}");
    }

    #[test]
    fn test_k_magnitude_preserved() {
        let theta = 0.8;
        let phi = 1.2;
        let kr = 0.5;
        let kth = -0.3;
        let kph = 0.7;

        let k2_sph = kr * kr + kth * kth + kph * kph;
        let (kx, ky, kz) = k_spherical_to_ecef(kr, kth, kph, theta, phi);
        let k2_ecef = kx * kx + ky * ky + kz * kz;

        assert!(
            (k2_ecef - k2_sph).abs() < EPS,
            "k² should be preserved: {k2_sph} → {k2_ecef}"
        );
    }

    #[test]
    fn test_gradient_transform_radial_at_equator() {
        // At equator (θ=π/2, φ=0): r̂ = x̂, so ∂H/∂r should map to ∂H/∂x
        let dh_dr = 1.0;
        let (dh_dx, dh_dy, dh_dz) =
            gradient_spherical_to_ecef(dh_dr, 0.0, 0.0, EARTH_RADIUS, PI / 2.0, 0.0);
        assert!(
            (dh_dx - 1.0).abs() < EPS,
            "Radial gradient at equator/prime-meridian → x: got {dh_dx}"
        );
        assert!(dh_dy.abs() < EPS, "Should be ~0 in y, got {dh_dy}");
        assert!(dh_dz.abs() < EPS, "Should be ~0 in z, got {dh_dz}");
    }

    #[test]
    fn test_gradient_transform_radial_at_pole() {
        // At north pole (θ≈0, φ=0): r̂ = ẑ, so ∂H/∂r should map to ∂H/∂z
        let dh_dr = 1.0;
        let (dh_dx, dh_dy, dh_dz) =
            gradient_spherical_to_ecef(dh_dr, 0.0, 0.0, EARTH_RADIUS, 0.001, 0.0);
        assert!(
            dh_dz.abs() > 0.99,
            "Radial gradient at pole → z: got {dh_dz}"
        );
        assert!(dh_dx.abs() < 0.01, "Should be ~0 in x, got {dh_dx}");
        assert!(dh_dy.abs() < 0.01, "Should be ~0 in y, got {dh_dy}");
    }

    #[test]
    fn test_ecef_at_known_points() {
        // North pole: (r, 0, 0) → (0, 0, r)
        let (x, y, z) = spherical_to_ecef(EARTH_RADIUS, 0.0, 0.0);
        assert!(x.abs() < EPS, "North pole x should be ~0, got {x}");
        assert!(y.abs() < EPS, "North pole y should be ~0, got {y}");
        assert!(
            (z - EARTH_RADIUS).abs() < EPS,
            "North pole z should be ~R, got {z}"
        );

        // Equator, prime meridian: (r, π/2, 0) → (r, 0, 0)
        let (x, y, z) = spherical_to_ecef(EARTH_RADIUS, PI / 2.0, 0.0);
        assert!(
            (x - EARTH_RADIUS).abs() < EPS,
            "Equator x should be ~R, got {x}"
        );
        assert!(y.abs() < EPS, "Equator y should be ~0, got {y}");
        assert!(z.abs() < EPS, "Equator z should be ~0, got {z}");
    }
}
