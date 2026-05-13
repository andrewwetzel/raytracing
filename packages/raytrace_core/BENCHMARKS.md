# Benchmarking ionotrace

Criterion-based benchmarks for measuring and comparing ionotrace performance
across the full ray-tracing parameter space.

## Quick Start

```bash
# From the repo root:
just bench              # Run all benchmarks
just bench-single       # Single-ray benchmarks only
just bench-fan          # Fan trace benchmarks only
just bench-throughput   # Throughput benchmarks only

# Or from packages/raytrace_core:
cargo bench                                  # All benchmarks
cargo bench --bench bench_single_ray         # Just single-ray
cargo bench -- "single_ray/elevation"        # Filter to one group
```

## Benchmark Suites

### `bench_single_ray` — Individual Ray Performance

Traces a single ray per iteration, sweeping one parameter at a time while
holding the rest fixed.  **Prints a diagnostic table before each group**
showing the physics outcome (steps, max height, ground range, returned) so
you can immediately see _why_ timings differ.

| Group | Parameter swept | # Configs | Key insight |
|-------|----------------|-----------|-------------|
| `elevation` | 5°–89° | 18 | Low elevations → more steps (longer path) |
| `frequency` | 2–30 MHz | 9 | Below foF2 → reflected; above → escapes |
| `azimuth` | 0°–315° | 8 | Magnetic field coupling varies with direction |
| `latitude` | -60°–80° | 7 | Dip angle changes magnetic effects |
| `ed_model` | All 6 models | 6 | Model complexity vs. accuracy trade-off |
| `mag_model` | All 4 models | 4 | IGRF-14 is most expensive (spherical harmonics) |
| `ray_mode` | O vs X | 2 | X-mode refracts at higher altitude |
| `coord_system` | Spherical vs ECEF | 8 | ECEF avoids polar singularity, may cost more |
| `step_size` | 1.0–20.0 | 5 | Smaller step → more iterations → slower |
| `integrator` | RK4 / RK4+AM / RK4+AM+err | 3 | Higher-order methods: fewer steps, more work/step |

**Example diagnostic output:**
```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│ 📊 Diagnostics: single_ray/frequency — 20° elev, 0° az, 40°N, X-mode, Spherical   │
├──────────────────────┬────────┬──────────────┬──────────────┬──────────┬───────────┤
│               Config │  Steps │  Max Ht (km) │  Gnd Rng (km)│ Returned │    Points │
├──────────────────────┼────────┼──────────────┼──────────────┼──────────┼───────────┤
│               2 MHz  │     28 │         59.1 │        233.7 │    ✓ yes │         4 │
│              10 MHz  │     84 │        196.1 │        751.2 │    ✓ yes │         9 │
│              30 MHz  │    500 │       3419.8 │          0.0 │    ✗ no  │        51 │
└──────────────────────┴────────┴──────────────┴──────────────┴──────────┴───────────┘
```

### `bench_fan_trace` — Parallel Fan Sweep

Benchmarks `fan_trace()` which parallelizes across elevation angles via Rayon.
Prints fan-level summaries (rays, returned count, range spread, max apex).

| Group | Parameter swept | # Configs |
|-------|----------------|-----------|
| `size` | 17/41/81/161 rays | 4 |
| `frequency` | 5–30 MHz | 5 |
| `ed_model` | Chapman / DualChapman / QP / VarChapman | 4 |
| `max_hops` | 1 / 2 / 3 | 3 |

### `bench_throughput` — Bulk Throughput

Traces a large batch of diverse rays in one iteration to measure aggregate
rays/second.  Prints a batch summary with return statistics, step-count
distribution histogram, and height/range bounds.

| Group | Batch size | Description |
|-------|-----------|-------------|
| `throughput` | 121 rays | freq × elev × az + lat × mode × coord + ED models |
| `throughput_hifi` | 8 rays | High-fidelity: step=1.0, max_steps=2000, mode 3 |

## Reading the Output

### Diagnostic Tables

Every benchmark group prints a diagnostic table **to stderr** before the
criterion timing begins. This is crucial for understanding results:

- **Steps** — Total integration steps.  More steps = more work = slower.
  This is the primary driver of timing differences.
- **Max Ht** — Peak altitude reached.  A ray that escapes the ionosphere
  (high frequency, steep elevation) will hit `max_steps`.
- **Gnd Rng** — Ground range of the landing point (0 if ray didn't return).
- **Returned** — Whether the ray came back to ground (✓) or escaped (✗).
  Escaped rays always take `max_steps` iterations.
- **Δ values** — For coord_system comparisons, the difference between
  Spherical and ECEF results shows if the two formulations agree.

### Criterion Output

After the diagnostics, criterion's standard output shows timing:

```
single_ray/elevation/20deg
                        time:   [148.23 µs 150.71 µs 153.32 µs]
                        change: [-1.2% +0.3% +1.8%] (p = 0.68 > 0.05)
                        No change in performance detected.
```

- **time** — [lower CI, estimate, upper CI] for one iteration
- **change** — Comparison with the previous run (if baseline exists)
- **HTML reports** — Generated at `target/criterion/` with plots

## Tips

- **Run specific groups**: `cargo bench -- "ed_model"` to focus on one area
- **Save baselines**: `cargo bench -- --save-baseline v0.3.1` before changes
- **Compare baselines**: `cargo bench -- --baseline v0.3.1` after changes
- **Verbose diagnostics**: Diagnostic tables print to stderr, pipe stdout
  to `/dev/null` if you just want the physics info
- **Quiet diagnostics**: Pipe stderr to `/dev/null` if you just want timing
