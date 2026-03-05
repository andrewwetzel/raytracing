# ionotrace

[![Crates.io](https://img.shields.io/crates/v/ionotrace.svg)](https://crates.io/crates/ionotrace)
[![docs.rs](https://docs.rs/ionotrace/badge.svg)](https://docs.rs/ionotrace)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](../../LICENSE)

High-performance ionospheric ray tracing engine in Rust. Implements the OT 75-76 algorithm for simulating HF radio wave propagation through the Earth's ionosphere.

Compiles to **WebAssembly** for in-browser use, or runs natively as a Rust library.

## Features

- **Full 3D ray tracing** — Hamilton's equations in spherical coordinates (r, θ, φ)
- **RK4 / Adams-Moulton** adaptive integrator with automatic step-size control
- **6 electron density models** — Chapman, ELECT1, Linear, Quasi-Parabolic, Variable Chapman, Dual Chapman
- **4 magnetic field models** — Dipole, Constant, Cubic, IGRF-14 (degree-13 spherical harmonics)
- **4 refractive index models** — Full/partial Appleton-Hartree with/without collisions and magnetic field
- **6 perturbation models** — Torus, Trough, Shock, Bulge, Exponential
- **3 collision frequency models** — Double-exponential, Constant, Single-exponential
- **Multi-hop propagation** with ground reflection
- **Zero-allocation complex arithmetic** for inner-loop performance
- **WASM bindings** via `wasm-bindgen` (behind `cfg(target_arch = "wasm32")`)

## Usage (Rust)

```rust
use ionotrace::{TraceConfig, ModelParams, fan_trace, FanTraceConfig};
use ionotrace::params::{ElectronDensityModel, RayMode, MagneticFieldModel};

// Simple Single Ray: 10 MHz, 20° elevation, all defaults
let result = TraceConfig::new(10.0, 20.0).trace().unwrap();
println!("Max height: {:.2} km", result.max_height);

// Customized Sweep: Using the Builder pattern for physics configuration
let params = ModelParams::builder()
    .ed_model(ElectronDensityModel::DualChapman)
    .mag_model(MagneticFieldModel::Dipole)
    .fc(8.0)
    .hm(300.0)
    .build()
    .unwrap();

let sweep_config = FanTraceConfig {
    freq_mhz: 15.0,
    ray_mode: RayMode::Ordinary.to_sign(),
    elev_min: 5.0,
    elev_max: 85.0,
    elev_step: 1.0, 
    step_size: 5.0,
    max_steps: 1000,
    max_hops: 1,
    azimuth_deg: 45.0,
    tx_lat_deg: 40.0,
    params,
};

// Fan traces run automatically in parallel via Rayon on multi-core native systems!
let sweep_results = fan_trace(&sweep_config).unwrap();
println!("Computed {} rays in {} ms", sweep_results.n_rays, sweep_results.elapsed_ms);
```

## Usage (WASM)

When compiled with `wasm-pack build --target web`, the crate exposes a `trace_fan_wasm(json)` function that accepts and returns JSON strings:

```javascript
import init, { trace_fan_wasm } from './pkg/ionotrace.js';
await init();

const result = JSON.parse(trace_fan_wasm(JSON.stringify({
    freq_mhz: 10.0,
    ray_mode: -1,
    elev_min: 5,
    elev_max: 80,
    elev_step: 2,
    fc: 10.0,
    hm: 250,
    sh: 100,
})));

console.log(`Traced ${result.n_rays} rays in ${result.elapsed_ms} ms`);
```

## Target Solver

Find the launch angles to hit a specific geographic location:

```rust
use ionotrace::{solve_target, TargetConfig, SearchSpec};

let config = TargetConfig {
    target_lat_deg: 50.0,
    target_lon_deg: 5.0,
    tx_lat_deg: 40.0,
    freq_mhz: SearchSpec::Fixed(10.0),
    error_limit_km: 20.0,
    ..TargetConfig::default()
};

let result = solve_target(&config).unwrap();
if let Some(best) = &result.best {
    println!("Elevation: {:.1}°, Azimuth: {:.1}°, Error: {:.1} km",
        best.elevation_deg, best.azimuth_deg, best.error_km);
}
```

## Building

```bash
# Native
cargo build --release

# WASM (requires wasm-pack)
wasm-pack build --target web --out-dir ../../apps/frontend/pkg

# Tests
cargo test
```

## Algorithm

Solves Hamilton's equations for the ray path through the ionosphere:

```
H = ½(c²k²/ω² - n²)
```

where n² is the complex refractive index from the Appleton-Hartree formula. The integrator uses 4th-order Runge-Kutta with Adams-Moulton predictor-corrector and adaptive step-size control.

Based on: *A Versatile Three-Dimensional Ray Tracing Computer Program for Radio Waves in the Ionosphere*, R. M. Jones & J. J. Stephenson, OT Report 75-76 (1975). [PDF](https://www.ionolab.org/pubs/OT_Report_75_76.pdf)

## API Documentation

Full API reference on [docs.rs/ionotrace](https://docs.rs/ionotrace).

## License

MIT — see [LICENSE](../../LICENSE) for details.
