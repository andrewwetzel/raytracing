//! Error types for ionospheric ray tracing.

use std::fmt;
use std::error::Error;

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
}

impl fmt::Display for TraceError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TraceError::InvalidFrequency(v) => write!(f, "Invalid frequency: {} MHz. Must be > 0.", v),
            TraceError::InvalidElevation(v) => write!(f, "Invalid elevation: {} deg. Must be between -90 and 90.", v),
            TraceError::InvalidStepSize(v) => write!(f, "Invalid step size: {}. Must be > 0.", v),
            TraceError::InvalidMaxSteps(v) => write!(f, "Invalid max steps: {}. Must be > 0.", v),
        }
    }
}

impl Error for TraceError {}
