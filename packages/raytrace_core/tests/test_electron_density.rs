//! Tests for electron density models and perturbations

use raytrace_core::params::*;
use raytrace_core::models::electron_density::*;

fn default_params() -> ModelParams {
    ModelParams::default()
}

// ---- CHAPX (default) ----

#[test]
fn test_chapx_at_peak() {
    let p = default_params(); // hm=250, fc=10, freq=10 → x = fc²/freq² * exp(0) = 1.0 at peak
    let r = EARTH_RADIUS + p.hm;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    // At peak height with alpha=0.5 and z=0: x = (fc/freq)^2 * exp(alpha*(exz-z))
    // z=0 → exz=0, so x = 1.0 * exp(0) = 1.0
    assert!((ed.x - 1.0).abs() < 0.01, "CHAPX x at peak should be ~1.0, got {}", ed.x);
}

#[test]
fn test_chapx_above_peak() {
    let p = default_params();
    let r = EARTH_RADIUS + p.hm + 100.0; // 100 km above peak
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed.x < 1.0, "CHAPX x above peak should be < 1.0");
    assert!(ed.x > 0.0, "CHAPX x above peak should be > 0.0");
    assert!(ed.dxdr < 0.0, "CHAPX dxdr above peak should be negative (decreasing)");
}

#[test]
fn test_chapx_below_peak() {
    let p = default_params();
    let r = EARTH_RADIUS + 100.0; // well below hm=250
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed.x > 0.0, "CHAPX x below peak should be > 0.0");
    assert!(ed.x < 1.0, "CHAPX x below peak should be < 1.0");
    assert!(ed.dxdr > 0.0, "CHAPX dxdr below peak should be positive (increasing)");
}

#[test]
fn test_chapx_frequency_scaling() {
    let p = default_params();
    let r = EARTH_RADIUS + p.hm;
    let ed_10 = compute_ed(r, PID2, 0.0, 10.0, &p); // freq = fc
    let ed_20 = compute_ed(r, PID2, 0.0, 20.0, &p); // freq = 2*fc
    // x scales as (fc/freq)^2, so at 20 MHz: x = (10/20)^2 * x_10 = 0.25 * x_10
    assert!((ed_20.x - ed_10.x * 0.25).abs() < 0.01, "Higher freq should reduce x by (fc/freq)²");
}

// ---- ELECT1 ----

#[test]
fn test_elect1() {
    let mut p = default_params();
    p.ed_model = 1;
    let r = EARTH_RADIUS + p.hm;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed.x > 0.0, "ELECT1 should give positive x at peak");
    assert_eq!(ed.dxdth, 0.0, "ELECT1 has no theta dependence");
}

// ---- LINEAR ----

#[test]
fn test_linear_below_peak() {
    let mut p = default_params();
    p.ed_model = 2;
    let r = EARTH_RADIUS + 100.0;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed.x > 0.0, "LINEAR below peak should be positive");
    assert!(ed.dxdr > 0.0, "LINEAR below peak should be increasing");
}

#[test]
fn test_linear_at_peak() {
    let mut p = default_params();
    p.ed_model = 2;
    let r = EARTH_RADIUS + p.hm;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    // At exactly hm: x = fc²/freq² * hm/hm = 1.0
    assert!((ed.x - 1.0).abs() < 0.01, "LINEAR at peak should be ~1.0");
}

#[test]
fn test_linear_above_topside() {
    let mut p = default_params();
    p.ed_model = 2;
    p.ym = 100.0;
    let r = EARTH_RADIUS + p.hm + p.ym; // above topside → 0
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert_eq!(ed.x, 0.0, "LINEAR above topside should be 0");
}

// ---- QPARAB ----

#[test]
fn test_qparab_at_peak() {
    let mut p = default_params();
    p.ed_model = 3;
    let r = EARTH_RADIUS + p.hm;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!((ed.x - 1.0).abs() < 0.01, "QPARAB at peak should be ~1.0");
}

#[test]
fn test_qparab_below_bottom() {
    let mut p = default_params();
    p.ed_model = 3;
    p.ym = 100.0;
    let rb = EARTH_RADIUS + p.hm - p.ym / 2.0;
    let r = rb - 10.0; // below bottom
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert_eq!(ed.x, 0.0, "QPARAB below bottom should be 0");
}

// ---- VCHAPX ----

#[test]
fn test_vchapx() {
    let mut p = default_params();
    p.ed_model = 4;
    let r = EARTH_RADIUS + p.hm;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed.x > 0.0, "VCHAPX at peak height should be positive");
}

#[test]
fn test_vchapx_at_ground() {
    let mut p = default_params();
    p.ed_model = 4;
    let r = EARTH_RADIUS; // h=0
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert_eq!(ed.x, 0.0, "VCHAPX at ground (h=0) should be 0");
}

// ---- DCHAPT ----

#[test]
fn test_dchapt_single_layer() {
    let mut p = default_params();
    p.ed_model = 5;
    p.fc2 = 0.0; // single layer
    let r = EARTH_RADIUS + p.hm;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed.x > 0.0, "DCHAPT single layer should be positive at peak");
}

#[test]
fn test_dchapt_dual_layer() {
    let mut p = default_params();
    p.ed_model = 5;
    p.fc2 = 5.0;
    p.hm2 = 150.0;
    p.sh2 = 50.0;
    let r = EARTH_RADIUS + 200.0;
    let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed.x > 0.0, "DCHAPT dual layer should be positive");
}

// ---- Perturbation: TORUS ----

#[test]
fn test_torus_perturbation_amplifies() {
    let mut p = default_params();
    let r = EARTH_RADIUS + p.hm;
    let ed_base = compute_ed(r, PID2, 0.0, p.fc, &p);

    p.pert_model = 1;
    p.p1 = 0.5; // 50% enhancement
    p.p2 = 200.0; // width in km
    p.p3 = 200.0;
    p.p4 = 0.0; // no tilt
    p.p5 = p.hm;  // center at peak
    let ed_pert = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed_pert.x > ed_base.x, "Torus perturbation should amplify ED");
}

// ---- Perturbation: TROUGH ----

#[test]
fn test_trough_perturbation_depletes() {
    let mut p = default_params();
    let r = EARTH_RADIUS + p.hm;
    let ed_base = compute_ed(r, PID2, 0.0, p.fc, &p);

    p.pert_model = 2;
    p.p1 = -0.5; // 50% depletion
    p.p2 = 0.1;
    p.p3 = 0.0;
    p.p4 = 1.0;
    let ed_pert = compute_ed(r, PID2, 0.0, p.fc, &p);
    assert!(ed_pert.x < ed_base.x, "Trough perturbation should deplete ED");
}

// ---- All models produce finite values ----

#[test]
fn test_all_ed_models_finite() {
    for model in 0..=5u8 {
        let mut p = default_params();
        p.ed_model = model;
        let r = EARTH_RADIUS + 200.0;
        let ed = compute_ed(r, PID2, 0.0, p.fc, &p);
        assert!(ed.x.is_finite(), "ED model {} x not finite", model);
        assert!(ed.dxdr.is_finite(), "ED model {} dxdr not finite", model);
        assert!(ed.dxdth.is_finite(), "ED model {} dxdth not finite", model);
        assert!(ed.dxdph.is_finite(), "ED model {} dxdph not finite", model);
    }
}
