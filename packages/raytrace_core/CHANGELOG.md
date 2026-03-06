# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-03-06

### Added

#### ECEF Coordinate Integration (Issue #1 — Polar Singularity Fix)
- **New module `ecef.rs`**: Spherical ↔ ECEF Cartesian coordinate transforms for position, wave vector, and Hamiltonian gradients (Jacobian-based).
- **New module `hamiltonian_ecef.rs`**: ECEF Hamiltonian wrapper that evaluates physics models in their native spherical coordinates and transforms gradients back to ECEF via the Jacobian — no coordinate singularities.
- **ECEF integrator wrappers**: `rk4_step_ecef`, `am_step_ecef`, and `exit_routine_ecef` in `tracer.rs` mirror the spherical integrator but call the ECEF Hamiltonian.
- **`CoordinateSystem` enum** (`Spherical` | `Ecef`) in `params.rs` — selects integration coordinate system. Default: `Spherical` (backward-compatible).
- `TraceConfig.coord_system` field for per-trace coordinate system selection.

#### WGS-84 Oblate Spheroid (Issue #4 — Spherical Earth Fix)
- **New module `wgs84.rs`**: WGS-84 constants, Bowring geocentric ↔ geodetic conversion, geodetic altitude, ellipsoid surface radius, and Vincenty geodesic distance.
- **`EarthModel` enum** (`Sphere` | `Wgs84`) in `params.rs` — selects Earth shape model. Default: `Sphere` (backward-compatible).
- `ModelParams.earth_model` field for per-trace Earth model selection.
- When `Wgs84` is active: altitude uses geodetic height above ellipsoid; ground range uses Vincenty distance.

#### Empirical Ionosphere Grid Ingestion (Issue #3)
- **New module `grid.rs`**: 3D trilinear-interpolated ionosphere model. Accepts regular `fp(alt, lat, lon)` grids from IRI-2020, NeQuick, SAMI3, or custom sources.
- `IonosphereGrid::from_csv` and `IonosphereGrid::from_json` loaders for easy interop with Python/MATLAB toolkits.
- Finite-difference spatial gradients (∂X/∂r, ∂X/∂θ, ∂X/∂φ) computed automatically via central differences.
- **`GridInterp`** variant added to `ElectronDensityModel` enum.
- `ModelParams.ed_grid: Option<Arc<IonosphereGrid>>` field — thread-safe grid data sharing for parallel fan traces.

#### Sen-Wyller Magneto-Ionic Theory (Issue #5)
- **Sen-Wyller dispersion relation** (`swwfwc`): velocity-dependent collision frequencies via Dingle integral Padé approximations (G₁, G₂, G₃).
- **`SenWyller`** variant added to `RefractiveIndexModel` enum — provides 5–15 dB more accurate D-region absorption than standard Appleton-Hartree.
- ∂n²/∂Z computed via central finite differences on the Dingle integrals for robust Hamiltonian gradient flow.

### Changed
- `trace_ray` now accepts a `coord_system` parameter and dispatches to `trace_ray_spherical` (legacy) or `trace_ray_ecef` (new).
- Spherical path now supports WGS-84 altitude and ground range when `earth_model = Wgs84`.

### Tests
- Expanded test suite from 118 to 156 tests:
  - 8 new WGS-84 unit tests (geodetic roundtrip, polar/equatorial altitude, Vincenty distance, ellipsoid radii, sphere vs WGS-84 comparison)
  - 6 new ECEF unit tests (position/k-vector roundtrip, magnitude preservation, gradient transforms at equator and pole)
  - 3 new ECEF Hamiltonian tests (initial call, near-pole stability, mid-latitude agreement with spherical path)
  - 8 new grid interpolation tests (trilinear exact/midpoint/clamping, gradient accuracy, CSV/JSON roundtrip, profile shape)
  - 6 new Sen-Wyller tests (Dingle integral limits, finiteness, AH convergence, D-region absorption comparison, derivative finiteness)

## [0.3.1] - 2026-03-05

### Added
- **Comprehensive Documentation**: Added field-level documentation to all public structs in `tracer`, `fan`, `target`, and `params` modules.
- **Runnable Doc Examples**: Added 5 runnable examples to the crate root (`lib.rs`) covering Quick Start, Custom Physics, Fan Traces, Target Solver, and Exporting.
- **New Example**: Added `examples/single_ray.rs` as a minimal hello-world entry point for new users.
- **Physics Hierarchy Guide**: Added a guide in `models/mod.rs` explaining how the internal physics models interact.
- **README Updates**: Added a Target Solver usage section and docs.rs badge.

## [0.3.0] - 2026-03-05

### Added
- **Builder Pattern**: Added the `derive_builder` crate to `ModelParams`. You can now ergonomically construct physics environments using `ModelParams::builder().build()`.
- **Advanced Export Formatting**: Added a new `export` module featuring `export_trace_csv`, `export_fan_trace_csv`, and `export_json` to seamlessly serialize `TraceResult`s and `FanTraceResult`s to standard data science formats.
- **Parallel Fan Sweeps**: Replaced the sequential ray processing in `fan_trace` with `rayon`. Native builds now instantly farm out massive elevation sweeps across all available CPU cores via `into_par_iter()`.
- **`tracing` Observability**: Integrated the `tracing` ecosystem to emit `span`s and events. Real-time debug logs are now available during deep RK4 integration steps by simply attaching a subscriber.
- **Target Solver Diagnostics**: `TargetResult` now includes a `status` field (`"ok"`, `"no_brackets"`, `"no_convergence"`) for solver transparency.
- **Input Validation**: `TraceConfig::validate()` and `ModelParams::validate()` provide pre-flight checks for invalid configurations.
- **Examples**: Added `examples/fan_sweep_csv.rs` to demonstrate configuring, executing, and saving a parallel fan sweep.

### Changed
- The `TraceConfig` usage documentation has been fully rewritten to encourage the new Builder-pattern initialization.
- Replaced manual array memcpy blocks with native Rust assignment equivalents (`s.fv[2] = s.fv[3]`) to align with idiomatic standards.
- Replaced various magic constants with standard library mathematical equivalents (e.g. `core::f64::consts::LN_10`).

### Fixed

#### Numerical Stability
- Guarded negative n² in k-vector rescaling across all 4 Appleton-Hartree models (`.max(0.0)` prevents NaN).
- Added step-halving depth limit (max 10) to Adams-Moulton integrator to prevent runaway halving.
- Added NaN/Inf divergence guard to integrator — ray terminates cleanly instead of propagating garbage.
- Guarded pole singularity in Hamiltonian (`rsth` minimum threshold of `1e-12`).
- Converted recursive integrator warmup to iterative loop (prevents stack overflow).

#### Division-by-Zero Guards
- `chapx`, `elect1`, `dchapt`: return zero electron density when scale height `sh ≤ 0`.
- `linear`: return zero when `hm ≤ 0`; `qparab`: return zero when `ym ≤ 0`.
- `chapx`, `dchapt`: guard `dxdth` division when latitude coefficient `temp ≈ 0`.

#### Overflow Prevention
- Collision models: clamp height to ≥ 0 and exponent arguments to `[-20, 20]` to prevent exp overflow at negative heights.
- Bulge and exponential perturbations: clamp `(h/p2)` exponent to `[-20, 20]`.

#### Target Solver
- Fixed elapsed-time operator precedence in `solve_target_wasm`.
- Fixed multi-hop longitude accumulation (added `lon_offset` tracking).
- Fixed bisection direction for escape-boundary brackets.
- Deduplicated gc-error calculation into `best_hop_gc_error`.
- Removed dead `range_km` and `absorption` fields from internal `HopLanding`.

#### Other
- Fixed the previous "Serialize Map error" in CSV generation by destructing object structures in the new internal `FanExportRow` format.
- Removed several pieces of dead code including `RayMode::from_sign`.
- Handled all internal `cargo clippy` violations. The crate is now warning-free.

### Tests
- Expanded test suite from 88 to 118 tests covering:
  - Fortran regression (OT 75-76 gold standard)
  - Stress tests (extreme frequency, elevation, O-mode)
  - Input validation (TraceConfig, ModelParams, TargetConfig)
  - Perturbation finiteness (all 5 models)
  - Degenerate parameters (sh=0, hm=0, ym=0)
  - Solver diagnostics and multi-hop longitude
