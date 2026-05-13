//! Bulk throughput benchmark — traces a large batch of diverse rays to produce
//! aggregate throughput metrics (rays/second).
//!
//! Before timing, prints a **summary of the batch composition** so you can see
//! exactly what is being timed, and a **result summary** showing how many rays
//! returned, the step-count distribution, and aggregate physics.
//!
//! # Benchmark groups
//!
//! | Group | Description |
//! |-------|-------------|
//! | `throughput` | 121 diverse rays (freq × elev × az + lat × mode × coord + ED models) |
//! | `throughput_hifi` | 8 rays with step=1.0, max_steps=2000 (high-fidelity) |

use criterion::{criterion_group, criterion_main, Criterion};
use ionotrace::params::*;
use ionotrace::tracer::{trace_ray, TraceResult};
use ionotrace::CoordinateSystem;

/// A compact description of a single ray to trace.
struct RaySpec {
    freq: f64,
    elev: f64,
    az: f64,
    lat: f64,
    mode: f64,
    coord: CoordinateSystem,
    params: ModelParams,
    /// Human-readable label for diagnostics (e.g. "10MHz/20°/45°az/40°N")
    label: String,
}

/// Build a diverse batch of ray specifications covering the parameter space.
fn build_ray_batch() -> Vec<RaySpec> {
    let freqs = [5.0, 10.0, 15.0, 25.0];
    let elevations = [5.0, 15.0, 30.0, 45.0, 60.0, 80.0];
    let azimuths = [0.0, 90.0, 180.0, 270.0];
    let latitudes = [-40.0, 0.0, 40.0, 70.0];
    let modes: [(f64, &str); 2] = [(-1.0, "X"), (1.0, "O")];
    let coords = [
        (CoordinateSystem::Spherical, "Sph"),
        (CoordinateSystem::Ecef, "ECEF"),
    ];

    let ed_models: Vec<(&str, ModelParams)> = vec![
        ("Chapman", ModelParams::default()),
        ("DualChapman", {
            let mut p = ModelParams::default();
            p.ed_model = ElectronDensityModel::DualChapman;
            p.fc2 = 4.0;
            p.hm2 = 120.0;
            p.sh2 = 30.0;
            p
        }),
        ("QuasiParab", {
            let mut p = ModelParams::default();
            p.ed_model = ElectronDensityModel::QuasiParabolic;
            p
        }),
    ];

    let mut batch = Vec::with_capacity(256);
    let p = ModelParams::default();

    // Sweep elevation × frequency × azimuth at mid-latitude with default model
    for &freq in &freqs {
        for &elev in &elevations {
            for &az in &azimuths {
                batch.push(RaySpec {
                    freq,
                    elev,
                    az,
                    lat: 40.0,
                    mode: -1.0,
                    coord: CoordinateSystem::Spherical,
                    params: p.clone(),
                    label: format!("{freq:.0}MHz/{elev:.0}°/{az:.0}°az"),
                });
            }
        }
    }

    // Sweep latitude × mode × coord system
    for &lat in &latitudes {
        for &(mode_val, mode_name) in &modes {
            for &(coord, coord_name) in &coords {
                batch.push(RaySpec {
                    freq: 10.0,
                    elev: 20.0,
                    az: 45.0,
                    lat,
                    mode: mode_val,
                    coord,
                    params: p.clone(),
                    label: format!("{lat:.0}°N/{mode_name}/{coord_name}"),
                });
            }
        }
    }

    // Sweep ED models × elevation
    for (model_name, params) in &ed_models {
        for &elev in &[10.0, 30.0, 60.0] {
            batch.push(RaySpec {
                freq: 10.0,
                elev,
                az: 0.0,
                lat: 40.0,
                mode: -1.0,
                coord: CoordinateSystem::Spherical,
                params: params.clone(),
                label: format!("{model_name}/{elev:.0}°"),
            });
        }
    }

    batch
}

/// Print a full diagnostic summary of the batch results.
fn print_batch_summary(name: &str, results: &[(String, TraceResult)]) {
    let n = results.len();
    let returned = results.iter().filter(|(_, r)| r.returned_to_ground).count();
    let escaped = n - returned;
    let steps: Vec<usize> = results.iter().map(|(_, r)| r.n_steps).collect();
    let total_steps: usize = steps.iter().sum();
    let min_steps = steps.iter().min().copied().unwrap_or(0);
    let max_steps = steps.iter().max().copied().unwrap_or(0);
    let avg_steps = total_steps as f64 / n as f64;

    let max_heights: Vec<f64> = results.iter().map(|(_, r)| r.max_height).collect();
    let min_ht = max_heights.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_ht = max_heights
        .iter()
        .cloned()
        .fold(f64::NEG_INFINITY, f64::max);

    let ranges: Vec<f64> = results
        .iter()
        .filter(|(_, r)| r.returned_to_ground)
        .map(|(_, r)| r.ground_range_km)
        .collect();
    let min_range = ranges.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_range = ranges.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

    eprintln!();
    eprintln!("┌─────────────────────────────────────────────────────────────┐");
    eprintln!("│ {:<59} │", format!("📊 Batch Summary: {name}"));
    eprintln!("├─────────────────────────────────────────────────────────────┤");
    eprintln!(
        "│  Total rays:       {:>6}                                  │",
        n
    );
    eprintln!(
        "│  Returned:         {:>6}  ({:.0}%){}│",
        returned,
        100.0 * returned as f64 / n as f64,
        " ".repeat(25)
    );
    eprintln!(
        "│  Escaped:          {:>6}  ({:.0}%){}│",
        escaped,
        100.0 * escaped as f64 / n as f64,
        " ".repeat(25)
    );
    eprintln!(
        "│  Total int. steps: {:>6}                                  │",
        total_steps
    );
    eprintln!("├─────────────────────────────────────────────────────────────┤");
    eprintln!(
        "│  Steps:   min={:<5}  avg={:<7.1}  max={:<5}              │",
        min_steps, avg_steps, max_steps
    );
    eprintln!(
        "│  Max Ht:  min={:<7.1} km  max={:<7.1} km                 │",
        min_ht, max_ht
    );
    if !ranges.is_empty() {
        eprintln!(
            "│  Range:   min={:<7.1} km  max={:<7.1} km                 │",
            if min_range.is_finite() {
                min_range
            } else {
                0.0
            },
            if max_range.is_finite() {
                max_range
            } else {
                0.0
            }
        );
    }
    eprintln!("├─────────────────────────────────────────────────────────────┤");

    // Print step-count distribution histogram
    let buckets = [
        (0, 50, "  0–50"),
        (51, 100, " 51–100"),
        (101, 200, "101–200"),
        (201, 300, "201–300"),
        (301, 400, "301–400"),
        (401, 500, "401–500"),
        (501, usize::MAX, "  500+"),
    ];
    eprintln!("│  Step distribution:                                       │");
    for (lo, hi, label) in &buckets {
        let count = steps.iter().filter(|&&s| s >= *lo && s <= *hi).count();
        if count > 0 {
            let bar_len = (count * 30 / n).max(1);
            let bar: String = "█".repeat(bar_len);
            eprintln!("│    {label} steps: {bar:<30} {:>3} rays │", count);
        }
    }
    eprintln!("└─────────────────────────────────────────────────────────────┘");
    eprintln!();
}

fn bench_bulk_throughput(c: &mut Criterion) {
    let batch = build_ray_batch();
    let n = batch.len();

    // Run once for diagnostics
    let results: Vec<(String, TraceResult)> = batch
        .iter()
        .map(|ray| {
            let r = trace_ray(
                ray.freq,
                ray.mode,
                ray.elev,
                ray.az,
                ray.lat,
                2,
                ray.coord,
                5.0,
                500,
                1e-4,
                2e-6,
                100.0,
                &ray.params,
                10,
            )
            .unwrap();
            (ray.label.clone(), r)
        })
        .collect();
    print_batch_summary(&format!("{n} diverse rays"), &results);

    let mut group = c.benchmark_group("throughput");
    group.sample_size(10);
    group.throughput(criterion::Throughput::Elements(n as u64));

    group.bench_function(format!("{n}_diverse_rays"), |b| {
        b.iter(|| {
            for ray in &batch {
                let _ = trace_ray(
                    ray.freq,
                    ray.mode,
                    ray.elev,
                    ray.az,
                    ray.lat,
                    2,
                    ray.coord,
                    5.0,
                    500,
                    1e-4,
                    2e-6,
                    100.0,
                    &ray.params,
                    10,
                );
            }
        });
    });

    group.finish();
}

fn bench_bulk_throughput_high_precision(c: &mut Criterion) {
    let p = ModelParams::default();
    let elevations = [5.0, 10.0, 20.0, 30.0, 45.0, 60.0, 75.0, 85.0];
    let n = elevations.len();

    // Run once for diagnostics
    let results: Vec<(String, TraceResult)> = elevations
        .iter()
        .map(|&elev| {
            let r = trace_ray(
                10.0,
                -1.0,
                elev,
                0.0,
                40.0,
                3,
                CoordinateSystem::Spherical,
                1.0,
                2000,
                1e-4,
                2e-6,
                100.0,
                &p,
                10,
            )
            .unwrap();
            (format!("{elev:.0}° hi-fi"), r)
        })
        .collect();
    print_batch_summary(&format!("{n} high-fidelity rays (step=1.0)"), &results);

    let mut group = c.benchmark_group("throughput_hifi");
    group.sample_size(10);
    group.throughput(criterion::Throughput::Elements(n as u64));

    group.bench_function(format!("{n}_rays_step1.0"), |b| {
        b.iter(|| {
            for &elev in &elevations {
                let _ = trace_ray(
                    10.0,
                    -1.0,
                    elev,
                    0.0,
                    40.0,
                    3,
                    CoordinateSystem::Spherical,
                    1.0,
                    2000,
                    1e-4,
                    2e-6,
                    100.0,
                    &p,
                    10,
                );
            }
        });
    });

    group.finish();
}

criterion_group!(
    benches,
    bench_bulk_throughput,
    bench_bulk_throughput_high_precision
);
criterion_main!(benches);
