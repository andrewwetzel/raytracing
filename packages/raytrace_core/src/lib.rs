//! ionotrace — High-performance ionospheric ray tracing engine
//!
//! Rust implementation of the OT 75-76 ray tracing algorithm with WASM bindings.
//! Simulates HF radio wave propagation through a magnetized, collisional plasma
//! using Hamilton's equations of motion.
//!
//! # Quick Start
//!
//! ```
//! use ionotrace::{TraceConfig, ModelParams};
//!
//! let config = TraceConfig::new(10.0, 20.0); // 10 MHz, 20° elevation
//! let result = config.trace().unwrap();
//!
//! println!("Max height: {:.2} km", result.max_height);
//! println!("Ground range: {:.1} km", result.ground_range_km);
//! println!("Returned to ground: {}", result.returned_to_ground);
//! ```
//!
//! # Model Selection
//!
//! Override physics models via [`ModelParams`]:
//!
//! ```
//! use ionotrace::{TraceConfig, ModelParams};
//! use ionotrace::params::{ElectronDensityModel, MagneticFieldModel};
//!
//! let mut config = TraceConfig::new(15.0, 30.0);
//! config.params = ModelParams::builder()
//!     .ed_model(ElectronDensityModel::DualChapman)
//!     .mag_model(MagneticFieldModel::Igrf14)
//!     .build()
//!     .unwrap();
//! ```

#[cfg(target_arch = "wasm32")]
use serde::{Deserialize, Serialize};
#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;

pub(crate) mod complex;
pub mod error;
pub mod export;
pub mod fan;
pub(crate) mod hamiltonian;
pub(crate) mod integrator;
pub mod models;
pub mod params;
pub mod target;
pub mod tracer;

// Public re-exports for ergonomic API
pub use error::TraceError;
pub use export::{export_fan_trace_csv, export_json, export_trace_csv};
pub use fan::{fan_trace, FanRay, FanRayPoint, FanTraceConfig, FanTraceResult};
pub use params::ModelParams;
pub use target::{solve_target, SearchSpec, TargetConfig, TargetResult, TargetSolution};
pub use tracer::{TraceConfig, TracePoint, TraceResult};

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

#[cfg(target_arch = "wasm32")]
fn parse_ed_model(v: u8) -> ElectronDensityModel {
    match v {
        1 => ElectronDensityModel::Elect1,
        2 => ElectronDensityModel::Linear,
        3 => ElectronDensityModel::QuasiParabolic,
        4 => ElectronDensityModel::VarChapman,
        5 => ElectronDensityModel::DualChapman,
        _ => ElectronDensityModel::Chapman,
    }
}

#[cfg(target_arch = "wasm32")]
fn parse_mag_model(v: u8) -> MagneticFieldModel {
    match v {
        1 => MagneticFieldModel::Constant,
        2 => MagneticFieldModel::Cubic,
        3 => MagneticFieldModel::Igrf14,
        _ => MagneticFieldModel::Dipole,
    }
}

#[cfg(target_arch = "wasm32")]
fn parse_rindex_model(v: u8) -> RefractiveIndexModel {
    match v {
        1 => RefractiveIndexModel::NoFieldNoCollisions,
        2 => RefractiveIndexModel::NoFieldWithCollisions,
        3 => RefractiveIndexModel::WithFieldNoCollisions,
        _ => RefractiveIndexModel::Full,
    }
}

#[cfg(target_arch = "wasm32")]
fn parse_pert_model(v: u8) -> PerturbationModel {
    match v {
        1 => PerturbationModel::Torus,
        2 => PerturbationModel::Trough,
        3 => PerturbationModel::Shock,
        4 => PerturbationModel::Bulge,
        5 => PerturbationModel::Exponential,
        _ => PerturbationModel::None,
    }
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
            }))
            .unwrap_or_default();
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
    let ed_model = parse_ed_model(req.ed_model.unwrap_or(0));
    let mag_model = parse_mag_model(req.mag_model.unwrap_or(0));
    let rindex_model = parse_rindex_model(req.rindex_model.unwrap_or(0));
    let pert_model = parse_pert_model(req.pert_model.unwrap_or(0));

    let params = ModelParams {
        earth_r: EARTH_RADIUS,
        ed_model,
        mag_model,
        col_model: CollisionModel::default(),
        rindex_model,
        fc,
        hm,
        sh,
        alpha: 0.5,
        ed_a: 0.0,
        ed_b: 0.0,
        ed_c: 0.0,
        ed_e: 0.0,
        ym: 100.0,
        fc2: 0.0,
        hm2: 0.0,
        sh2: 0.0,
        chi: 3.0,
        fh,
        dip: 0.0,
        epoch_year: 2025.0,
        nu1: 1_050_000.0,
        h1: 100.0,
        a1: 0.148,
        nu2: 30.0,
        h2: 140.0,
        a2: 0.0183,
        pert_model,
        p1: 0.0,
        p2: 0.0,
        p3: 0.0,
        p4: 0.0,
        p5: 0.0,
        p6: 0.0,
        p7: 0.0,
        p8: 0.0,
        p9: 0.0,
    };

    let fan_config = fan::FanTraceConfig {
        freq_mhz: req.freq_mhz,
        ray_mode: req.ray_mode,
        elev_min: req.elev_min,
        elev_max: req.elev_max,
        elev_step: req.elev_step,
        azimuth_deg,
        tx_lat_deg,
        step_size,
        max_steps,
        max_hops,
        params,
    };

    let result = fan::fan_trace(&fan_config).unwrap_or(fan::FanTraceResult {
        n_rays: 0,
        rays: Vec::new(),
    });

    let elapsed = js_sys::Date::now() - start;

    let response = FanTraceResponse {
        rays: result.rays,
        n_rays: result.n_rays,
        elapsed_ms: (elapsed * 100.0).round() / 100.0,
        freq_mhz: req.freq_mhz,
        fc,
        hm,
    };

    serde_json::to_string(&response).unwrap_or_default()
}

/// Solve for launch parameters to hit a target location (called from JavaScript).
///
/// Accepts a JSON string request, returns a JSON string response.
#[cfg(target_arch = "wasm32")]
#[wasm_bindgen]
pub fn solve_target_wasm(request_json: &str) -> String {
    let config: TargetConfig = match serde_json::from_str(request_json) {
        Ok(c) => c,
        Err(e) => {
            return serde_json::to_string(&serde_json::json!({
                "error": format!("Invalid request: {}", e),
                "solutions": [],
                "rays_traced": 0
            }))
            .unwrap_or_default();
        }
    };

    let start = js_sys::Date::now();

    let result = match solve_target(&config) {
        Ok(mut r) => {
            r.elapsed_ms = (js_sys::Date::now() - start * 100.0).round() / 100.0;
            r
        }
        Err(e) => {
            return serde_json::to_string(&serde_json::json!({
                "error": format!("{}", e),
                "solutions": [],
                "rays_traced": 0
            }))
            .unwrap_or_default();
        }
    };

    serde_json::to_string(&result).unwrap_or_default()
}
