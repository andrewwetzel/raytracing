//! Integration tests for the target location solver.

use ionotrace::params::*;
use ionotrace::target::{solve_target, SearchSpec, TargetConfig};
use ionotrace::tracer::TraceConfig;

/// Helper: trace a ray and return its landing coordinates so we can use them as a known target.
fn known_landing(freq: f64, elev: f64, az: f64, tx_lat: f64) -> (f64, f64, f64) {
    let mut cfg = TraceConfig::new(freq, elev);
    cfg.azimuth_deg = az;
    cfg.tx_lat_deg = tx_lat;
    cfg.print_every = 1;
    let r = cfg.trace().unwrap();
    assert!(r.returned_to_ground, "Setup ray must return to ground");
    let last = r.points.last().unwrap();
    (last.lat_deg, last.lon_deg, r.ground_range_km)
}

#[test]
fn test_target_basic_convergence() {
    // Trace a known ray and use its landing point as the target
    let (lat, lon, _range) = known_landing(10.0, 20.0, 0.0, 40.0);

    let config = TargetConfig {
        target_lat_deg: lat,
        target_lon_deg: lon,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 10.0,
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    assert!(
        result.best.is_some(),
        "Solver should find at least one solution"
    );
    let best = result.best.unwrap();
    assert!(
        best.error_km <= 10.0,
        "Best error should be within limit, got {:.2} km",
        best.error_km
    );
    println!(
        "Found: elev={:.2}°, az={:.2}°, error={:.2} km, rays={}",
        best.elevation_deg, best.azimuth_deg, best.error_km, result.rays_traced
    );
}

#[test]
fn test_target_error_within_limit() {
    let (lat, lon, _) = known_landing(10.0, 30.0, 0.0, 40.0);

    let config = TargetConfig {
        target_lat_deg: lat,
        target_lon_deg: lon,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 15.0,
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    for sol in &result.solutions {
        assert!(
            sol.error_km <= config.error_limit_km,
            "All solutions must be within limit: got {:.2} km",
            sol.error_km
        );
    }
}

#[test]
fn test_target_tight_tolerance() {
    let (lat, lon, _) = known_landing(10.0, 25.0, 0.0, 40.0);

    let config = TargetConfig {
        target_lat_deg: lat,
        target_lon_deg: lon,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 2.0,
        coarse_step: 1.0,
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    assert!(
        result.best.is_some(),
        "Solver should converge with tight tolerance"
    );
    let best = result.best.unwrap();
    assert!(
        best.error_km <= 2.0,
        "Best error should be < 2 km, got {:.2} km",
        best.error_km
    );
}

#[test]
fn test_target_no_solution_unreachable() {
    // Target at the antipode — no single-hop ray can reach there
    let config = TargetConfig {
        target_lat_deg: -40.0,
        target_lon_deg: 180.0,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 5.0,
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    assert!(
        result.solutions.is_empty(),
        "Should find no solutions for antipodal target"
    );
}

#[test]
fn test_target_frequency_range() {
    let (lat, lon, _) = known_landing(10.0, 20.0, 0.0, 40.0);

    let config = TargetConfig {
        target_lat_deg: lat,
        target_lon_deg: lon,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Range {
            min: 8.0,
            max: 12.0,
            step: 2.0,
        },
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 15.0,
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    assert!(
        result.best.is_some(),
        "Should find solution when sweeping frequencies"
    );
}

#[test]
fn test_target_with_ray_path() {
    let (lat, lon, _) = known_landing(10.0, 20.0, 0.0, 40.0);

    let config = TargetConfig {
        target_lat_deg: lat,
        target_lon_deg: lon,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 15.0,
        include_ray_path: true,
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    let best = result.best.unwrap();
    assert!(
        best.ray_path.is_some(),
        "Ray path should be included when requested"
    );
    let path = best.ray_path.unwrap();
    assert!(
        path.len() > 5,
        "Ray path should have multiple points, got {}",
        path.len()
    );
}

#[test]
fn test_target_different_ed_models() {
    let (lat, lon, _) = known_landing(10.0, 20.0, 0.0, 40.0);

    for model in [
        ElectronDensityModel::Chapman,
        ElectronDensityModel::DualChapman,
    ] {
        let mut params = ModelParams::default();
        params.ed_model = model;

        let config = TargetConfig {
            target_lat_deg: lat,
            target_lon_deg: lon,
            tx_lat_deg: 40.0,
            freq_mhz: SearchSpec::Fixed(10.0),
            azimuth_deg: SearchSpec::Fixed(0.0),
            error_limit_km: 15.0,
            params,
            ..TargetConfig::default()
        };

        let result = solve_target(&config).unwrap();
        // Just verify it runs without panicking
        println!(
            "ED model {:?}: {} solutions, {} rays",
            model,
            result.solutions.len(),
            result.rays_traced
        );
    }
}
