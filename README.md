# Ionospheric Ray Tracing

3D ionospheric ray tracing engine based on [OT Report 75-76](https://www.ionolab.org/pubs/OT_Report_75_76.pdf) (1975). Implements Hamilton's equations for radio wave propagation through a magnetized, collisional plasma.

**Two implementations, one algorithm:**

| Engine | Language | Notes |
|--------|----------|-------|
| `ionotrace` | **Rust** (WASM) | Production — runs in-browser via WebAssembly |
| `ft_raytrace` | Fortran | Reference — original port of all 47 subroutines |

Both produce identical results for the OT 75-76 sample case: **max height 74.08 km**, ray returns to ground.

## Project Structure

```
packages/
├── raytrace_core/          # 🚀 Rust engine (ionotrace crate)
│   ├── src/
│   │   ├── lib.rs          # Entry point + WASM bindings
│   │   ├── params.rs       # Model parameters (ModelParams)
│   │   ├── complex.rs      # Zero-alloc complex arithmetic
│   │   ├── hamiltonian.rs  # Hamilton's equations (∂H/∂r, ∂H/∂k)
│   │   ├── integrator.rs   # RK4 / Adams-Moulton stepper
│   │   ├── tracer.rs       # Ray tracing loop
│   │   └── models/         # Physics models
│   │       ├── electron_density.rs   # Chapman, ELECT1, Linear, etc.
│   │       ├── magnetic_field.rs     # Dipole, IGRF-14 (degree 13)
│   │       ├── collision.rs          # Collision frequency profiles
│   │       └── refractive_index.rs   # Appleton-Hartree formula
│   ├── tests/              # Unit + integration tests
│   └── Cargo.toml
├── ft_raytrace/            # 🔬 Fortran reference engine
│   ├── src/                # 47 subroutines (.f files)
│   ├── test/               # Unit + end-to-end tests
│   └── fpm.toml
apps/
└── frontend/               # Static web UI
    ├── index.html           # Main application
    ├── script.js            # 2D canvas rendering + controls
    ├── globe3d.js           # Three.js 3D globe view
    ├── style.css            # Styles
    └── pkg/                 # WASM build output (checked in)
docs/
└── equations.tex            # Key equations in LaTeX
```

## Quick Start

### Local Development

```bash
# Prerequisites: Rust 1.70+, wasm-pack, just
just build-wasm           # Build WASM module
just serve-static         # Serve at http://localhost:9000
```

### Deploy (Cloudflare Pages)

The frontend is a static site — no build step needed on Cloudflare. Create a Pages project pointed at this repo with:

| Setting | Value |
|---------|-------|
| Build command | *(leave empty)* |
| Build output directory | `apps/frontend` |

The WASM `pkg/` directory is checked into the repo. Rebuild locally with `just build-wasm` when the Rust engine changes.

### Fortran

```bash
# Prerequisites: gfortran, just
just test                    # Run all 47 tests
just test-e2e-sample-case   # Run sample case validation
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

## Algorithm

The ray tracer solves Hamilton's equations for the ray path through the ionosphere:

```
dr/dt   = -∂H/∂kr  / (∂H/∂ω · c)
dθ/dt   = -∂H/∂kθ  / (∂H/∂ω · r · c)
dφ/dt   = -∂H/∂kφ  / (∂H/∂ω · r·sinθ · c)
dkr/dt  =  ∂H/∂r   / (∂H/∂ω · c) + ...
```

where `H = ½(c²k²/ω² - n²)` is the Hamiltonian and `n²` is the complex refractive index from the Appleton-Hartree formula. Integration uses RK4 with Adams-Moulton predictor-corrector.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, testing, and PR guidelines.

## Security

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities.

## References

- **Original Paper:** *A Versatile Three-Dimensional Ray Tracing Computer Program for Radio Waves in the Ionosphere* — R. Michael Jones & Judith J. Stephenson, OT Report 75-76 (1975). [PDF](https://www.ionolab.org/pubs/OT_Report_75_76.pdf)
- **PHaRLAP:** Modern Fortran HF raytracing engine. [Link](https://www.dst.defence.gov.au/our-technologies/pharlap)
- **PyLap:** Python interface for PHaRLAP. [GitHub](https://github.com/HamSCI/PyLap)

## License

MIT — see [LICENSE](LICENSE) for details.
