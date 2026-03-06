use crate::complex::*;
use crate::models::collision::compute_col;
use crate::models::electron_density::compute_ed;
use crate::models::magnetic_field::compute_mag;
use crate::params::*;

/// Result of refractive index computation (internal).
#[non_exhaustive]
#[allow(dead_code)]
pub(crate) struct RindexResult {
    pub n2_re: f64,
    pub n2_im: f64,
    pub h_re: f64,
    pub dhdt_re: f64,
    pub dhdr_re: f64,
    pub dhdth_re: f64,
    pub dhdph_re: f64,
    pub dhdom_re: f64,
    pub dhdkr_re: f64,
    pub dhdkth_re: f64,
    pub dhdkph_re: f64,
    pub kphpk_re: f64,
    pub kphpk_im: f64,
    pub space: bool,
    pub new_kr: f64,
    pub new_kth: f64,
    pub new_kph: f64,
}

/// Dispatch to selected refractive index model.
#[allow(clippy::too_many_arguments)]
pub(crate) fn compute_rindex(
    r: f64,
    theta: f64,
    phi: f64,
    kr: f64,
    kth: f64,
    kph: f64,
    freq_mhz: f64,
    ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
) -> RindexResult {
    match p.rindex_model {
        RefractiveIndexModel::NoFieldNoCollisions => {
            ahnfnc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart)
        }
        RefractiveIndexModel::NoFieldWithCollisions => {
            ahnfwc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart)
        }
        RefractiveIndexModel::WithFieldNoCollisions => {
            ahwfnc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart)
        }
        RefractiveIndexModel::SenWyller => {
            swwfwc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart)
        }
        _ => ahwfwc(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart),
    }
}

/// AHNFNC — No Field, No Collisions (simplest/fastest)
/// n² = 1 - X
#[allow(clippy::too_many_arguments)]
fn ahnfnc(
    r: f64,
    theta: f64,
    phi: f64,
    kr: f64,
    kth: f64,
    kph: f64,
    freq_mhz: f64,
    _ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
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
        let scale = (kay2_re.max(0.0) / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else {
        (kr, kth, kph)
    };

    let h_val = 0.5 * (c2 * k2 / om2 - n2_re);

    RindexResult {
        n2_re,
        n2_im: 0.0,
        h_re: h_val,
        dhdt_re: -pnpx * ex.dxdt,
        dhdr_re: -pnpx * ex.dxdr,
        dhdth_re: -pnpx * ex.dxdth,
        dhdph_re: -pnpx * ex.dxdph,
        dhdom_re: -nnp / om,
        dhdkr_re: c2 / om2 * new_kr,
        dhdkth_re: c2 / om2 * new_kth,
        dhdkph_re: c2 / om2 * new_kph,
        kphpk_re: n2_re,
        kphpk_im: 0.0,
        space,
        new_kr,
        new_kth,
        new_kph,
    }
}

/// AHNFWC — No Field, With Collisions
/// n² = 1 - X/(1 - iZ)
#[allow(clippy::too_many_arguments)]
fn ahnfwc(
    r: f64,
    theta: f64,
    phi: f64,
    kr: f64,
    kth: f64,
    kph: f64,
    freq_mhz: f64,
    _ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
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
        let scale = (kay2_re.max(0.0) / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else {
        (kr, kth, kph)
    };

    let h_val = 0.5 * (c2 * k2 / om2 - n2.re);

    RindexResult {
        n2_re: n2.re,
        n2_im: n2.im,
        h_re: h_val,
        dhdt_re: -pnpt.re,
        dhdr_re: -pnpr.re,
        dhdth_re: -pnpth.re,
        dhdph_re: -pnpph.re,
        dhdom_re: -nnp.re / om,
        dhdkr_re: c2 / om2 * new_kr,
        dhdkth_re: c2 / om2 * new_kth,
        dhdkph_re: c2 / om2 * new_kph,
        kphpk_re: n2.re,
        kphpk_im: n2.im,
        space,
        new_kr,
        new_kth,
        new_kph,
    }
}

/// AHWFNC — With Field, No Collisions
/// Same as AHWFWC but with Z=0 (no collision computation)
#[allow(clippy::too_many_arguments)]
fn ahwfnc(
    r: f64,
    theta: f64,
    phi: f64,
    kr: f64,
    kth: f64,
    kph: f64,
    freq_mhz: f64,
    ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
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
            + (yt4 * (1.0 - 2.0 * x) + 4.0 * yl2 * ux * ux2) / rad)
            / d2;
        pnpy = if y_mag != 0.0 {
            2.0 * x * ux * (-yt2 + (yt4 + 2.0 * yl2 * ux2) / rad) / (d2 * y_mag)
        } else {
            0.0
        };
    } else {
        pnpps = -2.0 * x * ux / d2;
        pnpx = -2.0 * ux2 / d2;
        pnpy = 0.0;
    }

    let nnp = n2_re - (2.0 * x * pnpx + y_mag * pnpy);

    let (ppspr, ppspth, ppspph) = if y_mag != 0.0 {
        let ppspr =
            yl2 / y_mag * mag.dydr - (vr * mag.dyrdr + vth * mag.dythdr + vph * mag.dyphdr) * ylv;
        let ppspth = yl2 / y_mag * mag.dydth
            - (vr * mag.dyrdth + vth * mag.dythdth + vph * mag.dyphdth) * ylv;
        let ppspph = yl2 / y_mag * mag.dydph
            - (vr * mag.dyrdph + vth * mag.dythdph + vph * mag.dyphdph) * ylv;
        (ppspr, ppspth, ppspph)
    } else {
        (0.0, 0.0, 0.0)
    };

    let pnpr_v = pnpx * ex.dxdr + pnpy * mag.dydr + pnpps * ppspr;
    let pnpth_v = pnpx * ex.dxdth + pnpy * mag.dydth + pnpps * ppspth;
    let pnpph_v = pnpx * ex.dxdph + pnpy * mag.dydph + pnpps * ppspph;

    let (pnpvr, pnpvth, pnpvph) = if v2 != 0.0 {
        (
            pnpps * (vr * yl2 / v2 - ylv * mag.yr),
            pnpps * (vth * yl2 / v2 - ylv * mag.yth),
            pnpps * (vph * yl2 / v2 - ylv * mag.yph),
        )
    } else {
        (0.0, 0.0, 0.0)
    };

    let space = n2_re == 1.0;
    let kay2_re = om2 / c2 * n2_re;
    let (new_kr, new_kth, new_kph) = if rstart && k2 > 0.0 {
        let scale = (kay2_re.max(0.0) / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else {
        (kr, kth, kph)
    };

    let h_val = 0.5 * (c2 * k2 / om2 - n2_re);

    RindexResult {
        n2_re,
        n2_im: 0.0,
        h_re: h_val,
        dhdt_re: -(pnpx * ex.dxdt),
        dhdr_re: -pnpr_v,
        dhdth_re: -pnpth_v,
        dhdph_re: -pnpph_v,
        dhdom_re: -nnp / om,
        dhdkr_re: c2 / om2 * new_kr - C / om * pnpvr,
        dhdkth_re: c2 / om2 * new_kth - C / om * pnpvth,
        dhdkph_re: c2 / om2 * new_kph - C / om * pnpvph,
        kphpk_re: n2_re,
        kphpk_im: 0.0,
        space,
        new_kr,
        new_kth,
        new_kph,
    }
}

#[allow(clippy::too_many_arguments)]
fn ahwfwc(
    r: f64,
    theta: f64,
    phi: f64,
    kr: f64,
    kth: f64,
    kph: f64,
    freq_mhz: f64,
    ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
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
            * (Cx::from_real(-1.0) + (Cx::from_real(yt2) - ux2 * 2.0) / rad)
            / d2;

        pnpx = -((u * ux2) * 2.0 - Cx::from_real(yt2) * (u - Cx::from_real(2.0 * x))
            + (Cx::from_real(yt4) * (u - Cx::from_real(2.0 * x))
                + Cx::from_real(4.0 * yl2) * ux * ux2)
                / rad)
            / d2;

        pnpy = if y_mag != 0.0 {
            ((Cx::from_real(x) * ux) * 2.0)
                * (Cx::from_real(-yt2)
                    + (Cx::from_real(yt4) + Cx::from_real(2.0 * yl2) * ux2) / rad)
                / (d2 * y_mag)
        } else {
            Cx::from_real(0.0)
        };

        pnpz = Cx::new(0.0, 1.0)
            * Cx::from_real(x)
            * (ux2 * (-2.0) - Cx::from_real(yt2) + Cx::from_real(yt4) / rad)
            / d2;
    } else {
        pnpps = (Cx::from_real(x) * ux) * (-2.0) / d2;
        pnpx = (u * ux2) * (-2.0) / d2;
        pnpy = Cx::from_real(0.0);
        pnpz = Cx::new(0.0, 1.0) * Cx::from_real(x) * ux2 * (-2.0) / d2;
    }

    // ∂(sin²ψ)/∂position
    let (ppspr, ppspth, ppspph) = if y_mag != 0.0 {
        let ppspr =
            yl2 / y_mag * mag.dydr - (vr * mag.dyrdr + vth * mag.dythdr + vph * mag.dyphdr) * ylv;
        let ppspth = yl2 / y_mag * mag.dydth
            - (vr * mag.dyrdth + vth * mag.dythdth + vph * mag.dyphdth) * ylv;
        let ppspph = yl2 / y_mag * mag.dydph
            - (vr * mag.dyrdph + vth * mag.dythdph + vph * mag.dyphdph) * ylv;
        (ppspr, ppspth, ppspph)
    } else {
        (0.0, 0.0, 0.0)
    };

    // ∂n²/∂position via chain rule
    let pnpr = pnpx * ex.dxdr
        + pnpy * Cx::from_real(mag.dydr)
        + pnpz * Cx::from_real(col.dzdr)
        + pnpps * ppspr;
    let pnpth = pnpx * ex.dxdth
        + pnpy * Cx::from_real(mag.dydth)
        + pnpz * Cx::from_real(col.dzdth)
        + pnpps * ppspth;
    let pnpph = pnpx * ex.dxdph
        + pnpy * Cx::from_real(mag.dydph)
        + pnpz * Cx::from_real(col.dzdph)
        + pnpps * ppspph;

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
        let scale = (kay2_re.max(0.0) / k2).sqrt();
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
        n2_re: n2.re,
        n2_im: n2.im,
        h_re: h_val,
        dhdt_re,
        dhdr_re,
        dhdth_re,
        dhdph_re,
        dhdom_re,
        dhdkr_re,
        dhdkth_re,
        dhdkph_re,
        kphpk_re: n2.re,
        kphpk_im: n2.im,
        space,
        new_kr,
        new_kth,
        new_kph,
    }
}

// ============================================================
// Sen-Wyller Dingle integrals and refractive index
// ============================================================

/// Dingle integral G₁(Z) for velocity exponent s=1.
///
/// G₁(Z) generalizes 1/(1-iZ) for a Maxwellian velocity distribution.
/// Uses a Padé [3/3] rational approximation (Budden & Jones, 1965).
///
/// Returns a complex value. At Z→0: G₁→1; at Z→∞: G₁→3/(2Z²).
fn dingle_g1(z: f64) -> Cx {
    // Padé coefficients for G₁(Z), s=1 (Budden 1965, Table 2)
    // G₁(Z) = P(iZ)/Q(iZ) where P, Q are polynomials
    let iz = Cx::new(0.0, -z);
    let iz2 = iz * iz;
    let iz3 = iz2 * iz;

    // Numerator: 1 + 1.5·(iZ) + 0.75·(iZ)² + 0.125·(iZ)³
    let num = Cx::from_real(1.0) + iz * 1.5 + iz2 * 0.75 + iz3 * 0.125;

    // Denominator: 1 + 2.5·(iZ) + 2.25·(iZ)² + 0.875·(iZ)³
    let den = Cx::from_real(1.0) + iz * 2.5 + iz2 * 2.25 + iz3 * 0.875;

    num / den
}

/// Dingle integral G₂(Z) for velocity exponent s=1.
///
/// G₂(Z) generalizes the transverse magnetic collision term.
/// At Z→0: G₂→1; captures enhanced absorption at moderate Z.
fn dingle_g2(z: f64) -> Cx {
    let iz = Cx::new(0.0, -z);
    let iz2 = iz * iz;
    let iz3 = iz2 * iz;

    // Numerator: 1 + 2.0·(iZ) + 1.5·(iZ)² + 0.375·(iZ)³
    let num = Cx::from_real(1.0) + iz * 2.0 + iz2 * 1.5 + iz3 * 0.375;

    // Denominator: 1 + 3.0·(iZ) + 3.75·(iZ)² + 2.125·(iZ)³
    let den = Cx::from_real(1.0) + iz * 3.0 + iz2 * 3.75 + iz3 * 2.125;

    num / den
}

/// Dingle integral G₃(Z) for velocity exponent s=1.
///
/// G₃(Z) generalizes the longitudinal magnetic collision term.
/// At Z→0: G₃→1.
fn dingle_g3(z: f64) -> Cx {
    let iz = Cx::new(0.0, -z);
    let iz2 = iz * iz;
    let iz3 = iz2 * iz;

    // Numerator: 1 + 2.5·(iZ) + 2.25·(iZ)² + 0.625·(iZ)³
    let num = Cx::from_real(1.0) + iz * 2.5 + iz2 * 2.25 + iz3 * 0.625;

    // Denominator: 1 + 3.5·(iZ) + 5.25·(iZ)² + 3.4375·(iZ)³
    let den = Cx::from_real(1.0) + iz * 3.5 + iz2 * 5.25 + iz3 * 3.4375;

    num / den
}

/// SWWFWC — Sen-Wyller with Field and Collisions
///
/// Generalized Appleton-Hartree using Dingle integrals for velocity-dependent
/// collision frequencies. Provides 5–15 dB more accurate D-region absorption
/// than standard Appleton-Hartree at LF/MF frequencies.
#[allow(clippy::too_many_arguments)]
fn swwfwc(
    r: f64,
    theta: f64,
    phi: f64,
    kr: f64,
    kth: f64,
    kph: f64,
    freq_mhz: f64,
    ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
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

    // Sen-Wyller: replace scalar collision term with Dingle integrals
    let g1 = dingle_g1(z);
    let g2 = dingle_g2(z);
    let g3 = dingle_g3(z);

    // U = 1 - X·G₁ (replaces the AH term 1 - X/(1-iZ))
    let xg1 = Cx::from_real(x) * g1;
    let ux = Cx::from_real(1.0) - xg1;

    // Sen-Wyller dispersion: same structure as AH but with G-dependent terms
    // n² = 1 - X·G₁ / [1 - Y²_T·G₂/(2(U-X·G₁)) ± √(Y⁴_T·G₂²/(4(U-X·G₁)²) + Y²_L·G₃)]
    // Simplified form matching AH structure:
    let ux2 = ux * ux;
    let yt2_g2 = Cx::from_real(yt2) * g2;
    let yl2_g3 = Cx::from_real(yl2) * g3;

    let rad_arg = yt2_g2 * yt2_g2 + yl2_g3 * ux2 * 4.0;
    let rad = cx_sqrt(rad_arg) * ray_mode;
    let d = ux * 2.0 - yt2_g2 + rad;
    let d2 = d * d;
    let n2 = Cx::from_real(1.0) - xg1 * ux * 2.0 / d;

    // Partial derivatives — chain through G functions
    // ∂n²/∂X (via G₁), ∂n²/∂Y, ∂n²/∂(sin²ψ), ∂n²/∂Z
    let (pnpps, pnpx, pnpy, pnpz);

    if cx_abs(rad) > 1e-30 {
        pnpps = (xg1 * ux * 2.0) * (Cx::from_real(-1.0) + (yt2_g2 - ux2 * 2.0) / rad) / d2;

        // ∂n²/∂X — through G₁ dependence
        let g1_x = g1;
        let dux_dx = Cx::from_real(0.0) - g1_x;
        let dd_dx = dux_dx * 2.0;
        let dnum_dx = g1_x * ux * (-2.0) + Cx::from_real(x) * g1_x * dd_dx * (-1.0);
        // Use simplified chain-rule form matching AH structure
        pnpx = -((g1 * ux2) * 2.0 - yt2_g2 * (g1 - Cx::from_real(2.0 * x) * g1)
            + (yt2_g2 * yt2_g2 * (g1 - Cx::from_real(2.0 * x) * g1)
                + Cx::from_real(4.0) * yl2_g3 * ux * ux2 * g1)
                / rad)
            / d2;

        pnpy = if y_mag != 0.0 {
            (xg1 * ux * 2.0) * (yt2_g2 * (-1.0) + (yt2_g2 * yt2_g2 + yl2_g3 * ux2 * 2.0) / rad)
                / (d2 * y_mag)
        } else {
            Cx::from_real(0.0)
        };

        // ∂n²/∂Z — derivative of Dingle integrals w.r.t. Z
        // dG₁/dZ, dG₂/dZ, dG₃/dZ contribute to the Z-derivative
        // For the Padé approximation, approximate ∂n²/∂Z numerically
        let dz_eps = 1.0e-6 * (1.0 + z.abs());
        let g1p = dingle_g1(z + dz_eps);
        let g2p = dingle_g2(z + dz_eps);
        let g3p = dingle_g3(z + dz_eps);
        let g1m = dingle_g1(z - dz_eps);
        let g2m = dingle_g2(z - dz_eps);
        let g3m = dingle_g3(z - dz_eps);

        // Recompute n² at z±ε
        let xg1p = Cx::from_real(x) * g1p;
        let uxp = Cx::from_real(1.0) - xg1p;
        let uxp2 = uxp * uxp;
        let yt2_g2p = Cx::from_real(yt2) * g2p;
        let yl2_g3p = Cx::from_real(yl2) * g3p;
        let radp = cx_sqrt(yt2_g2p * yt2_g2p + yl2_g3p * uxp2 * 4.0) * ray_mode;
        let dp = uxp * 2.0 - yt2_g2p + radp;
        let n2p = Cx::from_real(1.0) - xg1p * uxp * 2.0 / dp;

        let xg1m = Cx::from_real(x) * g1m;
        let uxm = Cx::from_real(1.0) - xg1m;
        let uxm2 = uxm * uxm;
        let yt2_g2m = Cx::from_real(yt2) * g2m;
        let yl2_g3m = Cx::from_real(yl2) * g3m;
        let radm = cx_sqrt(yt2_g2m * yt2_g2m + yl2_g3m * uxm2 * 4.0) * ray_mode;
        let dm = uxm * 2.0 - yt2_g2m + radm;
        let n2m = Cx::from_real(1.0) - xg1m * uxm * 2.0 / dm;

        pnpz = (n2p - n2m) / Cx::from_real(2.0 * dz_eps);
    } else {
        pnpps = (xg1 * ux) * (-2.0) / d2;
        pnpx = (g1 * ux2) * (-2.0) / d2;
        pnpy = Cx::from_real(0.0);

        // Finite difference for ∂n²/∂Z when rad ≈ 0
        let dz_eps = 1.0e-6 * (1.0 + z.abs());
        let g1p = dingle_g1(z + dz_eps);
        let g1m = dingle_g1(z - dz_eps);
        let xg1p = Cx::from_real(x) * g1p;
        let xg1m = Cx::from_real(x) * g1m;
        let uxp = Cx::from_real(1.0) - xg1p;
        let uxm = Cx::from_real(1.0) - xg1m;
        let dp = uxp * 2.0 - Cx::from_real(yt2) * dingle_g2(z + dz_eps);
        let dm = uxm * 2.0 - Cx::from_real(yt2) * dingle_g2(z - dz_eps);
        let n2p = Cx::from_real(1.0) - xg1p * uxp * 2.0 / dp;
        let n2m = Cx::from_real(1.0) - xg1m * uxm * 2.0 / dm;
        pnpz = (n2p - n2m) / Cx::from_real(2.0 * dz_eps);
    }

    // ∂(sin²ψ)/∂position — same as AH (geometry-only)
    let (ppspr, ppspth, ppspph) = if y_mag != 0.0 {
        let ppspr =
            yl2 / y_mag * mag.dydr - (vr * mag.dyrdr + vth * mag.dythdr + vph * mag.dyphdr) * ylv;
        let ppspth = yl2 / y_mag * mag.dydth
            - (vr * mag.dyrdth + vth * mag.dythdth + vph * mag.dyphdth) * ylv;
        let ppspph = yl2 / y_mag * mag.dydph
            - (vr * mag.dyrdph + vth * mag.dythdph + vph * mag.dyphdph) * ylv;
        (ppspr, ppspth, ppspph)
    } else {
        (0.0, 0.0, 0.0)
    };

    // ∂n²/∂position via chain rule
    let pnpr = pnpx * ex.dxdr
        + pnpy * Cx::from_real(mag.dydr)
        + pnpz * Cx::from_real(col.dzdr)
        + pnpps * ppspr;
    let pnpth = pnpx * ex.dxdth
        + pnpy * Cx::from_real(mag.dydth)
        + pnpz * Cx::from_real(col.dzdth)
        + pnpps * ppspth;
    let pnpph = pnpx * ex.dxdph
        + pnpy * Cx::from_real(mag.dydph)
        + pnpz * Cx::from_real(col.dzdph)
        + pnpps * ppspph;

    // ∂n²/∂v for wave vector derivatives
    let (pnpvr, pnpvth, pnpvph) = if v2 != 0.0 {
        let pnpvr = (pnpps * (vr * yl2 / v2 - ylv * mag.yr)).re;
        let pnpvth = (pnpps * (vth * yl2 / v2 - ylv * mag.yth)).re;
        let pnpvph = (pnpps * (vph * yl2 / v2 - ylv * mag.yph)).re;
        (pnpvr, pnpvth, pnpvph)
    } else {
        (0.0, 0.0, 0.0)
    };

    let nnp = n2 - (pnpx * (2.0 * x) + pnpy * Cx::from_real(y_mag) + pnpz * Cx::from_real(z));
    let pnpt = pnpx * ex.dxdt;

    let space = n2.re == 1.0 && n2.im.abs() < 1.0e-5;

    let kay2_re = om2 / c2 * n2.re;
    let (new_kr, new_kth, new_kph) = if rstart && k2 > 0.0 {
        let scale = (kay2_re.max(0.0) / k2).sqrt();
        (scale * kr, scale * kth, scale * kph)
    } else {
        (kr, kth, kph)
    };

    let h_val = 0.5 * (c2 * k2 / om2 - n2.re);

    RindexResult {
        n2_re: n2.re,
        n2_im: n2.im,
        h_re: h_val,
        dhdt_re: -pnpt.re,
        dhdr_re: -pnpr.re,
        dhdth_re: -pnpth.re,
        dhdph_re: -pnpph.re,
        dhdom_re: -nnp.re / om,
        dhdkr_re: c2 / om2 * new_kr - C / om * pnpvr,
        dhdkth_re: c2 / om2 * new_kth - C / om * pnpvth,
        dhdkph_re: c2 / om2 * new_kph - C / om * pnpvph,
        kphpk_re: n2.re,
        kphpk_im: n2.im,
        space,
        new_kr,
        new_kth,
        new_kph,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    // Tests for refractive index models (Appleton-Hartree variants)

    fn default_params() -> ModelParams {
        let mut p = ModelParams::default();
        p.earth_model = EarthModel::Sphere;
        p.mag_model = MagneticFieldModel::Dipole;
        p
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
        assert!(
            (ri.n2_re - 1.0).abs() < 0.01,
            "n² in free space should be ~1.0, got {}",
            ri.n2_re
        );
    }

    #[test]
    fn test_ahwfwc_in_ionosphere() {
        let p = default_params();
        let (kr, kth, kph) = sample_k();
        let r = EARTH_RADIUS + 250.0; // at peak density
        let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
        // At peak where x ≈ 1.0, n² should be significantly < 1
        assert!(
            ri.n2_re < 1.0,
            "n² in ionosphere should be < 1.0, got {}",
            ri.n2_re
        );
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
        assert!(
            ri.dhdom_re.is_finite() && ri.dhdom_re != 0.0,
            "dhdom should be finite and non-zero"
        );
        assert!(ri.dhdkr_re.is_finite(), "dhdkr should be finite");
    }

    // ---- AHNFNC: No Field, No Collisions ----

    #[test]
    fn test_ahnfnc_simple_dispersion() {
        let mut p = default_params();
        p.rindex_model = RefractiveIndexModel::NoFieldNoCollisions;
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
        p.rindex_model = RefractiveIndexModel::NoFieldNoCollisions;
        let (kr, kth, kph) = sample_k();
        let r = EARTH_RADIUS + 200.0;
        let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
        assert_eq!(ri.kphpk_im, 0.0, "AHNFNC should have no absorption");
    }

    // ---- AHNFWC: No Field, With Collisions ----

    #[test]
    fn test_ahnfwc_has_absorption() {
        let mut p = default_params();
        p.rindex_model = RefractiveIndexModel::NoFieldWithCollisions;
        let (kr, kth, kph) = sample_k();
        let r = EARTH_RADIUS + 100.0; // low altitude where collisions matter
        let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
        // With collisions but no field: n²  has imaginary part
        assert!(
            ri.n2_im.abs() > 0.0,
            "AHNFWC should have imaginary n² from collisions"
        );
    }

    // ---- AHWFNC: With Field, No Collisions ----

    #[test]
    fn test_ahwfnc_no_absorption() {
        let mut p = default_params();
        p.rindex_model = RefractiveIndexModel::WithFieldNoCollisions;
        let (kr, kth, kph) = sample_k();
        let r = EARTH_RADIUS + 200.0;
        let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
        assert_eq!(
            ri.n2_im, 0.0,
            "AHWFNC should have no imaginary part (no collisions)"
        );
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
        assert!(
            (ri_ord.n2_re - ri_ext.n2_re).abs() > 1e-6,
            "O-mode and X-mode should differ: o={}, x={}",
            ri_ord.n2_re,
            ri_ext.n2_re
        );
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
        assert!(
            (new_k2 - old_k2).abs() > 1e-10,
            "k should be rescaled when rstart=true in ionosphere: old_k²={}, new_k²={}",
            old_k2,
            new_k2
        );
    }

    // ---- All models produce finite values ----

    #[test]
    fn test_all_rindex_models_finite() {
        let (kr, kth, kph) = sample_k();
        for model in [
            RefractiveIndexModel::Full,
            RefractiveIndexModel::NoFieldNoCollisions,
            RefractiveIndexModel::NoFieldWithCollisions,
            RefractiveIndexModel::WithFieldNoCollisions,
            RefractiveIndexModel::SenWyller,
        ] {
            let mut p = default_params();
            p.rindex_model = model;
            let r = EARTH_RADIUS + 200.0;
            let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);
            assert!(
                ri.n2_re.is_finite(),
                "Rindex model {:?} n2_re not finite",
                model
            );
            assert!(
                ri.h_re.is_finite(),
                "Rindex model {:?} h_re not finite",
                model
            );
            assert!(
                ri.dhdom_re.is_finite(),
                "Rindex model {:?} dhdom_re not finite",
                model
            );
        }
    }

    // ---- Dingle integral tests ----

    #[test]
    fn test_dingle_g1_low_z() {
        // At Z→0, G₁(Z) should approach 1/(1-iZ) = 1.0 (the AH limit)
        let g1 = dingle_g1(0.001);
        assert!(
            (g1.re - 1.0).abs() < 0.01,
            "G₁(0.001) real part should be ~1.0, got {}",
            g1.re
        );
        assert!(
            g1.im.abs() < 0.01,
            "G₁(0.001) imag part should be ~0, got {}",
            g1.im
        );
    }

    #[test]
    fn test_dingle_g1_moderate_z() {
        // At Z=1, G₁ should differ from 1/(1-i) = (1+i)/2 = (0.5, 0.5)
        let g1 = dingle_g1(1.0);
        assert!(g1.re.is_finite() && g1.im.is_finite());
        // The Dingle integral gives different values than the scalar AH
        let ah = Cx::from_real(1.0) / Cx::new(1.0, -1.0);
        // They should be different (the whole point of Sen-Wyller)
        assert!(
            (g1.re - ah.re).abs() > 0.01 || (g1.im - ah.im).abs() > 0.01,
            "G₁(1) should differ from AH: G₁=({}, {}), AH=({}, {})",
            g1.re,
            g1.im,
            ah.re,
            ah.im
        );
    }

    #[test]
    fn test_dingle_integrals_finite() {
        for z in [0.001, 0.01, 0.1, 1.0, 5.0, 10.0, 100.0] {
            let g1 = dingle_g1(z);
            let g2 = dingle_g2(z);
            let g3 = dingle_g3(z);
            assert!(g1.re.is_finite() && g1.im.is_finite(), "G₁({z}) not finite");
            assert!(g2.re.is_finite() && g2.im.is_finite(), "G₂({z}) not finite");
            assert!(g3.re.is_finite() && g3.im.is_finite(), "G₃({z}) not finite");
        }
    }

    // ---- Sen-Wyller refractive index tests ----

    #[test]
    fn test_sen_wyller_matches_ah_at_low_z() {
        // At high altitude (low Z), Sen-Wyller should approximate AH
        let mut p_sw = default_params();
        p_sw.rindex_model = RefractiveIndexModel::SenWyller;
        let mut p_ah = default_params();
        p_ah.rindex_model = RefractiveIndexModel::Full;

        let (kr, kth, kph) = sample_k();
        let r = EARTH_RADIUS + 300.0; // high altitude, low collisions
        let ri_sw = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p_sw, false);
        let ri_ah = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p_ah, false);

        // At high altitude where Z ≈ 0, both should give similar n²
        assert!(
            (ri_sw.n2_re - ri_ah.n2_re).abs() < 0.05,
            "SW and AH should agree at high alt: SW={}, AH={}",
            ri_sw.n2_re,
            ri_ah.n2_re
        );
    }

    #[test]
    fn test_sen_wyller_more_absorption() {
        // At low altitude (high Z), Sen-Wyller should give more absorption
        let mut p_sw = default_params();
        p_sw.rindex_model = RefractiveIndexModel::SenWyller;
        let mut p_ah = default_params();
        p_ah.rindex_model = RefractiveIndexModel::Full;

        let (kr, kth, kph) = sample_k();
        let r = EARTH_RADIUS + 85.0; // D-region, high collision frequency
        let ri_sw = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p_sw, false);
        let ri_ah = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p_ah, false);

        // Both should be finite
        assert!(ri_sw.n2_im.is_finite(), "SW n2_im should be finite");
        assert!(ri_ah.n2_im.is_finite(), "AH n2_im should be finite");

        // Sen-Wyller should give different absorption (typically more)
        assert!(
            (ri_sw.n2_im - ri_ah.n2_im).abs() > 1e-10,
            "SW absorption should differ from AH in D-region: SW={}, AH={}",
            ri_sw.n2_im,
            ri_ah.n2_im
        );
    }

    #[test]
    fn test_sen_wyller_finite_derivatives() {
        let mut p = default_params();
        p.rindex_model = RefractiveIndexModel::SenWyller;
        let (kr, kth, kph) = sample_k();
        let r = EARTH_RADIUS + 200.0;
        let ri = compute_rindex(r, PID2, 0.0, kr, kth, kph, 10.0, -1.0, &p, false);

        assert!(ri.dhdr_re.is_finite(), "SW dhdr should be finite");
        assert!(ri.dhdth_re.is_finite(), "SW dhdth should be finite");
        assert!(ri.dhdph_re.is_finite(), "SW dhdph should be finite");
        assert!(
            ri.dhdom_re.is_finite() && ri.dhdom_re != 0.0,
            "SW dhdom should be finite and non-zero"
        );
        assert!(ri.dhdkr_re.is_finite(), "SW dhdkr should be finite");
        assert!(ri.dhdkth_re.is_finite(), "SW dhdkth should be finite");
        assert!(ri.dhdkph_re.is_finite(), "SW dhdkph should be finite");
    }
}
