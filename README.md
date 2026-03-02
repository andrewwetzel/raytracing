# Ionospheric Ray Tracing

A faithful conversion of the OT Report 75-76 (1975) three-dimensional ray tracing program for ionospheric radio wave propagation. All 47 subroutines from the original Fortran source have been transcribed (via OCR), corrected, and individually tested.

## Current Status

**All subroutines converted and tested.** The program successfully reproduces the sample case from OT Report 75-76 using real ionospheric models (Chapman layer, dipole magnetic field, EXPZ2 collisions, Appleton-Hartree extraordinary ray).

### Steps Completed

1. **Phase 1 — Ionospheric Models:** 17 electron density models (ELECT1, EXPX, BULGE, GAUSEL, TABLEX, CHAPX, VCHAPX, DCHAPT, LINEAR, QPARAB, TORUS, DTORUS, TROUGH, SHOCK, WAVE, WAVE2, DOPPLER)
2. **Phase 1b — Magnetic Field & Collisions:** 8 models (CONSTY, DIPOLY, CUBEY, HARMONY, CONSTZ, TABLEZ, EXPZ, EXPZ2)
3. **Phase 2 — Refractive Index:** 11 formulas including Appleton-Hartree (4 variants), Booker Quartic (2 variants), and Sen-Wyller (2 variants + 3 helpers)
4. **Phase 3 — Ray Tracing Engine:** HAMLTN, RKAM, TRACE, REACH, BACKUP, POLCAR
5. **Phase 4 — I/O & Main:** NITIAL, READW, PRINTR, RAYPLT, BLOCK_DATA
6. **Validation:** End-to-end tests reproducing the sample case from OT 75-76

### Test Results

| Category                   | Tests | Status      |
|----------------------------|-------|-------------|
| Electron density models    | 17    | ✅ All pass |
| Magnetic field models      | 4     | ✅ All pass |
| Collision frequency models | 4     | ✅ All pass |
| Refractive index formulas  | 10    | ✅ All pass |
| Ray tracing engine         | 6     | ✅ All pass |
| I/O subroutines            | 2     | ✅ All pass |
| End-to-end integration     | 4     | ✅ All pass |
| **Total**                  | **47**| **✅ All pass** |

### Performance

| Benchmark                   | Result              |
|-----------------------------|---------------------|
| 100 rays × 20 steps        | **1.15 ms** total   |
| Per integration step        | **0.58 µs**         |
| vs. CDC 3800 (1975)         | **~15,600× faster** |

## Project Structure

```
packages/
├── ft_raytrace/          # Fortran ray tracing engine
│   ├── src/              # All 47 subroutines (.f files)
│   ├── test/             # Individual + end-to-end tests
│   ├── fpm.toml          # Fortran Package Manager config
│   └── *.dat             # Data files for tabulated models
├── backend/              # Python/FastAPI backend (for future web UI)
│   ├── main.py
│   ├── Dockerfile
│   └── requirements.txt
apps/
├── frontend/             # Static frontend (HTML/CSS/JS)
└── hello_fortran_example/ # Simple Fortran example
docs/
├── 75-76.pdf             # Original OT Report 75-76
├── equations.tex         # Key equations reference
└── python_conversion_plan.md  # Future Python port plan
```

## Prerequisites

- **gfortran** (GNU Fortran compiler)
- **just** (task runner) — `cargo install just` or via package manager

## Quick Start

```bash
# Clone the repo
git clone https://github.com/andrewwetzel/raytracing.git
cd raytracing

# Run ALL Fortran tests (47 assertions)
just test

# Run a specific subroutine test
just test-chapx
just test-ahwfwc
just test-hamltn

# Run end-to-end integration tests
just test-e2e-vertical
just test-e2e-oblique
just test-e2e-perf
just test-e2e-sample-case

# Run tests via Fortran Package Manager
just fpm-test
```

## Local Development (Web UI)

```bash
# Start backend + frontend with Docker Compose
just test-local

# Stop local services
just stop-local
```

## Deployment

```bash
# Deploy backend to Cloud Run
just deploy-backend

# Deploy frontend to Firebase Hosting
just deploy-frontend

# Deploy both
just deploy
```

## References

- **Foundational Paper:** *A Versatile Three-Dimensional Ray Tracing Computer Program for Radio Waves in the Ionosphere* — R. Michael Jones & Judith J. Stephenson, Office of Telecommunications Report 75-76 (1975). [PDF](https://www.ionolab.org/pubs/OT_Report_75_76.pdf)
- **PHaRLAP:** Modern FORTRAN HF raytracing engine by the Australian Department of Defence. [Link](https://www.dst.defence.gov.au/our-technologies/pharlap)
- **PyLap:** Python interface for PHaRLAP by HamSCI. [GitHub](https://github.com/HamSCI/PyLap)

## License

See [LICENSE](LICENSE) for details.
