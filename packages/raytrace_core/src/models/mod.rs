//! Physics models for ionospheric ray tracing.
//!
//! The ray tracing engine decomposes the ionosphere into independent,
//! swappable models that are evaluated at each integration step:
//!
//! 1. **Electron density** ([`electron_density`]) — The plasma frequency profile
//!    (e.g., Chapman, Quasi-Parabolic). Controls where refraction occurs.
//!
//! 2. **Magnetic field** ([`magnetic_field`]) — The geomagnetic field direction
//!    and strength (e.g., Dipole, IGRF-14). Causes magneto-ionic splitting into
//!    ordinary and extraordinary modes.
//!
//! 3. **Collision frequency** ([`collision`]) — Electron-neutral collision rate vs.
//!    altitude. Determines absorption and slightly modifies the refractive index.
//!
//! These three models feed into the **Appleton-Hartree equation** (computed
//! internally) which produces the complex refractive index n² that drives
//! Hamilton's equations for the ray path.
//!
//! Model selection is controlled via [`crate::params::ModelParams`].

pub mod collision;
pub mod electron_density;
pub mod magnetic_field;
pub(crate) mod refractive_index;

pub use collision::{compute_col, CollisionResult};
pub use electron_density::{compute_ed, ElectronDensityResult};
pub use magnetic_field::{compute_mag, MagneticFieldResult};
