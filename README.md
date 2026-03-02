# Ionospheric Ray Tracing

3D ionospheric ray tracing engine based on OT Report 75-76 (1975). Implements Hamilton's equations for radio wave propagation through a magnetized, collisional plasma.

**Three implementations, one algorithm:**

| Engine | Language | Time/ray | Notes |
|--------|----------|----------|-------|
| `raytrace_core` | **Rust** (PyO3) | **0.028 ms** | Production — 23× faster than Fortran |
| `ft_raytrace` | Fortran | 0.64 ms | Original port — all 47 subroutines |
| `pyraytrace` | Python | 2.65 ms | Prototyping — extensible models |

All three produce identical results for the OT 75-76 sample case: **max height 74.08 km**, ray returns to ground.

## Project Structure

```
packages/
├── raytrace_core/        # 🚀 Rust engine with Python bindings (PyO3)
│   ├── src/lib.rs        # Full physics + integrator (~1570 lines)
│   └── Cargo.toml
├── pyraytrace/           # 🐍 Python package (models, CLI, tests)
│   ├── pyraytrace/       # Package source
│   │   ├── core/         # equations.py, integrator.py, tracer.py
│   │   ├── models/       # electron_density, magnetic_field, collision, rindex
│   │   ├── cli.py        # CLI entry point
│   │   └── constants.py  # Physical constants
│   ├── configs/          # YAML simulation configs
│   ├── tests/            # 13 pytest tests
│   └── pyproject.toml
├── ft_raytrace/          # 🔬 Fortran engine (original port)
│   ├── src/              # 47 subroutines (.f files)
│   ├── test/             # Unit + end-to-end tests
│   └── fpm.toml
└── backend/              # FastAPI backend (future web UI)
docs/
├── 75-76.pdf             # Original OT Report 75-76
├── equations.tex         # Key equations reference
└── python_conversion_plan.md
```

## Quick Start

### Rust Engine (fastest)

```bash
# Prerequisites: Python 3.11+, Rust 1.70+
cd packages/pyraytrace
python3 -m venv .venv && .venv/bin/pip install -e ".[dev]"
.venv/bin/pip install maturin

# Build Rust extension
cd ../raytrace_core
VIRTUAL_ENV=../pyraytrace/.venv .venv/bin/maturin develop --release

# Run from Python
.venv/bin/python -c "
import raytrace_core
result = raytrace_core.trace_ray_py(
    freq_mhz=10.0, ray_mode=-1.0,
    elevation_deg=20.0, azimuth_deg=45.0, tx_lat_deg=40.0,
    int_mode=2, step_size=10.0, max_steps=200,
    e1max=1e-4, e1min=2e-6, e2max=100.0,
    earth_r=6370.0,
    fc=10.0, hm=250.0, sh=100.0, alpha=0.5,
    ed_a=0.0, ed_b=0.0, ed_c=0.0, ed_e=0.0,
    fh=0.8, nu1=1050000.0, h1=100.0, a1=0.148,
    nu2=30.0, h2=140.0, a2=0.0183,
)
print(f'Max height: {result[\"max_height\"]:.2f} km')
"
```

### Python CLI

```bash
cd packages/pyraytrace
.venv/bin/python -m pyraytrace run configs/sample_case.yaml
```

### Fortran

```bash
# Prerequisites: gfortran, just (task runner)
just test                    # Run all 47 tests
just test-e2e-sample-case    # Run sample case validation
```

### Tests

```bash
# Python tests (13 assertions)
cd packages/pyraytrace && .venv/bin/python -m pytest tests/ -v

# Fortran tests (47 assertions)
just test
```

## Physics Models

All models from the original Fortran codebase are available in the Rust engine via selector parameters:

| Category | Selector | Models |
|----------|----------|--------|
| **Electron Density** | `ed_model=0..5` | CHAPX (default), ELECT1, LINEAR, QPARAB, VCHAPX, DCHAPT |
| **ED Perturbations** | `pert_model=0..5` | none (default), TORUS, TROUGH, SHOCK, BULGE, EXPX |
| **Magnetic Field** | `mag_model=0..3` | DIPOLY (default), CONSTY, CUBEY, HARMONY (IGRF-14) |
| **Collision Freq** | `col_model=0..2` | EXPZ2 (default), CONSTZ, EXPZ |
| **Refractive Index** | `rindex_model=0..3` | AHWFWC (default), AHNFNC, AHNFWC, AHWFNC |

The **HARMONY** model embeds real IGRF-14 (epoch 2025.0) spherical harmonic coefficients from NOAA — no external data files needed.

For real ionospheric conditions, the IRI-2020 and IGRF models are also available via the Python layer (see `configs/iri_igrf_sample.yaml`).

### Not Ported

| Model | Reason |
|-------|--------|
| **TABLEX** (tabular electron density) | Superseded by IRI-2020 integration, which provides measured ionospheric profiles globally. TABLEX was designed for manually entering ionosonde data — IRI replaces this with a full empirical model. |
| **TABLEZ** (tabular collision freq) | Same rationale — the built-in exponential models (EXPZ2, EXPZ) cover standard collision profiles adequately. |
| **HARMONY file I/O** | The Fortran version reads coefficients from a file at runtime. Our Rust port embeds IGRF-14 coefficients at compile time instead, which is faster and requires no external files. |
| **Booker Quartic** (BQWFWC, BQWFNC) | Specialized formulation for waveguide modes. The Appleton-Hartree variants cover standard HF ray tracing. |
| **Sen-Wyller** (SWWF, SWNF) | Generalized collision model. Standard exponential collision models are sufficient for most applications. |

## Algorithm

The ray tracer solves Hamilton's equations for the ray path through the ionosphere:

```
dr/dt   = -∂H/∂kr  / (∂H/∂ω · c)
dθ/dt   = -∂H/∂kθ  / (∂H/∂ω · r · c)
dφ/dt   = -∂H/∂kφ  / (∂H/∂ω · r·sinθ · c)
dkr/dt  =  ∂H/∂r   / (∂H/∂ω · c) + ...
```

where `H = ½(c²k²/ω² - n²)` is the Hamiltonian and `n²` is the complex refractive index from the Appleton-Hartree formula. Integration uses RK4 with Adams-Moulton predictor-corrector.

## References

- **Original Paper:** *A Versatile Three-Dimensional Ray Tracing Computer Program for Radio Waves in the Ionosphere* — R. Michael Jones & Judith J. Stephenson, OT Report 75-76 (1975). [PDF](https://www.ionolab.org/pubs/OT_Report_75_76.pdf)
- **PHaRLAP:** Modern Fortran HF raytracing engine. [Link](https://www.dst.defence.gov.au/our-technologies/pharlap)
- **PyLap:** Python interface for PHaRLAP. [GitHub](https://github.com/HamSCI/PyLap)

## License

See [LICENSE](LICENSE) for details.
