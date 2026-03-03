//! raytrace_core — High-performance ionospheric ray tracing engine
//!
//! Rust implementation of the OT 75-76 ray tracing algorithm with WASM bindings.
//! Ports the performance-critical inner loop: HAMLTN → AHWFWC → RKAM.

#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;
#[cfg(target_arch = "wasm32")]
use serde::{Serialize, Deserialize};

pub mod params;
pub mod complex;
pub mod models;
pub mod hamiltonian;
pub mod integrator;
pub mod tracer;

#[cfg(target_arch = "wasm32")]
use params::*;
#[cfg(target_arch = "wasm32")]
use tracer::trace_ray;

// ============================================================
// WASM Bindings (only compiled for wasm32 target)
// ============================================================

/// Fan trace request from JavaScript
#[cfg(target_arch = "wasm32")]
#[derive(Deserialize)]
struct FanTraceRequest {
    freq_mhz: f64,
    ray_mode: f64,
    elev_min: f64,
    elev_max: f64,
    elev_step: f64,
    azimuth_deg: Option<f64>,
    tx_lat_deg: Option<f64>,
    fc: Option<f64>,
    hm: Option<f64>,
    sh: Option<f64>,
    fh: Option<f64>,
    step_size: Option<f64>,
    max_steps: Option<usize>,
    max_hops: Option<u8>,
    ed_model: Option<u8>,
    mag_model: Option<u8>,
    rindex_model: Option<u8>,
    pert_model: Option<u8>,
}

/// A single ray result for the frontend
#[cfg(target_arch = "wasm32")]
#[derive(Serialize)]
struct FanRay {
    elev: f64,
    max_h: f64,
    ground: bool,
    range_km: f64,
    hops: u8,
    absorption: f64,
    pts: Vec<FanRayPoint>,
}

/// A point in a fan ray for the frontend
#[cfg(target_arch = "wasm32")]
#[derive(Serialize)]
struct FanRayPoint {
    h: f64,
    t: f64,
    lat: f64,
    lon: f64,
    range: f64,
}

/// Fan trace response
#[cfg(target_arch = "wasm32")]
#[derive(Serialize)]
struct FanTraceResponse {
    rays: Vec<FanRay>,
    n_rays: usize,
    elapsed_ms: f64,
    freq_mhz: f64,
    fc: f64,
    hm: f64,
}

/// Trace a fan of rays through the ionosphere (called from JavaScript).
///
/// Accepts a JSON string request, returns a JSON string response.
#[cfg(target_arch = "wasm32")]
#[wasm_bindgen]
pub fn trace_fan_wasm(request_json: &str) -> String {
    let req: FanTraceRequest = match serde_json::from_str(request_json) {
        Ok(r) => r,
        Err(e) => {
            return serde_json::to_string(&serde_json::json!({
                "error": format!("Invalid request: {}", e),
                "rays": []
            })).unwrap_or_default();
        }
    };

    let start = js_sys::Date::now();

    let azimuth_deg = req.azimuth_deg.unwrap_or(0.0);
    let tx_lat_deg = req.tx_lat_deg.unwrap_or(40.0);
    let fc = req.fc.unwrap_or(10.0);
    let hm = req.hm.unwrap_or(250.0);
    let sh = req.sh.unwrap_or(100.0);
    let fh = req.fh.unwrap_or(0.8);
    let step_size = req.step_size.unwrap_or(5.0);
    let max_steps = req.max_steps.unwrap_or(500);
    let max_hops = req.max_hops.unwrap_or(1).max(1).min(5);
    let ed_model = req.ed_model.unwrap_or(0);
    let mag_model = req.mag_model.unwrap_or(0);
    let rindex_model = req.rindex_model.unwrap_or(0);
    let pert_model = req.pert_model.unwrap_or(0);

    let params = ModelParams {
        earth_r: EARTH_RADIUS,
        ed_model,
        mag_model,
        col_model: 0,
        rindex_model,
        fc, hm, sh,
        alpha: 0.5,
        ed_a: 0.0, ed_b: 0.0, ed_c: 0.0, ed_e: 0.0,
        ym: 100.0,
        fc2: 0.0, hm2: 0.0, sh2: 0.0,
        chi: 3.0,
        fh,
        dip: 0.0,
        epoch_year: 2025.0,
        nu1: 1_050_000.0, h1: 100.0, a1: 0.148,
        nu2: 30.0, h2: 140.0, a2: 0.0183,
        pert_model,
        p1: 0.0, p2: 0.0, p3: 0.0, p4: 0.0, p5: 0.0,
        p6: 0.0, p7: 0.0, p8: 0.0, p9: 0.0,
    };

    let mut rays = Vec::new();
    let mut elev = req.elev_min;
    while elev <= req.elev_max + 0.01 {
        let mut all_pts: Vec<FanRayPoint> = Vec::new();
        let mut total_range = 0.0f64;
        let mut max_h = 0.0f64;
        let mut _total_steps = 0usize;
        let mut returned = false;
        let mut hops_completed: u8 = 0;
        let mut total_absorption = 0.0f64;

        // Current hop parameters
        let cur_elev = elev;
        let mut cur_lat = tx_lat_deg;
        let cur_az = azimuth_deg;

        for _hop in 0..max_hops {
            let result = trace_ray(
                req.freq_mhz, req.ray_mode,
                cur_elev, cur_az, cur_lat,
                2, step_size, max_steps,
                1e-4, 2e-6, 100.0,
                &params, 1,
            );

            if result.max_height > max_h { max_h = result.max_height; }
            _total_steps += result.n_steps;

            // Add points with range offset
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
                // Accumulate absorption from last point
                if let Some(last_pt) = result.points.last() {
                    total_absorption += last_pt.absorption;
                }

                // If more hops remain, compute reflected state
                if _hop < max_hops - 1 {
                    // Get the final point's latitude for new launch position
                    if let Some(last_pt) = result.points.last() {
                        cur_lat = last_pt.lat_deg;
                    }
                    // Reflect: use the same elevation angle (specular reflection off flat ground)
                    // cur_elev stays the same, cur_az stays the same
                    // This is a good approximation for spherical Earth
                } else {
                    break;
                }
            } else {
                // Ray escaped — no more hops
                break;
            }
        }

        // If ray escaped (no ground return), get absorption from last point
        if !returned {
            if let Some(last_pt) = all_pts.last() {
                // Use the absorption we can get from the traced result
            }
        }

        rays.push(FanRay {
            elev: (elev * 10.0).round() / 10.0,
            max_h: (max_h * 100.0).round() / 100.0,
            ground: returned,
            range_km: (total_range * 10.0).round() / 10.0,
            hops: hops_completed,
            absorption: (total_absorption * 10000.0).round() / 10000.0,
            pts: all_pts,
        });

        elev += req.elev_step;
    }

    let elapsed = js_sys::Date::now() - start;
    let n_rays = rays.len();

    let response = FanTraceResponse {
        rays,
        n_rays,
        elapsed_ms: (elapsed * 100.0).round() / 100.0,
        freq_mhz: req.freq_mhz,
        fc,
        hm,
    };

    serde_json::to_string(&response).unwrap_or_default()
}
