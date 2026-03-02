# pyraytrace

Python implementation of the OT 75-76 ionospheric ray tracing engine. Provides an extensible, model-based architecture for prototyping and experimentation.

## Installation

```bash
python3 -m venv .venv
.venv/bin/pip install -e ".[dev]"
```

## Usage

### CLI

```bash
# Run the OT 75-76 sample case
.venv/bin/python -m pyraytrace run configs/sample_case.yaml

# Save results as JSON
.venv/bin/python -m pyraytrace run configs/sample_case.yaml -o results.json
```

### Python API

```python
from pyraytrace.core.tracer import SimulationConfig, run_ray
from pyraytrace.models.electron_density import Chapx
from pyraytrace.models.magnetic_field import Dipoly
from pyraytrace.models.collision import Expz2
from pyraytrace.models.refractive_index import Ahwfwc

# Build model chain
rindex = Ahwfwc(Chapx(), Dipoly(), Expz2())

config = SimulationConfig(
    freq_mhz=10.0,
    ray_mode=-1.0,        # extraordinary
    elevation_deg=20.0,
    azimuth_deg=45.0,
    model_params={"fc": 10.0, "hm": 250.0, "sh": 100.0, "alpha": 0.5, "fh": 0.8,
                  "nu1": 1050000.0, "h1": 100.0, "a1": 0.148,
                  "nu2": 30.0, "h2": 140.0, "a2": 0.0183},
)

result = run_ray(config, rindex)
print(f"Max height: {result.max_height:.2f} km")
print(f"Ground return: {result.returned_to_ground}")
```

## Tests

```bash
.venv/bin/python -m pytest tests/ -v
```

13 tests: geometry, electron density, magnetic field, collision, equations, and e2e sample case.

## Architecture

```
pyraytrace/
├── constants.py          # Physical constants
├── geometry.py           # Spherical ↔ Cartesian conversions
├── cli.py                # CLI entry point
├── core/
│   ├── equations.py      # Hamilton's equations (HAMLTN)
│   ├── integrator.py     # RK4/Adams-Moulton (RKAM)
│   └── tracer.py         # Simulation runner (TRACE)
└── models/
    ├── base.py           # Abstract base classes
    ├── electron_density.py  # Chapx, Elect1, Linear, Qparab
    ├── magnetic_field.py    # Dipoly, Consty
    ├── collision.py         # Expz2, Constz, Expz
    └── refractive_index.py  # Ahwfwc (Appleton-Hartree)
```

## Performance

~2.65 ms per ray (sample case). For production use, see `raytrace_core` (Rust, 0.028 ms/ray).
