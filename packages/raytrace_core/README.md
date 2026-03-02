# raytrace_core

High-performance Rust implementation of the OT 75-76 ionospheric ray tracing engine, exposed to Python via PyO3.

**0.028 ms per ray** — 23× faster than Fortran, 96× faster than Python.

## Building

Requires Rust 1.70+ and a Python virtualenv.

```bash
# From the pyraytrace venv
cd packages/raytrace_core
VIRTUAL_ENV=../pyraytrace/.venv maturin develop --release
```

## Usage (from Python)

```python
import raytrace_core

result = raytrace_core.trace_ray_py(
    # Ray parameters
    freq_mhz=10.0,          # Wave frequency (MHz)
    ray_mode=-1.0,           # -1 extraordinary, +1 ordinary
    elevation_deg=20.0,      # Launch elevation (degrees)
    azimuth_deg=45.0,        # Launch azimuth (degrees)
    tx_lat_deg=40.0,         # Transmitter latitude (degrees)
    # Integration
    int_mode=2,              # 1=RK, 2=RK+AM, 3=RK+AM+error
    step_size=10.0,          # Integration step
    max_steps=200,           # Max integration steps
    e1max=1e-4, e1min=2e-6, e2max=100.0,
    # Chapman electron density
    earth_r=6370.0,
    fc=10.0, hm=250.0, sh=100.0, alpha=0.5,
    ed_a=0.0, ed_b=0.0, ed_c=0.0, ed_e=0.0,
    # Dipole magnetic field
    fh=0.8,
    # EXPZ2 collisions
    nu1=1050000.0, h1=100.0, a1=0.148,
    nu2=30.0, h2=140.0, a2=0.0183,
    print_every=10,
)

print(f"Max height: {result['max_height']:.2f} km")  # 74.08 km
print(f"Steps: {result['n_steps']}")                  # 43
print(f"Ground: {result['returned_to_ground']}")      # True
```

## What's Inside

Single-file Rust implementation (`src/lib.rs`, ~850 lines):

- **CHAPX** — Chapman layer electron density model
- **DIPOLY** — Dipole magnetic field model
- **EXPZ2** — Double-exponential collision frequency
- **AHWFWC** — Appleton-Hartree refractive index (complex)
- **HAMLTN** — Hamilton's equations for ray tracing
- **RKAM** — RK4 / Adams-Moulton integrator with adaptive step-size
- Custom zero-allocation complex number arithmetic
- PyO3 bindings exposing `trace_ray_py()` to Python

## Benchmark

```
Rust:    0.028 ms/ray  (10,000 iterations)
Fortran: 0.640 ms/ray
Python:  2.650 ms/ray  (100 iterations)
```
