# ionotrace (Python)

Python bindings for the [ionotrace](https://crates.io/crates/ionotrace) Rust crate — high-performance ionospheric ray tracing.

## Install

```bash
pip install ionotrace
```

### From source (requires Rust toolchain)

```bash
pip install maturin
cd packages/ionotrace-python
maturin develop --release
```

## Quick Start

```python
import ionotrace

# Single ray: 10 MHz, 20° elevation
result = ionotrace.TraceConfig(10.0, 20.0).trace()
print(f"Max height: {result.max_height:.1f} km")
print(f"Ground range: {result.ground_range_km:.1f} km")

# Fan sweep: 5°–80° in 2° steps
config = ionotrace.FanTraceConfig(freq_mhz=15.0, elev_min=5.0, elev_max=80.0, elev_step=2.0)
fan = ionotrace.fan_trace(config)
print(f"Traced {fan.n_rays} rays")

# Target solver: find launch angles to hit (50°N, 5°E)
target = ionotrace.TargetConfig(target_lat_deg=50.0, target_lon_deg=5.0)
solution = ionotrace.solve_target(target)
if solution.best:
    print(f"Elevation: {solution.best.elevation_deg:.1f}°, Error: {solution.best.error_km:.1f} km")
```

## License

MIT
