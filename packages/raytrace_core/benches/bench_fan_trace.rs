//! Fan trace benchmarks — parallel sweep performance at various densities.
//!
//! Each group prints a diagnostic summary before benchmarking, showing the
//! aggregate fan results (total rays, returned count, ground-range spread)
//! so you can understand how the workload scales.
//!
//! # Benchmark groups
//!
//! | Group | Swept parameter | Fixed at |
//! |-------|-----------------|----------|
//! | `size` | Elevation step 5°/2°/1°/0.5° | 10 MHz, defaults |
//! | `frequency` | 5–30 MHz | 41 rays @ 2° step |
//! | `ed_model` | Chapman / DualChapman / QP / VarChapman | 41 rays @ 2° |
//! | `max_hops` | 1 / 2 / 3 | 17 rays @ 5° step |

use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion};
use ionotrace::params::*;
use ionotrace::{fan_trace, FanTraceConfig, FanTraceResult};

// ── Diagnostic helpers ───────────────────────────────────────────────

fn print_fan_header(group_name: &str) {
    eprintln!();
    eprintln!("┌───────────────────────────────────────────────────────────────────────────────────────────────────┐");
    eprintln!("│ {:<93} │", format!("📊 Diagnostics: {group_name}"));
    eprintln!("├──────────────────────┬────────┬──────────┬────────────────┬────────────────┬────────────────────┤");
    eprintln!(
        "│ {:>20} │ {:>6} │ {:>8} │ {:>14} │ {:>14} │ {:>18} │",
        "Config", "Rays", "Returned", "Min Range (km)", "Max Range (km)", "Max Height (km)"
    );
    eprintln!("├──────────────────────┼────────┼──────────┼────────────────┼────────────────┼────────────────────┤");
}

fn print_fan_row(label: &str, r: &FanTraceResult) {
    let returned = r.rays.iter().filter(|ray| ray.ground).count();
    let ranges: Vec<f64> = r
        .rays
        .iter()
        .filter(|ray| ray.ground)
        .map(|ray| ray.range_km)
        .collect();
    let max_heights: Vec<f64> = r.rays.iter().map(|ray| ray.max_h).collect();

    let min_range = ranges.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_range = ranges.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
    let max_ht = max_heights
        .iter()
        .cloned()
        .fold(f64::NEG_INFINITY, f64::max);

    eprintln!(
        "│ {:>20} │ {:>6} │ {:>8} │ {:>14.1} │ {:>14.1} │ {:>18.1} │",
        label,
        r.n_rays,
        returned,
        if min_range.is_finite() {
            min_range
        } else {
            0.0
        },
        if max_range.is_finite() {
            max_range
        } else {
            0.0
        },
        if max_ht.is_finite() { max_ht } else { 0.0 }
    );
}

fn print_fan_footer() {
    eprintln!("└──────────────────────┴────────┴──────────┴────────────────┴────────────────┴────────────────────┘");
    eprintln!();
}

// ── Fan Size Scaling ─────────────────────────────────────────────────

fn bench_fan_sizes(c: &mut Criterion) {
    let configs: Vec<(&str, f64)> = vec![
        ("17_rays@5deg", 5.0),
        ("41_rays@2deg", 2.0),
        ("81_rays@1deg", 1.0),
        ("161_rays@0.5deg", 0.5),
    ];

    print_fan_header("fan_trace/size — 10 MHz, defaults");
    for (label, step) in &configs {
        let config = FanTraceConfig {
            freq_mhz: 10.0,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: *step,
            ..FanTraceConfig::default()
        };
        let r = fan_trace(&config).unwrap();
        print_fan_row(label, &r);
    }
    print_fan_footer();

    let mut group = c.benchmark_group("fan_trace/size");
    group.sample_size(20);
    for (label, step) in &configs {
        let config = FanTraceConfig {
            freq_mhz: 10.0,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: *step,
            ..FanTraceConfig::default()
        };
        group.bench_with_input(BenchmarkId::from_parameter(label), &config, |b, cfg| {
            b.iter(|| fan_trace(cfg).unwrap());
        });
    }
    group.finish();
}

// ── Fan Frequency Comparison ─────────────────────────────────────────

fn bench_fan_frequencies(c: &mut Criterion) {
    let freqs = [5.0, 10.0, 15.0, 20.0, 30.0];

    print_fan_header("fan_trace/frequency — 41 rays @ 2°, defaults");
    for &freq in &freqs {
        let config = FanTraceConfig {
            freq_mhz: freq,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: 2.0,
            ..FanTraceConfig::default()
        };
        let r = fan_trace(&config).unwrap();
        print_fan_row(&format!("{freq:.0} MHz"), &r);
    }
    print_fan_footer();

    let mut group = c.benchmark_group("fan_trace/frequency");
    group.sample_size(20);
    for freq in freqs {
        let config = FanTraceConfig {
            freq_mhz: freq,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: 2.0,
            ..FanTraceConfig::default()
        };
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{freq:.0}MHz")),
            &config,
            |b, cfg| {
                b.iter(|| fan_trace(cfg).unwrap());
            },
        );
    }
    group.finish();
}

// ── Fan ED Model Comparison ──────────────────────────────────────────

fn bench_fan_models(c: &mut Criterion) {
    let models = [
        ("Chapman", ElectronDensityModel::Chapman),
        ("DualChapman", ElectronDensityModel::DualChapman),
        ("QuasiParabolic", ElectronDensityModel::QuasiParabolic),
        ("VarChapman", ElectronDensityModel::VarChapman),
    ];

    print_fan_header("fan_trace/ed_model — 10 MHz, 41 rays @ 2°");
    for (name, model) in &models {
        let mut params = ModelParams::default();
        params.ed_model = *model;
        if matches!(model, ElectronDensityModel::DualChapman) {
            params.fc2 = 4.0;
            params.hm2 = 120.0;
            params.sh2 = 30.0;
        }
        let config = FanTraceConfig {
            freq_mhz: 10.0,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: 2.0,
            params,
            ..FanTraceConfig::default()
        };
        let r = fan_trace(&config).unwrap();
        print_fan_row(name, &r);
    }
    print_fan_footer();

    let mut group = c.benchmark_group("fan_trace/ed_model");
    group.sample_size(20);
    for (name, model) in models {
        let mut params = ModelParams::default();
        params.ed_model = model;
        if matches!(model, ElectronDensityModel::DualChapman) {
            params.fc2 = 4.0;
            params.hm2 = 120.0;
            params.sh2 = 30.0;
        }
        let config = FanTraceConfig {
            freq_mhz: 10.0,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: 2.0,
            params,
            ..FanTraceConfig::default()
        };
        group.bench_with_input(BenchmarkId::from_parameter(name), &config, |b, cfg| {
            b.iter(|| fan_trace(cfg).unwrap());
        });
    }
    group.finish();
}

// ── Fan Multi-Hop Comparison ─────────────────────────────────────────

fn bench_fan_max_hops(c: &mut Criterion) {
    print_fan_header("fan_trace/max_hops — 10 MHz, 17 rays @ 5°");
    for hops in [1_u8, 2, 3] {
        let config = FanTraceConfig {
            freq_mhz: 10.0,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: 5.0,
            max_hops: hops,
            ..FanTraceConfig::default()
        };
        let r = fan_trace(&config).unwrap();
        print_fan_row(&format!("{hops} hops"), &r);
    }
    print_fan_footer();

    let mut group = c.benchmark_group("fan_trace/max_hops");
    group.sample_size(15);
    for hops in [1_u8, 2, 3] {
        let config = FanTraceConfig {
            freq_mhz: 10.0,
            elev_min: 5.0,
            elev_max: 85.0,
            elev_step: 5.0,
            max_hops: hops,
            ..FanTraceConfig::default()
        };
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{hops}_hops")),
            &config,
            |b, cfg| {
                b.iter(|| fan_trace(cfg).unwrap());
            },
        );
    }
    group.finish();
}

criterion_group!(
    benches,
    bench_fan_sizes,
    bench_fan_frequencies,
    bench_fan_models,
    bench_fan_max_hops,
);
criterion_main!(benches);
