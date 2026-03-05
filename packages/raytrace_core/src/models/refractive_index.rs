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

#[cfg(test)]
mod tests {
    use super::*;
    // Tests for refractive index models (Appleton-Hartree variants)

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
}
