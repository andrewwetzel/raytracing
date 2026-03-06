use ionotrace::params::*;
use ionotrace::target::{solve_target, SearchSpec, TargetConfig};
use ionotrace::tracer::TraceConfig;

/// Deterministic test params — isolated from default model changes.
fn test_params() -> ModelParams {
    let mut p = ModelParams::default();
    p.earth_model = EarthModel::Sphere;
    p.mag_model = MagneticFieldModel::Dipole;
    p
}

/// Helper: trace a ray and return its landing coordinates so we can use them as a known target.
fn known_landing(freq: f64, elev: f64, az: f64, tx_lat: f64) -> (f64, f64, f64) {
    let mut cfg = TraceConfig::new(freq, elev);
    cfg.azimuth_deg = az;
    cfg.tx_lat_deg = tx_lat;
    cfg.print_every = 1;
    cfg.params = test_params();
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
        params: test_params(),
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
        params: test_params(),
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
        params: test_params(),
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
        params: test_params(),
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
        params: test_params(),
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
        params: test_params(),
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
        let mut params = test_params();
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

#[test]
fn test_target_escape_boundary_long_range() {
    // Long-range target that requires near-escape-boundary elevation angles.
    // Previously the solver would find zero brackets because rays transition
    // from "returned but too short" directly to "escaped" without a sign change.
    let config = TargetConfig {
        target_lat_deg: 40.0, // roughly Spain latitude
        target_lon_deg: 50.0, // ~50° east of TX → very long range
        tx_lat_deg: 34.0,     // SC latitude
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 100.0, // generous tolerance for this geometry
        coarse_step: 2.0,
        elev_min: 1.0,
        elev_max: 60.0,
        max_bisect_iters: 30,
        max_hops: 1,
        step_size: 5.0,
        max_steps: 1000,
        params: test_params(),
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    // The key assertion: the solver should explore escape-boundary brackets
    // even if no classic sign-change brackets exist.
    println!(
        "Escape-boundary test: {} solutions, {} rays traced, best_err={:.1} km",
        result.solutions.len(),
        result.rays_traced,
        result
            .best
            .as_ref()
            .map(|s| s.error_km)
            .unwrap_or(f64::INFINITY),
    );
    // We mainly verify this doesn't panic and does trace rays through escape brackets.
    // Whether a solution is found depends on ionospheric physics — the important thing
    // is that the solver TRIES the escape boundary rather than giving up with 0 brackets.
    assert!(
        result.rays_traced > 40,
        "Solver should trace extra rays for escape-boundary brackets, got only {}",
        result.rays_traced
    );
}

#[test]
fn test_target_multi_hop_long_distance() {
    // Multi-hop test: a target at ~3000 km requires at least 2 hops.
    // First, find a known landing at modest elevation to determine single-hop range,
    // then set a target beyond that range and verify multi-hop can reach it.
    let (lat1, lon1, range1) = known_landing(10.0, 15.0, 0.0, 40.0);
    println!(
        "Single-hop at 15°: landing ({:.2}, {:.2}), range {:.0} km",
        lat1, lon1, range1
    );

    // Target at roughly 2x single-hop range — requires 2+ hops
    let target_range = range1 * 2.0;
    let target_lat = 40.0 + (target_range / 111.0); // approx latitude offset

    let config = TargetConfig {
        target_lat_deg: target_lat,
        target_lon_deg: 0.0,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 50.0,
        coarse_step: 2.0,
        elev_min: 3.0,
        elev_max: 60.0,
        max_bisect_iters: 30,
        max_hops: 3,
        step_size: 5.0,
        max_steps: 1000,
        params: test_params(),
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    println!(
        "Multi-hop test: target_lat={:.1}, {} solutions, {} rays, best_err={:.1} km",
        target_lat,
        result.solutions.len(),
        result.rays_traced,
        result
            .best
            .as_ref()
            .map(|s| s.error_km)
            .unwrap_or(f64::INFINITY),
    );

    if let Some(best) = &result.best {
        println!(
            "  Best: elev={:.2}°, hops={}, range={:.0} km",
            best.elevation_deg, best.hops, best.range_km
        );
        assert!(
            best.hops >= 2,
            "Solution for 2x single-hop range should use multiple hops, got {} hops",
            best.hops
        );
    }
    // The solver should at least explore brackets for the multi-hop case
    assert!(
        result.rays_traced > 30,
        "Solver should trace rays for multi-hop search, got only {}",
        result.rays_traced
    );
}

// ---- Multi-hop longitude accumulation test (I) ----

#[test]
fn test_multi_hop_longitude_accumulates() {
    // With az=45° and multi-hop, longitude should accumulate across hops.
    // This specifically verifies the longitude fix (lon_offset) in fire_ray.
    let (lat, lon, _) = known_landing(10.0, 20.0, 45.0, 40.0);

    let config = TargetConfig {
        target_lat_deg: lat,
        target_lon_deg: lon,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(45.0),
        error_limit_km: 50.0,
        max_hops: 2,
        include_ray_path: true,
        params: test_params(),
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    if let Some(best) = &result.best {
        // With azimuth=45° the landing longitude should be non-zero
        assert!(
            best.landing_lon_deg.abs() > 0.01,
            "Multi-hop az=45° should produce non-zero longitude, got {:.4}°",
            best.landing_lon_deg
        );
    }
}

// ---- Solver status diagnostic test (G) ----

#[test]
fn test_solver_status_ok_for_reachable_target() {
    let (lat, lon, _) = known_landing(10.0, 20.0, 0.0, 40.0);

    let config = TargetConfig {
        target_lat_deg: lat,
        target_lon_deg: lon,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 15.0,
        params: test_params(),
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    assert_eq!(
        result.status, "ok",
        "Reachable target should have status 'ok'"
    );
}

#[test]
fn test_solver_status_for_unreachable_target() {
    let config = TargetConfig {
        target_lat_deg: -40.0,
        target_lon_deg: 180.0,
        tx_lat_deg: 40.0,
        freq_mhz: SearchSpec::Fixed(10.0),
        azimuth_deg: SearchSpec::Fixed(0.0),
        error_limit_km: 5.0,
        params: test_params(),
        ..TargetConfig::default()
    };

    let result = solve_target(&config).unwrap();
    assert_ne!(
        result.status, "ok",
        "Unreachable target should not have status 'ok'"
    );
}

// ---- Input validation test ----

#[test]
fn test_solve_target_rejects_invalid_config() {
    let config = TargetConfig {
        elev_min: 60.0,
        elev_max: 10.0, // min > max!
        params: test_params(),
        ..TargetConfig::default()
    };

    let result = solve_target(&config);
    assert!(result.is_err(), "elev_min > elev_max should be rejected");
}
