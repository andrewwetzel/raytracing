//! Single-ray benchmarks across diverse ionospheric configurations.
//!
//! Each benchmark group prints a **diagnostic table** before timing begins,
//! showing the physics outcome of every configuration (steps taken, max height,
//! ground range, returned-to-ground).  This makes it easy to see _why_ two
//! configurations have different timings — a ray that takes 400 steps is doing
//! roughly 4× more work than one that finishes in 100.
//!
//! # Benchmark groups
//!
//! | Group | Swept parameter | Fixed at |
//! |-------|-----------------|----------|
//! | `elevation` | 5°–89° | 10 MHz, 0° az, 40°N, X-mode, spherical |
//! | `frequency` | 2–30 MHz | 20° elev, 0° az, 40°N |
//! | `azimuth` | 0°–315° | 10 MHz, 20° elev, 40°N |
//! | `latitude` | -60°–80° | 10 MHz, 20° elev, 0° az |
//! | `ed_model` | All 6 ED models | 10 MHz, 20° elev, 45° az, 40°N |
//! | `mag_model` | All 4 mag models | 10 MHz, 20° elev, 45° az, 40°N |
//! | `ray_mode` | O vs X | 10 MHz, 20° elev, 45° az, 40°N |
//! | `coord_system` | Spherical vs ECEF × 4 elevations | 10 MHz, 0° az, 40°N |
//! | `step_size` | 1.0–20.0 | 10 MHz, 20° elev, 45° az, 40°N |
//! | `integrator` | RK4 / RK4+AM / RK4+AM+err | 10 MHz, 20° elev, 45° az, 40°N |

use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion};
use ionotrace::params::*;
use ionotrace::tracer::{trace_ray, TraceResult};
use ionotrace::CoordinateSystem;

// ── Helpers ──────────────────────────────────────────────────────────

fn default_params() -> ModelParams {
    ModelParams::default()
}

/// Trace a single ray and return the result for diagnostics.
fn trace_with_result(
    freq: f64,
    elev: f64,
    az: f64,
    lat: f64,
    mode: f64,
    coord: CoordinateSystem,
    params: &ModelParams,
) -> TraceResult {
    trace_ray(
        freq, mode, elev, az, lat, 2, coord, 5.0, 500, 1e-4, 2e-6, 100.0, params, 10,
    )
    .unwrap()
}

/// Trace with explicit integrator parameters and return the result.
fn trace_with_integrator(
    freq: f64,
    elev: f64,
    az: f64,
    lat: f64,
    mode: f64,
    coord: CoordinateSystem,
    int_mode: usize,
    step_size: f64,
    max_steps: usize,
    params: &ModelParams,
) -> TraceResult {
    trace_ray(
        freq, mode, elev, az, lat, int_mode, coord, step_size, max_steps, 1e-4, 2e-6, 100.0,
        params, 10,
    )
    .unwrap()
}

/// Print a diagnostic header for a benchmark group.
fn print_header(group_name: &str) {
    eprintln!();
    eprintln!(
        "┌─────────────────────────────────────────────────────────────────────────────────────┐"
    );
    eprintln!("│ {:<81} │", format!("📊 Diagnostics: {group_name}"));
    eprintln!(
        "├──────────────────────┬────────┬──────────────┬──────────────┬──────────┬───────────┤"
    );
    eprintln!(
        "│ {:>20} │ {:>6} │ {:>12} │ {:>12} │ {:>8} │ {:>9} │",
        "Config", "Steps", "Max Ht (km)", "Gnd Rng (km)", "Returned", "Points"
    );
    eprintln!(
        "├──────────────────────┼────────┼──────────────┼──────────────┼──────────┼───────────┤"
    );
}

fn print_row(label: &str, r: &TraceResult) {
    eprintln!(
        "│ {:>20} │ {:>6} │ {:>12.1} │ {:>12.1} │ {:>8} │ {:>9} │",
        label,
        r.n_steps,
        r.max_height,
        r.ground_range_km,
        if r.returned_to_ground {
            "✓ yes"
        } else {
            "✗ no"
        },
        r.points.len()
    );
}

fn print_footer() {
    eprintln!(
        "└──────────────────────┴────────┴──────────────┴──────────────┴──────────┴───────────┘"
    );
    eprintln!();
}

// ── Elevation Sweep ──────────────────────────────────────────────────

fn bench_elevation_sweep(c: &mut Criterion) {
    let p = default_params();
    let elevations = [
        5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0,
        80.0, 85.0, 89.0,
    ];

    // Diagnostic preamble
    print_header("single_ray/elevation — 10 MHz X-mode, 0° az, 40°N, Spherical");
    for &elev in &elevations {
        let r = trace_with_result(10.0, elev, 0.0, 40.0, -1.0, CoordinateSystem::Spherical, &p);
        print_row(&format!("{elev:.0}°"), &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/elevation");
    for elev in elevations {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{elev:.0}deg")),
            &elev,
            |b, &e| {
                b.iter(|| {
                    trace_with_result(10.0, e, 0.0, 40.0, -1.0, CoordinateSystem::Spherical, &p)
                });
            },
        );
    }
    group.finish();
}

// ── Frequency Sweep ──────────────────────────────────────────────────

fn bench_frequency_sweep(c: &mut Criterion) {
    let p = default_params();
    let freqs = [2.0, 5.0, 8.0, 10.0, 12.0, 15.0, 20.0, 25.0, 30.0];

    print_header("single_ray/frequency — 20° elev, 0° az, 40°N, X-mode, Spherical");
    for &freq in &freqs {
        let r = trace_with_result(freq, 20.0, 0.0, 40.0, -1.0, CoordinateSystem::Spherical, &p);
        print_row(&format!("{freq:.0} MHz"), &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/frequency");
    for freq in freqs {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{freq:.0}MHz")),
            &freq,
            |b, &f| {
                b.iter(|| {
                    trace_with_result(f, 20.0, 0.0, 40.0, -1.0, CoordinateSystem::Spherical, &p)
                });
            },
        );
    }
    group.finish();
}

// ── Azimuth Sweep ────────────────────────────────────────────────────

fn bench_azimuth_sweep(c: &mut Criterion) {
    let p = default_params();
    let azimuths = [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0];

    print_header("single_ray/azimuth — 10 MHz, 20° elev, 40°N, X-mode, Spherical");
    for &az in &azimuths {
        let r = trace_with_result(10.0, 20.0, az, 40.0, -1.0, CoordinateSystem::Spherical, &p);
        print_row(&format!("{az:.0}°"), &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/azimuth");
    for az in azimuths {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{az:.0}az")),
            &az,
            |b, &a| {
                b.iter(|| {
                    trace_with_result(10.0, 20.0, a, 40.0, -1.0, CoordinateSystem::Spherical, &p)
                });
            },
        );
    }
    group.finish();
}

// ── Latitude Sweep ───────────────────────────────────────────────────

fn bench_latitude_sweep(c: &mut Criterion) {
    let p = default_params();
    let latitudes = [-60.0, -30.0, 0.0, 20.0, 40.0, 60.0, 80.0];

    print_header("single_ray/latitude — 10 MHz, 20° elev, 0° az, X-mode, Spherical");
    for &lat in &latitudes {
        let r = trace_with_result(10.0, 20.0, 0.0, lat, -1.0, CoordinateSystem::Spherical, &p);
        print_row(&format!("{lat:.0}°N"), &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/latitude");
    for lat in latitudes {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{lat:.0}lat")),
            &lat,
            |b, &l| {
                b.iter(|| {
                    trace_with_result(10.0, 20.0, 0.0, l, -1.0, CoordinateSystem::Spherical, &p)
                });
            },
        );
    }
    group.finish();
}

// ── Electron Density Model Comparison ────────────────────────────────

fn bench_ed_models(c: &mut Criterion) {
    let models: Vec<(&str, ModelParams)> = vec![
        ("Chapman", {
            let p = default_params();
            p
        }),
        ("Elect1", {
            let mut p = default_params();
            p.ed_model = ElectronDensityModel::Elect1;
            p
        }),
        ("Linear", {
            let mut p = default_params();
            p.ed_model = ElectronDensityModel::Linear;
            p
        }),
        ("QuasiParabolic", {
            let mut p = default_params();
            p.ed_model = ElectronDensityModel::QuasiParabolic;
            p
        }),
        ("VarChapman", {
            let mut p = default_params();
            p.ed_model = ElectronDensityModel::VarChapman;
            p
        }),
        ("DualChapman", {
            let mut p = default_params();
            p.ed_model = ElectronDensityModel::DualChapman;
            p.fc2 = 4.0;
            p.hm2 = 120.0;
            p.sh2 = 30.0;
            p
        }),
    ];

    print_header("single_ray/ed_model — 10 MHz, 20° elev, 45° az, 40°N, X-mode");
    for (name, params) in &models {
        let r = trace_with_result(
            10.0,
            20.0,
            45.0,
            40.0,
            -1.0,
            CoordinateSystem::Spherical,
            params,
        );
        print_row(name, &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/ed_model");
    for (name, params) in &models {
        group.bench_with_input(BenchmarkId::from_parameter(*name), params, |b, p| {
            b.iter(|| {
                trace_with_result(10.0, 20.0, 45.0, 40.0, -1.0, CoordinateSystem::Spherical, p)
            });
        });
    }
    group.finish();
}

// ── Magnetic Field Model Comparison ──────────────────────────────────

fn bench_mag_models(c: &mut Criterion) {
    let models: Vec<(&str, ModelParams)> = vec![
        ("Dipole", {
            let p = default_params();
            p
        }),
        ("Constant", {
            let mut p = default_params();
            p.mag_model = MagneticFieldModel::Constant;
            p
        }),
        ("Cubic", {
            let mut p = default_params();
            p.mag_model = MagneticFieldModel::Cubic;
            p
        }),
        ("IGRF14", {
            let mut p = default_params();
            p.mag_model = MagneticFieldModel::Igrf14;
            p
        }),
    ];

    print_header("single_ray/mag_model — 10 MHz, 20° elev, 45° az, 40°N, X-mode");
    for (name, params) in &models {
        let r = trace_with_result(
            10.0,
            20.0,
            45.0,
            40.0,
            -1.0,
            CoordinateSystem::Spherical,
            params,
        );
        print_row(name, &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/mag_model");
    for (name, params) in &models {
        group.bench_with_input(BenchmarkId::from_parameter(*name), params, |b, p| {
            b.iter(|| {
                trace_with_result(10.0, 20.0, 45.0, 40.0, -1.0, CoordinateSystem::Spherical, p)
            });
        });
    }
    group.finish();
}

// ── Ray Mode Comparison ──────────────────────────────────────────────

fn bench_ray_modes(c: &mut Criterion) {
    let p = default_params();

    print_header("single_ray/ray_mode — 10 MHz, 20° elev, 45° az, 40°N, Spherical");
    let rx = trace_with_result(
        10.0,
        20.0,
        45.0,
        40.0,
        -1.0,
        CoordinateSystem::Spherical,
        &p,
    );
    print_row("X-mode", &rx);
    let ro = trace_with_result(10.0, 20.0, 45.0, 40.0, 1.0, CoordinateSystem::Spherical, &p);
    print_row("O-mode", &ro);
    print_footer();

    let mut group = c.benchmark_group("single_ray/ray_mode");
    group.bench_function("X-mode", |b| {
        b.iter(|| {
            trace_with_result(
                10.0,
                20.0,
                45.0,
                40.0,
                -1.0,
                CoordinateSystem::Spherical,
                &p,
            )
        });
    });
    group.bench_function("O-mode", |b| {
        b.iter(|| trace_with_result(10.0, 20.0, 45.0, 40.0, 1.0, CoordinateSystem::Spherical, &p));
    });
    group.finish();
}

// ── Coordinate System Comparison ─────────────────────────────────────

fn bench_coord_systems(c: &mut Criterion) {
    let p = default_params();
    let elevations = [10.0, 30.0, 60.0, 80.0];

    print_header("single_ray/coord_system — 10 MHz, 0° az, 40°N, X-mode");
    for &elev in &elevations {
        let rs = trace_with_result(10.0, elev, 0.0, 40.0, -1.0, CoordinateSystem::Spherical, &p);
        print_row(&format!("Sph {elev:.0}°"), &rs);
        let re = trace_with_result(10.0, elev, 0.0, 40.0, -1.0, CoordinateSystem::Ecef, &p);
        print_row(&format!("ECEF {elev:.0}°"), &re);
        // Show the delta so you can see if the two coordinate systems agree
        eprintln!(
            "│ {:>20} │ {:>+6} │ {:>+12.2} │ {:>+12.2} │          │           │",
            format!("  Δ(ECEF−Sph) {elev:.0}°"),
            re.n_steps as i64 - rs.n_steps as i64,
            re.max_height - rs.max_height,
            re.ground_range_km - rs.ground_range_km
        );
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/coord_system");
    for elev in elevations {
        group.bench_with_input(
            BenchmarkId::new("Spherical", format!("{elev:.0}deg")),
            &elev,
            |b, &e| {
                b.iter(|| {
                    trace_with_result(10.0, e, 0.0, 40.0, -1.0, CoordinateSystem::Spherical, &p)
                })
            },
        );
        group.bench_with_input(
            BenchmarkId::new("ECEF", format!("{elev:.0}deg")),
            &elev,
            |b, &e| {
                b.iter(|| trace_with_result(10.0, e, 0.0, 40.0, -1.0, CoordinateSystem::Ecef, &p))
            },
        );
    }
    group.finish();
}

// ── Step-Size / Precision Comparison ─────────────────────────────────

fn bench_step_sizes(c: &mut Criterion) {
    let p = default_params();
    let steps = [1.0, 2.5, 5.0, 10.0, 20.0];

    print_header("single_ray/step_size — 10 MHz, 20° elev, 45° az, 40°N, X-mode");
    for &step in &steps {
        let r = trace_with_integrator(
            10.0,
            20.0,
            45.0,
            40.0,
            -1.0,
            CoordinateSystem::Spherical,
            2,
            step,
            1000,
            &p,
        );
        print_row(&format!("h={step}"), &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/step_size");
    for step in steps {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("h={step}")),
            &step,
            |b, &s| {
                b.iter(|| {
                    trace_with_integrator(
                        10.0,
                        20.0,
                        45.0,
                        40.0,
                        -1.0,
                        CoordinateSystem::Spherical,
                        2,
                        s,
                        1000,
                        &p,
                    )
                });
            },
        );
    }
    group.finish();
}

// ── Integration Mode Comparison ──────────────────────────────────────

fn bench_integrators(c: &mut Criterion) {
    let p = default_params();
    let modes = [("RK4-only", 1_usize), ("RK4+AM", 2), ("RK4+AM+error", 3)];

    print_header("single_ray/integrator — 10 MHz, 20° elev, 45° az, 40°N, X-mode");
    for &(name, mode) in &modes {
        let r = trace_with_integrator(
            10.0,
            20.0,
            45.0,
            40.0,
            -1.0,
            CoordinateSystem::Spherical,
            mode,
            5.0,
            500,
            &p,
        );
        print_row(name, &r);
    }
    print_footer();

    let mut group = c.benchmark_group("single_ray/integrator");
    for (name, mode) in modes {
        group.bench_function(name, |b| {
            b.iter(|| {
                trace_with_integrator(
                    10.0,
                    20.0,
                    45.0,
                    40.0,
                    -1.0,
                    CoordinateSystem::Spherical,
                    mode,
                    5.0,
                    500,
                    &p,
                )
            });
        });
    }
    group.finish();
}

// ── Group & Register ─────────────────────────────────────────────────

criterion_group!(
    benches,
    bench_elevation_sweep,
    bench_frequency_sweep,
    bench_azimuth_sweep,
    bench_latitude_sweep,
    bench_ed_models,
    bench_mag_models,
    bench_ray_modes,
    bench_coord_systems,
    bench_step_sizes,
    bench_integrators,
);
criterion_main!(benches);
