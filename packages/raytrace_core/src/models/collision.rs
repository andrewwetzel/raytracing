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
pub fn compute_col(r: f64, theta: f64, phi: f64, freq_mhz: f64, p: &ModelParams) -> CollisionResult {
    match p.col_model {
        CollisionModel::Constant => constz(r, theta, phi, freq_mhz, p),
        CollisionModel::SingleExponential => expz(r, theta, phi, freq_mhz, p),
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
