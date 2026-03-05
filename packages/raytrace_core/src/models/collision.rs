use crate::params::*;

/// Result of collision frequency computation at a point.
#[non_exhaustive]
pub struct CollisionResult {
    /// Normalized collision frequency Z = ν/ω.
    pub z: f64,
    /// ∂Z/∂r.
    pub dzdr: f64,
    /// ∂Z/∂θ.
    pub dzdth: f64,
    /// ∂Z/∂φ.
    pub dzdph: f64,
}

/// Dispatch to selected collision model.
pub fn compute_col(
    r: f64,
    theta: f64,
    phi: f64,
    freq_mhz: f64,
    p: &ModelParams,
) -> CollisionResult {
    match p.col_model {
        CollisionModel::Constant => constz(r, theta, phi, freq_mhz, p),
        CollisionModel::SingleExponential => expz(r, theta, phi, freq_mhz, p),
        _ => expz2(r, theta, phi, freq_mhz, p),
    }
}

/// Two-term exponential collision (EXPZ2) — default
fn expz2(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    let h = (r - p.earth_r).max(0.0);
    let omega = PIT2 * freq_mhz * 1.0e6;
    if omega == 0.0 {
        return CollisionResult { z: 0.0, dzdr: 0.0, dzdth: 0.0, dzdph: 0.0 };
    }

    let arg1 = (-p.a1 * (h - p.h1)).clamp(-20.0, 20.0);
    let arg2 = (-p.a2 * (h - p.h2)).clamp(-20.0, 20.0);
    let exp1 = p.nu1 * arg1.exp();
    let exp2 = p.nu2 * arg2.exp();

    let z = (exp1 + exp2) / omega;
    let dzdr = (-p.a1 * exp1 - p.a2 * exp2) / omega;

    CollisionResult {
        z,
        dzdr,
        dzdth: 0.0,
        dzdph: 0.0,
    }
}

/// Constant collision frequency (CONSTZ)
fn constz(_r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    let omega = PIT2 * freq_mhz * 1.0e6;
    let z = if omega != 0.0 { p.nu1 / omega } else { 0.0 };
    CollisionResult {
        z,
        dzdr: 0.0,
        dzdth: 0.0,
        dzdph: 0.0,
    }
}

/// Single exponential collision (EXPZ)
fn expz(r: f64, _theta: f64, _phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    let h = (r - p.earth_r).max(0.0);
    let omega = PIT2 * freq_mhz * 1.0e6;
    if omega == 0.0 {
        return CollisionResult { z: 0.0, dzdr: 0.0, dzdth: 0.0, dzdph: 0.0 };
    }

    let arg1 = (-p.a1 * (h - p.h1)).clamp(-20.0, 20.0);
    let exp1 = p.nu1 * arg1.exp();

    let z = exp1 / omega;
    let dzdr = -p.a1 * exp1 / omega;

    CollisionResult {
        z,
        dzdr,
        dzdth: 0.0,
        dzdph: 0.0,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    // Tests for collision frequency models

    fn default_params() -> ModelParams {
        ModelParams::default()
    }

    // ---- EXPZ2 (default) ----

    #[test]
    fn test_expz2_at_low_altitude() {
        let p = default_params();
        let col = compute_col(EARTH_RADIUS + 80.0, PID2, 0.0, 10.0, &p);
        assert!(col.z > 0.0, "EXPZ2 z at 80 km should be positive");
        assert!(
            col.dzdr < 0.0,
            "EXPZ2 dzdr should be negative (decreasing with height)"
        );
    }

    #[test]
    fn test_expz2_decreases_with_altitude() {
        let p = default_params();
        let col_low = compute_col(EARTH_RADIUS + 80.0, PID2, 0.0, 10.0, &p);
        let col_high = compute_col(EARTH_RADIUS + 300.0, PID2, 0.0, 10.0, &p);
        assert!(
            col_low.z > col_high.z,
            "Collision frequency should decrease with altitude"
        );
    }

    #[test]
    fn test_expz2_no_angular_dependence() {
        let p = default_params();
        let col = compute_col(EARTH_RADIUS + 200.0, PID2, 0.0, 10.0, &p);
        assert_eq!(col.dzdth, 0.0, "EXPZ2 should have no theta dependence");
        assert_eq!(col.dzdph, 0.0, "EXPZ2 should have no phi dependence");
    }

    // ---- CONSTZ ----

    #[test]
    fn test_constz_constant() {
        let mut p = default_params();
        p.col_model = CollisionModel::Constant;
        let col1 = compute_col(EARTH_RADIUS + 100.0, PID2, 0.0, 10.0, &p);
        let col2 = compute_col(EARTH_RADIUS + 500.0, 1.0, 1.0, 10.0, &p);
        assert!((col1.z - col2.z).abs() < 1e-15, "CONSTZ should be constant");
        assert_eq!(col1.dzdr, 0.0, "CONSTZ dzdr should be 0");
    }

    #[test]
    fn test_constz_value() {
        let mut p = default_params();
        p.col_model = CollisionModel::Constant;
        let col = compute_col(EARTH_RADIUS, PID2, 0.0, 10.0, &p);
        let omega = PIT2 * 10.0e6;
        let expected = p.nu1 / omega;
        assert!((col.z - expected).abs() < 1e-12, "CONSTZ z = nu1/omega");
    }

    // ---- EXPZ ----

    #[test]
    fn test_expz_single_exponential() {
        let mut p = default_params();
        p.col_model = CollisionModel::SingleExponential;
        let col = compute_col(EARTH_RADIUS + 150.0, PID2, 0.0, 10.0, &p);
        assert!(col.z > 0.0, "EXPZ should be positive");
        assert!(col.dzdr < 0.0, "EXPZ dzdr should be negative");
    }

    #[test]
    fn test_expz_vs_expz2() {
        // EXPZ uses only the first exponential, EXPZ2 uses both
        // At high altitude where second term is negligible, they should agree closely
        let mut p1 = default_params();
        p1.col_model = CollisionModel::DoubleExponential; // EXPZ2
        let mut p2 = default_params();
        p2.col_model = CollisionModel::SingleExponential; // EXPZ

        // At very low altitude where the first term dominates
        let r = EARTH_RADIUS + p1.h1;
        let col1 = compute_col(r, PID2, 0.0, 10.0, &p1);
        let col2 = compute_col(r, PID2, 0.0, 10.0, &p2);
        // EXPZ2 should be >= EXPZ (it adds a second term)
        assert!(col1.z >= col2.z, "EXPZ2 >= EXPZ (extra term)");
    }

    // ---- All models produce finite values ----

    #[test]
    fn test_all_collision_models_finite() {
        for model in [
            CollisionModel::DoubleExponential,
            CollisionModel::Constant,
            CollisionModel::SingleExponential,
        ] {
            let mut p = default_params();
            p.col_model = model;
            let col = compute_col(EARTH_RADIUS + 200.0, PID2, 0.0, 10.0, &p);
            assert!(col.z.is_finite(), "Col model {:?} z not finite", model);
            assert!(
                col.dzdr.is_finite(),
                "Col model {:?} dzdr not finite",
                model
            );
        }
    }
}
