//! Ray tracing execution and result types.

use std::f64::consts::PI;

use crate::error::TraceError;
use crate::hamiltonian::hamltn;
use crate::integrator::*;
use crate::params::*;

/// A point along the ray path.
#[non_exhaustive]
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
pub struct TracePoint {
    /// Integration step number.
    pub step: usize,
    /// Integration parameter (dimensionless time).
    pub t: f64,
    /// Height above Earth's surface in km.
    pub height_km: f64,
    /// Geographic latitude in degrees.
    pub lat_deg: f64,
    /// Geographic longitude in degrees.
    pub lon_deg: f64,
    /// Great-circle ground range from transmitter in km.
    pub ground_range_km: f64,
    /// Group path (approximation).
    pub group_path: f64,
    /// Phase path.
    pub phase_path: f64,
    /// Cumulative absorption in dB.
    pub absorption: f64,
}

/// Result of tracing a single ray through the ionosphere.
#[non_exhaustive]
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
pub struct TraceResult {
    /// Ray path points (sampled every `print_every` steps + ground return).
    pub points: Vec<TracePoint>,
    /// Peak altitude reached by the ray in km.
    pub max_height: f64,
    /// Total ground range if the ray returned, in km.
    pub ground_range_km: f64,
    /// Whether the ray returned to the ground.
    pub returned_to_ground: bool,
    /// Total integration steps taken.
    pub n_steps: usize,
}

/// Configuration for tracing a ray through the ionosphere.
///
/// Use [`TraceConfig::new`] for a minimal setup, then override fields as needed:
///
/// ```
/// use ionotrace::{TraceConfig, ModelParams};
/// use ionotrace::params::RayMode;
///
/// let mut config = TraceConfig::new(10.0, 20.0);
/// config.ray_mode = RayMode::Ordinary;
/// config.azimuth_deg = 45.0;
/// let result = config.trace().unwrap();
/// println!("Max height: {:.2} km", result.max_height);
/// ```
///
/// # Stability
///
/// This struct is `#[non_exhaustive]` — always construct with `..TraceConfig::new()`
/// to remain forward-compatible.
#[non_exhaustive]
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
pub struct TraceConfig {
    /// Radio wave frequency in MHz.
    pub freq_mhz: f64,
    /// Wave mode (ordinary or extraordinary).
    pub ray_mode: RayMode,
    /// Launch elevation angle in degrees (0 = horizontal, 90 = vertical).
    pub elevation_deg: f64,
    /// Launch azimuth in degrees (0 = north, clockwise).
    pub azimuth_deg: f64,
    /// Transmitter latitude in degrees.
    pub tx_lat_deg: f64,
    /// Integration mode: 1 = RK4 only, 2 = RK4+Adams-Moulton, 3 = RK4+AM+error control.
    pub int_mode: usize,
    /// Integration step size (dimensionless).
    pub step_size: f64,
    /// Maximum number of integration steps.
    pub max_steps: usize,
    /// Upper error tolerance for adaptive step control.
    pub e1max: f64,
    /// Lower error tolerance for adaptive step control.
    pub e1min: f64,
    /// Maximum step size for adaptive step control.
    pub e2max: f64,
    /// Record a point every N steps.
    pub print_every: usize,
    /// Physics model parameters.
    pub params: ModelParams,
}

impl TraceConfig {
    /// Create a new trace configuration with the given frequency and elevation.
    ///
    /// All other parameters are set to sensible defaults:
    /// - X-mode, 0° azimuth, 40° latitude
    /// - RK4+AM integrator, step size 5.0, max 500 steps
    /// - Default `ModelParams` (Chapman + Dipole + AHWFWC)
    pub fn new(freq_mhz: f64, elevation_deg: f64) -> Self {
        Self {
            freq_mhz,
            ray_mode: RayMode::default(),
            elevation_deg,
            azimuth_deg: 0.0,
            tx_lat_deg: 40.0,
            int_mode: 2,
            step_size: 5.0,
            max_steps: 500,
            e1max: 1e-4,
            e1min: 2e-6,
            e2max: 100.0,
            print_every: 1,
            params: ModelParams::default(),
        }
    }

    /// Validate this configuration without running a trace.
    ///
    /// Returns `Ok(())` if the configuration is valid, or a [`TraceError`]
    /// describing the first problem found. Useful for pre-flight checks.
    pub fn validate(&self) -> Result<(), TraceError> {
        if self.freq_mhz <= 0.0 {
            return Err(TraceError::InvalidFrequency(self.freq_mhz));
        }
        if !(-90.0..=90.0).contains(&self.elevation_deg) {
            return Err(TraceError::InvalidElevation(self.elevation_deg));
        }
        if self.step_size <= 0.0 {
            return Err(TraceError::InvalidStepSize(self.step_size));
        }
        if self.max_steps == 0 {
            return Err(TraceError::InvalidMaxSteps(self.max_steps));
        }
        Ok(())
    }

    /// Trace a ray through the ionosphere using this configuration.
    ///
    /// Returns a [`TraceResult`] containing the ray path and summary statistics,
    /// or a [`TraceError`] if the configuration is invalid.
    pub fn trace(&self) -> Result<TraceResult, TraceError> {
        trace_ray(
            self.freq_mhz,
            self.ray_mode.to_sign(),
            self.elevation_deg,
            self.azimuth_deg,
            self.tx_lat_deg,
            self.int_mode,
            self.step_size,
            self.max_steps,
            self.e1max,
            self.e1min,
            self.e2max,
            &self.params,
            self.print_every,
        )
    }
}

/// Trace a ray through the ionosphere (internal implementation).
///
/// Prefer [`TraceConfig::trace`] for the public API.
#[doc(hidden)]
#[tracing::instrument(skip(p), level = "debug")]
#[allow(clippy::too_many_arguments)]
pub fn trace_ray(
    freq_mhz: f64,
    ray_mode: f64,
    elevation_deg: f64,
    azimuth_deg: f64,
    tx_lat_deg: f64,
    int_mode: usize,
    step_size: f64,
    max_steps: usize,
    e1max: f64,
    e1min: f64,
    e2max: f64,
    p: &ModelParams,
    print_every: usize,
) -> Result<TraceResult, TraceError> {
    if freq_mhz <= 0.0 {
        return Err(TraceError::InvalidFrequency(freq_mhz));
    }
    if !(-90.0..=90.0).contains(&elevation_deg) {
        return Err(TraceError::InvalidElevation(elevation_deg));
    }
    if step_size <= 0.0 {
        return Err(TraceError::InvalidStepSize(step_size));
    }
    if max_steps == 0 {
        return Err(TraceError::InvalidMaxSteps(max_steps));
    }

    let elev_rad = elevation_deg * PI / 180.0;
    let az_rad = azimuth_deg * PI / 180.0;

    // Initial state
    let r0 = p.earth_r;
    let theta0 = PID2 - tx_lat_deg * PI / 180.0;
    let phi0 = 0.0;
    let degs = 180.0 / PI;

    // Helper: ground range in km from initial position
    let ground_range = |theta: f64, phi: f64| -> f64 {
        let cos_ang = theta0.cos() * theta.cos() + theta0.sin() * theta.sin() * (phi - phi0).cos();
        p.earth_r * cos_ang.clamp(-1.0, 1.0).acos()
    };

    let kr0 = elev_rad.sin();
    let kth0 = elev_rad.cos() * (PI - az_rad).cos();
    let kph0 = elev_rad.cos() * (PI - az_rad).sin();

    // First call: compute derivatives and rescale k
    let mut y = [r0, theta0, phi0, kr0, kth0, kph0, 0.0, 0.0];
    let (_d0, _, new_kr, new_kth, new_kph) = hamltn(&y, freq_mhz, ray_mode, p, true);
    y[3] = new_kr;
    y[4] = new_kth;
    y[5] = new_kph;

    // Init integrator
    let mut state = IntegratorState::new(
        &y, 0.0, step_size, int_mode, e1max, e1min, e2max, 1.0e-8, 0.5,
    );

    // Store initial derivatives
    let (d_init, _, _, _, _) = hamltn(&state.y, freq_mhz, ray_mode, p, false);
    state.dydt = d_init;
    state.fv[state.mm] = d_init;

    let mut result = TraceResult {
        points: Vec::with_capacity(max_steps / print_every + 5),
        max_height: 0.0,
        ground_range_km: 0.0,
        returned_to_ground: false,
        n_steps: 0,
    };

    result.points.push(TracePoint {
        step: 0,
        t: 0.0,
        height_km: 0.0,
        lat_deg: tx_lat_deg,
        lon_deg: 0.0,
        ground_range_km: 0.0,
        group_path: 0.0,
        phase_path: 0.0,
        absorption: 0.0,
    });

    let mut went_up = false;

    for step_num in 1..=max_steps {
        // One integrator step (may need multiple calls during warmup when mm < 4)
        if state.mm < 4 || state.mode == 1 {
            rk4_step(&mut state, freq_mhz, ray_mode, p);
            // Warmup: rk4_step no longer recurses, keep stepping until mm >= 4
            while state.mm < 4 && state.mode != 1 && !state.diverged {
                rk4_step(&mut state, freq_mhz, ray_mode, p);
            }
        } else {
            am_step(&mut state, freq_mhz, ray_mode, p);
        }

        // Bail if integrator diverged (NaN/Inf detected)
        if state.diverged {
            break;
        }

        let h = state.y[0] - p.earth_r;
        if h > result.max_height {
            result.max_height = h;
        }
        if h > 10.0 {
            went_up = true;
        }
        if h.is_nan() || h.abs() > 50000.0 {
            break;
        }

        let ground = went_up && h < 0.0;
        if ground && !result.returned_to_ground {
            result.returned_to_ground = true;
            tracing::debug!(step = step_num, final_height = h, "Ray returned to ground");
        }

        if step_num % print_every == 0 || ground {
            let theta = state.y[1];
            let phi = state.y[2];
            let lat = (PID2 - theta) * degs;
            let lon = phi * degs;
            let gr = ground_range(theta, phi);
            // Group path = integral of (c/vg) ds ≈ phase_path for simple cases
            let gp = state.y[6]; // close to group path for non-dispersive
            result.points.push(TracePoint {
                step: step_num,
                t: state.t,
                height_km: h,
                lat_deg: lat,
                lon_deg: lon,
                ground_range_km: gr,
                group_path: gp,
                phase_path: state.y[6],
                absorption: state.y[7],
            });
            if ground {
                result.ground_range_km = gr;
            }
        }

        result.n_steps = step_num;
        if ground {
            break;
        }
    }

    Ok(result)
}
