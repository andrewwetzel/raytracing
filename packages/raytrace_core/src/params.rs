use std::f64::consts::PI;

pub const PIT2: f64 = 2.0 * PI;
pub const PID2: f64 = PI / 2.0;
pub const C: f64 = 2.997925e5; // Speed of light in km/s
pub const LOGTEN: f64 = 2.302585092994046; // ln(10)
pub const EARTH_RADIUS: f64 = 6370.0;

/// Model parameters (replaces Fortran W-array)
#[derive(Clone, Debug)]
#[allow(dead_code)]
pub struct ModelParams {
    pub earth_r: f64,
    // Model selectors
    pub ed_model: u8,     // 0=chapx,1=elect1,2=linear,3=qparab,4=vchapx,5=dchapt
    pub mag_model: u8,    // 0=dipoly,1=consty,2=cubey
    pub col_model: u8,    // 0=expz2,1=constz,2=expz
    pub rindex_model: u8, // 0=ahwfwc,1=ahnfnc,2=ahnfwc,3=ahwfnc
    // Electron density params
    pub fc: f64,
    pub hm: f64,
    pub sh: f64,
    pub alpha: f64,
    pub ed_a: f64,
    pub ed_b: f64,
    pub ed_c: f64,
    pub ed_e: f64,
    pub ym: f64,
    // Second layer for DCHAPT
    pub fc2: f64,
    pub hm2: f64,
    pub sh2: f64,
    // VCHAPX exponent
    pub chi: f64,
    // Magnetic field
    pub fh: f64,
    pub dip: f64,  // dip angle for CUBEY (radians)
    pub epoch_year: f64, // year for IGRF interpolation (e.g. 2025.0)
    // Collision
    pub nu1: f64,
    pub h1: f64,
    pub a1: f64,
    pub nu2: f64,
    pub h2: f64,
    pub a2: f64,
    // Perturbation params (TORUS/TROUGH/SHOCK/BULGE/EXPX)
    pub pert_model: u8,  // 0=none,1=torus,2=trough,3=shock,4=bulge,5=expx
    pub p1: f64, pub p2: f64, pub p3: f64, pub p4: f64, pub p5: f64,
    pub p6: f64, pub p7: f64, pub p8: f64, pub p9: f64,
}

impl Default for ModelParams {
    fn default() -> Self {
        Self {
            earth_r: EARTH_RADIUS,
            ed_model: 0, mag_model: 0, col_model: 0, rindex_model: 0,
            fc: 10.0, hm: 250.0, sh: 100.0, alpha: 0.5,
            ed_a: 0.0, ed_b: 0.0, ed_c: 0.0, ed_e: 0.0,
            ym: 100.0,
            fc2: 0.0, hm2: 0.0, sh2: 0.0,
            chi: 3.0,
            fh: 0.8, dip: 0.0, epoch_year: 2025.0,
            nu1: 1_050_000.0, h1: 100.0, a1: 0.148,
            nu2: 30.0, h2: 140.0, a2: 0.0183,
            pert_model: 0,
            p1: 0.0, p2: 0.0, p3: 0.0, p4: 0.0, p5: 0.0,
            p6: 0.0, p7: 0.0, p8: 0.0, p9: 0.0,
        }
    }
}
