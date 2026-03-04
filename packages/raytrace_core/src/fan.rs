//! Fan tracing API for computing multiple rays across an elevation spread.

use crate::error::TraceError;
use crate::params::ModelParams;
use crate::tracer::trace_ray;
use serde::{Deserialize, Serialize};

#[cfg(not(target_arch = "wasm32"))]
use rayon::prelude::*;

/// Configuration for a fan of rays.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FanTraceConfig {
    pub freq_mhz: f64,
    pub ray_mode: f64,
    pub elev_min: f64,
    pub elev_max: f64,
    pub elev_step: f64,
    pub azimuth_deg: f64,
    pub tx_lat_deg: f64,
    pub step_size: f64,
    pub max_steps: usize,
    pub max_hops: u8,
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
    pub h: f64,
    pub t: f64,
    pub lat: f64,
    pub lon: f64,
    pub range: f64,
}

/// A single completed ray within a fan trace.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FanRay {
    pub elev: f64,
    pub max_h: f64,
    pub ground: bool,
    pub range_km: f64,
    pub hops: u8,
    pub absorption: f64,
    pub pts: Vec<FanRayPoint>,
}

/// The result of a complete fan trace operation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FanTraceResult {
    pub rays: Vec<FanRay>,
    pub n_rays: usize,
}

/// Trace a fan of rays through the ionosphere.
#[tracing::instrument(skip(config), level = "info")]
pub fn fan_trace(config: &FanTraceConfig) -> Result<FanTraceResult, TraceError> {
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

            let mut cur_lat = config.tx_lat_deg;

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
                        lon: (pt.lon_deg * 10000.0).round() / 10000.0,
                        range: ((total_range + pt.ground_range_km) * 10.0).round() / 10.0,
                    });
                }

                if result.returned_to_ground {
                    hops_completed += 1;
                    total_range += result.ground_range_km;
                    returned = true;

                    if let Some(last_pt) = result.points.last() {
                        total_absorption += last_pt.absorption;
                    }

                    if _hop < config.max_hops - 1 {
                        if let Some(last_pt) = result.points.last() {
                            cur_lat = last_pt.lat_deg;
                        }
                    } else {
                        break;
                    }
                } else {
                    break;
                }
            }

            Some(FanRay {
                elev: (elev * 10.0).round() / 10.0,
                max_h: (max_h * 100.0).round() / 100.0,
                ground: returned,
                range_km: (total_range * 10.0).round() / 10.0,
                hops: hops_completed,
                absorption: (total_absorption * 10000.0).round() / 10000.0,
                pts: all_pts,
            })
        })
        .collect();

    Ok(FanTraceResult {
        n_rays: rays.len(),
        rays,
    })
}
