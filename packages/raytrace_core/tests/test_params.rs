//! Tests for ModelParams defaults and constants

use ionotrace::params::*;

#[test]
fn test_default_params() {
    let p = ModelParams::default();
    assert_eq!(p.earth_r, EARTH_RADIUS);
    assert_eq!(p.ed_model, ElectronDensityModel::default());
    assert_eq!(p.mag_model, MagneticFieldModel::default());
    assert_eq!(p.col_model, CollisionModel::default());
    assert_eq!(p.rindex_model, RefractiveIndexModel::default());
    assert_eq!(p.fc, 10.0);
    assert_eq!(p.hm, 250.0);
    assert_eq!(p.sh, 100.0);
    assert_eq!(p.fh, 0.8);
    assert_eq!(p.pert_model, PerturbationModel::default());
}

#[test]
fn test_constants() {
    assert_eq!(EARTH_RADIUS, 6370.0);
}
