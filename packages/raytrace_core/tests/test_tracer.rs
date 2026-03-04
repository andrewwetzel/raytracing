//! End-to-end tests for trace_ray (matches OT 75-76 sample case)

use ionotrace::params::*;
use ionotrace::tracer::trace_ray;

fn sample_params() -> ModelParams {
    ModelParams::default() // CHAPX + DIPOLY + EXPZ2 + AHWFWC
}

#[test]
fn test_sample_case_ray_returns() {
    let p = sample_params();
    let result = trace_ray(
        10.0, -1.0, 20.0, 45.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 10,
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
        10.0, -1.0, 20.0, 45.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 10,
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
        10.0, -1.0, 20.0, 45.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 10,
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
        10.0, -1.0, 20.0, 0.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 10,
    )
    .unwrap();
    let r60 = trace_ray(
        10.0, -1.0, 60.0, 0.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 10,
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
        10.0, -1.0, 20.0, 0.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 10,
    )
    .unwrap();
    let r15 = trace_ray(
        15.0, -1.0, 20.0, 0.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 10,
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
        10.0, -1.0, 20.0, 45.0, 40.0, 2, 5.0, 300, 1e-4, 2e-6, 100.0, &p, 1,
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
            10.0, -1.0, 30.0, 0.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 50,
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
            10.0, -1.0, 30.0, 0.0, 40.0, 2, 10.0, 200, 1e-4, 2e-6, 100.0, &p, 50,
        )
        .unwrap();
        assert!(r.n_steps > 0, "Mag model {:?} should produce steps", model);
    }
}
