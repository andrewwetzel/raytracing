use crate::params::*;
use crate::models::refractive_index::compute_rindex;

/// Compute derivatives [dr/dt, dθ/dt, dφ/dt, dkr/dt, dkth/dt, dkph/dt, dphase/dt, dabsorb/dt]
pub fn hamltn(
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
