# Contributing

Thanks for your interest in contributing to the Ionospheric Ray Tracer! This document covers how to get started.

## Prerequisites

- **Rust** 1.70+ and [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/) for the WASM engine
- **gfortran** for running the Fortran reference implementation tests
- [**just**](https://github.com/casey/just) task runner

## Development Setup

```bash
git clone https://github.com/andrewwetzel/raytracing.git
cd raytracing

# Build the WASM module
just build-wasm

# Serve locally
just serve-static    # http://localhost:9000
```

## Running Tests

```bash
# Rust tests (with coverage)
just test-rust

# Fortran tests (all 47 subroutines)
just test-fortran

# Everything
just test
```

## Project Structure

| Directory | Language | Purpose |
|-----------|----------|---------|
| `packages/raytrace_core/` | Rust | Physics engine (compiles to WASM) |
| `packages/ft_raytrace/` | Fortran | Reference implementation from OT 75-76 |
| `apps/frontend/` | HTML/JS/CSS | Web UI (loads WASM module) |
| `docs/` | — | Reference material and equations |

## Making Changes

1. **Fork** the repo and create a feature branch
2. **Write tests** — Rust tests go in `packages/raytrace_core/tests/`
3. **Verify** — run `just test-rust` and confirm the WASM build with `just build-wasm`
4. **Submit a PR** with a clear description of what changed and why

### Physics Changes

If modifying the ray tracing engine:
- Validate against the OT 75-76 sample case (`just test-e2e-sample-case` for Fortran, or `cargo test` for Rust)
- The expected result: vertical ray reaches **max height 74.08 km** and returns to ground
- Both Rust and Fortran implementations should produce matching results

### Frontend Changes

The frontend is a static site — no build tools required beyond `just serve-static`. Changes are reflected immediately on reload.

## Code Style

- **Rust**: Follow standard `rustfmt` conventions
- **Fortran**: Fixed-form F77 (matching the original OT 75-76 code)
- **JavaScript**: No framework — vanilla JS with ES modules

## Reporting Issues

Use [GitHub Issues](https://github.com/andrewwetzel/raytracing/issues) for bug reports and feature requests. Include:
- Steps to reproduce
- Expected vs actual behavior
- Browser and OS if frontend-related
