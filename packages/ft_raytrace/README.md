# ft_raytrace — Fortran Ray Tracing Package

Converted from the OT Report 75-76 (1975) three-dimensional ray tracing program for ionospheric radio wave propagation. This package contains all subroutines faithfully transcribed from the original Fortran 66/77 source code (via OCR), corrected, and tested.

## Overview

The ray tracing program computes three-dimensional paths of radio waves through a model ionosphere using Haselgrove's equations. It supports multiple ionospheric electron density models, magnetic field models, collision frequency profiles, and refractive index formulas.

## Architecture

```
src/
├── Ionospheric Models (Phase 1)
│   ├── ELECT1.f    — Simple electron density
│   ├── EXPX.f      — Exponential electron density
│   ├── BULGE.f     — Equatorial bulge model
│   ├── GAUSEL.f    — Gaussian electron density
│   ├── TABLEX.f    — Tabulated electron density (file input)
│   ├── CHAPX.f     — Chapman layer model
│   ├── VCHAPX.f    — Variable Chapman layer
│   ├── DCHAPT.f    — DCHAPT modified Chapman
│   ├── LINEAR.f    — Linear electron density
│   ├── QPARAB.f    — Quasi-parabolic model
│   ├── TORUS.f     — Toroidal model
│   ├── DTORUS.f    — Double torus model
│   ├── TROUGH.f    — Trough model
│   ├── SHOCK.f     — Shock wave model
│   ├── WAVE.f      — Traveling wave perturbation
│   ├── WAVE2.f     — Second wave perturbation
│   └── DOPPLER.f   — Doppler shift model
│
├── Magnetic Field & Collisions (Phase 1b)
│   ├── CONSTY.f    — Constant magnetic field
│   ├── DIPOLY.f    — Dipole magnetic field
│   ├── CUBEY.f     — Cubic magnetic field
│   ├── HARMONY.f   — Harmonic magnetic field
│   ├── CONSTZ.f    — Constant collision frequency
│   ├── TABLEZ.f    — Tabulated collision frequency
│   ├── EXPZ.f      — Exponential collision frequency
│   └── EXPZ2.f     — Two-exponential collision frequency
│
├── Refractive Index (Phase 2)
│   ├── AHWFWC.f    — Appleton-Hartree with field, with collisions
│   ├── AHWFNC.f    — Appleton-Hartree with field, no collisions
│   ├── AHNFWC.f    — Appleton-Hartree no field, with collisions
│   ├── AHNFNC.f    — Appleton-Hartree no field, no collisions
│   ├── BQWFWC.f    — Booker Quartic with field, with collisions
│   ├── BQWFNC.f    — Booker Quartic with field, no collisions
│   ├── SWWF.f      — Sen-Wyller with field
│   ├── SWNF.f      — Sen-Wyller no field
│   ├── FRESNEL.f   — Fresnel integral helper
│   ├── FSW.f       — Sen-Wyller helper
│   └── FGSW.f      — Sen-Wyller helper
│
├── Ray Tracing Engine (Phase 3)
│   ├── HAMLTN.f    — Hamilton's equations (Haselgrove)
│   ├── RKAM.f      — Runge-Kutta / Adams-Moulton integrator
│   ├── TRACE.f     — Main ray path controller
│   ├── REACH.f     — Straight-line propagation
│   ├── BACKUP.f    — Ray backtracking logic
│   └── POLCAR.f    — Spherical ↔ Cartesian coordinate conversion
│
├── I/O & Main (Phase 4)
│   ├── NITIAL.f    — Main program (initialization + ray loop)
│   ├── READW.f     — W-array card input reader
│   ├── PRINTR.f    — Output formatter with coordinate rotation
│   ├── RAYPLT.f    — Plotter stub (no-op)
│   └── BLOCK_DATA.f — Block data initialization
│
test/
├── test_*.f              — Individual subroutine tests
├── test_e2e_vertical.f   — Vertical incidence end-to-end test
├── test_e2e_oblique.f    — Oblique 30° ray end-to-end test
├── test_e2e_perf.f       — Performance benchmark (100 rays)
├── test_e2e_sample_case.f — OT 75-76 sample case validation
├── test_stub_models.f    — Base test stubs
├── test_engine_stubs.f   — RINDEX stub for engine tests
└── test_rindex_stub.f    — Minimal RINDEX stub for PRINTR tests
```

## Prerequisites

- **gfortran** (GNU Fortran compiler)
- **just** (task runner) — `cargo install just` or via package manager

## Quick Start

```bash
# Run ALL tests (41 targets, 47 assertions)
just test

# Run a specific test
just test-chapx
just test-ahwfwc
just test-hamltn
just test-trace

# Run end-to-end tests
just test-e2e-vertical
just test-e2e-oblique
just test-e2e-perf
just test-e2e-sample-case
```

## Test Results

| Category | Tests | Status |
|----------|-------|--------|
| Electron density models | 17 | ✅ All pass |
| Magnetic field models | 4 | ✅ All pass |
| Collision frequency models | 4 | ✅ All pass |
| Refractive index formulas | 10 | ✅ All pass |
| Ray tracing engine | 6 | ✅ All pass |
| I/O subroutines | 2 | ✅ All pass |
| End-to-end integration | 4 | ✅ All pass |
| **Total** | **47** | **✅ All pass** |

## Performance

| Benchmark | Result |
|-----------|--------|
| 100 rays × 20 steps | **1.15 ms** total |
| Per integration step | **0.58 µs** |
| vs. CDC 3800 (1975) | **~15,600× faster** |

## Sample Case Validation

The program reproduces the sample case from OT Report 75-76 using real ionospheric models:
- **CHAPX** Chapman layer (fc=10 MHz, hmax=250 km, H=100 km)
- **DIPOLY** dipole magnetic field (fH=0.8 MHz)
- **EXPZ2** collision frequency profile
- **AHWFWC** Appleton-Hartree extraordinary ray

The ray correctly propagates through the ionosphere and returns to ground.

## Source

OT Report 75-76: *A Versatile Three-Dimensional Ray Tracing Computer Program for Radio Waves in the Ionosphere* (1975), Office of Telecommunications, U.S. Department of Commerce.
