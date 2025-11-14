# Ionospheric Ray Tracing

This project simulates the propagation of radio waves through the Earth's ionosphere. It provides a simple web application to visualize ray tracing calculations and will eventually incorporate various methods and more complex visualizations.

## Project Goal

The primary goal of this project is to develop a tool for simulating and visualizing the path of radio waves as they travel through the ionosphere. This can be used for various applications, including:

*   Understanding radio wave propagation
*   Predicting communication link performance
*   Analyzing ionospheric effects on satellite navigation systems

## Getting Started

To get started with this project, you will need to have Python and Flask installed. You can then clone the repository and run the web application.

```bash
git clone https://github.com/your-username/raytracing.git
cd raytracing/apps
python app.py
```

## Documentation

The `docs` folder contains relevant research papers and a LaTeX file with a list of key equations used in the simulations.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## References and Acknowledgements
This project is based on or inspired by the following work:
### Foundational Paper
- **Title:** A Versatile Three-Dimensional Ray Tracing Computer Program for Radio Waves in the Ionosphere
- **Authors:** R. Michael Jones & Judith J. Stephenson
- **Publication:** Office of Telecommunications Report 75-76 (1975)
- **Source:** [Full Citation & PDF at CONICET Digital Repository](https://www.ionolab.org/pubs/OT_Report_75_76.pdf)

### Modern Implementations
- **PHaRLAP (FORTRAN Engine):** The modern FORTRAN-based numerical engine for HF raytracing, developed by the Australian Department of Defence.
- **Link:** [PHaRLAP Official Technology Page](httpshttps://www.dst.defence.gov.au/our-technologies/pharlap)
- **PyLap (Python Interface):** The Python interface for PHaRLAP, maintained by the HamSCI community.
- **Link:** [HamSCI/PyLap GitHub Repository](https://github.com/HamSCI/PyLap)

## Development Plan: Profiling-Guided Optimization
This project follows a "Python-first, Rust-accelerated" hybrid model.

1.  **Phase 1: Python Prototype (NumPy/SciPy)**
    *   Implement the *entire* ray-tracing logic in Python.
    *   Use `numpy` for all state vectors, matrix math, and calculations.
    *   Use `scipy.integrate.solve_ivp` as the core ODE integrator.
    *   The main Python task is to write a function (e.g., `def ray_derivatives(...)`) that calculates the 6 Haselgrove derivatives, which is then passed to `solve_ivp`.

2.  **Phase 2: Profile**
    *   Once the Python prototype is working and validated, profile it (e.g., using `cProfile`).
    *   Confirm that the bottleneck is the `ray_derivatives` function, which is called thousands of times by the SciPy solver.

3.  **Phase 3: Rust Rewrite (PyO3)**
    *   Re-implement the single, bottlenecked `ray_derivatives` function in Rust.
    *   Use `PyO3` to create Python bindings for this Rust function, compiling it into a shared library (a `.pyd` or `.so` file).

4.  **Phase 4: Integration**
    *   Modify the main Python script to `import` the new Rust module.
    *   Pass the *Rust-compiled function* (e.g., `my_rust_lib.ray_derivatives`) to `scipy.integrate.solve_ivp` instead of the pure Python one.

5.  **Phase 5: Benchmark**
    *   The high-level logic (I/O, setup, plotting) remains in Python for flexibility.
    *   The "hot loop" (the math-heavy derivative calculation) now runs at native Rust speed, providing a massive performance boost.
