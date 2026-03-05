//! Fan tracing — sweep a range of elevation angles in one call.
//!
//! A "fan trace" fires multiple rays at different elevation angles through
//! the same ionosphere, producing a complete picture of how ray paths vary
//! with launch angle. On native builds, the sweep is parallelized via Rayon.
//!
//! # Example
//!
//! ```
//! use ionotrace::{fan_trace, FanTraceConfig};
//!
//! let result = fan_trace(&FanTraceConfig::default()).unwrap();
//!
//! for ray in &result.rays {
//!     if ray.ground {
//!         println!("{:.0}° → {:.0} km, max height {:.0} km",
//!             ray.elev, ray.range_km, ray.max_h);
//!     }
//! }
//! ```

use crate::error::TraceError;
use crate::params::ModelParams;
use crate::tracer::trace_ray;
use serde::{Deserialize, Serialize};

#[cfg(not(target_arch = "wasm32"))]
use rayon::prelude::*;

/// Configuration for a fan of rays.
///
/// Use struct update syntax with [`Default`] for concise setup:
///
/// ```
/// use ionotrace::FanTraceConfig;
///
/// let config = FanTraceConfig {
///     freq_mhz: 15.0,
///     elev_min: 10.0,
///     elev_max: 70.0,
///     ..FanTraceConfig::default()
/// };
/// ```
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FanTraceConfig {
    /// Transmit frequency in MHz. Must be > 0.
    pub freq_mhz: f64,
    /// Ray mode: `1.0` = ordinary, `-1.0` = extraordinary. See [`params::RayMode`](crate::params::RayMode).
    pub ray_mode: f64,
    /// Minimum elevation angle in degrees.
    pub elev_min: f64,
    /// Maximum elevation angle in degrees.
    pub elev_max: f64,
    /// Step between elevation angles in degrees.
    pub elev_step: f64,
    /// Azimuth angle in degrees (0 = north, 90 = east).
    pub azimuth_deg: f64,
    /// Transmitter latitude in degrees (positive = north).
    pub tx_lat_deg: f64,
    /// Integration step size in km.
    pub step_size: f64,
    /// Maximum integration steps per ray.
    pub max_steps: usize,
    /// Maximum number of ground-reflection hops (1–5).
    pub max_hops: u8,
    /// Physics model parameters. See [`ModelParams`].
    pub params: ModelParams,
}

impl Default for FanTraceConfig {
    fn default() -> Self {
        Self {
            freq_mhz: 10.0,
            ray_mode: 1.0,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: 5.0,
            azimuth_deg: 0.0,
            tx_lat_deg: 40.0,
            step_size: 5.0,
            max_steps: 500,
            max_hops: 1,
            params: ModelParams::default(),
        }
    }
}

/// A point along a fan ray trajectory.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FanRayPoint {
    /// Height above Earth's surface in km.
    pub h: f64,
    /// Integration time parameter.
    pub t: f64,
    /// Geographic latitude in degrees.
    pub lat: f64,
    /// Geographic longitude in degrees (relative to TX).
    pub lon: f64,
    /// Cumulative ground range in km.
    pub range: f64,
}

/// Summary of a single completed hop within a ray trace.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HopSummary {
    /// Cumulative ground range after this hop in km.
    pub range_km: f64,
    /// Landing latitude in degrees.
    pub lat: f64,
    /// Landing longitude in degrees.
    pub lon: f64,
    /// Cumulative absorption after this hop in dB.
    pub absorption: f64,
}

/// A single completed ray within a fan trace.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FanRay {
    /// Launch elevation angle in degrees.
    pub elev: f64,
    /// Maximum height reached in km.
    pub max_h: f64,
    /// Whether the ray returned to ground.
    pub ground: bool,
    /// Total ground range in km (0 if ray escaped).
    pub range_km: f64,
    /// Number of completed ground-reflection hops.
    pub hops: u8,
    /// Total absorption in dB.
    pub absorption: f64,
    /// Landing latitude in degrees (geographic). 0.0 if ray escaped.
    pub landing_lat: f64,
    /// Landing longitude in degrees (relative, phi=0 at TX). 0.0 if ray escaped.
    pub landing_lon: f64,
    /// Full ray path as a series of points.
    pub pts: Vec<FanRayPoint>,
    /// Per-hop landing summaries.
    pub hop_summaries: Vec<HopSummary>,
}

/// The result of a complete fan trace operation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FanTraceResult {
    /// All traced rays, one per elevation angle.
    pub rays: Vec<FanRay>,
    /// Total number of rays traced.
    pub n_rays: usize,
}

/// Trace a fan of rays through the ionosphere.
#[tracing::instrument(skip(config), level = "info")]
pub fn fan_trace(config: &FanTraceConfig) -> Result<FanTraceResult, TraceError> {
    // Input validation
    if config.freq_mhz <= 0.0 {
        return Err(TraceError::InvalidFrequency(config.freq_mhz));
    }
    if config.elev_step <= 0.0 {
        return Err(TraceError::InvalidStepSize(config.elev_step));
    }
    if config.max_steps == 0 {
        return Err(TraceError::InvalidMaxSteps(config.max_steps));
    }
    if config.elev_min > config.elev_max {
        return Err(TraceError::InvalidElevation(config.elev_min));
    }

    tracing::info!(
        freq_mhz = config.freq_mhz,
        elev_min = config.elev_min,
        elev_max = config.elev_max,
        "Starting fan trace sweep"
    );
    let mut elevations = Vec::new();
    let mut e = config.elev_min;
    while e <= config.elev_max + 0.01 {
        elevations.push(e);
        e += config.elev_step;
    }

    #[cfg(not(target_arch = "wasm32"))]
    let iter = elevations.into_par_iter();
    #[cfg(target_arch = "wasm32")]
    let iter = elevations.into_iter();

    let rays: Vec<FanRay> = iter
        .filter_map(|elev| {
            let mut all_pts: Vec<FanRayPoint> = Vec::new();
            let mut total_range = 0.0f64;
            let mut max_h = 0.0f64;
            let mut returned = false;
            let mut hops_completed: u8 = 0;
            let mut total_absorption = 0.0f64;
            let mut hop_summaries = Vec::new();

            let mut cur_lat = config.tx_lat_deg;
            // Accumulated longitude offset: each hop starts at phi=0,
            // so we must add the ending lon of the previous hop.
            let mut lon_offset = 0.0f64;

            for _hop in 0..config.max_hops {
                let result = match trace_ray(
                    config.freq_mhz,
                    config.ray_mode,
                    elev,
                    config.azimuth_deg,
                    cur_lat,
                    2,
                    config.step_size,
                    config.max_steps,
                    1e-4,
                    2e-6,
                    100.0,
                    &config.params,
                    1,
                ) {
                    Ok(r) => r,
                    Err(_) => break, // Stop tracing this ray on error
                };

                if result.max_height > max_h {
                    max_h = result.max_height;
                }

                for pt in &result.points {
                    all_pts.push(FanRayPoint {
                        h: (pt.height_km * 100.0).round() / 100.0,
                        t: (pt.t * 100.0).round() / 100.0,
                        lat: (pt.lat_deg * 10000.0).round() / 10000.0,
                        lon: ((pt.lon_deg + lon_offset) * 10000.0).round() / 10000.0,
                        range: ((total_range + pt.ground_range_km) * 10.0).round() / 10.0,
                    });
                }

                if result.returned_to_ground {
                    hops_completed += 1;
                    total_range += result.ground_range_km;
                    returned = true;

                    if let Some(last_pt) = result.points.last() {
                        total_absorption += last_pt.absorption;
                        hop_summaries.push(HopSummary {
                            range_km: (total_range * 10.0).round() / 10.0,
                            lat: (last_pt.lat_deg * 10000.0).round() / 10000.0,
                            lon: ((last_pt.lon_deg + lon_offset) * 10000.0).round() / 10000.0,
                            absorption: (total_absorption * 10000.0).round() / 10000.0,
                        });
                    }

                    if _hop < config.max_hops - 1 {
                        if let Some(last_pt) = result.points.last() {
                            cur_lat = last_pt.lat_deg;
                            lon_offset += last_pt.lon_deg;
                        }
                    } else {
                        break;
                    }
                } else {
                    break;
                }
            }

            // Extract landing coordinates from last point
            let (landing_lat, landing_lon) = if returned {
                if let Some(last) = all_pts.last() {
                    (last.lat, last.lon)
                } else {
                    (0.0, 0.0)
                }
            } else {
                (0.0, 0.0)
            };

            Some(FanRay {
                elev: (elev * 10.0).round() / 10.0,
                max_h: (max_h * 100.0).round() / 100.0,
                ground: returned,
                range_km: (total_range * 10.0).round() / 10.0,
                hops: hops_completed,
                absorption: (total_absorption * 10000.0).round() / 10000.0,
                landing_lat,
                landing_lon,
                pts: all_pts,
                hop_summaries,
            })
        })
        .collect();

    Ok(FanTraceResult {
        n_rays: rays.len(),
        rays,
    })
}
