//! Physics model dispatch and result types.

pub mod electron_density;
pub mod magnetic_field;
pub mod collision;
pub(crate) mod refractive_index;

pub use electron_density::{ElectronDensityResult, compute_ed};
pub use magnetic_field::{MagneticFieldResult, compute_mag};
pub use collision::{CollisionResult, compute_col};
