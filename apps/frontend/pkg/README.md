# ionotrace

[![Crates.io](https://img.shields.io/crates/v/ionotrace.svg)](https://crates.io/crates/ionotrace)
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
use ionotrace::params::ModelParams;
use ionotrace::tracer::trace_ray;

let params = ModelParams::default(); // Chapman + Dipole + AHWFWC

let result = trace_ray(
    10.0,   // freq_mhz
    -1.0,   // ray_mode (-1 = X-mode, +1 = O-mode)
    20.0,   // elevation_deg
    0.0,    // azimuth_deg
    40.0,   // tx_lat_deg
    2,      // int_mode (1=RK4, 2=RK4+AM, 3=RK4+AM+error)
    5.0,    // step_size
    500,    // max_steps
    1e-4,   // e1max (error tolerance)
    2e-6,   // e1min
    100.0,  // e2max
    &params,
    1,      // print_every
);

println!("Max height: {:.2} km", result.max_height);
println!("Ground range: {:.1} km", result.ground_range_km);
println!("Returned: {}", result.returned_to_ground);
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

## License

MIT — see [LICENSE](../../LICENSE) for details.
