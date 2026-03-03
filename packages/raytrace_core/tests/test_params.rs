//! Tests for ModelParams defaults and constants

use raytrace_core::params::*;

#[test]
fn test_default_params() {
    let p = ModelParams::default();
    assert_eq!(p.earth_r, EARTH_RADIUS);
    assert_eq!(p.ed_model, 0);
    assert_eq!(p.mag_model, 0);
    assert_eq!(p.col_model, 0);
    assert_eq!(p.rindex_model, 0);
    assert_eq!(p.fc, 10.0);
    assert_eq!(p.hm, 250.0);
    assert_eq!(p.sh, 100.0);
    assert_eq!(p.fh, 0.8);
    assert_eq!(p.pert_model, 0);
}

#[test]
fn test_constants() {
    assert!((PIT2 - 2.0 * std::f64::consts::PI).abs() < 1e-15);
    assert!((PID2 - std::f64::consts::PI / 2.0).abs() < 1e-15);
    assert_eq!(EARTH_RADIUS, 6370.0);
    assert!(C > 2.99e5 && C < 3.0e5); // speed of light ~ 3e5 km/s
}
