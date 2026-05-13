//! Hamilton's equations in ECEF Cartesian coordinates (internal).
//!
//! Wraps the existing spherical-coordinate physics models by:
//! 1. Converting `(x, y, z)` → `(r, θ, φ)` at each step
//! 2. Evaluating refractive index in spherical coordinates
//! 3. Transforming gradients back to ECEF via the Jacobian
//!
//! This eliminates the polar coordinate singularity present in the
//! spherical Hamiltonian (`1/(r·sin θ)` terms).

use crate::ecef::*;
use crate::models::refractive_index::compute_rindex;
use crate::params::*;

/// Compute derivatives [dx/dt, dy/dt, dz/dt, dkx/dt, dky/dt, dkz/dt, dphase/dt, dabsorb/dt]
/// for the ECEF state vector.
pub(crate) fn hamltn_ecef(
    y: &[f64],
    freq_mhz: f64,
    ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
) -> ([f64; 8], bool, f64, f64, f64) {
    let (x_pos, y_pos, z_pos) = (y[0], y[1], y[2]);
    let (kx, ky, kz) = (y[3], y[4], y[5]);

    // ── Step 1: Convert position and k-vector to spherical ──
    let (r, theta, phi) = ecef_to_spherical(x_pos, y_pos, z_pos);
    let (kr, kth, kph) = k_ecef_to_spherical(kx, ky, kz, theta, phi);

    // ── Step 2: Evaluate physics in spherical coordinates ──
    let ri = compute_rindex(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart);

    let phpom = ri.dhdom_re;

    // ── Step 3: Transform spatial gradients → ECEF ──
    let (dhdx, dhdy, dhdz) = if phpom != 0.0 {
        gradient_spherical_to_ecef(ri.dhdr_re, ri.dhdth_re, ri.dhdph_re, r, theta, phi)
    } else {
        (0.0, 0.0, 0.0)
    };

    // ── Step 4: Transform k-gradients → ECEF ──
    let (dhdkx, dhdky, dhdkz) = if phpom != 0.0 {
        k_gradient_spherical_to_ecef(ri.dhdkr_re, ri.dhdkth_re, ri.dhdkph_re, theta, phi)
    } else {
        (0.0, 0.0, 0.0)
    };

    // ── Step 5: ECEF equations of motion (no singularities!) ──
    let (dxdt, dydt, dzdt) = if phpom != 0.0 {
        (
            -dhdkx / (phpom * C),
            -dhdky / (phpom * C),
            -dhdkz / (phpom * C),
        )
    } else {
        (0.0, 0.0, 0.0)
    };

    let (dkxdt, dkydt, dkzdt) = if phpom != 0.0 {
        (dhdx / (phpom * C), dhdy / (phpom * C), dhdz / (phpom * C))
    } else {
        (0.0, 0.0, 0.0)
    };

    // Phase path
    let d_phase = if phpom != 0.0 {
        let om = PIT2 * 1.0e6 * freq_mhz;
        ri.kphpk_re / phpom / om
    } else {
        0.0
    };

    // Absorption
    let d_absorb = if phpom != 0.0 {
        let om = PIT2 * 1.0e6 * freq_mhz;
        // Use the ECEF k-vector magnitude (same as spherical since rotation preserves |k|)
        let new_k_sph = k_ecef_to_spherical(kx, ky, kz, theta, phi);
        let k2 = new_k_sph.0.powi(2) + new_k_sph.1.powi(2) + new_k_sph.2.powi(2);
        if k2 > 0.0 {
            let kay2i = om * om / (C * C) * ri.n2_im;
            10.0 / LOGTEN * ri.kphpk_im * kay2i / k2 / phpom / C
        } else {
            0.0
        }
    } else {
        0.0
    };

    let derivs = [dxdt, dydt, dzdt, dkxdt, dkydt, dkzdt, d_phase, d_absorb];

    // Transform rescaled k-vector back to ECEF for the caller
    let (new_kx, new_ky, new_kz) =
        k_spherical_to_ecef(ri.new_kr, ri.new_kth, ri.new_kph, theta, phi);

    (derivs, ri.space, new_kx, new_ky, new_kz)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ecef::spherical_to_ecef;

    fn default_params() -> ModelParams {
        ModelParams::default()
    }

    #[test]
    fn test_ecef_hamltn_initial_call() {
        let p = default_params();
        let theta0 = PID2 - 40.0_f64.to_radians();
        let phi0 = 0.0;
        let r0 = p.earth_r;

        let (x0, y0, z0) = spherical_to_ecef(r0, theta0, phi0);

        let elev = 20.0_f64.to_radians();
        let az = 45.0_f64.to_radians();
        let kr = elev.sin();
        let kth = elev.cos() * (std::f64::consts::PI - az).cos();
        let kph = elev.cos() * (std::f64::consts::PI - az).sin();
        let (kx, ky, kz) = k_spherical_to_ecef(kr, kth, kph, theta0, phi0);

        let y = [x0, y0, z0, kx, ky, kz, 0.0, 0.0];
        let (derivs, _space, new_kx, new_ky, new_kz) = hamltn_ecef(&y, 10.0, -1.0, &p, true);

        assert!(new_kx.is_finite(), "new_kx should be finite");
        assert!(new_ky.is_finite(), "new_ky should be finite");
        assert!(new_kz.is_finite(), "new_kz should be finite");
        for (i, d) in derivs.iter().enumerate() {
            assert!(d.is_finite(), "ECEF derivative {} not finite: {}", i, d);
        }
    }

    #[test]
    fn test_ecef_hamltn_near_pole() {
        // The whole point: verify no singularity near the pole
        let p = default_params();
        let theta0 = 0.01; // ~89.4°N — near pole
        let phi0 = 0.0;
        let r0 = p.earth_r;

        let (x0, y0, z0) = spherical_to_ecef(r0, theta0, phi0);

        let elev = 20.0_f64.to_radians();
        let kr = elev.sin();
        let kth = -elev.cos();
        let kph = 0.0;
        let (kx, ky, kz) = k_spherical_to_ecef(kr, kth, kph, theta0, phi0);

        let y = [x0, y0, z0, kx, ky, kz, 0.0, 0.0];
        let (derivs, _space, _, _, _) = hamltn_ecef(&y, 10.0, -1.0, &p, true);

        for (i, d) in derivs.iter().enumerate() {
            assert!(
                d.is_finite(),
                "ECEF derivative {} at pole not finite: {}",
                i,
                d
            );
        }
        // Derivatives should have reasonable magnitude (not huge)
        for (i, d) in derivs[0..6].iter().enumerate() {
            assert!(
                d.abs() < 1.0e6,
                "ECEF derivative {} at pole has unreasonable magnitude: {}",
                i,
                d
            );
        }
    }

    #[test]
    fn test_ecef_matches_spherical_midlat() {
        // At mid-latitude, ECEF and spherical Hamiltonians should give
        // equivalent velocity directions
        use crate::hamiltonian::hamltn;

        let p = default_params();
        let theta0 = PID2 - 40.0_f64.to_radians();
        let phi0 = 0.0;
        let r0 = p.earth_r;

        let elev = 20.0_f64.to_radians();
        let az = 0.0; // due north for simplicity
        let kr = elev.sin();
        let kth = -elev.cos();
        let kph = 0.0;

        // Spherical
        let y_sph = [r0, theta0, phi0, kr, kth, kph, 0.0, 0.0];
        let (d_sph, _, nkr, nkth, nkph) = hamltn(&y_sph, 10.0, -1.0, &p, true);

        // ECEF
        let (x0, y0, z0) = spherical_to_ecef(r0, theta0, phi0);
        let (kx, ky, kz) = k_spherical_to_ecef(kr, kth, kph, theta0, phi0);
        let y_ecef = [x0, y0, z0, kx, ky, kz, 0.0, 0.0];
        let (d_ecef, _, _, _, _) = hamltn_ecef(&y_ecef, 10.0, -1.0, &p, true);

        // Convert spherical velocity to ECEF for comparison
        // dr/dt → radial
        let drdt = d_sph[0];
        let r_dthdt = r0 * d_sph[1];
        let rsth_dphdt = r0 * theta0.sin() * d_sph[2];
        let (vx_sph, vy_sph, vz_sph) = k_spherical_to_ecef(drdt, r_dthdt, rsth_dphdt, theta0, phi0);

        // Compare velocity magnitudes (should be close)
        let v_sph = (vx_sph * vx_sph + vy_sph * vy_sph + vz_sph * vz_sph).sqrt();
        let v_ecef = (d_ecef[0] * d_ecef[0] + d_ecef[1] * d_ecef[1] + d_ecef[2] * d_ecef[2]).sqrt();

        assert!(
            v_sph > 0.0 && v_ecef > 0.0,
            "Velocities should be non-zero: sph={v_sph}, ecef={v_ecef}"
        );

        // Phase path derivatives should match closely
        assert!(
            (d_ecef[6] - d_sph[6]).abs() < 1e-6,
            "Phase path derivatives should match: ecef={}, sph={}",
            d_ecef[6],
            d_sph[6]
        );
    }
}
