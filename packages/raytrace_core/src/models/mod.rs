//! Physics model dispatch and result types.

pub mod collision;
pub mod electron_density;
pub mod magnetic_field;
pub(crate) mod refractive_index;

pub use collision::{compute_col, CollisionResult};
pub use electron_density::{compute_ed, ElectronDensityResult};
pub use magnetic_field::{compute_mag, MagneticFieldResult};
