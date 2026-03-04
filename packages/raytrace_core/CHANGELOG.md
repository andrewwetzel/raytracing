# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - Unreleased

### Added
- **Builder Pattern**: Added the `derive_builder` crate to `ModelParams`. You can now ergonomically construct physics environments using `ModelParams::builder().build()`.
- **Advanced Export Formatting**: Added a new `export` module featuring `export_trace_csv`, `export_fan_trace_csv`, and `export_json` to seamlessly serialize `TraceResult`s and `FanTraceResult`s to standard data science formats.
- **Parallel Fan Sweeps**: Replaced the sequential ray processing in `fan_trace` with `rayon`. Native builds now instantly farm out massive elevation sweeps across all available CPU cores via `into_par_iter()`.
- **`tracing` Observability**: Integrated the `tracing` ecosystem to emit `span`s and events. Real-time debug logs are now available during deep RK4 integration steps by simply attaching a subscriber.
- **Examples**: Added `examples/fan_sweep_csv.rs` to demonstrate configuring, executing, and saving a parallel fan sweep.

### Changed
- The `TraceConfig` usage documentation has been fully rewritten to encourage the new Builder-pattern initialization.
- Replaced manual array memcpy blocks with native Rust assignment equivalents (`s.fv[2] = s.fv[3]`) to align with idiomatic standards.
- Replaced various magic constants with standard library mathematical equivalents (e.g. `core::f64::consts::LN_10`).

### Fixed
- Fixed the previous "Serialize Map error" in CSV generation by destructing object structures in the new internal `FanExportRow` format.
- Removed several pieces of dead code including `RayMode::from_sign`.
- Handled all 49 internal `cargo clippy` violations involving unnecessary `f64` typecasting and redundant argument counts. The crate is now warning-free.
