//! Physical constants and model parameters for ionospheric ray tracing.

use std::f64::consts::PI;

/// 2π
pub(crate) const PIT2: f64 = 2.0 * PI;
/// π/2
pub(crate) const PID2: f64 = PI / 2.0;
/// Speed of light in km/s
pub(crate) const C: f64 = 2.997925e5;
/// ln(10) — used for dB absorption conversion
pub(crate) const LOGTEN: f64 = core::f64::consts::LN_10;
/// Mean Earth radius in km
pub const EARTH_RADIUS: f64 = 6370.0;

// ============================================================
// Model Selector Enums
// ============================================================

/// Electron density profile model.
///
/// Selects how the ionospheric electron density varies with altitude and position.
#[non_exhaustive]
#[derive(
    serde::Serialize, serde::Deserialize, Clone, Copy, Debug, Default, PartialEq, Eq, Hash,
)]
pub enum ElectronDensityModel {
    /// Chapman layer — classic single-layer profile with analytic gradients.
    #[default]
    Chapman,
    /// ELECT1 — tabulated multi-layer profile with interpolated gradients.
    Elect1,
    /// Piecewise-linear — density increases to hmF2 then decreases.
    Linear,
    /// Quasi-parabolic — smooth parabolic profile centered on hmF2.
    QuasiParabolic,
    /// Variable Chapman — Chapman with altitude-varying scale height.
    VarChapman,
    /// Dual Chapman — two superimposed layers (E + F2 regions).
    DualChapman,
}

/// Magnetic field model.
///
/// Selects the geomagnetic field model used for magneto-ionic splitting.
#[non_exhaustive]
#[derive(
    serde::Serialize, serde::Deserialize, Clone, Copy, Debug, Default, PartialEq, Eq, Hash,
)]
pub enum MagneticFieldModel {
    /// Centered dipole — simple but captures essential field geometry.
    #[default]
    Dipole,
    /// Constant — uniform field everywhere (for isolating magneto-ionic effects).
    Constant,
    /// Cubic — higher-order polynomial with fixed dip angle.
    Cubic,
    /// IGRF-14 — degree-13 spherical harmonics with epoch interpolation (2020–2030).
    Igrf14,
}

/// Collision frequency model.
///
/// Selects how electron-neutral collision frequency varies with altitude.
#[non_exhaustive]
#[derive(
    serde::Serialize, serde::Deserialize, Clone, Copy, Debug, Default, PartialEq, Eq, Hash,
)]
pub enum CollisionModel {
    /// Double-exponential (EXPZ2) — two exponential terms for realistic profile.
    #[default]
    DoubleExponential,
    /// Constant — uniform collision frequency at all altitudes.
    Constant,
    /// Single-exponential (EXPZ) — one exponential decay term.
    SingleExponential,
}

/// Refractive index model.
///
/// Selects which terms are included in the Appleton-Hartree formula.
#[non_exhaustive]
#[derive(
    serde::Serialize, serde::Deserialize, Clone, Copy, Debug, Default, PartialEq, Eq, Hash,
)]
pub enum RefractiveIndexModel {
    /// Full Appleton-Hartree — magnetic field + collisions. Most accurate.
    #[default]
    Full,
    /// No field, no collisions — simplest, n² = 1 - X.
    NoFieldNoCollisions,
    /// No field, with collisions — includes absorption but no O/X splitting.
    NoFieldWithCollisions,
    /// With field, no collisions — O/X splitting but no absorption.
    WithFieldNoCollisions,
}

/// Ionospheric perturbation model.
///
/// Adds a localized density modification on top of the background profile.
#[non_exhaustive]
#[derive(
    serde::Serialize, serde::Deserialize, Clone, Copy, Debug, Default, PartialEq, Eq, Hash,
)]
pub enum PerturbationModel {
    /// No perturbation — undisturbed ionosphere.
    #[default]
    None,
    /// Toroidal density enhancement (plasma bubble / TID).
    Torus,
    /// Mid-latitude density depletion (trough).
    Trough,
    /// Propagating density discontinuity (shockwave).
    Shock,
    /// Broad density enhancement (equatorial anomaly).
    Bulge,
    /// Exponential density perturbation.
    Exponential,
}

/// Characteristic wave mode for magneto-ionic propagation.
///
/// The Earth's magnetic field splits radio waves into two modes.
#[non_exhaustive]
#[derive(
    serde::Serialize, serde::Deserialize, Clone, Copy, Debug, Default, PartialEq, Eq, Hash,
)]
pub enum RayMode {
    /// Extraordinary (X-mode) — refracts at a higher frequency than O-mode.
    #[default]
    Extraordinary,
    /// Ordinary (O-mode) — refracts at the plasma frequency.
    Ordinary,
}

impl RayMode {
    /// Convert to the internal numeric representation used by the physics engine.
    pub fn to_sign(self) -> f64 {
        match self {
            RayMode::Extraordinary => -1.0,
            RayMode::Ordinary => 1.0,
        }
    }
}

// ============================================================
// Model Parameters
// ============================================================

/// Configuration for all ionospheric physics models.
///
/// This struct carries the parameters needed by the electron density, magnetic field,
/// collision, refractive index, and perturbation models. Use [`Default::default()`]
/// to get a standard mid-latitude daytime configuration, then override specific fields:
///
/// ```
/// use ionotrace::params::ModelParams;
/// use ionotrace::params::ElectronDensityModel;
///
/// let params = ModelParams::builder()
///     .ed_model(ElectronDensityModel::DualChapman)
///     .fc(8.0)
///     .build()
///     .unwrap();
/// ```
///
/// # Stability
///
/// This struct is `#[non_exhaustive]` — new fields may be added in future versions.
/// Always construct with `..ModelParams::default()` to remain forward-compatible.
#[non_exhaustive]
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug, derive_builder::Builder)]
#[builder(default, setter(into))]
pub struct ModelParams {
    /// Earth radius in km (default: 6370.0).
    pub earth_r: f64,

    // ---- Model selectors ----
    /// Electron density profile model.
    pub ed_model: ElectronDensityModel,
    /// Magnetic field model.
    pub mag_model: MagneticFieldModel,
    /// Collision frequency model.
    pub col_model: CollisionModel,
    /// Refractive index model.
    pub rindex_model: RefractiveIndexModel,
    /// Ionospheric perturbation model.
    pub pert_model: PerturbationModel,

    // ---- Electron density parameters ----
    /// Critical frequency foF2 in MHz (default: 10.0).
    pub fc: f64,
    /// Peak height hmF2 in km (default: 250.0).
    pub hm: f64,
    /// Scale height in km (default: 100.0).
    pub sh: f64,
    /// Chapman alpha parameter (default: 0.5).
    pub alpha: f64,
    /// ELECT1 model parameter a.
    pub ed_a: f64,
    /// ELECT1 model parameter b.
    pub ed_b: f64,
    /// ELECT1 model parameter c.
    pub ed_c: f64,
    /// ELECT1 model parameter e.
    pub ed_e: f64,
    /// Semi-thickness ym in km (default: 100.0).
    pub ym: f64,

    // ---- Second layer (DualChapman) ----
    /// Second layer critical frequency in MHz.
    pub fc2: f64,
    /// Second layer peak height in km.
    pub hm2: f64,
    /// Second layer scale height in km.
    pub sh2: f64,

    // ---- VarChapman ----
    /// Exponent for variable-Chapman scale height (default: 3.0).
    pub chi: f64,

    // ---- Magnetic field ----
    /// Gyrofrequency fH in MHz (default: 0.8).
    pub fh: f64,
    /// Dip angle in radians (for Cubic model).
    pub dip: f64,
    /// Epoch year for IGRF interpolation, e.g. 2025.0 (default: 2025.0).
    pub epoch_year: f64,

    // ---- Collision frequency ----
    /// First collision term amplitude (default: 1,050,000).
    pub nu1: f64,
    /// First collision reference height in km (default: 100.0).
    pub h1: f64,
    /// First collision decay rate in 1/km (default: 0.148).
    pub a1: f64,
    /// Second collision term amplitude (default: 30.0).
    pub nu2: f64,
    /// Second collision reference height in km (default: 140.0).
    pub h2: f64,
    /// Second collision decay rate in 1/km (default: 0.0183).
    pub a2: f64,

    // ---- Perturbation parameters ----
    /// Perturbation parameter 1 (model-dependent).
    pub p1: f64,
    /// Perturbation parameter 2 (model-dependent).
    pub p2: f64,
    /// Perturbation parameter 3 (model-dependent).
    pub p3: f64,
    /// Perturbation parameter 4 (model-dependent).
    pub p4: f64,
    /// Perturbation parameter 5 (model-dependent).
    pub p5: f64,
    /// Perturbation parameter 6 (model-dependent).
    pub p6: f64,
    /// Perturbation parameter 7 (model-dependent).
    pub p7: f64,
    /// Perturbation parameter 8 (model-dependent).
    pub p8: f64,
    /// Perturbation parameter 9 (model-dependent).
    pub p9: f64,
}

impl ModelParams {
    /// Create a new builder for ModelParams, allowing chainable configuration.
    ///
    /// The builder is initialized with `ModelParams::default()` values.
    /// Call `.build().unwrap()` when finished.
    pub fn builder() -> ModelParamsBuilder {
        ModelParamsBuilder::default()
    }

    /// Validate these parameters for physical reasonableness.
    ///
    /// Returns `Ok(())` if valid, or a descriptive error string.
    /// This does not check model-specific parameter combinations,
    /// only basic sanity of the core fields.
    pub fn validate(&self) -> Result<(), String> {
        if self.earth_r <= 0.0 {
            return Err(format!("earth_r must be positive, got {}", self.earth_r));
        }
        if self.fc < 0.0 {
            return Err(format!("fc (foF2) must be non-negative, got {}", self.fc));
        }
        if self.hm < 0.0 {
            return Err(format!("hm (hmF2) must be non-negative, got {}", self.hm));
        }
        if self.sh < 0.0 {
            return Err(format!("sh (scale height) must be non-negative, got {}", self.sh));
        }
        if self.fh < 0.0 {
            return Err(format!("fh (gyrofrequency) must be non-negative, got {}", self.fh));
        }
        Ok(())
    }
}

impl Default for ModelParams {
    fn default() -> Self {
        Self {
            earth_r: EARTH_RADIUS,
            ed_model: ElectronDensityModel::default(),
            mag_model: MagneticFieldModel::default(),
            col_model: CollisionModel::default(),
            rindex_model: RefractiveIndexModel::default(),
            pert_model: PerturbationModel::default(),
            fc: 10.0,
            hm: 250.0,
            sh: 100.0,
            alpha: 0.5,
            ed_a: 0.0,
            ed_b: 0.0,
            ed_c: 0.0,
            ed_e: 0.0,
            ym: 100.0,
            fc2: 0.0,
            hm2: 0.0,
            sh2: 0.0,
            chi: 3.0,
            fh: 0.8,
            dip: 0.0,
            epoch_year: 2025.0,
            nu1: 1_050_000.0,
            h1: 100.0,
            a1: 0.148,
            nu2: 30.0,
            h2: 140.0,
            a2: 0.0183,
            p1: 0.0,
            p2: 0.0,
            p3: 0.0,
            p4: 0.0,
            p5: 0.0,
            p6: 0.0,
            p7: 0.0,
            p8: 0.0,
            p9: 0.0,
        }
    }
}
