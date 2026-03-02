//! raytrace_core — High-performance ionospheric ray tracing engine
//!
//! Rust implementation of the OT 75-76 ray tracing algorithm with PyO3 bindings.
//! Ports the performance-critical inner loop: HAMLTN → AHWFWC → RKAM.

use pyo3::prelude::*;
use std::f64::consts::PI;

// ============================================================
// Constants
// ============================================================

const PIT2: f64 = 2.0 * PI;
const PID2: f64 = PI / 2.0;
const C: f64 = 2.997925e5; // Speed of light in km/s
const LOGTEN: f64 = 2.302585092994046; // ln(10)
const EARTH_RADIUS: f64 = 6370.0;

// ============================================================
// Configuration structs (passed from Python)
// ============================================================

/// Model parameters (replaces Fortran W-array)
#[derive(Clone, Debug)]
struct ModelParams {
    earth_r: f64,
    // Model selectors
    ed_model: u8,     // 0=chapx,1=elect1,2=linear,3=qparab,4=vchapx,5=dchapt
    mag_model: u8,    // 0=dipoly,1=consty,2=cubey
    col_model: u8,    // 0=expz2,1=constz,2=expz
    rindex_model: u8, // 0=ahwfwc,1=ahnfnc,2=ahnfwc,3=ahwfnc
    // Electron density params
    fc: f64,
    hm: f64,
    sh: f64,
    alpha: f64,
    ed_a: f64,
    ed_b: f64,
    ed_c: f64,
    ed_e: f64,
    ym: f64,
    // Second layer for DCHAPT
    fc2: f64,
    hm2: f64,
    sh2: f64,
    // VCHAPX exponent
    chi: f64,
    // Magnetic field
    fh: f64,
    dip: f64,  // dip angle for CUBEY (radians)
    epoch_year: f64, // year for IGRF interpolation (e.g. 2025.0)
    // Collision
    nu1: f64,
    h1: f64,
    a1: f64,
    nu2: f64,
    h2: f64,
    a2: f64,
    // Perturbation params (TORUS/TROUGH/SHOCK/BULGE/EXPX)
    pert_model: u8,  // 0=none,1=torus,2=trough,3=shock,4=bulge,5=expx
    p1: f64, p2: f64, p3: f64, p4: f64, p5: f64, p6: f64, p7: f64, p8: f64, p9: f64,
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

// ============================================================
// Electron Density Models
// ============================================================

struct ElectronDensityResult {
    x: f64,
    dxdr: f64,
    dxdth: f64,
    dxdph: f64,
    dxdt: f64,
}

/// Dispatch to the selected electron density model, then apply perturbation
fn compute_ed(r: f64, theta: f64, phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let mut ed = match p.ed_model {
        1 => elect1_ed(r, theta, phi, freq_mhz, p),
        2 => linear(r, theta, phi, freq_mhz, p),
        3 => qparab(r, theta, phi, freq_mhz, p),
        4 => vchapx(r, theta, phi, freq_mhz, p),
        5 => dchapt(r, theta, phi, freq_mhz, p),
        _ => chapx(r, theta, phi, freq_mhz, p),
    };
    // Apply perturbation modifier (multiplicative)
    match p.pert_model {
        1 => apply_torus(&mut ed, r, theta, phi, p),
        2 => apply_trough(&mut ed, r, theta, phi, p),
        3 => apply_shock(&mut ed, r, theta, phi, p),
        4 => apply_bulge(&mut ed, r, theta, phi, freq_mhz, p),
        5 => apply_expx_pert(&mut ed, r, p),
        _ => {}
    }
    ed
}

/// Chapman layer (CHAPX) — default
fn chapx(r: f64, theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let theta2 = theta - PID2;
    let hmax = p.hm + p.earth_r * p.ed_e * theta2;
    let h = r - p.earth_r;
    let z = (h - hmax) / p.sh;

    let d = if p.ed_b != 0.0 { PIT2 / p.ed_b } else { 0.0 };

    let temp = 1.0 + p.ed_a * (d * theta2).sin() + p.ed_c * theta2;
    let exz = 1.0 - (-z).exp();

    let fc_f = p.fc / freq_mhz;
    let x = fc_f * fc_f * temp * (p.alpha * (exz - z)).exp();
    let dxdr = -p.alpha * x * exz / p.sh;

    let mut dxdth = x * (d * p.ed_a * (PID2 - d * theta2).sin() + p.ed_c) / temp;
    dxdth -= dxdr * p.earth_r * p.ed_e;

    ElectronDensityResult { x, dxdr, dxdth, dxdph: 0.0, dxdt: 0.0 }
}

/// Simple exponential layer (ELECT1)
fn elect1_ed(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let h = r - p.earth_r;
    let z = (h - p.hm) / p.sh;
    let fc_f = p.fc / freq_mhz;
    let x = fc_f * fc_f * (1.0 - z - (-z).exp()).exp();
    let dxdr = -x * (1.0 - (-z).exp()) / p.sh;

    ElectronDensityResult { x, dxdr, dxdth: 0.0, dxdph: 0.0, dxdt: 0.0 }
}

/// Piecewise-linear density (LINEAR)
fn linear(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let h = r - p.earth_r;
    let fc_f = p.fc / freq_mhz;
    let fc2 = fc_f * fc_f;

    let (x, dxdr) = if h <= p.hm {
        (fc2 * h / p.hm, fc2 / p.hm)
    } else {
        let semi = p.ym / 2.0;
        let z = (h - p.hm) / semi;
        if z < 1.0 {
            (fc2 * (1.0 - z * z), fc2 * (-2.0 * z / semi))
        } else {
            (0.0, 0.0)
        }
    };

    ElectronDensityResult { x, dxdr, dxdth: 0.0, dxdph: 0.0, dxdt: 0.0 }
}

/// Quasi-parabolic density (QPARAB)
fn qparab(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let rm = p.earth_r + p.hm;
    let rb = rm - p.ym / 2.0;
    let fc_f = p.fc / freq_mhz;
    let fc2 = fc_f * fc_f;

    if r <= rb || r <= 0.0 {
        return ElectronDensityResult { x: 0.0, dxdr: 0.0, dxdth: 0.0, dxdph: 0.0, dxdt: 0.0 };
    }

    let half_ym = p.ym / 2.0;
    let ratio = (r - rm) / (r * half_ym / rm);
    let mut x = fc2 * (1.0 - ratio * ratio);

    // Derivative: d/dr of (1 - ((r-rm)*rm / (r*half_ym))^2)
    let num = (r - rm) * rm;
    let den = r * half_ym;
    let term = num / den;
    let dterm_dr = rm / den - num * rm / (den * den * r); // simplified
    let dterm_dr2 = (rm * r * half_ym - (r - rm) * rm * half_ym) / (r * half_ym * r * half_ym);
    let mut dxdr = fc2 * (-2.0 * term * dterm_dr2);

    if x < 0.0 {
        x = 0.0;
        dxdr = 0.0;
    }

    ElectronDensityResult { x, dxdr, dxdth: 0.0, dxdph: 0.0, dxdt: 0.0 }
}

/// Variable Chapman (VCHAPX) — uses tau = (hm/h)^chi exponent
fn vchapx(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let h = r - p.earth_r;
    if h <= 0.0 {
        return ElectronDensityResult { x: 0.0, dxdr: 0.0, dxdth: 0.0, dxdph: 0.0, dxdt: 0.0 };
    }
    let fc_f = p.fc / freq_mhz;
    let tau = (p.hm / h).powf(p.chi);
    let x = fc_f * fc_f * tau.sqrt() * (0.5 * (1.0 - tau)).exp();
    let dxdr = 0.5 * x * (tau - 1.0) * p.chi / h;
    ElectronDensityResult { x, dxdr, dxdth: 0.0, dxdph: 0.0, dxdt: 0.0 }
}

/// Dual-layer Chapman (DCHAPT) — two layers with latitude variation
fn dchapt(r: f64, theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let h = r - p.earth_r;
    if h <= 0.0 {
        return ElectronDensityResult { x: 0.0, dxdr: 0.0, dxdth: 0.0, dxdph: 0.0, dxdt: 0.0 };
    }
    let theta2 = theta - PID2;
    let earthe = p.earth_r * p.ed_e;
    let hmax = p.hm + earthe * theta2;
    let z1 = (h - hmax) / p.sh;
    let expz1 = 1.0 - (-z1).exp();
    let temp = 1.0 + p.ed_c * theta2;
    let fc_f = p.fc / freq_mhz;
    let x1 = fc_f * fc_f * temp * (0.5 * (expz1 - z1)).exp();
    let dxdr1 = -0.5 * x1 * expz1 / p.sh;
    let dxdth1 = x1 * p.ed_c / temp - dxdr1 * earthe;
    let (mut x, mut dxdr, mut dxdth) = (x1, dxdr1, dxdth1);
    if p.fc2 != 0.0 {
        let fc2_f = p.fc2 / freq_mhz;
        let z2 = (h - p.hm2 - earthe * theta2) / p.sh2;
        let expz2 = 1.0 - (-z2).exp();
        let x2 = fc2_f * fc2_f * temp * (0.5 * (expz2 - z2)).exp();
        let dxdr2 = -0.5 * x2 * expz2 / p.sh2;
        x += x2;
        dxdr += dxdr2;
        dxdth += x2 * p.ed_c / temp - dxdr2 * earthe;
    }
    ElectronDensityResult { x, dxdr, dxdth, dxdph: 0.0, dxdt: 0.0 }
}

// ---- Perturbation modifiers (applied after base ED model) ----
// p1..p9 map to Fortran W(151)..W(159)

/// Torus perturbation — Gaussian enhancement in tilted coordinates
fn apply_torus(ed: &mut ElectronDensityResult, r: f64, theta: f64, _phi: f64, p: &ModelParams) {
    if ed.x == 0.0 && ed.dxdr == 0.0 && ed.dxdth == 0.0 { return; }
    if p.p1 == 0.0 { return; }
    let r0 = p.earth_r + p.p5;
    let z = r - r0;
    let lambda = r0 * (theta - PID2);
    let (sinb, cosb) = (p.p4.sin(), p.p4.cos());
    let pp = lambda * cosb + z * sinb;
    let yy = z * cosb - lambda * sinb;
    let delta = p.p1 * (-(pp / p.p2).powi(2) - (yy / p.p3).powi(2)).exp();
    let del1 = delta + 1.0;
    let pdpr = -2.0 * delta * (pp * sinb / (p.p2 * p.p2) + yy * cosb / (p.p3 * p.p3));
    let pdpt = -2.0 * delta * (pp * r0 * cosb / (p.p2 * p.p2) - yy * r0 * sinb / (p.p3 * p.p3));
    ed.dxdr = ed.dxdr * del1 + ed.x * pdpr;
    ed.dxdth = ed.dxdth * del1 + ed.x * pdpt;
    ed.dxdph *= del1;
    ed.x *= del1;
}

/// Trough perturbation — latitude-dependent Gaussian depletion
fn apply_trough(ed: &mut ElectronDensityResult, _r: f64, theta: f64, _phi: f64, p: &ModelParams) {
    if ed.x == 0.0 && ed.dxdr == 0.0 && ed.dxdth == 0.0 { return; }
    if p.p1 == 0.0 { return; }
    let angle_raw = theta + p.p3 - PID2;
    let width = if angle_raw > 0.0 { p.p4 * p.p2 } else { p.p2 };
    let angle = angle_raw / width;
    let delta = p.p1 * (-angle * angle).exp();
    let del1 = delta + 1.0;
    ed.dxdr *= del1;
    ed.dxdth = ed.dxdth * del1 - 2.0 * ed.x * angle * delta / width;
    ed.dxdph *= del1;
    ed.x *= del1;
}

/// Shock (TID) perturbation — travelling ionospheric disturbance
fn apply_shock(ed: &mut ElectronDensityResult, r: f64, theta: f64, phi: f64, p: &ModelParams) {
    if ed.x == 0.0 && ed.dxdr == 0.0 && ed.dxdth == 0.0 { return; }
    if p.p1 == 0.0 || p.p2 == 0.0 { return; }
    let h = r - p.earth_r;
    let rhoc = p.p5 * (h - p.p6) - p.p2;
    let lon = phi - p.p4;
    let lat = PID2 - theta - p.p3;
    let u = lon.cos() * lat.cos();
    let rho = r * u.acos();
    let dif = rhoc - rho;
    let con_base = -9.0 / (p.p2 * p.p2);
    let cons = p.p1 * (con_base * dif * dif).exp();
    let c0nst = 1.0 + cons;
    let con = 2.0 * con_base * cons * dif;
    ed.dxdr = ed.dxdr * c0nst + ed.x * con * (p.p5 - rho / r);
    let u2 = u * u;
    if (1.0 - u2).abs() >= 1.0e-9 {
        let s = r / (1.0 - u2).sqrt();
        ed.dxdth = ed.dxdth * c0nst + ed.x * con * s * lon.cos() * lat.sin();
        ed.dxdph = ed.dxdph * c0nst - ed.x * con * s * lat.cos() * lon.sin();
    } else {
        ed.dxdth *= c0nst;
        ed.dxdph *= c0nst;
    }
    ed.x *= c0nst;
}

/// Bulge perturbation — equatorial enhancement
fn apply_bulge(ed: &mut ElectronDensityResult, r: f64, theta: f64, phi: f64, _freq: f64, p: &ModelParams) {
    if p.p2 <= 0.0 || p.p3 == 0.0 { return; }
    let hmax = p.p1 + 5.0 * p.p2;
    let h = r - (p.earth_r + hmax);
    let e = (h / p.p2).exp();
    let hsc2 = if p.p7 != 0.0 { p.p7 } else { 1.0 };
    let hsc3 = if p.p8 != 0.0 { p.p8 } else { 1.0 };
    let frac_term = p.p4 * (-((theta - p.p5) / hsc2).powi(2) - ((phi - p.p6) / hsc3).powi(2)).exp();
    let x_add = p.p3 * e * (1.0 + frac_term);
    ed.x += x_add;
    ed.dxdr += x_add / p.p2;
    ed.dxdth += -2.0 * p.p4 * x_add * (theta - p.p5) / (hsc2 * hsc2);
}

/// Exponential perturbation (EXPX)
fn apply_expx_pert(ed: &mut ElectronDensityResult, r: f64, p: &ModelParams) {
    if p.p2 <= 0.0 || p.p3 == 0.0 { return; }
    let hmax = p.p1 + 5.0 * p.p2;
    let h = r - (p.earth_r + hmax);
    let x_add = p.p3 * (h / p.p2).exp();
    ed.x += x_add;
    ed.dxdr += x_add / p.p2;
}

// ============================================================
// Magnetic Field Models
// ============================================================

struct MagneticFieldResult {
    y: f64,
    dydr: f64,
    dydth: f64,
    dydph: f64,
    yr: f64,
    yth: f64,
    yph: f64,
    dyrdr: f64,
    dyrdth: f64,
    dyrdph: f64,
    dythdr: f64,
    dythdth: f64,
    dythdph: f64,
    dyphdr: f64,
    dyphdth: f64,
    dyphdph: f64,
}

/// Dispatch to selected magnetic field model
fn compute_mag(r: f64, theta: f64, phi: f64, freq_mhz: f64, p: &ModelParams) -> MagneticFieldResult {
    match p.mag_model {
        1 => consty(r, theta, phi, freq_mhz, p),
        2 => cubey(r, theta, phi, freq_mhz, p),
        3 => harmony(r, theta, phi, freq_mhz, p),
        _ => dipoly(r, theta, phi, freq_mhz, p),
    }
}

/// Dipole field (DIPOLY) — default
fn dipoly(r: f64, theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> MagneticFieldResult {
    let sinth = theta.sin();
    let costh = theta.cos();
    let term9 = (1.0 + 3.0 * costh * costh).sqrt();

    let t1 = p.fh * (p.earth_r / r).powi(3) / freq_mhz;

    let y = t1 * term9;
    let yr = 2.0 * t1 * costh;
    let yth = t1 * sinth;

    let dyrdr = -3.0 * yr / r;
    let dyrdth = -2.0 * yth;
    let dythdr = -3.0 * yth / r;
    let dythdth = 0.5 * yr;

    let dydr = -3.0 * y / r;
    let dydth = -3.0 * y * sinth * costh / (term9 * term9);

    MagneticFieldResult {
        y, dydr, dydth, dydph: 0.0,
        yr, yth, yph: 0.0,
        dyrdr, dyrdth, dyrdph: 0.0,
        dythdr, dythdth, dythdph: 0.0,
        dyphdr: 0.0, dyphdth: 0.0, dyphdph: 0.0,
    }
}

/// Constant field along radial (CONSTY)
fn consty(_r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> MagneticFieldResult {
    let y = p.fh / freq_mhz;
    MagneticFieldResult {
        y, dydr: 0.0, dydth: 0.0, dydph: 0.0,
        yr: y, yth: 0.0, yph: 0.0,
        dyrdr: 0.0, dyrdth: 0.0, dyrdph: 0.0,
        dythdr: 0.0, dythdth: 0.0, dythdph: 0.0,
        dyphdr: 0.0, dyphdth: 0.0, dyphdph: 0.0,
    }
}

/// Cubic field with constant dip (CUBEY)
/// Same height variation as dipole but with fixed dip angle
fn cubey(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> MagneticFieldResult {
    let y = (p.earth_r / r).powi(3) * p.fh / freq_mhz;
    let yr = y * p.dip.sin();
    let yth = y * p.dip.cos();
    let dydr = -3.0 * y / r;
    let dyrdr = -3.0 * yr / r;
    let dythdr = -3.0 * yth / r;
    MagneticFieldResult {
        y, dydr, dydth: 0.0, dydph: 0.0,
        yr, yth, yph: 0.0,
        dyrdr, dyrdth: 0.0, dyrdph: 0.0,
        dythdr, dythdth: 0.0, dythdph: 0.0,
        dyphdr: 0.0, dyphdth: 0.0, dyphdph: 0.0,
    }
}

/// Spherical Harmonic magnetic field (HARMONY) — IGRF-14, degree 1-13
/// Coefficients for epoch 2025.0 with secular variation for epoch interpolation.
/// Set p.epoch_year for time interpolation (valid ~2020-2030).
fn harmony(r: f64, theta: f64, phi: f64, freq_mhz: f64, p: &ModelParams) -> MagneticFieldResult {
    const N_MAX: usize = 13;
    const N_COEFF: usize = 104; // sum(n+1 for n=1..13)

    // IGRF-14 g coefficients for 2025.0 (nT), flat index = sum(i+1, i=1..n-1) + m
    #[rustfmt::skip]
    const G0: [f64; N_COEFF] = [
        -29350.0, -1410.3,
        -2556.2, 2950.9, 1648.7,
        1360.9, -2404.2, 1243.8, 453.4,
        894.7, 799.6, 55.8, -281.1, 12.0,
        -232.9, 369.0, 187.2, -138.7, -141.9, 20.9,
        64.3, 63.8, 76.7, -115.7, -40.9, 14.9, -60.8,
        79.6, -76.9, -8.8, 59.3, 15.8, 2.5, -11.2, 14.3,
        23.1, 10.9, -17.5, 2.0, -21.8, 16.9, 14.9, -16.8, 1.0,
        4.7, 8.0, 3.0, -0.2, -2.5, -13.1, 2.4, 8.6, -8.7, -12.8,
        -1.3, -6.4, 0.2, 2.0, -1.0, -0.5, -0.9, 1.5, 0.9, -2.6, -3.9,
        3.0, -1.4, -2.5, 2.4, -0.6, 0.0, -0.6, -0.1, 1.1, -1.0, -0.1, 2.6,
        -2.0, -0.1, 0.4, 1.2, -1.2, 0.6, 0.5, 0.5, -0.1, -0.5, -0.2, -1.2, -0.7,
        0.2, -0.9, 0.6, 0.7, -0.2, 0.5, 0.1, 0.7, 0.0, 0.3, 0.2, 0.4, -0.5, -0.4,
    ];
    #[rustfmt::skip]
    const H0: [f64; N_COEFF] = [
        0.0, 4545.5,
        0.0, -3133.6, -814.2,
        0.0, -56.9, 237.6, -549.6,
        0.0, 278.6, -134.0, 212.0, -375.4,
        0.0, 45.3, 220.0, -122.9, 42.9, 106.2,
        0.0, -18.4, 16.8, 48.9, -59.8, 10.9, 72.8,
        0.0, -48.9, -14.4, -1.0, 23.5, -7.4, -25.1, -2.2,
        0.0, 7.2, -12.6, 11.5, -9.7, 12.7, 0.7, -5.2, 3.9,
        0.0, -24.8, 12.1, 8.3, -3.4, -5.3, 7.2, -0.6, 0.8, 9.8,
        0.0, 3.3, 0.1, 2.5, 5.4, -9.0, 0.4, -4.2, -3.8, 0.9, -9.0,
        0.0, 0.0, 2.8, -0.6, 0.1, 0.5, -0.3, -1.2, -1.7, -2.9, -1.8, -2.3,
        0.0, -1.2, 0.6, 1.0, -1.5, 0.0, 0.6, -0.2, 0.8, 0.1, -0.9, 0.1, 0.2,
        0.0, -0.9, 0.7, 1.2, -0.3, -1.3, -0.1, 0.2, -0.2, 0.5, 0.6, -0.6, -0.3, -0.5,
    ];
    // Secular variation (nT/yr) for 2025-2030, degree 1-8 only
    #[rustfmt::skip]
    const SVG: [f64; N_COEFF] = [
        12.6, 10.0,
        -11.2, -5.3, -8.3,
        -1.5, -4.4, 0.4, -15.6,
        -1.7, -2.3, -5.8, 5.4, -6.8,
        0.6, 1.3, 0.0, 0.7, 2.3, 1.0,
        -0.2, -0.3, 0.8, 1.2, -0.8, 0.4, 0.9,
        -0.1, -0.1, -0.1, 0.5, -0.1, -0.8, -0.8, 0.9,
        -0.1, 0.2, 0.0, 0.4, -0.1, 0.3, 0.1, 0.0, 0.3,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    ];
    #[rustfmt::skip]
    const SVH: [f64; N_COEFF] = [
        0.0, -21.5,
        0.0, -27.3, -11.1,
        0.0, 3.8, -0.2, -3.9,
        0.0, -1.3, 4.1, 1.6, -4.1,
        0.0, -0.5, 2.1, 0.5, 1.7, 1.9,
        0.0, 0.3, -1.6, -0.4, 0.8, 0.7, 0.9,
        0.0, 0.6, 0.5, -0.7, 0.0, -0.9, 0.5, -0.3,
        0.0, -0.3, 0.4, -0.3, 0.4, -0.5, -0.6, 0.3, 0.2,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    ];

    // Interpolate coefficients to requested epoch
    let dt = p.epoch_year - 2025.0;
    let mut gc = [0.0f64; N_COEFF];
    let mut hc = [0.0f64; N_COEFF];
    for i in 0..N_COEFF {
        gc[i] = G0[i] + dt * SVG[i];
        hc[i] = H0[i] + dt * SVH[i];
    }

    // Flat index helper: for degree n, order m → sum(i+1, i=1..n-1) + m
    let idx = |n: usize, m: usize| -> usize {
        n * (n + 1) / 2 - 1 + m
    };

    const EOM: f64 = 1.7589e7; // e/m ratio (C/kg)
    let costh = theta.cos();
    let sinth = theta.sin().max(1.0e-10);
    let aor = p.earth_r / r;

    // sin/cos(m*phi)
    let mut sp = [0.0f64; N_MAX + 1];
    let mut cp = [0.0f64; N_MAX + 1];
    for m in 0..=N_MAX {
        sp[m] = ((m as f64) * phi).sin();
        cp[m] = ((m as f64) * phi).cos();
    }

    // Associated Legendre functions P[n][m] and derivative dP/dtheta
    // Using Schmidt semi-normalized form with recursion
    let nn = N_MAX + 2;
    let mut pp = vec![vec![0.0f64; nn]; nn];
    let mut dp = vec![vec![0.0f64; nn]; nn];
    pp[0][0] = 1.0;
    pp[1][0] = costh;
    dp[1][0] = -sinth;
    pp[1][1] = sinth;
    dp[1][1] = costh;

    for n in 2..=N_MAX {
        let nf = n as f64;
        // m = 0
        pp[n][0] = ((2.0 * nf - 1.0) * costh * pp[n - 1][0] - (nf - 1.0) * pp[n - 2][0]) / nf;
        dp[n][0] = nf * (pp[n - 1][0] - costh * pp[n][0]) / sinth;
        // m = n (sectoral)
        let fact = ((2.0 * nf - 1.0) / (2.0 * nf)).sqrt();
        pp[n][n] = fact * sinth * pp[n - 1][n - 1];
        dp[n][n] = fact * (costh * pp[n - 1][n - 1] + sinth * dp[n - 1][n - 1]);
        // m = 1..n-1
        for m in 1..n {
            let mf = m as f64;
            let a = (2.0 * nf - 1.0) * costh * pp[n - 1][m];
            let b = ((nf - 1.0 + mf) * (nf - 1.0 - mf) / ((2.0 * nf - 3.0) * 1.0)).sqrt()
                * (2.0 * nf - 1.0).sqrt() * pp[n - 2][m];
            pp[n][m] = (a - b) / ((nf + mf) * (nf - mf)).sqrt();
            dp[n][m] = nf * costh * pp[n][m] / sinth - ((nf * nf - mf * mf) as f64).sqrt() * pp[n - 1][m] / sinth;
        }
    }

    // Accumulate field components
    let mut br = 0.0f64;
    let mut bt = 0.0f64;
    let mut bp = 0.0f64;
    let mut dbr_dr = 0.0f64;
    let mut dbr_dt = 0.0f64;
    let mut dbr_dp = 0.0f64;
    let mut dbt_dr = 0.0f64;
    let mut dbt_dt = 0.0f64;
    let mut dbt_dp = 0.0f64;
    let mut dbp_dr = 0.0f64;
    let mut dbp_dt = 0.0f64;
    let mut dbp_dp = 0.0f64;

    let mut rn = aor * aor; // (a/r)^2
    for n in 1..=N_MAX {
        rn *= aor; // (a/r)^(n+2)
        let nf = n as f64;
        let drn_dr = -(nf + 2.0) * rn / r;

        for m in 0..=n {
            let mf = m as f64;
            let i = idx(n, m);
            let g = gc[i];
            let h = hc[i];

            let cos_term = g * cp[m] + h * sp[m];
            let sin_term = mf * (h * cp[m] - g * sp[m]);

            let p_nm = pp[n][m];
            let dp_nm = dp[n][m];

            br += (nf + 1.0) * rn * cos_term * p_nm;
            bt += -rn * cos_term * dp_nm;
            bp += -rn * sin_term * p_nm / sinth;

            dbr_dr += (nf + 1.0) * drn_dr * cos_term * p_nm;
            dbr_dt += (nf + 1.0) * rn * cos_term * dp_nm;
            dbr_dp += (nf + 1.0) * rn * (-sin_term / mf.max(1.0) * mf) * p_nm;

            dbt_dr += -drn_dr * cos_term * dp_nm;
            // d²P/dθ² approximated via recursion identity
            let d2p = -nf * (nf + 1.0) * p_nm + mf * mf / (sinth * sinth) * p_nm + costh / sinth * dp_nm;
            dbt_dt += -rn * cos_term * d2p;
            dbt_dp += -rn * (-sin_term / mf.max(1.0) * mf) * dp_nm;

            dbp_dr += -drn_dr * sin_term * p_nm / sinth;
            dbp_dt += -rn * sin_term * (dp_nm * sinth - p_nm * costh) / (sinth * sinth);
            let cos2_term = -mf * mf * (g * cp[m] + h * sp[m]);
            dbp_dp += -rn * cos2_term * p_nm / sinth;
        }
    }

    // Convert from nT to normalized gyrofrequency
    let conv = EOM / PIT2 * 1.0e-6 / freq_mhz;
    let yr = conv * br;
    let yth = conv * bt;
    let yph = conv * bp;
    let y = (yr * yr + yth * yth + yph * yph).sqrt().max(1.0e-10);

    let dyrdr = conv * dbr_dr;
    let dyrdth = conv * dbr_dt;
    let dyrdph = conv * dbr_dp;
    let dythdr = conv * dbt_dr;
    let dythdth = conv * dbt_dt;
    let dythdph = conv * dbt_dp;
    let dyphdr = conv * dbp_dr;
    let dyphdth = conv * dbp_dt;
    let dyphdph = conv * dbp_dp;

    let dydr = (yr * dyrdr + yth * dythdr + yph * dyphdr) / y;
    let dydth = (yr * dyrdth + yth * dythdth + yph * dyphdth) / y;
    let dydph = (yr * dyrdph + yth * dythdph + yph * dyphdph) / y;

    MagneticFieldResult {
        y, dydr, dydth, dydph,
        yr, yth, yph,
        dyrdr, dyrdth, dyrdph,
        dythdr, dythdth, dythdph,
        dyphdr, dyphdth, dyphdph,
    }
}

// ============================================================
// Collision Frequency Models
// ============================================================

struct CollisionResult {
    z: f64,
    dzdr: f64,
    dzdth: f64,
    dzdph: f64,
}

/// Dispatch to selected collision model
fn compute_col(r: f64, theta: f64, phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    match p.col_model {
        1 => constz(r, theta, phi, freq_mhz, p),
        2 => expz(r, theta, phi, freq_mhz, p),
        _ => expz2(r, theta, phi, freq_mhz, p),
    }
}

/// Two-term exponential collision (EXPZ2) — default
fn expz2(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    let h = r - p.earth_r;
    let omega = PIT2 * freq_mhz * 1.0e6;

    let exp1 = p.nu1 * (-p.a1 * (h - p.h1)).exp();
    let exp2 = p.nu2 * (-p.a2 * (h - p.h2)).exp();

    let z = (exp1 + exp2) / omega;
    let dzdr = (-p.a1 * exp1 - p.a2 * exp2) / omega;

    CollisionResult { z, dzdr, dzdth: 0.0, dzdph: 0.0 }
}

/// Constant collision frequency (CONSTZ)
fn constz(_r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    let omega = PIT2 * freq_mhz * 1.0e6;
    let z = if omega != 0.0 { p.nu1 / omega } else { 0.0 };
    CollisionResult { z, dzdr: 0.0, dzdth: 0.0, dzdph: 0.0 }
}

/// Single exponential collision (EXPZ)
fn expz(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    let h = r - p.earth_r;
    let omega = PIT2 * freq_mhz * 1.0e6;

    let exp1 = p.nu1 * (-p.a1 * (h - p.h1)).exp();

    let z = exp1 / omega;
    let dzdr = -p.a1 * exp1 / omega;

    CollisionResult { z, dzdr, dzdth: 0.0, dzdph: 0.0 }
}

// ============================================================
// Appleton-Hartree Refractive Index (AHWFWC)
// ============================================================

struct RindexResult {
    n2_re: f64,
    n2_im: f64,
    h_re: f64,
    dhdt_re: f64,
    dhdr_re: f64,
    dhdth_re: f64,
    dhdph_re: f64,
    dhdom_re: f64,
    dhdkr_re: f64,
    dhdkth_re: f64,
    dhdkph_re: f64,
    kphpk_re: f64,
    kphpk_im: f64,
    space: bool,
    new_kr: f64,
    new_kth: f64,
    new_kph: f64,
}

/// Complex number operations (inline for speed)
#[derive(Clone, Copy)]
struct Cx { re: f64, im: f64 }

impl Cx {
    fn new(re: f64, im: f64) -> Self { Self { re, im } }
    fn from_real(re: f64) -> Self { Self { re, im: 0.0 } }
}

impl std::ops::Add for Cx {
    type Output = Cx;
    fn add(self, o: Cx) -> Cx { Cx::new(self.re + o.re, self.im + o.im) }
}
impl std::ops::Sub for Cx {
    type Output = Cx;
    fn sub(self, o: Cx) -> Cx { Cx::new(self.re - o.re, self.im - o.im) }
}
impl std::ops::Mul for Cx {
    type Output = Cx;
    fn mul(self, o: Cx) -> Cx {
        Cx::new(self.re * o.re - self.im * o.im, self.re * o.im + self.im * o.re)
    }
}
impl std::ops::Mul<f64> for Cx {
    type Output = Cx;
    fn mul(self, s: f64) -> Cx { Cx::new(self.re * s, self.im * s) }
}
impl std::ops::Div for Cx {
    type Output = Cx;
    fn div(self, o: Cx) -> Cx {
        let d = o.re * o.re + o.im * o.im;
        if d == 0.0 { return Cx::new(0.0, 0.0); }
        Cx::new((self.re * o.re + self.im * o.im) / d,
                (self.im * o.re - self.re * o.im) / d)
    }
}
impl std::ops::Neg for Cx {
    type Output = Cx;
    fn neg(self) -> Cx { Cx::new(-self.re, -self.im) }
}

fn cx_sqrt(c: Cx) -> Cx {
    let mag = (c.re * c.re + c.im * c.im).sqrt();
    let r = ((mag + c.re) / 2.0).sqrt();
    let i = if c.im >= 0.0 { ((mag - c.re) / 2.0).sqrt() } else { -((mag - c.re) / 2.0).sqrt() };
    Cx::new(r, i)
}

fn cx_abs(c: Cx) -> f64 { (c.re * c.re + c.im * c.im).sqrt() }

/// Dispatch to selected refractive index model
fn compute_rindex(
    r: f64, theta: f64, phi: f64,
    kr: f64, kth: f64, kph: f64,
    freq_mhz: f64, ray_mode: f64,
    p: &ModelParams, rstart: bool,
) -> RindexResult {
    match p.rindex_model {
        1 => ahnfnc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart),
        2 => ahnfwc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart),
        3 => ahwfnc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart),
        _ => ahwfwc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart),
    }
}

/// AHNFNC — No Field, No Collisions (simplest/fastest)
/// n² = 1 - X
fn ahnfnc(
    r: f64, theta: f64, phi: f64,
    kr: f64, kth: f64, kph: f64,
    freq_mhz: f64, _ray_mode: f64,
    p: &ModelParams, rstart: bool,
) -> RindexResult {
    let om = PIT2 * freq_mhz * 1.0e6;
    let c2 = C * C;
    let k2 = kr * kr + kth * kth + kph * kph;
    let om2 = om * om;

    let ex = compute_ed(r, theta, phi, freq_mhz, p);
    let x = ex.x;

    let pnpx = -0.5;
    let n2_re = 1.0 - x;
    let nnp = n2_re - 2.0 * x * pnpx;

    let space = n2_re == 1.0;
    let kay2_re = om2 / c2 * n2_re;
    let (new_kr, new_kth, new_kph) = if rstart && k2 > 0.0 {
        let scale = (kay2_re / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else {
        (kr, kth, kph)
    };

    let h_val = 0.5 * (c2 * k2 / om2 - n2_re);

    RindexResult {
        n2_re, n2_im: 0.0,
        h_re: h_val,
        dhdt_re: -pnpx * ex.dxdt,
        dhdr_re: -pnpx * ex.dxdr,
        dhdth_re: -pnpx * ex.dxdth,
        dhdph_re: -pnpx * ex.dxdph,
        dhdom_re: -nnp / om,
        dhdkr_re: c2 / om2 * new_kr,
        dhdkth_re: c2 / om2 * new_kth,
        dhdkph_re: c2 / om2 * new_kph,
        kphpk_re: n2_re, kphpk_im: 0.0,
        space, new_kr, new_kth, new_kph,
    }
}

/// AHNFWC — No Field, With Collisions
/// n² = 1 - X/(1 - iZ)
fn ahnfwc(
    r: f64, theta: f64, phi: f64,
    kr: f64, kth: f64, kph: f64,
    freq_mhz: f64, _ray_mode: f64,
    p: &ModelParams, rstart: bool,
) -> RindexResult {
    let om = PIT2 * freq_mhz * 1.0e6;
    let c2 = C * C;
    let k2 = kr * kr + kth * kth + kph * kph;
    let om2 = om * om;

    let ex = compute_ed(r, theta, phi, freq_mhz, p);
    let x = ex.x;
    let col = compute_col(r, theta, phi, freq_mhz, p);
    let z = col.z;

    let u = Cx::new(1.0, -z);
    let n2 = Cx::from_real(1.0) - Cx::from_real(x) / u;

    let pnpx = Cx::from_real(-1.0) / (u * 2.0);
    let pnpz = Cx::new(0.0, -1.0) * Cx::from_real(x) / (u * u * 2.0);
    let nnp = n2 - (pnpx * (2.0 * x) + pnpz * Cx::from_real(z));

    let pnpr = pnpx * ex.dxdr + pnpz * Cx::from_real(col.dzdr);
    let pnpth = pnpx * ex.dxdth + pnpz * Cx::from_real(col.dzdth);
    let pnpph = pnpx * ex.dxdph + pnpz * Cx::from_real(col.dzdph);
    let pnpt = pnpx * ex.dxdt;

    let space = n2.re == 1.0 && n2.im.abs() < 1.0e-5;
    let kay2_re = om2 / c2 * n2.re;
    let (new_kr, new_kth, new_kph) = if rstart && k2 > 0.0 {
        let scale = (kay2_re / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else {
        (kr, kth, kph)
    };

    let h_val = 0.5 * (c2 * k2 / om2 - n2.re);

    RindexResult {
        n2_re: n2.re, n2_im: n2.im,
        h_re: h_val,
        dhdt_re: -pnpt.re,
        dhdr_re: -pnpr.re,
        dhdth_re: -pnpth.re,
        dhdph_re: -pnpph.re,
        dhdom_re: -nnp.re / om,
        dhdkr_re: c2 / om2 * new_kr,
        dhdkth_re: c2 / om2 * new_kth,
        dhdkph_re: c2 / om2 * new_kph,
        kphpk_re: n2.re, kphpk_im: n2.im,
        space, new_kr, new_kth, new_kph,
    }
}

/// AHWFNC — With Field, No Collisions
/// Same as AHWFWC but with Z=0 (no collision computation)
fn ahwfnc(
    r: f64, theta: f64, phi: f64,
    kr: f64, kth: f64, kph: f64,
    freq_mhz: f64, ray_mode: f64,
    p: &ModelParams, rstart: bool,
) -> RindexResult {
    // Same as full AHWFWC but skip collision computation (Z=0)
    let om = PIT2 * freq_mhz * 1.0e6;
    let c2 = C * C;
    let k2 = kr * kr + kth * kth + kph * kph;
    let om2 = om * om;

    let vr = C / om * kr;
    let vth = C / om * kth;
    let vph = C / om * kph;

    let ex = compute_ed(r, theta, phi, freq_mhz, p);
    let x = ex.x;
    let mag = compute_mag(r, theta, phi, freq_mhz, p);
    let y_mag = mag.y;

    let v2 = vr * vr + vth * vth + vph * vph;
    let vdoty = vr * mag.yr + vth * mag.yth + vph * mag.yph;
    let (ylv, yl2) = if v2 != 0.0 { (vdoty / v2, vdoty * vdoty / v2) } else { (0.0, 0.0) };

    let yt2 = y_mag * y_mag - yl2;
    let yt4 = yt2 * yt2;

    // U = 1 (no collisions), so UX = 1-X
    let ux = 1.0 - x;
    let ux2 = ux * ux;
    let rad_arg = yt4 + 4.0 * yl2 * ux2;
    let rad = ray_mode * rad_arg.sqrt();
    let d = 2.0 * ux - yt2 + rad;
    let d2 = d * d;
    let n2_re = 1.0 - 2.0 * x * ux / d;

    let (pnpps, pnpx, pnpy);
    if rad.abs() > 1e-30 {
        pnpps = 2.0 * x * ux * (-1.0 + (yt2 - 2.0 * ux2) / rad) / d2;
        pnpx = -(2.0 * ux2 - yt2 * (1.0 - 2.0 * x)
            + (yt4 * (1.0 - 2.0 * x) + 4.0 * yl2 * ux * ux2) / rad) / d2;
        pnpy = if y_mag != 0.0 {
            2.0 * x * ux * (-yt2 + (yt4 + 2.0 * yl2 * ux2) / rad) / (d2 * y_mag)
        } else { 0.0 };
    } else {
        pnpps = -2.0 * x * ux / d2;
        pnpx = -2.0 * ux2 / d2;
        pnpy = 0.0;
    }

    let nnp = n2_re - (2.0 * x * pnpx + y_mag * pnpy);

    let (ppspr, ppspth, ppspph) = if y_mag != 0.0 {
        let ppspr = yl2 / y_mag * mag.dydr - (vr * mag.dyrdr + vth * mag.dythdr + vph * mag.dyphdr) * ylv;
        let ppspth = yl2 / y_mag * mag.dydth - (vr * mag.dyrdth + vth * mag.dythdth + vph * mag.dyphdth) * ylv;
        let ppspph = yl2 / y_mag * mag.dydph - (vr * mag.dyrdph + vth * mag.dythdph + vph * mag.dyphdph) * ylv;
        (ppspr, ppspth, ppspph)
    } else { (0.0, 0.0, 0.0) };

    let pnpr_v = pnpx * ex.dxdr + pnpy * mag.dydr + pnpps * ppspr;
    let pnpth_v = pnpx * ex.dxdth + pnpy * mag.dydth + pnpps * ppspth;
    let pnpph_v = pnpx * ex.dxdph + pnpy * mag.dydph + pnpps * ppspph;

    let (pnpvr, pnpvth, pnpvph) = if v2 != 0.0 {
        (pnpps * (vr * yl2 / v2 - ylv * mag.yr),
         pnpps * (vth * yl2 / v2 - ylv * mag.yth),
         pnpps * (vph * yl2 / v2 - ylv * mag.yph))
    } else { (0.0, 0.0, 0.0) };

    let space = n2_re == 1.0;
    let kay2_re = om2 / c2 * n2_re;
    let (new_kr, new_kth, new_kph) = if rstart && k2 > 0.0 {
        let scale = (kay2_re / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else { (kr, kth, kph) };

    let h_val = 0.5 * (c2 * k2 / om2 - n2_re);

    RindexResult {
        n2_re, n2_im: 0.0,
        h_re: h_val,
        dhdt_re: -(pnpx * ex.dxdt),
        dhdr_re: -pnpr_v,
        dhdth_re: -pnpth_v,
        dhdph_re: -pnpph_v,
        dhdom_re: -nnp / om,
        dhdkr_re: c2 / om2 * new_kr - C / om * pnpvr,
        dhdkth_re: c2 / om2 * new_kth - C / om * pnpvth,
        dhdkph_re: c2 / om2 * new_kph - C / om * pnpvph,
        kphpk_re: n2_re, kphpk_im: 0.0,
        space, new_kr, new_kth, new_kph,
    }
}

fn ahwfwc(
    r: f64, theta: f64, phi: f64,
    kr: f64, kth: f64, kph: f64,
    freq_mhz: f64, ray_mode: f64,
    p: &ModelParams, rstart: bool,
) -> RindexResult {
    let om = PIT2 * freq_mhz * 1.0e6;
    let c2 = C * C;
    let k2 = kr * kr + kth * kth + kph * kph;
    let om2 = om * om;

    let vr = C / om * kr;
    let vth = C / om * kth;
    let vph = C / om * kph;

    let ex = compute_ed(r, theta, phi, freq_mhz, p);
    let x = ex.x;

    let mag = compute_mag(r, theta, phi, freq_mhz, p);
    let y_mag = mag.y;

    let v2 = vr * vr + vth * vth + vph * vph;
    let vdoty = vr * mag.yr + vth * mag.yth + vph * mag.yph;

    let (ylv, yl2) = if v2 != 0.0 {
        (vdoty / v2, vdoty * vdoty / v2)
    } else {
        (0.0, 0.0)
    };

    let yt2 = y_mag * y_mag - yl2;
    let yt4 = yt2 * yt2;

    let col = compute_col(r, theta, phi, freq_mhz, p);
    let z = col.z;

    // Complex Appleton-Hartree
    let u = Cx::new(1.0, -z);
    let ux = u - Cx::from_real(x);
    let ux2 = ux * ux;

    let rad_arg = Cx::from_real(yt4) + Cx::from_real(4.0 * yl2) * ux2;
    let rad = cx_sqrt(rad_arg) * ray_mode;
    let d = (u * ux) * 2.0 - Cx::from_real(yt2) + rad;
    let d2 = d * d;
    let n2 = Cx::from_real(1.0) - (Cx::from_real(x) * ux) * 2.0 / d;

    // Partial derivatives of n²
    let (pnpps, pnpx, pnpy, pnpz);

    if cx_abs(rad) > 1e-30 {
        pnpps = ((Cx::from_real(x) * ux) * 2.0)
            * (Cx::from_real(-1.0) + (Cx::from_real(yt2) - ux2 * 2.0) / rad) / d2;

        pnpx = -((u * ux2) * 2.0 - Cx::from_real(yt2) * (u - Cx::from_real(2.0 * x))
            + (Cx::from_real(yt4) * (u - Cx::from_real(2.0 * x))
                + Cx::from_real(4.0 * yl2) * ux * ux2) / rad) / d2;

        pnpy = if y_mag != 0.0 {
            ((Cx::from_real(x) * ux) * 2.0)
                * (Cx::from_real(-yt2) + (Cx::from_real(yt4) + Cx::from_real(2.0 * yl2) * ux2) / rad)
                / (d2 * y_mag)
        } else {
            Cx::from_real(0.0)
        };

        pnpz = Cx::new(0.0, 1.0) * Cx::from_real(x)
            * (ux2 * (-2.0) - Cx::from_real(yt2) + Cx::from_real(yt4) / rad) / d2;
    } else {
        pnpps = (Cx::from_real(x) * ux) * (-2.0) / d2;
        pnpx = (u * ux2) * (-2.0) / d2;
        pnpy = Cx::from_real(0.0);
        pnpz = Cx::new(0.0, 1.0) * Cx::from_real(x) * ux2 * (-2.0) / d2;
    }

    // ∂(sin²ψ)/∂position
    let (ppspr, ppspth, ppspph) = if y_mag != 0.0 {
        let ppspr = yl2 / y_mag * mag.dydr
            - (vr * mag.dyrdr + vth * mag.dythdr + vph * mag.dyphdr) * ylv;
        let ppspth = yl2 / y_mag * mag.dydth
            - (vr * mag.dyrdth + vth * mag.dythdth + vph * mag.dyphdth) * ylv;
        let ppspph = yl2 / y_mag * mag.dydph
            - (vr * mag.dyrdph + vth * mag.dythdph + vph * mag.dyphdph) * ylv;
        (ppspr, ppspth, ppspph)
    } else {
        (0.0, 0.0, 0.0)
    };

    // ∂n²/∂position via chain rule
    let pnpr = pnpx * ex.dxdr + pnpy * Cx::from_real(mag.dydr) +
               pnpz * Cx::from_real(col.dzdr) + pnpps * ppspr;
    let pnpth = pnpx * ex.dxdth + pnpy * Cx::from_real(mag.dydth) +
                pnpz * Cx::from_real(col.dzdth) + pnpps * ppspth;
    let pnpph = pnpx * ex.dxdph + pnpy * Cx::from_real(mag.dydph) +
                pnpz * Cx::from_real(col.dzdph) + pnpps * ppspph;

    // ∂n²/∂v for wave vector derivatives (real parts only)
    let (pnpvr, pnpvth, pnpvph) = if v2 != 0.0 {
        let pnpvr = (pnpps * (vr * yl2 / v2 - ylv * mag.yr)).re;
        let pnpvth = (pnpps * (vth * yl2 / v2 - ylv * mag.yth)).re;
        let pnpvph = (pnpps * (vph * yl2 / v2 - ylv * mag.yph)).re;
        (pnpvr, pnpvth, pnpvph)
    } else {
        (0.0, 0.0, 0.0)
    };

    // NNP = n² - (2X·∂n²/∂X + Y·∂n²/∂Y + Z·∂n²/∂Z)
    let nnp = n2 - (pnpx * (2.0 * x) + pnpy * Cx::from_real(y_mag) + pnpz * Cx::from_real(z));

    let pnpt = pnpx * ex.dxdt;

    let space = n2.re == 1.0 && n2.im.abs() < 1.0e-5;

    // Rescale k-vector on first call
    let kay2_re = om2 / c2 * n2.re;
    let (new_kr, new_kth, new_kph) = if rstart && k2 > 0.0 {
        let scale = (kay2_re / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else {
        (kr, kth, kph)
    };

    // Hamiltonian and derivatives (using rescaled k)
    let h_val = 0.5 * (c2 * k2 / om2 - n2.re);

    let dhdt_re = -pnpt.re;
    let dhdr_re = -pnpr.re;
    let dhdth_re = -pnpth.re;
    let dhdph_re = -pnpph.re;
    let dhdom_re = -nnp.re / om;
    let dhdkr_re = c2 / om2 * new_kr - C / om * pnpvr;
    let dhdkth_re = c2 / om2 * new_kth - C / om * pnpvth;
    let dhdkph_re = c2 / om2 * new_kph - C / om * pnpvph;

    RindexResult {
        n2_re: n2.re, n2_im: n2.im,
        h_re: h_val,
        dhdt_re, dhdr_re, dhdth_re, dhdph_re,
        dhdom_re, dhdkr_re, dhdkth_re, dhdkph_re,
        kphpk_re: n2.re, kphpk_im: n2.im,
        space, new_kr, new_kth, new_kph,
    }
}

// ============================================================
// Hamilton's Equations (HAMLTN)
// ============================================================

/// Compute derivatives [dr/dt, dθ/dt, dφ/dt, dkr/dt, dkth/dt, dkph/dt, dphase/dt, dabsorb/dt]
fn hamltn(
    y: &[f64], freq_mhz: f64, ray_mode: f64,
    p: &ModelParams, rstart: bool,
) -> ([f64; 8], bool, f64, f64, f64) {
    let r = y[0];
    let theta = y[1];
    let phi = y[2];
    let kr = y[3];
    let kth = y[4];
    let kph = y[5];

    let sth = theta.sin();
    let rsth = r * sth;

    let ri = compute_rindex(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart);

    let phpom = ri.dhdom_re;
    let phpkr = ri.dhdkr_re;
    let phpkth = ri.dhdkth_re;
    let phpkph = ri.dhdkph_re;

    let new_kr = ri.new_kr;
    let new_kth = ri.new_kth;
    let new_kph = ri.new_kph;

    let (drdt, dthdt, dphdt);

    if phpom != 0.0 {
        drdt = -phpkr / (phpom * C);
        dthdt = if r != 0.0 { -phpkth / (phpom * r * C) } else { 0.0 };
        dphdt = if rsth != 0.0 { -phpkph / (phpom * rsth * C) } else { 0.0 };
    } else {
        drdt = 0.0;
        dthdt = 0.0;
        dphdt = 0.0;
    }

    let dkrdt = if phpom != 0.0 {
        ri.dhdr_re / (phpom * C) + new_kth * dthdt + new_kph * sth * dphdt
    } else { 0.0 };

    let dkthdt = if phpom != 0.0 && r != 0.0 {
        ri.dhdth_re / (phpom * C) - (new_kth * drdt + new_kph * r * theta.cos() * dphdt) / r
    } else { 0.0 };

    let dkphdt = if phpom != 0.0 && rsth != 0.0 {
        let mut v = ri.dhdph_re / (phpom * C) - new_kph * sth * drdt / rsth;
        v -= new_kph * r * theta.cos() * dthdt / rsth;
        v
    } else { 0.0 };

    // Phase path
    let d_phase = if phpom != 0.0 {
        let om = PIT2 * 1.0e6 * freq_mhz;
        ri.kphpk_re / phpom / om
    } else { 0.0 };

    // Absorption
    let d_absorb = if phpom != 0.0 {
        let om = PIT2 * 1.0e6 * freq_mhz;
        let k2 = new_kr * new_kr + new_kth * new_kth + new_kph * new_kph;
        if k2 > 0.0 {
            let kay2i = om * om / (C * C) * ri.n2_im;
            10.0 / LOGTEN * ri.kphpk_im * kay2i / k2 / phpom / C
        } else { 0.0 }
    } else { 0.0 };

    let derivs = [drdt, dthdt, dphdt, dkrdt, dkthdt, dkphdt, d_phase, d_absorb];
    (derivs, ri.space, new_kr, new_kth, new_kph)
}

// ============================================================
// RK4/Adams-Moulton Integrator (RKAM)
// ============================================================

const NN: usize = 8;

struct IntegratorState {
    y: [f64; NN],
    dydt: [f64; NN],
    yu: [[f64; NN]; 6],
    fv: [[f64; NN]; 6],
    xv: [f64; 6],
    t: f64,
    step: f64,
    mm: usize,
    ll: usize,
    mode: usize,
    alpha: f64,
    epm: f64,
    e1max: f64,
    e1min: f64,
    e2max: f64,
    e2min: f64,
    fact: f64,
}

impl IntegratorState {
    fn new(y0: &[f64; NN], t0: f64, step: f64, mode: usize,
           e1max: f64, e1min: f64, e2max: f64, e2min: f64, fact: f64) -> Self {
        let mut s = Self {
            y: *y0,
            dydt: [0.0; NN],
            yu: [[0.0; NN]; 6],
            fv: [[0.0; NN]; 6],
            xv: [0.0; 6],
            t: t0,
            step,
            mm: 1,
            ll: 1,
            mode,
            alpha: t0,
            epm: 0.0,
            e1max,
            e1min: if e1min <= 0.0 { e1max / 55.0 } else { e1min },
            e2max,
            e2min,
            fact: if fact <= 0.0 { 0.5 } else { fact },
        };
        if mode == 1 { s.mm = 4; }
        s.xv[s.mm] = t0;
        for i in 0..NN {
            s.yu[s.mm][i] = y0[i];
        }
        s
    }
}

fn rk4_step(
    s: &mut IntegratorState,
    freq_mhz: f64, ray_mode: f64, p: &ModelParams,
) {
    let bet = [0.5, 0.5, 1.0, 0.0];
    let mut dely = [[0.0f64; NN]; 4];
    let mm = s.mm;

    for k in 0..4 {
        for i in 0..NN {
            dely[k][i] = s.step * s.fv[mm][i];
            s.y[i] = s.yu[mm][i] + bet[k] * dely[k][i];
        }
        s.t = bet[k] * s.step + s.xv[mm];
        let (d, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
        s.dydt = d;
        for i in 0..NN {
            s.fv[mm][i] = d[i];
        }
    }

    for i in 0..NN {
        let delta = (dely[0][i] + 2.0 * dely[1][i] + 2.0 * dely[2][i] + dely[3][i]) / 6.0;
        s.yu[mm + 1][i] = s.yu[mm][i] + delta;
    }
    s.mm += 1;
    s.xv[s.mm] = s.xv[s.mm - 1] + s.step;
    for i in 0..NN { s.y[i] = s.yu[s.mm][i]; }
    s.t = s.xv[s.mm];

    let (d, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d;

    if s.mode == 1 {
        exit_routine(s);
        return;
    }

    for i in 0..NN { s.fv[s.mm][i] = d[i]; }

    if s.mm <= 3 {
        rk4_step(s, freq_mhz, ray_mode, p);
        return;
    }

    am_step(s, freq_mhz, ray_mode, p);
}

fn am_step(
    s: &mut IntegratorState,
    freq_mhz: f64, ray_mode: f64, p: &ModelParams,
) {
    let mut dely1 = [0.0f64; NN];

    // Predictor (Adams-Bashforth)
    for i in 0..NN {
        let delta = s.step * (55.0 * s.fv[4][i] - 59.0 * s.fv[3][i]
            + 37.0 * s.fv[2][i] - 9.0 * s.fv[1][i]) / 24.0;
        s.y[i] = s.yu[4][i] + delta;
        dely1[i] = s.y[i];
    }

    s.t = s.xv[4] + s.step;
    let (d, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d;
    s.xv[5] = s.t;

    // Corrector (Adams-Moulton)
    for i in 0..NN {
        let delta = s.step * (9.0 * d[i] + 19.0 * s.fv[4][i]
            - 5.0 * s.fv[3][i] + s.fv[2][i]) / 24.0;
        s.yu[5][i] = s.yu[4][i] + delta;
        s.y[i] = s.yu[5][i];
    }

    let (d2, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d2;

    if s.mode <= 2 {
        exit_routine(s);
        return;
    }

    // Error analysis (mode 3)
    let mut sse = 0.0f64;
    for i in 0..NN {
        let mut epsil = 8.0 * (s.y[i] - dely1[i]).abs();
        if s.y[i].abs() > 1.0e-8 {
            epsil /= s.y[i].abs();
        }
        if sse < epsil { sse = epsil; }
    }

    if s.e1max <= sse {
        if s.step.abs() <= s.e2min {
            exit_routine(s);
            return;
        }
        s.ll = 1;
        s.mm = 1;
        s.step *= s.fact;
        // Reinit from current y
        for i in 0..NN {
            s.yu[1][i] = s.y[i];
            s.fv[1][i] = s.dydt[i];
        }
        s.xv[1] = s.t;
        rk4_step(s, freq_mhz, ray_mode, p);
        return;
    }

    if s.ll <= 1 || sse >= s.e1min || s.e2max <= s.step.abs() {
        exit_routine(s);
        return;
    }

    // Double step
    s.ll = 2;
    s.mm = 3;
    s.xv[2] = s.xv[3];
    s.xv[3] = s.xv[5];
    for i in 0..NN {
        s.fv[2][i] = s.fv[3][i];
        s.fv[3][i] = s.dydt[i];
        s.yu[2][i] = s.yu[3][i];
        s.yu[3][i] = s.yu[5][i];
    }
    s.step *= 2.0;
    rk4_step(s, freq_mhz, ray_mode, p);
}

fn exit_routine(s: &mut IntegratorState) {
    s.ll = 2;
    s.mm = 4;

    for k in 1..4 {
        s.xv[k] = s.xv[k + 1];
        for i in 0..NN {
            s.fv[k][i] = s.fv[k + 1][i];
            s.yu[k][i] = s.yu[k + 1][i];
        }
    }
    s.xv[4] = s.xv[5];
    for i in 0..NN {
        s.fv[4][i] = s.dydt[i];
        s.yu[4][i] = s.yu[5][i];
    }

    if s.mode <= 2 { return; }
    let e = (s.xv[4] - s.alpha).abs();
    s.epm = s.epm.max(e);
}

// ============================================================
// Full Ray Trace (TRACE + NITIAL)
// ============================================================

/// A point along the ray path
struct TracePoint {
    step: usize,
    t: f64,
    height_km: f64,
    lat_deg: f64,
    lon_deg: f64,
    ground_range_km: f64,
    group_path: f64,
    phase_path: f64,
    absorption: f64,
}

/// Result of tracing one ray
struct TraceResult {
    points: Vec<TracePoint>,
    max_height: f64,
    ground_range_km: f64,
    returned_to_ground: bool,
    n_steps: usize,
}

fn trace_ray(
    freq_mhz: f64, ray_mode: f64,
    elevation_deg: f64, azimuth_deg: f64,
    tx_lat_deg: f64,
    int_mode: usize, step_size: f64, max_steps: usize,
    e1max: f64, e1min: f64, e2max: f64,
    p: &ModelParams,
    print_every: usize,
) -> TraceResult {
    let elev_rad = elevation_deg * PI / 180.0;
    let az_rad = azimuth_deg * PI / 180.0;

    // Initial state
    let r0 = p.earth_r;
    let theta0 = PID2 - tx_lat_deg * PI / 180.0;
    let phi0 = 0.0;
    let degs = 180.0 / PI;

    // Helper: ground range in km from initial position
    let ground_range = |theta: f64, phi: f64| -> f64 {
        let cos_ang = theta0.cos() * theta.cos() + theta0.sin() * theta.sin() * (phi - phi0).cos();
        p.earth_r * cos_ang.clamp(-1.0, 1.0).acos()
    };

    let kr0 = elev_rad.sin();
    let kth0 = elev_rad.cos() * (PI - az_rad).cos();
    let kph0 = elev_rad.cos() * (PI - az_rad).sin();

    // First call: compute derivatives and rescale k
    let mut y = [r0, theta0, phi0, kr0, kth0, kph0, 0.0, 0.0];
    let (d0, _, new_kr, new_kth, new_kph) = hamltn(&y, freq_mhz, ray_mode, p, true);
    y[3] = new_kr;
    y[4] = new_kth;
    y[5] = new_kph;

    // Init integrator
    let mut state = IntegratorState::new(
        &y, 0.0, step_size, int_mode,
        e1max, e1min, e2max, 1.0e-8, 0.5,
    );

    // Store initial derivatives
    let (d_init, _, _, _, _) = hamltn(&state.y, freq_mhz, ray_mode, p, false);
    state.dydt = d_init;
    for i in 0..NN {
        state.fv[state.mm][i] = d_init[i];
    }

    let mut result = TraceResult {
        points: Vec::with_capacity(max_steps / print_every + 5),
        max_height: 0.0,
        ground_range_km: 0.0,
        returned_to_ground: false,
        n_steps: 0,
    };

    result.points.push(TracePoint {
        step: 0, t: 0.0, height_km: 0.0,
        lat_deg: tx_lat_deg, lon_deg: 0.0,
        ground_range_km: 0.0, group_path: 0.0,
        phase_path: 0.0, absorption: 0.0,
    });

    let mut went_up = false;

    for step_num in 1..=max_steps {
        // One integrator step
        if state.mm < 4 || state.mode == 1 {
            rk4_step(&mut state, freq_mhz, ray_mode, p);
        } else {
            am_step(&mut state, freq_mhz, ray_mode, p);
        }

        let h = state.y[0] - p.earth_r;
        if h > result.max_height { result.max_height = h; }
        if h > 10.0 { went_up = true; }
        if h.is_nan() || h.abs() > 50000.0 { break; }

        let ground = went_up && h < 0.0;
        if ground { result.returned_to_ground = true; }

        if step_num % print_every == 0 || ground {
            let theta = state.y[1];
            let phi = state.y[2];
            let lat = (PID2 - theta) * degs;
            let lon = phi * degs;
            let gr = ground_range(theta, phi);
            // Group path = integral of (c/vg) ds ≈ phase_path for simple cases
            let gp = state.y[6]; // close to group path for non-dispersive
            result.points.push(TracePoint {
                step: step_num,
                t: state.t,
                height_km: h,
                lat_deg: lat,
                lon_deg: lon,
                ground_range_km: gr,
                group_path: gp,
                phase_path: state.y[6],
                absorption: state.y[7],
            });
            if ground {
                result.ground_range_km = gr;
            }
        }

        result.n_steps = step_num;
        if ground { break; }
    }

    result
}

// ============================================================
// PyO3 Bindings
// ============================================================

/// Trace a single ray through the ionosphere (called from Python).
///
/// Returns a dict with: max_height, returned_to_ground, n_steps, points
#[pyfunction]
#[pyo3(signature = (
    freq_mhz, ray_mode, elevation_deg, azimuth_deg, tx_lat_deg,
    int_mode, step_size, max_steps, e1max, e1min, e2max,
    earth_r, fc, hm, sh, alpha, ed_a, ed_b, ed_c, ed_e,
    fh, nu1, h1, a1, nu2, h2, a2,
    print_every=10, ed_model=0, mag_model=0, col_model=0, ym=100.0,
    rindex_model=0, dip=0.0, fc2=0.0, hm2=0.0, sh2=0.0, chi=3.0,
    pert_model=0, p1=0.0, p2=0.0, p3=0.0, p4=0.0, p5=0.0,
    p6=0.0, p7=0.0, p8=0.0, p9=0.0,
    epoch_year=2025.0
))]
fn trace_ray_py(
    py: Python<'_>,
    freq_mhz: f64, ray_mode: f64,
    elevation_deg: f64, azimuth_deg: f64, tx_lat_deg: f64,
    int_mode: usize, step_size: f64, max_steps: usize,
    e1max: f64, e1min: f64, e2max: f64,
    earth_r: f64,
    fc: f64, hm: f64, sh: f64, alpha: f64,
    ed_a: f64, ed_b: f64, ed_c: f64, ed_e: f64,
    fh: f64,
    nu1: f64, h1: f64, a1: f64,
    nu2: f64, h2: f64, a2: f64,
    print_every: usize,
    ed_model: u8, mag_model: u8, col_model: u8,
    ym: f64,
    rindex_model: u8, dip: f64,
    fc2: f64, hm2: f64, sh2: f64, chi: f64,
    pert_model: u8,
    p1: f64, p2: f64, p3: f64, p4: f64, p5: f64,
    p6: f64, p7: f64, p8: f64, p9: f64,
    epoch_year: f64,
) -> PyResult<PyObject> {
    let params = ModelParams {
        earth_r,
        ed_model, mag_model, col_model, rindex_model,
        fc, hm, sh, alpha,
        ed_a, ed_b, ed_c, ed_e,
        ym, fc2, hm2, sh2, chi,
        fh, dip, epoch_year,
        nu1, h1, a1, nu2, h2, a2,
        pert_model,
        p1, p2, p3, p4, p5, p6, p7, p8, p9,
    };

    let result = trace_ray(
        freq_mhz, ray_mode, elevation_deg, azimuth_deg, tx_lat_deg,
        int_mode, step_size, max_steps, e1max, e1min, e2max,
        &params, print_every,
    );

    let dict = pyo3::types::PyDict::new(py);
    dict.set_item("max_height", result.max_height)?;
    dict.set_item("ground_range_km", result.ground_range_km)?;
    dict.set_item("returned_to_ground", result.returned_to_ground)?;
    dict.set_item("n_steps", result.n_steps)?;

    let points_list = pyo3::types::PyList::empty(py);
    for pt in &result.points {
        let pt_dict = pyo3::types::PyDict::new(py);
        pt_dict.set_item("step", pt.step)?;
        pt_dict.set_item("t", pt.t)?;
        pt_dict.set_item("height_km", pt.height_km)?;
        pt_dict.set_item("lat_deg", pt.lat_deg)?;
        pt_dict.set_item("lon_deg", pt.lon_deg)?;
        pt_dict.set_item("ground_range_km", pt.ground_range_km)?;
        pt_dict.set_item("group_path", pt.group_path)?;
        pt_dict.set_item("phase_path", pt.phase_path)?;
        pt_dict.set_item("absorption", pt.absorption)?;
        points_list.append(pt_dict)?;
    }
    dict.set_item("points", points_list)?;

    Ok(dict.into())
}

/// A Python module implemented in Rust.
#[pymodule]
fn raytrace_core(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(trace_ray_py, m)?)?;
    Ok(())
}
