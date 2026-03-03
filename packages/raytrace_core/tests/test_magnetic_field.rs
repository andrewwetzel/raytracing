//! Tests for magnetic field models

use raytrace_core::params::*;
use raytrace_core::models::magnetic_field::*;

const EPS: f64 = 1e-10;

fn default_params() -> ModelParams {
    ModelParams::default()
}

// ---- DIPOLY (default) ----

#[test]
fn test_dipoly_at_equator() {
    let p = default_params(); // fh=0.8, freq=10
    let r = EARTH_RADIUS + 250.0;
    let mag = compute_mag(r, PID2, 0.0, 10.0, &p);
    assert!(mag.y > 0.0, "DIPOLY |Y| should be positive");
    assert!(mag.yr.abs() < EPS, "DIPOLY yr at equator (cosθ=0) should be ~0");
    assert!(mag.yth > 0.0, "DIPOLY yθ at equator should be positive (sinθ=1)");
}

#[test]
fn test_dipoly_at_pole() {
    let p = default_params();
    let r = EARTH_RADIUS + 250.0;
    let mag = compute_mag(r, 0.01, 0.0, 10.0, &p); // near north pole (θ ≈ 0)
    assert!(mag.y > 0.0, "DIPOLY |Y| at pole should be positive");
    assert!(mag.yr.abs() > mag.yth.abs(), "DIPOLY yr should dominate at pole");
}

#[test]
fn test_dipoly_decreases_with_altitude() {
    let p = default_params();
    let mag_low = compute_mag(EARTH_RADIUS + 100.0, PID2, 0.0, 10.0, &p);
    let mag_high = compute_mag(EARTH_RADIUS + 500.0, PID2, 0.0, 10.0, &p);
    assert!(mag_low.y > mag_high.y, "Dipole field should decrease with altitude");
}

#[test]
fn test_dipoly_r_cubed_scaling() {
    let p = default_params();
    let r1 = EARTH_RADIUS + 200.0;
    let r2 = EARTH_RADIUS + 400.0;
    let mag1 = compute_mag(r1, PID2, 0.0, 10.0, &p);
    let mag2 = compute_mag(r2, PID2, 0.0, 10.0, &p);
    // At equator, y = fh * (Re/r)^3 / freq * sin(θ)
    // So y1/y2 = (r2/r1)^3
    let expected_ratio = (r2 / r1).powi(3);
    let actual_ratio = mag1.y / mag2.y;
    assert!((actual_ratio - expected_ratio).abs() / expected_ratio < 0.01,
        "Dipole should follow r^-3: expected ratio {}, got {}", expected_ratio, actual_ratio);
}

// ---- CONSTY ----

#[test]
fn test_consty_constant() {
    let mut p = default_params();
    p.mag_model = 1;
    let mag1 = compute_mag(EARTH_RADIUS + 100.0, PID2, 0.0, 10.0, &p);
    let mag2 = compute_mag(EARTH_RADIUS + 500.0, 1.0, 1.0, 10.0, &p);
    assert!((mag1.y - mag2.y).abs() < EPS, "CONSTY should be constant everywhere");
    assert_eq!(mag1.dydr, 0.0, "CONSTY dydr should be 0");
    assert_eq!(mag1.dydth, 0.0, "CONSTY dydth should be 0");
}

// ---- CUBEY ----

#[test]
fn test_cubey() {
    let mut p = default_params();
    p.mag_model = 2;
    p.dip = 0.5; // ~29° dip angle
    let mag = compute_mag(EARTH_RADIUS + 250.0, PID2, 0.0, 10.0, &p);
    assert!(mag.y > 0.0, "CUBEY should give positive |Y|");
    assert!(mag.yr.abs() > 0.0, "CUBEY with non-zero dip should have yr");
    assert!(mag.yth.abs() > 0.0, "CUBEY with non-zero dip should have yth");
}

// ---- HARMONY (IGRF-14) ----

#[test]
fn test_harmony_gives_reasonable_field() {
    let mut p = default_params();
    p.mag_model = 3;
    p.epoch_year = 2025.0;
    let r = EARTH_RADIUS + 200.0; // 200 km altitude
    let mag = compute_mag(r, PID2, 0.0, 10.0, &p);
    assert!(mag.y > 0.0, "HARMONY should give positive |Y|");
    assert!(mag.y.is_finite(), "HARMONY Y should be finite, got {}", mag.y);
    // Field should have non-zero derivatives at this altitude
    assert!(mag.dydr.is_finite(), "HARMONY dydr should be finite");
}

#[test]
fn test_harmony_epoch_interpolation() {
    let mut p = default_params();
    p.mag_model = 3;
    p.epoch_year = 2025.0;
    let mag_2025 = compute_mag(EARTH_RADIUS, PID2, 0.0, 10.0, &p);
    p.epoch_year = 2030.0;
    let mag_2030 = compute_mag(EARTH_RADIUS, PID2, 0.0, 10.0, &p);
    // Field should be slightly different at different epochs
    assert!((mag_2025.y - mag_2030.y).abs() > 1e-6,
        "HARMONY at different epochs should differ");
}

#[test]
fn test_harmony_phi_dependence() {
    let mut p = default_params();
    p.mag_model = 3;
    let mag_0 = compute_mag(EARTH_RADIUS + 200.0, 1.0, 0.0, 10.0, &p);
    let mag_pi = compute_mag(EARTH_RADIUS + 200.0, 1.0, std::f64::consts::PI, 10.0, &p);
    // IGRF has phi dependence (unlike dipole)
    assert!((mag_0.y - mag_pi.y).abs() > 1e-6,
        "HARMONY should have longitude dependence");
}

// ---- All models produce finite values ----

#[test]
fn test_all_mag_models_finite() {
    for model in 0..=3u8 {
        let mut p = default_params();
        p.mag_model = model;
        p.dip = 0.5;
        let mag = compute_mag(EARTH_RADIUS + 200.0, 1.0, 0.5, 10.0, &p);
        assert!(mag.y.is_finite(), "Mag model {} y not finite", model);
        assert!(mag.dydr.is_finite(), "Mag model {} dydr not finite", model);
        assert!(mag.yr.is_finite(), "Mag model {} yr not finite", model);
        assert!(mag.yth.is_finite(), "Mag model {} yth not finite", model);
    }
}
