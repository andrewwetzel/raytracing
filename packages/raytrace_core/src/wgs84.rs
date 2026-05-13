//! WGS-84 oblate spheroid geometry.
//!
//! Provides geodetic altitude, coordinate conversions, and geodesic distance
//! calculations on the WGS-84 reference ellipsoid. Used by the tracer when
//! [`EarthModel::Wgs84`](crate::params::EarthModel::Wgs84) is selected.

use std::f64::consts::PI;

// ============================================================
// WGS-84 Constants (all lengths in km to match the engine)
// ============================================================

/// Semi-major axis (equatorial radius) in km.
pub const WGS84_A: f64 = 6378.137;

/// Semi-minor axis (polar radius) in km.
pub const WGS84_B: f64 = 6356.752_314_245;

/// Flattening: f = (a − b) / a.
pub const WGS84_F: f64 = 1.0 / 298.257_223_563;

/// First eccentricity squared: e² = (a² − b²) / a².
pub const WGS84_E2: f64 = (WGS84_A * WGS84_A - WGS84_B * WGS84_B) / (WGS84_A * WGS84_A);

/// Second eccentricity squared: e′² = (a² − b²) / b².
pub const WGS84_EP2: f64 = (WGS84_A * WGS84_A - WGS84_B * WGS84_B) / (WGS84_B * WGS84_B);

// ============================================================
// Geocentric ↔ Geodetic Conversions
// ============================================================

/// Convert geocentric spherical `(r, θ_colatitude)` to geodetic `(latitude, height)`.
///
/// Uses Bowring's iterative method (converges in 2–3 iterations for Earth).
///
/// # Arguments
/// * `r` — geocentric radius in km
/// * `theta` — colatitude in radians (0 = north pole, π/2 = equator)
///
/// # Returns
/// `(lat_geodetic_rad, height_km)` — geodetic latitude (radians) and height
/// above the WGS-84 ellipsoid in km.
pub fn geocentric_to_geodetic(r: f64, theta: f64) -> (f64, f64) {
    let lat_geocentric = PI / 2.0 - theta;
    let cos_gc = lat_geocentric.cos();
    let sin_gc = lat_geocentric.sin();

    // Cartesian in the meridional plane
    let rho = r * cos_gc; // distance from polar axis
    let z = r * sin_gc; // distance from equatorial plane

    // Bowring's iterative method
    let mut lat = lat_geocentric; // initial guess
    for _ in 0..5 {
        let sin_lat = lat.sin();
        let cos_lat = lat.cos();
        let n = WGS84_A / (1.0 - WGS84_E2 * sin_lat * sin_lat).sqrt();
        lat = (z + WGS84_E2 * n * sin_lat).atan2(rho);
        let _ = (n, cos_lat); // suppress unused warnings
    }

    let sin_lat = lat.sin();
    let cos_lat = lat.cos();
    let n = WGS84_A / (1.0 - WGS84_E2 * sin_lat * sin_lat).sqrt();

    let height = if cos_lat.abs() > 1.0e-10 {
        rho / cos_lat - n
    } else {
        z.abs() - n * (1.0 - WGS84_E2)
    };

    (lat, height)
}

/// Convert geodetic `(latitude, height)` to geocentric spherical `(r, θ_colatitude)`.
///
/// # Arguments
/// * `lat_rad` — geodetic latitude in radians
/// * `height_km` — height above WGS-84 ellipsoid in km
///
/// # Returns
/// `(r, theta)` — geocentric radius (km) and colatitude (radians).
pub fn geodetic_to_geocentric(lat_rad: f64, height_km: f64) -> (f64, f64) {
    let sin_lat = lat_rad.sin();
    let cos_lat = lat_rad.cos();
    let n = WGS84_A / (1.0 - WGS84_E2 * sin_lat * sin_lat).sqrt();

    let rho = (n + height_km) * cos_lat;
    let z = (n * (1.0 - WGS84_E2) + height_km) * sin_lat;

    let r = (rho * rho + z * z).sqrt();
    let theta = PI / 2.0 - z.atan2(rho);

    (r, theta)
}

/// Compute geodetic altitude above the WGS-84 ellipsoid.
///
/// This is a convenience wrapper around [`geocentric_to_geodetic`] that
/// returns only the altitude component.
pub fn geodetic_altitude(r: f64, theta: f64) -> f64 {
    let (_lat, h) = geocentric_to_geodetic(r, theta);
    h
}

/// Local ellipsoid surface radius at a given colatitude.
///
/// Returns the geocentric distance from Earth's center to the WGS-84
/// surface at colatitude `theta`.
pub fn ellipsoid_surface_radius(theta: f64) -> f64 {
    let lat = PI / 2.0 - theta;
    let sin_lat = lat.sin();
    let cos_lat = lat.cos();
    let a2 = WGS84_A * WGS84_A;
    let b2 = WGS84_B * WGS84_B;
    ((a2 * cos_lat).powi(2) + (b2 * sin_lat).powi(2)).sqrt()
        / (a2 * cos_lat * cos_lat + b2 * sin_lat * sin_lat).sqrt()
}

/// Geodesic (surface) distance between two points on the WGS-84 ellipsoid.
///
/// Implements Vincenty's inverse formula. Falls back to a spherical
/// approximation for near-antipodal points where Vincenty may not converge.
///
/// # Arguments
/// * `lat1`, `lon1` — first point in **radians** (geodetic)
/// * `lat2`, `lon2` — second point in **radians** (geodetic)
///
/// # Returns
/// Distance in km along the WGS-84 surface.
pub fn vincenty_distance(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    let u1 = ((1.0 - WGS84_F) * lat1.tan()).atan();
    let u2 = ((1.0 - WGS84_F) * lat2.tan()).atan();
    let sin_u1 = u1.sin();
    let cos_u1 = u1.cos();
    let sin_u2 = u2.sin();
    let cos_u2 = u2.cos();

    let mut lambda = lon2 - lon1;
    let mut prev_lambda;

    let (mut sin_sigma, mut cos_sigma, mut sigma);
    let (mut sin_alpha, mut cos2_alpha, mut cos_2sigma_m);

    for _ in 0..200 {
        let sin_lam = lambda.sin();
        let cos_lam = lambda.cos();

        let t1 = cos_u2 * sin_lam;
        let t2 = cos_u1 * sin_u2 - sin_u1 * cos_u2 * cos_lam;
        sin_sigma = (t1 * t1 + t2 * t2).sqrt();
        cos_sigma = sin_u1 * sin_u2 + cos_u1 * cos_u2 * cos_lam;
        sigma = sin_sigma.atan2(cos_sigma);

        sin_alpha = if sin_sigma.abs() > 1e-15 {
            cos_u1 * cos_u2 * sin_lam / sin_sigma
        } else {
            0.0
        };
        cos2_alpha = 1.0 - sin_alpha * sin_alpha;

        cos_2sigma_m = if cos2_alpha.abs() > 1e-15 {
            cos_sigma - 2.0 * sin_u1 * sin_u2 / cos2_alpha
        } else {
            0.0
        };

        let c = WGS84_F / 16.0 * cos2_alpha * (4.0 + WGS84_F * (4.0 - 3.0 * cos2_alpha));

        prev_lambda = lambda;
        lambda = (lon2 - lon1)
            + (1.0 - c)
                * WGS84_F
                * sin_alpha
                * (sigma
                    + c * sin_sigma
                        * (cos_2sigma_m
                            + c * cos_sigma * (-1.0 + 2.0 * cos_2sigma_m * cos_2sigma_m)));

        if (lambda - prev_lambda).abs() < 1e-12 {
            // Converged — compute distance
            let u_sq = cos2_alpha * WGS84_EP2;
            let a_v =
                1.0 + u_sq / 16384.0 * (4096.0 + u_sq * (-768.0 + u_sq * (320.0 - 175.0 * u_sq)));
            let b_v = u_sq / 1024.0 * (256.0 + u_sq * (-128.0 + u_sq * (74.0 - 47.0 * u_sq)));
            let delta_sigma = b_v
                * sin_sigma
                * (cos_2sigma_m
                    + b_v / 4.0
                        * (cos_sigma * (-1.0 + 2.0 * cos_2sigma_m * cos_2sigma_m)
                            - b_v / 6.0
                                * cos_2sigma_m
                                * (-3.0 + 4.0 * sin_sigma * sin_sigma)
                                * (-3.0 + 4.0 * cos_2sigma_m * cos_2sigma_m)));

            return WGS84_B * a_v * (sigma - delta_sigma);
        }
    }

    // Fallback: spherical approximation for near-antipodal points
    let d_lat = lat2 - lat1;
    let d_lon = lon2 - lon1;
    let a_h = (d_lat / 2.0).sin().powi(2) + lat1.cos() * lat2.cos() * (d_lon / 2.0).sin().powi(2);
    2.0 * WGS84_A * a_h.sqrt().asin()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EPS_KM: f64 = 0.01; // 10 m tolerance
    const EPS_RAD: f64 = 1.0e-8; // ~0.06 mm

    #[test]
    fn test_geodetic_altitude_at_equator() {
        // On the equatorial surface: r = WGS84_A, theta = π/2
        let (lat, h) = geocentric_to_geodetic(WGS84_A, PI / 2.0);
        assert!(
            h.abs() < EPS_KM,
            "Height at equatorial surface should be ~0, got {h}"
        );
        assert!(
            lat.abs() < EPS_RAD,
            "Latitude at equator should be ~0, got {lat}"
        );
    }

    #[test]
    fn test_geodetic_altitude_at_pole() {
        // On the polar surface: geodetic lat = 90°, height = 0
        let (r_pole, theta_pole) = geodetic_to_geocentric(PI / 2.0, 0.0);
        let (lat, h) = geocentric_to_geodetic(r_pole, theta_pole);
        assert!(
            h.abs() < EPS_KM,
            "Height at polar surface should be ~0, got {h}"
        );
        assert!(
            (lat - PI / 2.0).abs() < EPS_RAD,
            "Latitude at north pole should be π/2, got {lat}"
        );
    }

    #[test]
    fn test_ellipsoid_surface_radius_equator_vs_pole() {
        let r_eq = ellipsoid_surface_radius(PI / 2.0); // equator
        let r_pole = ellipsoid_surface_radius(0.0); // north pole
        assert!(
            (r_eq - WGS84_A).abs() < EPS_KM,
            "Equatorial surface radius should be ~WGS84_A, got {r_eq}"
        );
        assert!(
            (r_pole - WGS84_B).abs() < EPS_KM,
            "Polar surface radius should be ~WGS84_B, got {r_pole}"
        );
        assert!(
            r_eq > r_pole,
            "Equatorial radius should exceed polar radius"
        );
    }

    #[test]
    fn test_geocentric_geodetic_roundtrip() {
        // 45° lat, 300 km altitude
        let lat0 = 45.0_f64.to_radians();
        let h0 = 300.0;
        let (r, theta) = geodetic_to_geocentric(lat0, h0);
        let (lat_back, h_back) = geocentric_to_geodetic(r, theta);
        assert!(
            (lat_back - lat0).abs() < EPS_RAD,
            "Latitude roundtrip failed: {lat0} → {lat_back}"
        );
        assert!(
            (h_back - h0).abs() < EPS_KM,
            "Height roundtrip failed: {h0} → {h_back}"
        );
    }

    #[test]
    fn test_geodetic_altitude_above_sphere() {
        // A point at geocentric r = WGS84_A + 300 km above equator
        let h = geodetic_altitude(WGS84_A + 300.0, PI / 2.0);
        assert!(
            (h - 300.0).abs() < 0.1,
            "Geodetic altitude at equator should be ~300 km, got {h}"
        );
    }

    #[test]
    fn test_vincenty_known_distance() {
        // New York (40.7128°N, 74.0060°W) to London (51.5074°N, 0.1278°W)
        let lat1 = 40.7128_f64.to_radians();
        let lon1 = -74.0060_f64.to_radians();
        let lat2 = 51.5074_f64.to_radians();
        let lon2 = -0.1278_f64.to_radians();
        let d = vincenty_distance(lat1, lon1, lat2, lon2);
        // Known geodesic distance ≈ 5570 km
        assert!(
            (d - 5570.0).abs() < 20.0,
            "NYC-London distance should be ~5570 km, got {d}"
        );
    }

    #[test]
    fn test_vincenty_same_point() {
        let lat = 30.0_f64.to_radians();
        let lon = 50.0_f64.to_radians();
        let d = vincenty_distance(lat, lon, lat, lon);
        assert!(
            d.abs() < EPS_KM,
            "Distance to same point should be ~0, got {d}"
        );
    }

    #[test]
    fn test_wgs84_vs_sphere_altitude_difference() {
        // At the pole, geocentric radius for a 300 km geodetic altitude point
        let (r_wgs, _theta) = geodetic_to_geocentric(PI / 2.0, 300.0); // polar, 300 km
        let h_sphere = r_wgs - 6370.0; // using the old spherical Earth radius
        let h_geodetic = 300.0;
        // The difference should be ~13 km (WGS84_B ≈ 6356.7 vs 6370.0)
        let diff = (h_sphere - h_geodetic).abs();
        assert!(
            diff > 5.0,
            "WGS-84 vs sphere altitude difference should be significant, got {diff} km"
        );
    }
}
