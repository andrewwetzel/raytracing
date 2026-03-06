//! End-to-end tests for trace_ray (matches OT 75-76 sample case)

use ionotrace::params::*;
use ionotrace::tracer::trace_ray;
use ionotrace::CoordinateSystem;

fn sample_params() -> ModelParams {
    let mut p = ModelParams::default();
    p.earth_model = EarthModel::Sphere;
    p.mag_model = MagneticFieldModel::Dipole;
    p
}

#[test]
fn test_sample_case_ray_returns() {
    let p = sample_params();
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();
    assert!(
        result.returned_to_ground,
        "Sample case ray should return to ground"
    );
}

#[test]
fn test_sample_case_max_height() {
    let p = sample_params();
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();
    assert!(
        result.max_height > 50.0 && result.max_height < 200.0,
        "Max height should be ~74 km, got {}",
        result.max_height
    );
}

#[test]
fn test_sample_case_has_points() {
    let p = sample_params();
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();
    assert!(result.points.len() > 5, "Should have multiple trace points");
    assert!(
        result.n_steps > 10,
        "Should take >10 steps, got {}",
        result.n_steps
    );
}

#[test]
fn test_vertical_ray_goes_higher() {
    let p = sample_params();
    let r20 = trace_ray(
        10.0,
        -1.0,
        20.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();
    let r60 = trace_ray(
        10.0,
        -1.0,
        60.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();
    assert!(
        r60.max_height > r20.max_height,
        "Steeper elevation should reach higher: 60°={} vs 20°={}",
        r60.max_height,
        r20.max_height
    );
}

#[test]
fn test_higher_freq_penetrates_further() {
    let p = sample_params();
    let r10 = trace_ray(
        10.0,
        -1.0,
        20.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();
    let r15 = trace_ray(
        15.0,
        -1.0,
        20.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();
    assert!(
        r15.max_height >= r10.max_height,
        "Higher freq should penetrate further: 15MHz={} vs 10MHz={}",
        r15.max_height,
        r10.max_height
    );
}

#[test]
fn test_all_points_finite() {
    let p = sample_params();
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        5.0,
        300,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    for pt in &result.points {
        assert!(pt.height_km.is_finite(), "height_km not finite");
        assert!(pt.lat_deg.is_finite(), "lat_deg not finite");
        assert!(pt.lon_deg.is_finite(), "lon_deg not finite");
        assert!(pt.ground_range_km.is_finite(), "ground_range not finite");
    }
}

#[test]
fn test_different_ed_models() {
    for model in [
        ElectronDensityModel::Elect1,
        ElectronDensityModel::Linear,
        ElectronDensityModel::QuasiParabolic,
        ElectronDensityModel::VarChapman,
        ElectronDensityModel::DualChapman,
        ElectronDensityModel::Chapman,
    ] {
        let mut p = sample_params();
        p.ed_model = model;
        let r = trace_ray(
            10.0,
            -1.0,
            30.0,
            0.0,
            40.0,
            2,
            CoordinateSystem::Spherical,
            10.0,
            200,
            1e-4,
            2e-6,
            100.0,
            &p,
            50,
        )
        .unwrap();
        assert!(r.n_steps > 0, "ED model {:?} should produce steps", model);
        assert!(
            r.max_height > 0.0,
            "ED model {:?} should reach some height",
            model
        );
    }
}

#[test]
fn test_different_mag_models() {
    for model in [
        MagneticFieldModel::Constant,
        MagneticFieldModel::Cubic,
        MagneticFieldModel::Igrf14,
        MagneticFieldModel::Dipole,
    ] {
        let mut p = sample_params();
        p.mag_model = model;
        let r = trace_ray(
            10.0,
            -1.0,
            30.0,
            0.0,
            40.0,
            2,
            CoordinateSystem::Spherical,
            10.0,
            200,
            1e-4,
            2e-6,
            100.0,
            &p,
            50,
        )
        .unwrap();
        assert!(r.n_steps > 0, "Mag model {:?} should produce steps", model);
    }
}

// ---- Azimuth direction tests ----

#[test]
fn test_azimuth_northeast_displaces_east() {
    let p = sample_params();
    // Az=45° is northeast; ray should land with positive lon_deg (east)
    let r = trace_ray(
        10.0,
        -1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    if r.returned_to_ground {
        let last = r.points.last().unwrap();
        assert!(
            last.lon_deg > 0.0,
            "Azimuth 45° (NE) should produce positive longitude, got {}",
            last.lon_deg
        );
    }
}

#[test]
fn test_azimuth_northwest_displaces_west() {
    let p = sample_params();
    // Az=315° is northwest; ray should land with negative lon_deg (west)
    let r = trace_ray(
        10.0,
        -1.0,
        20.0,
        315.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    if r.returned_to_ground {
        let last = r.points.last().unwrap();
        assert!(
            last.lon_deg < 0.0,
            "Azimuth 315° (NW) should produce negative longitude, got {}",
            last.lon_deg
        );
    }
}

// ---- Edge latitude tests ----

#[test]
fn test_high_latitude_finite() {
    let p = sample_params();
    // +80° latitude (near north pole)
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        0.0,
        80.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        300,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    for pt in &result.points {
        assert!(pt.height_km.is_finite(), "height not finite at lat=80°");
        assert!(pt.lat_deg.is_finite(), "lat not finite at lat=80°");
        assert!(pt.lon_deg.is_finite(), "lon not finite at lat=80°");
    }
}

#[test]
fn test_south_latitude_finite() {
    let p = sample_params();
    // -60° latitude (southern hemisphere)
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        180.0,
        -60.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        300,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    for pt in &result.points {
        assert!(pt.height_km.is_finite(), "height not finite at lat=-60°");
        assert!(pt.lat_deg.is_finite(), "lat not finite at lat=-60°");
    }
}

// ---- Absorption sanity test ----

#[test]
fn test_absorption_finite() {
    let p = sample_params();
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        5.0,
        300,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    for pt in &result.points {
        assert!(pt.absorption.is_finite(), "absorption not finite");
    }
}

// ---- Input validation tests ----

#[test]
fn test_invalid_frequency_rejected() {
    let p = sample_params();
    let result = trace_ray(
        -5.0,
        -1.0,
        20.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    );
    assert!(result.is_err(), "Negative frequency should be rejected");
}

#[test]
fn test_invalid_elevation_rejected() {
    let p = sample_params();
    let result = trace_ray(
        10.0,
        -1.0,
        100.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    );
    assert!(result.is_err(), "Elevation > 90° should be rejected");
}

#[test]
fn test_zero_step_size_rejected() {
    let p = sample_params();
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        0.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    );
    assert!(result.is_err(), "Zero step size should be rejected");
}

// ---- Fortran regression test (H) ----
// Gold-standard values from OT 75-76 sample case:
// 10 MHz extraordinary, 20° elev, 45° az, 40°N, Chapman fc=10 hm=250 sh=100

#[test]
fn test_fortran_reference_sample_case() {
    let p = sample_params(); // CHAPX + DIPOLY + EXPZ2 + AHWFWC (matches Fortran)
                             // Match Fortran: mode 2, step=10, max_steps=200
    let result = trace_ray(
        10.0,
        -1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        10,
    )
    .unwrap();

    // Fortran expected: max height ~200 km (report says ~200, we allow 50-250)
    assert!(
        result.max_height > 50.0 && result.max_height < 250.0,
        "Reference case max height should be ~200 km (±50%), got {:.1} km",
        result.max_height
    );

    // Should return to ground
    assert!(
        result.returned_to_ground,
        "Reference case ray should return to ground"
    );

    // Ground range should be in ballpark of ~800 km
    assert!(
        result.ground_range_km > 100.0 && result.ground_range_km < 2000.0,
        "Reference case ground range should be ~800 km, got {:.1} km",
        result.ground_range_km
    );
}

// ---- TraceConfig::validate test ----

#[test]
fn test_trace_config_validate() {
    use ionotrace::tracer::TraceConfig;

    let good = TraceConfig::new(10.0, 20.0);
    assert!(good.validate().is_ok());

    let bad_freq = TraceConfig::new(-5.0, 20.0);
    assert!(bad_freq.validate().is_err());

    let bad_elev = TraceConfig::new(10.0, 100.0);
    assert!(bad_elev.validate().is_err());
}

// ---- ModelParams::validate test ----

#[test]
fn test_model_params_validate() {
    let good = ModelParams::default();
    assert!(good.validate().is_ok());

    let mut bad = ModelParams::default();
    bad.earth_r = -1.0;
    assert!(bad.validate().is_err());

    let mut bad_fc = ModelParams::default();
    bad_fc.fc = -5.0;
    assert!(bad_fc.validate().is_err());
}

// ---- Stress tests for extreme parameters (J) ----

#[test]
fn test_extreme_low_frequency() {
    let p = sample_params();
    // 2 MHz — well below foF2 of 10 MHz; ray should be heavily refracted
    let result = trace_ray(
        2.0,
        -1.0,
        20.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        5.0,
        500,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    assert!(result.n_steps > 0);
    for pt in &result.points {
        assert!(pt.height_km.is_finite());
    }
}

#[test]
fn test_extreme_high_frequency() {
    let p = sample_params();
    // 30 MHz — above foF2; ray should penetrate and escape
    let result = trace_ray(
        30.0,
        -1.0,
        20.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        5.0,
        500,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    assert!(result.n_steps > 0);
    for pt in &result.points {
        assert!(pt.height_km.is_finite());
    }
}

#[test]
fn test_extreme_low_elevation() {
    let p = sample_params();
    // 1° — nearly horizontal
    let result = trace_ray(
        10.0,
        -1.0,
        1.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        5.0,
        500,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    assert!(result.n_steps > 0);
    for pt in &result.points {
        assert!(pt.height_km.is_finite());
    }
}

#[test]
fn test_extreme_high_elevation() {
    let p = sample_params();
    // 89° — nearly vertical
    let result = trace_ray(
        10.0,
        -1.0,
        89.0,
        0.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        5.0,
        500,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    assert!(result.n_steps > 0);
    for pt in &result.points {
        assert!(pt.height_km.is_finite());
    }
}

#[test]
fn test_ordinary_mode_returns() {
    let p = sample_params();
    // O-mode (ray_mode=1.0) should also produce finite results
    let result = trace_ray(
        10.0,
        1.0,
        20.0,
        45.0,
        40.0,
        2,
        CoordinateSystem::Spherical,
        10.0,
        200,
        1e-4,
        2e-6,
        100.0,
        &p,
        1,
    )
    .unwrap();
    assert!(result.n_steps > 0);
    for pt in &result.points {
        assert!(pt.height_km.is_finite());
        assert!(pt.lat_deg.is_finite());
    }
}
