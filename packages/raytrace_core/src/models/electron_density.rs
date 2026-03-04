use crate::params::*;

/// Result of electron density computation at a point.
#[non_exhaustive]
pub struct ElectronDensityResult {
    /// Normalized electron density X = (fp/f)².
    pub x: f64,
    /// ∂X/∂r.
    pub dxdr: f64,
    /// ∂X/∂θ.
    pub dxdth: f64,
    /// ∂X/∂φ.
    pub dxdph: f64,
    /// ∂X/∂t (time derivative, usually 0).
    pub dxdt: f64,
}

/// Dispatch to the selected electron density model, then apply perturbation.
pub fn compute_ed(r: f64, theta: f64, phi: f64, freq_mhz: f64, p: &ModelParams) -> ElectronDensityResult {
    let mut ed = match p.ed_model {
        ElectronDensityModel::Elect1 => elect1_ed(r, theta, phi, freq_mhz, p),
        ElectronDensityModel::Linear => linear(r, theta, phi, freq_mhz, p),
        ElectronDensityModel::QuasiParabolic => qparab(r, theta, phi, freq_mhz, p),
        ElectronDensityModel::VarChapman => vchapx(r, theta, phi, freq_mhz, p),
        ElectronDensityModel::DualChapman => dchapt(r, theta, phi, freq_mhz, p),
        _ => chapx(r, theta, phi, freq_mhz, p),
    };
    // Apply perturbation modifier (multiplicative)
    match p.pert_model {
        PerturbationModel::Torus => apply_torus(&mut ed, r, theta, phi, p),
        PerturbationModel::Trough => apply_trough(&mut ed, r, theta, phi, p),
        PerturbationModel::Shock => apply_shock(&mut ed, r, theta, phi, p),
        PerturbationModel::Bulge => apply_bulge(&mut ed, r, theta, phi, freq_mhz, p),
        PerturbationModel::Exponential => apply_expx_pert(&mut ed, r, p),
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
    let _dterm_dr = rm / den - num * rm / (den * den * r); // simplified
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
