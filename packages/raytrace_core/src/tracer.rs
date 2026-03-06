//! Ray tracing execution and result types.

use std::f64::consts::PI;

use crate::ecef::*;
use crate::error::TraceError;
use crate::hamiltonian::hamltn;
use crate::hamiltonian_ecef::hamltn_ecef;
use crate::integrator::*;
use crate::params::*;
use crate::wgs84;

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
    /// Integration coordinate system.
    pub coord_system: CoordinateSystem,
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
    /// - RK4+AM integrator, step size 1.0 km, max 2000 steps
    /// - Default `ModelParams` (Chapman + Dipole + AHWFWC + WGS-84)
    pub fn new(freq_mhz: f64, elevation_deg: f64) -> Self {
        Self {
            freq_mhz,
            ray_mode: RayMode::default(),
            elevation_deg,
            azimuth_deg: 0.0,
            tx_lat_deg: 40.0,
            int_mode: 2,
            coord_system: CoordinateSystem::default(),
            step_size: 1.0,
            max_steps: 2000,
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
            self.coord_system,
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
    coord_system: CoordinateSystem,
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

    match coord_system {
        CoordinateSystem::Ecef => trace_ray_ecef(
            freq_mhz,
            ray_mode,
            elevation_deg,
            azimuth_deg,
            tx_lat_deg,
            int_mode,
            step_size,
            max_steps,
            e1max,
            e1min,
            e2max,
            p,
            print_every,
        ),
        CoordinateSystem::Spherical => trace_ray_spherical(
            freq_mhz,
            ray_mode,
            elevation_deg,
            azimuth_deg,
            tx_lat_deg,
            int_mode,
            step_size,
            max_steps,
            e1max,
            e1min,
            e2max,
            p,
            print_every,
        ),
    }
}

/// Spherical integration path (original OT 75-76 formulation).
#[allow(clippy::too_many_arguments)]
fn trace_ray_spherical(
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
    let elev_rad = elevation_deg * PI / 180.0;
    let az_rad = azimuth_deg * PI / 180.0;

    let r0 = p.earth_r;
    let theta0 = PID2 - tx_lat_deg * PI / 180.0;
    let phi0 = 0.0;
    let degs = 180.0 / PI;
    let tx_lat_rad = tx_lat_deg * PI / 180.0;

    // Helper: altitude above surface
    let altitude = |r: f64, theta: f64| -> f64 {
        match p.earth_model {
            EarthModel::Wgs84 => wgs84::geodetic_altitude(r, theta),
            EarthModel::Sphere => r - p.earth_r,
        }
    };

    // Helper: ground range in km from initial position
    let ground_range = |theta: f64, phi: f64| -> f64 {
        match p.earth_model {
            EarthModel::Wgs84 => {
                let lat1 = tx_lat_rad;
                let lat2 = PID2 - theta;
                wgs84::vincenty_distance(lat1, 0.0, lat2, phi)
            }
            EarthModel::Sphere => {
                let cos_ang =
                    theta0.cos() * theta.cos() + theta0.sin() * theta.sin() * (phi - phi0).cos();
                p.earth_r * cos_ang.clamp(-1.0, 1.0).acos()
            }
        }
    };

    let kr0 = elev_rad.sin();
    let kth0 = elev_rad.cos() * (PI - az_rad).cos();
    let kph0 = elev_rad.cos() * (PI - az_rad).sin();

    let mut y = [r0, theta0, phi0, kr0, kth0, kph0, 0.0, 0.0];
    let (_d0, _, new_kr, new_kth, new_kph) = hamltn(&y, freq_mhz, ray_mode, p, true);
    y[3] = new_kr;
    y[4] = new_kth;
    y[5] = new_kph;

    let mut state = IntegratorState::new(
        &y, 0.0, step_size, int_mode, e1max, e1min, e2max, 1.0e-8, 0.5,
    );

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
        if state.mm < 4 || state.mode == 1 {
            rk4_step(&mut state, freq_mhz, ray_mode, p);
            while state.mm < 4 && state.mode != 1 && !state.diverged {
                rk4_step(&mut state, freq_mhz, ray_mode, p);
            }
        } else {
            am_step(&mut state, freq_mhz, ray_mode, p);
        }

        if state.diverged {
            break;
        }

        let h = altitude(state.y[0], state.y[1]);
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
            let lat = match p.earth_model {
                EarthModel::Wgs84 => {
                    let (lat_gd, _) = wgs84::geocentric_to_geodetic(state.y[0], theta);
                    lat_gd * degs
                }
                EarthModel::Sphere => (PID2 - theta) * degs,
            };
            let lon = phi * degs;
            let gr = ground_range(theta, phi);
            let gp = state.y[6];
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

/// ECEF Cartesian integration path (singularity-free).
#[allow(clippy::too_many_arguments)]
fn trace_ray_ecef(
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
    let elev_rad = elevation_deg * PI / 180.0;
    let az_rad = azimuth_deg * PI / 180.0;
    let degs = 180.0 / PI;
    let tx_lat_rad = tx_lat_deg * PI / 180.0;

    // Initial spherical position
    let r0 = p.earth_r;
    let theta0 = PID2 - tx_lat_rad;
    let phi0 = 0.0;

    // Convert to ECEF
    let (x0, y0, z0) = spherical_to_ecef(r0, theta0, phi0);

    // Initial k-vector in spherical, then convert to ECEF
    let kr0 = elev_rad.sin();
    let kth0 = elev_rad.cos() * (PI - az_rad).cos();
    let kph0 = elev_rad.cos() * (PI - az_rad).sin();
    let (kx0, ky0, kz0) = k_spherical_to_ecef(kr0, kth0, kph0, theta0, phi0);

    // First call: compute derivatives and rescale k
    let mut y = [x0, y0, z0, kx0, ky0, kz0, 0.0, 0.0];
    let (_d0, _, new_kx, new_ky, new_kz) = hamltn_ecef(&y, freq_mhz, ray_mode, p, true);
    y[3] = new_kx;
    y[4] = new_ky;
    y[5] = new_kz;

    // Init integrator (same as spherical — integrator is coordinate-agnostic)
    let mut state = IntegratorState::new(
        &y, 0.0, step_size, int_mode, e1max, e1min, e2max, 1.0e-8, 0.5,
    );

    let (d_init, _, _, _, _) = hamltn_ecef(&state.y, freq_mhz, ray_mode, p, false);
    state.dydt = d_init;
    state.fv[state.mm] = d_init;

    // Helper: altitude from ECEF position
    let altitude = |x: f64, y: f64, z: f64| -> f64 {
        let (r, theta, _phi) = ecef_to_spherical(x, y, z);
        match p.earth_model {
            EarthModel::Wgs84 => wgs84::geodetic_altitude(r, theta),
            EarthModel::Sphere => r - p.earth_r,
        }
    };

    // Helper: ground range from ECEF position
    let ground_range = |x: f64, y: f64, z: f64| -> f64 {
        let (r, theta, phi) = ecef_to_spherical(x, y, z);
        match p.earth_model {
            EarthModel::Wgs84 => {
                let (lat2, _) = wgs84::geocentric_to_geodetic(r, theta);
                wgs84::vincenty_distance(tx_lat_rad, 0.0, lat2, phi)
            }
            EarthModel::Sphere => {
                let cos_ang =
                    theta0.cos() * theta.cos() + theta0.sin() * theta.sin() * (phi - phi0).cos();
                p.earth_r * cos_ang.clamp(-1.0, 1.0).acos()
            }
        }
    };

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

    // The integrator calls hamltn internally — we need to patch it to use
    // hamltn_ecef. Since the integrator is generic over its derivative function
    // via the hamltn call, we use a wrapper approach: temporarily redirect.
    // Actually, the integrator calls `hamltn` directly. For the ECEF path,
    // we run the same stepping logic but call hamltn_ecef manually.
    for step_num in 1..=max_steps {
        // Call ECEF Hamiltonian for the integrator step
        if state.mm < 4 || state.mode == 1 {
            rk4_step_ecef(&mut state, freq_mhz, ray_mode, p);
            while state.mm < 4 && state.mode != 1 && !state.diverged {
                rk4_step_ecef(&mut state, freq_mhz, ray_mode, p);
            }
        } else {
            am_step_ecef(&mut state, freq_mhz, ray_mode, p);
        }

        if state.diverged {
            break;
        }

        let h = altitude(state.y[0], state.y[1], state.y[2]);
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
            tracing::debug!(
                step = step_num,
                final_height = h,
                "Ray returned to ground (ECEF)"
            );
        }

        if step_num % print_every == 0 || ground {
            let (r, theta, phi) = ecef_to_spherical(state.y[0], state.y[1], state.y[2]);
            let lat = match p.earth_model {
                EarthModel::Wgs84 => {
                    let (lat_gd, _) = wgs84::geocentric_to_geodetic(r, theta);
                    lat_gd * degs
                }
                EarthModel::Sphere => (PID2 - theta) * degs,
            };
            let lon = phi * degs;
            let gr = ground_range(state.y[0], state.y[1], state.y[2]);
            let gp = state.y[6];
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

// ============================================================
// ECEF-aware integrator step wrappers
// ============================================================
// These mirror rk4_step / am_step but call hamltn_ecef instead of hamltn.

fn rk4_step_ecef(s: &mut IntegratorState, freq_mhz: f64, ray_mode: f64, p: &ModelParams) {
    if s.diverged {
        return;
    }
    let bet = [0.5, 0.5, 1.0, 0.0];
    let mut dely = [[0.0f64; NN]; 4];
    let mm = s.mm;

    for k in 0..4 {
        for i in 0..NN {
            dely[k][i] = s.step * s.fv[mm][i];
            s.y[i] = s.yu[mm][i] + bet[k] * dely[k][i];
        }
        s.t = bet[k] * s.step + s.xv[mm];
        let (d, _, _, _, _) = hamltn_ecef(&s.y, freq_mhz, ray_mode, p, false);
        s.dydt = d;
        s.fv[mm] = d;
    }

    for i in 0..NN {
        let delta = (dely[0][i] + 2.0 * dely[1][i] + 2.0 * dely[2][i] + dely[3][i]) / 6.0;
        s.yu[mm + 1][i] = s.yu[mm][i] + delta;
    }
    s.mm += 1;
    s.xv[s.mm] = s.xv[s.mm - 1] + s.step;
    s.y = s.yu[s.mm];
    s.t = s.xv[s.mm];

    if !s.y.iter().all(|v| v.is_finite()) {
        s.diverged = true;
        return;
    }

    let (d, _, _, _, _) = hamltn_ecef(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d;

    if s.mode == 1 {
        exit_routine_ecef(s);
        return;
    }

    s.fv[s.mm] = d;

    if s.mm <= 3 {
        return;
    }

    am_step_ecef(s, freq_mhz, ray_mode, p);
}

fn am_step_ecef(s: &mut IntegratorState, freq_mhz: f64, ray_mode: f64, p: &ModelParams) {
    if s.diverged {
        return;
    }
    let mut dely1 = [0.0f64; NN];

    for i in 0..NN {
        let delta = s.step
            * (55.0 * s.fv[4][i] - 59.0 * s.fv[3][i] + 37.0 * s.fv[2][i] - 9.0 * s.fv[1][i])
            / 24.0;
        s.y[i] = s.yu[4][i] + delta;
        dely1[i] = s.y[i];
    }

    s.t = s.xv[4] + s.step;
    let (d, _, _, _, _) = hamltn_ecef(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d;
    s.xv[5] = s.t;

    for i in 0..NN {
        let delta =
            s.step * (9.0 * d[i] + 19.0 * s.fv[4][i] - 5.0 * s.fv[3][i] + s.fv[2][i]) / 24.0;
        s.yu[5][i] = s.yu[4][i] + delta;
        s.y[i] = s.yu[5][i];
    }

    let (d2, _, _, _, _) = hamltn_ecef(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d2;

    if s.mode <= 2 {
        exit_routine_ecef(s);
        return;
    }

    // Error analysis (mode 3)
    let mut sse = 0.0f64;
    for i in 0..NN {
        let mut epsil = 8.0 * (s.y[i] - dely1[i]).abs();
        if s.y[i].abs() > 1.0e-8 {
            epsil /= s.y[i].abs();
        }
        if sse < epsil {
            sse = epsil;
        }
    }

    if s.e1max <= sse {
        if s.step.abs() <= s.e2min || s.halvings >= 10 {
            s.halvings = 0;
            exit_routine_ecef(s);
            return;
        }
        s.halvings += 1;
        s.ll = 1;
        s.mm = 1;
        s.step *= s.fact;
        s.yu[1] = s.y;
        s.fv[1] = s.dydt;
        s.xv[1] = s.t;
        rk4_step_ecef(s, freq_mhz, ray_mode, p);
        return;
    }

    if s.ll <= 1 || sse >= s.e1min || s.e2max <= s.step.abs() {
        exit_routine_ecef(s);
        return;
    }

    // Double step
    s.ll = 2;
    s.mm = 3;
    s.xv[2] = s.xv[3];
    s.xv[3] = s.xv[5];
    s.fv[2] = s.fv[3];
    s.fv[3] = s.dydt;
    s.yu[2] = s.yu[3];
    s.yu[3] = s.yu[5];
    s.step *= 2.0;
    rk4_step_ecef(s, freq_mhz, ray_mode, p);
}

fn exit_routine_ecef(s: &mut IntegratorState) {
    s.ll = 2;
    s.mm = 4;
    for k in 1..4 {
        s.xv[k] = s.xv[k + 1];
        s.fv[k] = s.fv[k + 1];
        s.yu[k] = s.yu[k + 1];
    }
    s.xv[4] = s.xv[5];
    s.fv[4] = s.dydt;
    s.yu[4] = s.yu[5];
    if s.mode <= 2 {
        return;
    }
    let e = (s.xv[4] - s.alpha).abs();
    s.epm = s.epm.max(e);
}
