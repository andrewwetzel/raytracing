use crate::params::*;

/// Result of magnetic field computation at a point.
#[non_exhaustive]
pub struct MagneticFieldResult {
    /// Normalized gyrofrequency Y = fH/f.
    pub y: f64,
    /// ∂Y/∂r.
    pub dydr: f64,
    /// ∂Y/∂θ.
    pub dydth: f64,
    /// ∂Y/∂φ.
    pub dydph: f64,
    /// Radial component of Y.
    pub yr: f64,
    /// Theta component of Y.
    pub yth: f64,
    /// Phi component of Y.
    pub yph: f64,
    /// ∂Yr/∂r.
    pub dyrdr: f64,
    /// ∂Yr/∂θ.
    pub dyrdth: f64,
    /// ∂Yr/∂φ.
    pub dyrdph: f64,
    /// ∂Yθ/∂r.
    pub dythdr: f64,
    /// ∂Yθ/∂θ.
    pub dythdth: f64,
    /// ∂Yθ/∂φ.
    pub dythdph: f64,
    /// ∂Yφ/∂r.
    pub dyphdr: f64,
    /// ∂Yφ/∂θ.
    pub dyphdth: f64,
    /// ∂Yφ/∂φ.
    pub dyphdph: f64,
}

/// Dispatch to selected magnetic field model.
pub fn compute_mag(
    r: f64,
    theta: f64,
    phi: f64,
    freq_mhz: f64,
    p: &ModelParams,
) -> MagneticFieldResult {
    match p.mag_model {
        MagneticFieldModel::Constant => consty(r, theta, phi, freq_mhz, p),
        MagneticFieldModel::Cubic => cubey(r, theta, phi, freq_mhz, p),
        MagneticFieldModel::Igrf14 => harmony(r, theta, phi, freq_mhz, p),
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
        y,
        dydr,
        dydth,
        dydph: 0.0,
        yr,
        yth,
        yph: 0.0,
        dyrdr,
        dyrdth,
        dyrdph: 0.0,
        dythdr,
        dythdth,
        dythdph: 0.0,
        dyphdr: 0.0,
        dyphdth: 0.0,
        dyphdph: 0.0,
    }
}

/// Constant field along radial (CONSTY)
fn consty(_r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> MagneticFieldResult {
    let y = p.fh / freq_mhz;
    MagneticFieldResult {
        y,
        dydr: 0.0,
        dydth: 0.0,
        dydph: 0.0,
        yr: y,
        yth: 0.0,
        yph: 0.0,
        dyrdr: 0.0,
        dyrdth: 0.0,
        dyrdph: 0.0,
        dythdr: 0.0,
        dythdth: 0.0,
        dythdph: 0.0,
        dyphdr: 0.0,
        dyphdth: 0.0,
        dyphdph: 0.0,
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
        y,
        dydr,
        dydth: 0.0,
        dydph: 0.0,
        yr,
        yth,
        yph: 0.0,
        dyrdr,
        dyrdth: 0.0,
        dyrdph: 0.0,
        dythdr,
        dythdth: 0.0,
        dythdph: 0.0,
        dyphdr: 0.0,
        dyphdth: 0.0,
        dyphdph: 0.0,
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
    let idx = |n: usize, m: usize| -> usize { n * (n + 1) / 2 - 1 + m };

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
                * (2.0 * nf - 1.0).sqrt()
                * pp[n - 2][m];
            pp[n][m] = (a - b) / ((nf + mf) * (nf - mf)).sqrt();
            dp[n][m] =
                nf * costh * pp[n][m] / sinth - (nf * nf - mf * mf).sqrt() * pp[n - 1][m] / sinth;
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
            let d2p =
                -nf * (nf + 1.0) * p_nm + mf * mf / (sinth * sinth) * p_nm + costh / sinth * dp_nm;
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
        y,
        dydr,
        dydth,
        dydph,
        yr,
        yth,
        yph,
        dyrdr,
        dyrdth,
        dyrdph,
        dythdr,
        dythdth,
        dythdph,
        dyphdr,
        dyphdth,
        dyphdph,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    // Tests for magnetic field models

    const EPS: f64 = 1e-10;

    fn default_params() -> ModelParams {
        ModelParams::default()
    }

    // ---- DIPOLY (default) ----

    #[test]
    fn test_dipoly_at_equator() {
        let p = default_params(); // fh=0.8, freq=10
        let r = EARTH_RADIUS + 250.0;
        let mag = compute_mag(r, PID2, 0.0, 10.0, &p);
        assert!(mag.y > 0.0, "DIPOLY |Y| should be positive");
        assert!(
            mag.yr.abs() < EPS,
            "DIPOLY yr at equator (cosθ=0) should be ~0"
        );
        assert!(
            mag.yth > 0.0,
            "DIPOLY yθ at equator should be positive (sinθ=1)"
        );
    }

    #[test]
    fn test_dipoly_at_pole() {
        let p = default_params();
        let r = EARTH_RADIUS + 250.0;
        let mag = compute_mag(r, 0.01, 0.0, 10.0, &p); // near north pole (θ ≈ 0)
        assert!(mag.y > 0.0, "DIPOLY |Y| at pole should be positive");
        assert!(
            mag.yr.abs() > mag.yth.abs(),
            "DIPOLY yr should dominate at pole"
        );
    }

    #[test]
    fn test_dipoly_decreases_with_altitude() {
        let p = default_params();
        let mag_low = compute_mag(EARTH_RADIUS + 100.0, PID2, 0.0, 10.0, &p);
        let mag_high = compute_mag(EARTH_RADIUS + 500.0, PID2, 0.0, 10.0, &p);
        assert!(
            mag_low.y > mag_high.y,
            "Dipole field should decrease with altitude"
        );
    }

    #[test]
    fn test_dipoly_r_cubed_scaling() {
        let p = default_params();
        let r1 = EARTH_RADIUS + 200.0;
        let r2 = EARTH_RADIUS + 400.0;
        let mag1 = compute_mag(r1, PID2, 0.0, 10.0, &p);
        let mag2 = compute_mag(r2, PID2, 0.0, 10.0, &p);
        // At equator, y = fh * (Re/r)^3 / freq * sin(θ)
        // So y1/y2 = (r2/r1)^3
        let expected_ratio = (r2 / r1).powi(3);
        let actual_ratio = mag1.y / mag2.y;
        assert!(
            (actual_ratio - expected_ratio).abs() / expected_ratio < 0.01,
            "Dipole should follow r^-3: expected ratio {}, got {}",
            expected_ratio,
            actual_ratio
        );
    }

    // ---- CONSTY ----

    #[test]
    fn test_consty_constant() {
        let mut p = default_params();
        p.mag_model = crate::params::MagneticFieldModel::Constant;
        let mag1 = compute_mag(EARTH_RADIUS + 100.0, PID2, 0.0, 10.0, &p);
        let mag2 = compute_mag(EARTH_RADIUS + 500.0, 1.0, 1.0, 10.0, &p);
        assert!(
            (mag1.y - mag2.y).abs() < EPS,
            "CONSTY should be constant everywhere"
        );
        assert_eq!(mag1.dydr, 0.0, "CONSTY dydr should be 0");
        assert_eq!(mag1.dydth, 0.0, "CONSTY dydth should be 0");
    }

    // ---- CUBEY ----

    #[test]
    fn test_cubey() {
        let mut p = default_params();
        p.mag_model = crate::params::MagneticFieldModel::Cubic;
        p.dip = 0.5; // ~29° dip angle
        let mag = compute_mag(EARTH_RADIUS + 250.0, PID2, 0.0, 10.0, &p);
        assert!(mag.y > 0.0, "CUBEY should give positive |Y|");
        assert!(mag.yr.abs() > 0.0, "CUBEY with non-zero dip should have yr");
        assert!(
            mag.yth.abs() > 0.0,
            "CUBEY with non-zero dip should have yth"
        );
    }

    // ---- HARMONY (IGRF-14) ----

    #[test]
    fn test_harmony_gives_reasonable_field() {
        let mut p = default_params();
        p.mag_model = crate::params::MagneticFieldModel::Igrf14;
        p.epoch_year = 2025.0;
        let r = EARTH_RADIUS + 200.0; // 200 km altitude
        let mag = compute_mag(r, PID2, 0.0, 10.0, &p);
        assert!(mag.y > 0.0, "HARMONY should give positive |Y|");
        assert!(
            mag.y.is_finite(),
            "HARMONY Y should be finite, got {}",
            mag.y
        );
        // Field should have non-zero derivatives at this altitude
        assert!(mag.dydr.is_finite(), "HARMONY dydr should be finite");
    }

    #[test]
    fn test_harmony_epoch_interpolation() {
        let mut p = default_params();
        p.mag_model = crate::params::MagneticFieldModel::Igrf14;
        p.epoch_year = 2025.0;
        let mag_2025 = compute_mag(EARTH_RADIUS, PID2, 0.0, 10.0, &p);
        p.epoch_year = 2030.0;
        let mag_2030 = compute_mag(EARTH_RADIUS, PID2, 0.0, 10.0, &p);
        // Field should be slightly different at different epochs
        assert!(
            (mag_2025.y - mag_2030.y).abs() > 1e-6,
            "HARMONY at different epochs should differ"
        );
    }

    #[test]
    fn test_harmony_phi_dependence() {
        let mut p = default_params();
        p.mag_model = crate::params::MagneticFieldModel::Igrf14;
        let mag_0 = compute_mag(EARTH_RADIUS + 200.0, 1.0, 0.0, 10.0, &p);
        let mag_pi = compute_mag(EARTH_RADIUS + 200.0, 1.0, std::f64::consts::PI, 10.0, &p);
        // IGRF has phi dependence (unlike dipole)
        assert!(
            (mag_0.y - mag_pi.y).abs() > 1e-6,
            "HARMONY should have longitude dependence"
        );
    }

    // ---- All models produce finite values ----

    #[test]
    fn test_all_mag_models_finite() {
        for model in [
            MagneticFieldModel::Constant,
            MagneticFieldModel::Cubic,
            MagneticFieldModel::Igrf14,
            MagneticFieldModel::Dipole,
        ] {
            let mut p = default_params();
            p.mag_model = model;
            p.dip = 0.5;
            let mag = compute_mag(EARTH_RADIUS + 200.0, 1.0, 0.5, 10.0, &p);
            assert!(mag.y.is_finite(), "Mag model {:?} y not finite", model);
            assert!(
                mag.dydr.is_finite(),
                "Mag model {:?} dydr not finite",
                model
            );
            assert!(mag.yr.is_finite(), "Mag model {:?} yr not finite", model);
            assert!(mag.yth.is_finite(), "Mag model {:?} yth not finite", model);
        }
    }
}
