# FORTRAN to Python: Ray-Tracer Conversion Plan

[cite_start]This document outlines a modern, object-oriented Python project structure for converting the FORTRAN 3D ray-tracing program[cite: 2]. The goal is to move from a procedural design using `COMMON` blocks for state to a modular, testable, and maintainable Python package.

The new design will rely on:
* [cite_start]**Object-Oriented Design:** A central `RayTracer` class will manage the simulation state, replacing the "heart" subroutine `TRACE`.
* **Dependency Injection:** Physics models (like electron density, refractive index, etc.) will be separate classes ("strategies") that are passed into the main `RayTracer`. [cite_start]This directly replaces the FORTRAN approach of swapping in different subroutines like `RINDEX` [cite: 1136] [cite_start]or `ELECTX`[cite: 1137].
* [cite_start]**Modern Tooling:** We'll replace the `W` array [cite: 1075] [cite_start]with a YAML configuration file, use `scipy` for integration (replacing `RKAM` [cite: 1134][cite_start]), and `pandas` for data output (replacing "rayset" punch cards ).

---

## 📂 Goal Python Project Structure

Here is the target directory and file layout for the new Python package, which we'll call `pyraytrace`.

```bash
raytracer_project/
├── configs/
│   └── sample_run.yaml         # Replaces Input Parameter Forms & W-array [cite: 1075, 1505]
│
├── notebooks/
│   └── run_and_plot.ipynb      # For analysis & plotting (replaces RAYPLT, PLOT) [cite: 1045, 1046]
│
├── src/
│   └── pyraytrace/
│       ├── __init__.py           # Makes `pyraytrace` a package
│       ├── cli.py                # Command-line entry point (replaces PROGRAM NITIAL) [cite: 1053]
│       │
│       ├── core/
│       │   ├── __init__.py
│       │   ├── simulation.py     # Manages simulation setup, loops, and runs
│       │   ├── tracer.py         # Holds the `RayTracer` class (replaces TRACE) [cite: 1051]
│       │   └── equations.py      # ODE system for SciPy (replaces HAMLTN) [cite: 1043]
│       │
│       ├── models/
│       │   ├── __init__.py
│       │   ├── base.py           # Abstract Base Classes (interfaces) for all models
│       │   ├── electron_density.py # All `ELECTX` models (CHAPX, QPARAB, etc.) [cite: 1040, 2673]
│       │   ├── magnetic_field.py   # All `MAGY` models (DIPOLY, HARMONY, etc.) [cite: 1037, 2833]
│       │   ├── collision.py        # All `COLFRZ` models (EXPZ, TABLEZ, etc.) [cite: 1035, 2883]
│       │   ├── perturbation.py     # All `ELECT1` models (WAVE, TORUS, etc.) [cite: 1039, 2753]
│       │   └── refractive_index.py # All 8 `RINDEX` versions (AppletonHartree, SenWyller) [cite: 1041, 2568]
│       │
│       └── utils/
│           ├── __init__.py
│           ├── config.py         # Pydantic models to load/validate YAML (replaces READW) [cite: 1052]
│           ├── geometry.py       # Coordinate conversions (replaces POLCAR) [cite: 1048]
│           └── output.py         # Handles saving DataFrames (replaces PRINTR punch logic) [cite: 1047]
│
├── tests/
│   ├── __init__.py
│   ├── test_tracer.py
│   └── test_models.py
│
└── pyproject.toml                # Project metadata and dependencies (scipy, numpy, pandas)