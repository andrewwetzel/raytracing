//! Tests for refractive index models (Appleton-Hartree variants)

use raytrace_core::params::*;
use raytrace_core::models::refractive_index::*;

fn default_params() -> ModelParams {
    ModelParams::default()
}

fn sample_k() -> (f64, f64, f64) {
    // Sample k-vector for 20° elevation, 45° azimuth
    let elev = 20.0_f64.to_radians();
    let az = 45.0_f64.to_radians();
    let kr = elev.sin();
    let kth = elev.cos() * (std::f64::consts::PI - az).cos();
    let kph = elev.cos() * (std::f64::consts::PI - az).sin();
    (kr, kth, kph)
}

// ---- AHWFWC (default): With Field, With Collisions ----

#[test]
fn test_ahwfwc_in_free_space() {
    let p = default_params();
    let (kr, kth, kph) = sample_k();
    // At ground level, far from ionosphere: ed ≈ 0
    let ri = compute_rindex(EARTH_RADIUS, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, true);
    // n² should be very close to 1.0 in free space
    assert!((ri.n2_re - 1.0).abs() < 0.01, "n² in free space should be ~1.0, got {}", ri.n2_re);
}

#[test]
fn test_ahwfwc_in_ionosphere() {
    let p = default_params();
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 250.0; // at peak density
    let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
    // At peak where x ≈ 1.0, n² should be significantly < 1
    assert!(ri.n2_re < 1.0, "n² in ionosphere should be < 1.0, got {}", ri.n2_re);
}

#[test]
fn test_ahwfwc_hamiltonian_derivatives() {
    let p = default_params();
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 200.0;
    let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
    // All Hamiltonian derivatives should be finite
    assert!(ri.dhdr_re.is_finite(), "dhdr should be finite");
    assert!(ri.dhdth_re.is_finite(), "dhdth should be finite");
    assert!(ri.dhdph_re.is_finite(), "dhdph should be finite");
    assert!(ri.dhdom_re.is_finite() && ri.dhdom_re != 0.0, "dhdom should be finite and non-zero");
    assert!(ri.dhdkr_re.is_finite(), "dhdkr should be finite");
}

// ---- AHNFNC: No Field, No Collisions ----

#[test]
fn test_ahnfnc_simple_dispersion() {
    let mut p = default_params();
    p.rindex_model = 1;
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 250.0;
    let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
    // n² = 1 - X, should be purely real
    assert_eq!(ri.n2_im, 0.0, "AHNFNC should have no imaginary part");
    assert!(ri.n2_re < 1.0, "n² should be < 1 in ionosphere");
}

#[test]
fn test_ahnfnc_no_absorption() {
    let mut p = default_params();
    p.rindex_model = 1;
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 200.0;
    let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
    assert_eq!(ri.kphpk_im, 0.0, "AHNFNC should have no absorption");
}

// ---- AHNFWC: No Field, With Collisions ----

#[test]
fn test_ahnfwc_has_absorption() {
    let mut p = default_params();
    p.rindex_model = 2;
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 100.0; // low altitude where collisions matter
    let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
    // With collisions but no field: n²  has imaginary part
    assert!(ri.n2_im.abs() > 0.0, "AHNFWC should have imaginary n² from collisions");
}

// ---- AHWFNC: With Field, No Collisions ----

#[test]
fn test_ahwfnc_no_absorption() {
    let mut p = default_params();
    p.rindex_model = 3;
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 200.0;
    let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
    assert_eq!(ri.n2_im, 0.0, "AHWFNC should have no imaginary part (no collisions)");
}

// ---- Ray mode (ordinary vs extraordinary) ----

#[test]
fn test_ray_mode_difference() {
    let p = default_params(); // rindex_model=0 (AHWFWC)
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 250.0;
    let ri_ord = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, 1.0, &p, false);
    let ri_ext = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
    // Ordinary and extraordinary modes should give different n²
    assert!((ri_ord.n2_re - ri_ext.n2_re).abs() > 1e-6,
        "O-mode and X-mode should differ: o={}, x={}", ri_ord.n2_re, ri_ext.n2_re);
}

// ---- k-vector rescaling on first call ----

#[test]
fn test_k_rescaling() {
    let p = default_params();
    let (kr, kth, kph) = sample_k();
    let r = EARTH_RADIUS + 250.0; // in the ionosphere where n² < 1
    let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, true);
    // On first call (rstart=true) in the ionosphere, k should be rescaled
    // The new k magnitude should differ from old since n² ≠ 1
    let new_k2 = ri.new_kr * ri.new_kr + ri.new_kth * ri.new_kth + ri.new_kph * ri.new_kph;
    let old_k2 = kr * kr + kth * kth + kph * kph;
    assert!(new_k2.is_finite(), "Rescaled k² should be finite");
    assert!((new_k2 - old_k2).abs() > 1e-10,
        "k should be rescaled when rstart=true in ionosphere: old_k²={}, new_k²={}", old_k2, new_k2);
}

// ---- All models produce finite values ----

#[test]
fn test_all_rindex_models_finite() {
    let (kr, kth, kph) = sample_k();
    for model in 0..=3u8 {
        let mut p = default_params();
        p.rindex_model = model;
        let r = EARTH_RADIUS + 200.0;
        let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
        assert!(ri.n2_re.is_finite(), "Rindex model {} n2_re not finite", model);
        assert!(ri.h_re.is_finite(), "Rindex model {} h_re not finite", model);
        assert!(ri.dhdom_re.is_finite(), "Rindex model {} dhdom_re not finite", model);
    }
}
