//! Target location solver — find ray launch parameters to hit a geographic target.
//!
//! Given a target (lat, lon) and transmitter location, finds the elevation and
//! azimuth angles that land a ray within a user-specified error tolerance.
//!
//! # Algorithm
//!
//! Three-phase approach optimized for speed:
//! 1. **Coarse fan sweep** — fire rays at coarse elevation steps, identify brackets
//! 2. **Bisection refinement** — narrow each bracket to sub-km accuracy
//! 3. **2D Nelder-Mead polish** — jointly optimize (elevation, azimuth) for exact target
//!
//! # Example
//!
//! ```
//! use ionotrace::target::{TargetConfig, solve_target};
//! use ionotrace::ModelParams;
//!
//! let config = TargetConfig {
//!     target_lat_deg: 45.0,
//!     target_lon_deg: 2.0,
//!     error_limit_km: 5.0,
//!     ..TargetConfig::default()
//! };
//! let result = solve_target(&config).unwrap();
//! if let Some(best) = &result.best {
//!     println!("Best elevation: {:.2}°, error: {:.1} km", best.elevation_deg, best.error_km);
//! }
//! ```

use std::f64::consts::PI;

use crate::error::TraceError;
use crate::params::*;
use crate::tracer::{trace_ray, TracePoint};
use serde::{Deserialize, Serialize};

#[cfg(not(target_arch = "wasm32"))]
use rayon::prelude::*;

// ============================================================
// Types
// ============================================================

/// How to specify a search dimension: fixed value or range.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum SearchSpec {
    /// Search across a range of values with a given step.
    Range { min: f64, max: f64, step: f64 },
    /// Use a single fixed value.
    Fixed(f64),
}

impl Default for SearchSpec {
    fn default() -> Self {
        SearchSpec::Fixed(0.0)
    }
}

/// Configuration for the target location solver.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TargetConfig {
    // ---- Target ----
    /// Target latitude in degrees (north positive).
    pub target_lat_deg: f64,
    /// Target longitude in degrees (east positive, relative to TX at lon=0).
    pub target_lon_deg: f64,

    // ---- Transmitter ----
    /// Transmitter latitude in degrees (default: 40.0).
    pub tx_lat_deg: f64,

    // ---- Search dimensions ----
    /// Frequency in MHz. Fixed value or `Range { min, max, step }`.
    pub freq_mhz: SearchSpec,
    /// Azimuth in degrees. Fixed value or `Range { min, max, step }`.
    pub azimuth_deg: SearchSpec,
    /// Ray mode: extraordinary (-1) or ordinary (+1).
    pub ray_mode: f64,

    // ---- Elevation search ----
    /// Minimum elevation angle to search (degrees, default: 3.0).
    pub elev_min: f64,
    /// Maximum elevation angle to search (degrees, default: 85.0).
    pub elev_max: f64,
    /// Coarse sweep step size in degrees (default: 2.0).
    pub coarse_step: f64,

    // ---- Convergence ----
    /// Required accuracy: max great-circle distance from landing to target (km, default: 5.0).
    pub error_limit_km: f64,
    /// Maximum bisection iterations per bracket (default: 30).
    pub max_bisect_iters: usize,
    /// Maximum Nelder-Mead iterations for 2D polish (default: 100).
    pub max_nm_iters: usize,

    // ---- Ray tracing ----
    /// Maximum hops to allow (default: 1).
    pub max_hops: u8,
    /// Integration step size (default: 5.0).
    pub step_size: f64,
    /// Maximum integration steps per ray (default: 500).
    pub max_steps: usize,
    /// Whether to include the full ray path in solutions (default: false).
    pub include_ray_path: bool,

    // ---- Physics ----
    /// Physics model parameters.
    pub params: ModelParams,
}

impl Default for TargetConfig {
    fn default() -> Self {
        Self {
            target_lat_deg: 50.0,
            target_lon_deg: 0.0,
            tx_lat_deg: 40.0,
            freq_mhz: SearchSpec::Fixed(10.0),
            azimuth_deg: SearchSpec::Fixed(0.0),
            ray_mode: -1.0, // X-mode
            elev_min: 3.0,
            elev_max: 85.0,
            coarse_step: 2.0,
            error_limit_km: 5.0,
            max_bisect_iters: 30,
            max_nm_iters: 100,
            max_hops: 1,
            step_size: 5.0,
            max_steps: 500,
            include_ray_path: false,
            params: ModelParams::default(),
        }
    }
}

/// A single solution found by the solver.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TargetSolution {
    /// Launch elevation angle in degrees.
    pub elevation_deg: f64,
    /// Launch azimuth angle in degrees.
    pub azimuth_deg: f64,
    /// Frequency in MHz.
    pub freq_mhz: f64,
    /// Landing latitude in degrees.
    pub landing_lat_deg: f64,
    /// Landing longitude in degrees.
    pub landing_lon_deg: f64,
    /// Great-circle distance error from landing to target in km.
    pub error_km: f64,
    /// Total ground range in km.
    pub range_km: f64,
    /// Peak altitude reached in km.
    pub max_height_km: f64,
    /// Number of hops completed.
    pub hops: u8,
    /// Total absorption in dB.
    pub absorption: f64,
    /// Group path (dimensionless integration variable).
    pub group_path: f64,
    /// Phase path.
    pub phase_path: f64,
    /// Full ray path (only populated if `include_ray_path` is true).
    pub ray_path: Option<Vec<TracePoint>>,
}

/// Result of the target location solver.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TargetResult {
    /// All solutions found within the error limit, sorted by ascending error.
    pub solutions: Vec<TargetSolution>,
    /// Best solution (alias for `solutions[0]`), if any.
    pub best: Option<TargetSolution>,
    /// Wall-clock time in milliseconds.
    pub elapsed_ms: f64,
    /// Total number of rays traced during the solve.
    pub rays_traced: usize,
}

// ============================================================
// Geodesic Helpers
// ============================================================

const DEG2RAD: f64 = PI / 180.0;
const RAD2DEG: f64 = 180.0 / PI;

/// Haversine great-circle distance in km between two lat/lon points (degrees).
fn haversine_km(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    let (la1, lo1) = (lat1 * DEG2RAD, lon1 * DEG2RAD);
    let (la2, lo2) = (lat2 * DEG2RAD, lon2 * DEG2RAD);
    let dlat = la2 - la1;
    let dlon = lo2 - lo1;
    let a = (dlat / 2.0).sin().powi(2) + la1.cos() * la2.cos() * (dlon / 2.0).sin().powi(2);
    2.0 * EARTH_RADIUS * a.sqrt().asin()
}

/// Initial bearing from point 1 to point 2 in degrees (0 = north, clockwise).
#[allow(dead_code)]
fn initial_bearing(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    let (la1, lo1) = (lat1 * DEG2RAD, lon1 * DEG2RAD);
    let (la2, lo2) = (lat2 * DEG2RAD, lon2 * DEG2RAD);
    let dlon = lo2 - lo1;
    let x = dlon.sin() * la2.cos();
    let y = la1.cos() * la2.sin() - la1.sin() * la2.cos() * dlon.cos();
    (x.atan2(y) * RAD2DEG + 360.0) % 360.0
}

// ============================================================
// Internal: fire a single ray and extract landing info
// ============================================================

/// Outcome of a single ray trace for the solver.
#[derive(Debug, Clone)]
struct RayOutcome {
    returned: bool,
    landing_lat: f64,
    landing_lon: f64,
    range_km: f64,
    max_height: f64,
    absorption: f64,
    group_path: f64,
    phase_path: f64,
    hops: u8,
    points: Option<Vec<TracePoint>>,
}

/// Fire a ray and return its landing outcome.
fn fire_ray(
    freq: f64,
    ray_mode: f64,
    elev: f64,
    az: f64,
    tx_lat: f64,
    config: &TargetConfig,
    keep_path: bool,
) -> Option<RayOutcome> {
    let print_every = if keep_path { 1 } else { 100 };

    let mut total_range = 0.0f64;
    let mut max_h = 0.0f64;
    let mut total_absorption = 0.0f64;
    let mut total_group = 0.0f64;
    let mut total_phase = 0.0f64;
    let mut returned = false;
    let mut hops: u8 = 0;
    let mut cur_lat = tx_lat;
    let mut landing_lat = 0.0f64;
    let mut landing_lon = 0.0f64;
    let mut all_pts: Vec<TracePoint> = Vec::new();

    for _hop in 0..config.max_hops {
        let result = trace_ray(
            freq,
            ray_mode,
            elev,
            az,
            cur_lat,
            2, // RK4+AM
            config.step_size,
            config.max_steps,
            1e-4,
            2e-6,
            100.0,
            &config.params,
            print_every,
        )
        .ok()?;

        if result.max_height > max_h {
            max_h = result.max_height;
        }

        if keep_path {
            all_pts.extend(result.points.iter().cloned());
        }

        if result.returned_to_ground {
            hops += 1;
            total_range += result.ground_range_km;
            returned = true;

            if let Some(last) = result.points.last() {
                landing_lat = last.lat_deg;
                landing_lon = last.lon_deg;
                total_absorption += last.absorption;
                total_group = last.group_path;
                total_phase = last.phase_path;
                cur_lat = last.lat_deg;
            }

            if _hop >= config.max_hops - 1 {
                break;
            }
        } else {
            break;
        }
    }

    Some(RayOutcome {
        returned,
        landing_lat,
        landing_lon,
        range_km: total_range,
        max_height: max_h,
        absorption: total_absorption,
        group_path: total_group,
        phase_path: total_phase,
        hops,
        points: if keep_path { Some(all_pts) } else { None },
    })
}

/// Compute the signed range error: positive if ray overshot, negative if undershot
/// (measured along the TX→target bearing direction).
fn signed_range_error(
    landing_lat: f64,
    landing_lon: f64,
    target_lat: f64,
    target_lon: f64,
    tx_lat: f64,
) -> f64 {
    let target_range = haversine_km(tx_lat, 0.0, target_lat, target_lon);
    let landing_range = haversine_km(tx_lat, 0.0, landing_lat, landing_lon);
    landing_range - target_range
}

// ============================================================
// Phase 1: Coarse Fan Sweep
// ============================================================

/// A bracket where the target range is straddled between two elevation angles.
#[derive(Debug, Clone)]
#[allow(dead_code)]
struct Bracket {
    elev_lo: f64,
    elev_hi: f64,
    err_lo: f64,
    err_hi: f64,
}

/// Phase 1: sweep elevations at coarse step, find brackets where range error crosses zero.
fn coarse_sweep(
    freq: f64,
    az: f64,
    config: &TargetConfig,
    rays_traced: &mut usize,
) -> Vec<Bracket> {
    let mut elevations = Vec::new();
    let mut e = config.elev_min;
    while e <= config.elev_max + 0.001 {
        elevations.push(e);
        e += config.coarse_step;
    }

    // Trace all coarse elevations
    let outcomes: Vec<(f64, Option<f64>)> = elevations
        .iter()
        .map(|&elev| {
            let outcome = fire_ray(freq, config.ray_mode, elev, az, config.tx_lat_deg, config, false);
            let signed_err = outcome.and_then(|o| {
                if o.returned {
                    Some(signed_range_error(
                        o.landing_lat,
                        o.landing_lon,
                        config.target_lat_deg,
                        config.target_lon_deg,
                        config.tx_lat_deg,
                    ))
                } else {
                    None
                }
            });
            (elev, signed_err)
        })
        .collect();

    *rays_traced += outcomes.len();

    // Find brackets: adjacent rays where signed error changes sign
    let mut brackets = Vec::new();
    for i in 0..outcomes.len().saturating_sub(1) {
        let (elev_lo, ref err_a) = outcomes[i];
        let (elev_hi, ref err_b) = outcomes[i + 1];

        match (err_a, err_b) {
            // Classic sign-change bracket: both returned, opposite sign errors
            (Some(ea), Some(eb)) if ea * eb < 0.0 => {
                brackets.push(Bracket {
                    elev_lo,
                    elev_hi,
                    err_lo: *ea,
                    err_hi: *eb,
                });
            }
            // Escape-boundary bracket: ray undershot then next escaped.
            // The target might be reachable just below the escape angle.
            (Some(ea), None) if *ea < 0.0 => {
                brackets.push(Bracket {
                    elev_lo,
                    elev_hi,
                    err_lo: *ea,
                    err_hi: 1e6, // synthetic overshoot for escaped ray
                });
            }
            // Escape-boundary bracket: ray escaped then next returned with undershoot.
            // (less common but possible with multi-hop or irregular profiles)
            (None, Some(eb)) if *eb < 0.0 => {
                brackets.push(Bracket {
                    elev_lo,
                    elev_hi,
                    err_lo: 1e6, // synthetic overshoot for escaped ray
                    err_hi: *eb,
                });
            }
            _ => {}
        }
    }

    brackets
}

// ============================================================
// Phase 2: Bisection Refinement
// ============================================================

/// Phase 2: bisect within a bracket to find elevation that minimizes range error.
fn bisect_elevation(
    freq: f64,
    az: f64,
    bracket: &Bracket,
    config: &TargetConfig,
    rays_traced: &mut usize,
) -> Option<(f64, RayOutcome)> {
    let mut lo = bracket.elev_lo;
    let mut hi = bracket.elev_hi;
    let mut err_lo = bracket.err_lo;

    let mut best_elev = lo;
    let mut best_outcome: Option<RayOutcome> = None;
    let mut best_abs_err = f64::INFINITY;

    for _ in 0..config.max_bisect_iters {
        let mid = (lo + hi) / 2.0;
        *rays_traced += 1;

        let outcome = fire_ray(freq, config.ray_mode, mid, az, config.tx_lat_deg, config, false);
        match outcome {
            Some(o) if o.returned => {
                let err = signed_range_error(
                    o.landing_lat,
                    o.landing_lon,
                    config.target_lat_deg,
                    config.target_lon_deg,
                    config.tx_lat_deg,
                );
                let abs_err = haversine_km(
                    o.landing_lat,
                    o.landing_lon,
                    config.target_lat_deg,
                    config.target_lon_deg,
                );

                if abs_err < best_abs_err {
                    best_abs_err = abs_err;
                    best_elev = mid;
                    best_outcome = Some(o);
                }

                // Early exit if within tolerance
                if abs_err <= config.error_limit_km {
                    break;
                }

                if err * err_lo < 0.0 {
                    hi = mid;
                } else {
                    lo = mid;
                    err_lo = err;
                }
            }
            _ => {
                // Ray didn't return; try shrinking from the non-returning side
                hi = mid;
            }
        }

        if (hi - lo).abs() < 1e-6 {
            break;
        }
    }

    best_outcome.map(|o| (best_elev, o))
}

// ============================================================
// Phase 3: 2D Nelder-Mead Polish
// ============================================================

/// Phase 3: Nelder-Mead simplex optimization on (elevation, azimuth) to minimize
/// great-circle distance to the exact target point.
fn nelder_mead_2d(
    freq: f64,
    initial_elev: f64,
    initial_az: f64,
    config: &TargetConfig,
    rays_traced: &mut usize,
) -> Option<(f64, f64, RayOutcome)> {
    let alpha = 1.0; // reflection
    let gamma = 2.0; // expansion
    let rho = 0.5;   // contraction
    let sigma = 0.5;  // shrink

    // Objective: great-circle distance from landing to target
    let mut objective = |elev: f64, az: f64| -> (f64, Option<RayOutcome>) {
        *rays_traced += 1;
        let elev_clamped = elev.clamp(config.elev_min, config.elev_max);
        match fire_ray(freq, config.ray_mode, elev_clamped, az, config.tx_lat_deg, config, false) {
            Some(o) if o.returned => {
                let dist = haversine_km(
                    o.landing_lat,
                    o.landing_lon,
                    config.target_lat_deg,
                    config.target_lon_deg,
                );
                (dist, Some(o))
            }
            _ => (1e9, None), // penalty for non-returning rays
        }
    };

    // Initial simplex: triangle around starting point
    let elev_delta = 0.5; // degrees
    let az_delta = 1.0;   // degrees

    let mut simplex: [(f64, f64, f64, Option<RayOutcome>); 3] = {
        let (f0, o0) = objective(initial_elev, initial_az);
        let (f1, o1) = objective(initial_elev + elev_delta, initial_az);
        let (f2, o2) = objective(initial_elev, initial_az + az_delta);
        [
            (initial_elev, initial_az, f0, o0),
            (initial_elev + elev_delta, initial_az, f1, o1),
            (initial_elev, initial_az + az_delta, f2, o2),
        ]
    };

    for _ in 0..config.max_nm_iters {
        // Sort by objective value
        simplex.sort_by(|a, b| a.2.partial_cmp(&b.2).unwrap_or(std::cmp::Ordering::Equal));

        // Best value
        if simplex[0].2 <= config.error_limit_km {
            break; // good enough
        }

        // Centroid of all points except worst
        let cx = (simplex[0].0 + simplex[1].0) / 2.0;
        let cy = (simplex[0].1 + simplex[1].1) / 2.0;

        // Reflection
        let rx = cx + alpha * (cx - simplex[2].0);
        let ry = cy + alpha * (cy - simplex[2].1);
        let (fr, or) = objective(rx, ry);

        if fr < simplex[1].2 && fr >= simplex[0].2 {
            // Accept reflection
            simplex[2] = (rx, ry, fr, or);
            continue;
        }

        if fr < simplex[0].2 {
            // Try expansion
            let ex = cx + gamma * (rx - cx);
            let ey = cy + gamma * (ry - cy);
            let (fe, oe) = objective(ex, ey);
            if fe < fr {
                simplex[2] = (ex, ey, fe, oe);
            } else {
                simplex[2] = (rx, ry, fr, or);
            }
            continue;
        }

        // Contraction
        let kx = cx + rho * (simplex[2].0 - cx);
        let ky = cy + rho * (simplex[2].1 - cy);
        let (fk, ok) = objective(kx, ky);
        if fk < simplex[2].2 {
            simplex[2] = (kx, ky, fk, ok);
            continue;
        }

        // Shrink: move all points toward best
        let best = (simplex[0].0, simplex[0].1);
        for item in simplex.iter_mut().skip(1) {
            let nx = best.0 + sigma * (item.0 - best.0);
            let ny = best.1 + sigma * (item.1 - best.1);
            let (fv, ov) = objective(nx, ny);
            *item = (nx, ny, fv, ov);
        }
    }

    // Sort final
    simplex.sort_by(|a, b| a.2.partial_cmp(&b.2).unwrap_or(std::cmp::Ordering::Equal));
    let best = &simplex[0];
    best.3.clone().map(|o| (best.0, best.1, o))
}

// ============================================================
// Public API
// ============================================================

/// Solve for the ray launch parameters that hit the target location.
///
/// Uses a 3-phase approach:
/// 1. Coarse fan sweep to find elevation brackets
/// 2. Bisection refinement within each bracket
/// 3. 2D Nelder-Mead polish on (elevation, azimuth)
///
/// Returns all solutions within `error_limit_km`, sorted by ascending error.
#[tracing::instrument(skip(config), level = "info")]
pub fn solve_target(config: &TargetConfig) -> Result<TargetResult, TraceError> {
    #[cfg(not(target_arch = "wasm32"))]
    let start = std::time::Instant::now();

    let mut total_rays: usize = 0;
    let mut all_solutions: Vec<TargetSolution> = Vec::new();

    // Expand frequency spec
    let frequencies = match &config.freq_mhz {
        SearchSpec::Fixed(f) => vec![*f],
        SearchSpec::Range { min, max, step } => {
            let mut v = Vec::new();
            let mut f = *min;
            while f <= *max + 0.001 {
                v.push(f);
                f += step;
            }
            v
        }
    };

    // Expand azimuth spec
    let azimuths = match &config.azimuth_deg {
        SearchSpec::Fixed(a) => vec![*a],
        SearchSpec::Range { min, max, step } => {
            let mut v = Vec::new();
            let mut a = *min;
            while a <= *max + 0.001 {
                v.push(a);
                a += step;
            }
            v
        }
    };

    // If the user gives fixed azimuth, we can also auto-compute a good bearing
    // from TX to target as a starting point for the search.
    let auto_az = initial_bearing(config.tx_lat_deg, 0.0, config.target_lat_deg, config.target_lon_deg);

    // Build all (freq, az) combos
    let combos: Vec<(f64, f64)> = frequencies
        .iter()
        .flat_map(|&f| azimuths.iter().map(move |&a| (f, a)))
        .collect();

    // Also include the auto-computed bearing if azimuth is fixed and it differs
    let mut search_combos = combos.clone();
    if let SearchSpec::Fixed(a) = &config.azimuth_deg {
        if (auto_az - a).abs() > 1.0 {
            for &f in &frequencies {
                search_combos.push((f, auto_az));
            }
        }
    }

    // Process each (freq, az) combo
    #[cfg(not(target_arch = "wasm32"))]
    let iter = search_combos.par_iter();
    #[cfg(target_arch = "wasm32")]
    let iter = search_combos.iter();

    let combo_results: Vec<(Vec<TargetSolution>, usize)> = iter
        .map(|&(freq, az)| {
            let mut rays = 0usize;
            let mut solutions = Vec::new();

            // Phase 1: Coarse sweep
            let brackets = coarse_sweep(freq, az, config, &mut rays);

            // Phase 2: Bisection for each bracket
            for bracket in &brackets {
                if let Some((elev, outcome)) = bisect_elevation(freq, az, bracket, config, &mut rays) {
                    let error = haversine_km(
                        outcome.landing_lat,
                        outcome.landing_lon,
                        config.target_lat_deg,
                        config.target_lon_deg,
                    );

                    // Phase 3: Nelder-Mead polish if not yet within tolerance
                    let (final_elev, final_az, final_outcome, final_error) = if error > config.error_limit_km {
                        if let Some((nm_elev, nm_az, nm_outcome)) =
                            nelder_mead_2d(freq, elev, az, config, &mut rays)
                        {
                            let nm_err = haversine_km(
                                nm_outcome.landing_lat,
                                nm_outcome.landing_lon,
                                config.target_lat_deg,
                                config.target_lon_deg,
                            );
                            if nm_err < error {
                                (nm_elev, nm_az, nm_outcome, nm_err)
                            } else {
                                (elev, az, outcome, error)
                            }
                        } else {
                            (elev, az, outcome, error)
                        }
                    } else {
                        // Already within tolerance, but still try a quick polish
                        if let Some((nm_elev, nm_az, nm_outcome)) =
                            nelder_mead_2d(freq, elev, az, config, &mut rays)
                        {
                            let nm_err = haversine_km(
                                nm_outcome.landing_lat,
                                nm_outcome.landing_lon,
                                config.target_lat_deg,
                                config.target_lon_deg,
                            );
                            if nm_err < error {
                                (nm_elev, nm_az, nm_outcome, nm_err)
                            } else {
                                (elev, az, outcome, error)
                            }
                        } else {
                            (elev, az, outcome, error)
                        }
                    };

                    if final_error <= config.error_limit_km {
                        // Re-trace with full path if requested
                        let ray_path = if config.include_ray_path {
                            fire_ray(
                                freq,
                                config.ray_mode,
                                final_elev,
                                final_az,
                                config.tx_lat_deg,
                                config,
                                true,
                            )
                            .and_then(|o| o.points)
                        } else {
                            None
                        };

                        solutions.push(TargetSolution {
                            elevation_deg: final_elev,
                            azimuth_deg: final_az,
                            freq_mhz: freq,
                            landing_lat_deg: final_outcome.landing_lat,
                            landing_lon_deg: final_outcome.landing_lon,
                            error_km: final_error,
                            range_km: final_outcome.range_km,
                            max_height_km: final_outcome.max_height,
                            hops: final_outcome.hops,
                            absorption: final_outcome.absorption,
                            group_path: final_outcome.group_path,
                            phase_path: final_outcome.phase_path,
                            ray_path,
                        });
                    }
                }
            }

            (solutions, rays)
        })
        .collect();

    for (solutions, rays) in combo_results {
        all_solutions.extend(solutions);
        total_rays += rays;
    }

    // Sort by error ascending
    all_solutions.sort_by(|a, b| a.error_km.partial_cmp(&b.error_km).unwrap_or(std::cmp::Ordering::Equal));

    // Deduplicate: remove solutions with very similar elevation/azimuth
    all_solutions.dedup_by(|a, b| {
        (a.elevation_deg - b.elevation_deg).abs() < 0.01
            && (a.azimuth_deg - b.azimuth_deg).abs() < 0.01
            && (a.freq_mhz - b.freq_mhz).abs() < 0.01
    });

    let best = all_solutions.first().cloned();

    #[cfg(not(target_arch = "wasm32"))]
    let elapsed_ms = start.elapsed().as_secs_f64() * 1000.0;
    #[cfg(target_arch = "wasm32")]
    let elapsed_ms = 0.0;

    tracing::info!(
        solutions = all_solutions.len(),
        rays_traced = total_rays,
        elapsed_ms = elapsed_ms,
        best_error_km = best.as_ref().map(|s| s.error_km).unwrap_or(f64::INFINITY),
        "Target solve complete"
    );

    Ok(TargetResult {
        solutions: all_solutions,
        best,
        elapsed_ms,
        rays_traced: total_rays,
    })
}
