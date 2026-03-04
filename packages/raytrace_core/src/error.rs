//! Error types for ionospheric ray tracing.

use std::error::Error;
use std::fmt;

/// Errors that can occur during ray tracing configuration or execution.
#[non_exhaustive]
#[derive(Debug, Clone, PartialEq)]
pub enum TraceError {
    /// Frequency must be strictly positive.
    InvalidFrequency(f64),
    /// Elevation angle must be between -90 and 90 degrees.
    InvalidElevation(f64),
    /// Step size must be strictly positive.
    InvalidStepSize(f64),
    /// Maximum steps must be strictly positive.
    InvalidMaxSteps(usize),
    /// No ray returned to ground in the search range.
    NoGroundReturn,
    /// Solver did not converge within iteration limit.
    SolverDidNotConverge {
        /// Best error achieved in km.
        best_error_km: f64,
    },
}

impl fmt::Display for TraceError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TraceError::InvalidFrequency(v) => {
                write!(f, "Invalid frequency: {} MHz. Must be > 0.", v)
            }
            TraceError::InvalidElevation(v) => write!(
                f,
                "Invalid elevation: {} deg. Must be between -90 and 90.",
                v
            ),
            TraceError::InvalidStepSize(v) => write!(f, "Invalid step size: {}. Must be > 0.", v),
            TraceError::InvalidMaxSteps(v) => write!(f, "Invalid max steps: {}. Must be > 0.", v),
            TraceError::NoGroundReturn => {
                write!(f, "No ray returned to ground in the search range.")
            }
            TraceError::SolverDidNotConverge { best_error_km } => write!(
                f,
                "Solver did not converge. Best error: {:.2} km.",
                best_error_km
            ),
        }
    }
}

impl Error for TraceError {}
