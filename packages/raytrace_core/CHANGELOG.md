# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
