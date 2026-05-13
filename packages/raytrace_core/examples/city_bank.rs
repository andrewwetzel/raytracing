use ionotrace::params::*;
use ionotrace::target::{solve_target, SearchSpec, TargetConfig, TargetSolution};
use std::fs::File;
use std::io::Write;

#[derive(Debug, Clone)]
struct City {
    name: &'static str,
    lat: f64,
    lon: f64,
}

// 25 major cities: regional clusters + intercontinental spread
const CITIES: &[City] = &[
    // ---- North America ----
    City { name: "New York",      lat:  40.7128, lon:  -74.0060 },
    City { name: "Chicago",       lat:  41.8781, lon:  -87.6298 },
    City { name: "Los Angeles",   lat:  34.0522, lon: -118.2437 },
    City { name: "Miami",         lat:  25.7617, lon:  -80.1918 },
    City { name: "Mexico City",   lat:  19.4326, lon:  -99.1332 },
    // ---- Europe ----
    City { name: "London",        lat:  51.5074, lon:   -0.1278 },
    City { name: "Paris",         lat:  48.8566, lon:    2.3522 },
    City { name: "Berlin",        lat:  52.5200, lon:   13.4050 },
    City { name: "Moscow",        lat:  55.7558, lon:   37.6173 },
    City { name: "Rome",          lat:  41.9028, lon:   12.4964 },
    City { name: "Madrid",        lat:  40.4168, lon:   -3.7038 },
    City { name: "Istanbul",      lat:  41.0082, lon:   28.9784 },
    // ---- Middle-East / Africa ----
    City { name: "Cairo",         lat:  30.0444, lon:   31.2357 },
    City { name: "Johannesburg",  lat: -26.2041, lon:   28.0473 },
    City { name: "Nairobi",       lat:  -1.2921, lon:   36.8219 },
    // ---- Asia ----
    City { name: "Mumbai",        lat:  19.0760, lon:   72.8777 },
    City { name: "Singapore",     lat:   1.3521, lon:  103.8198 },
    City { name: "Tokyo",         lat:  35.6762, lon:  139.6503 },
    City { name: "Beijing",       lat:  39.9042, lon:  116.4074 },
    City { name: "Seoul",         lat:  37.5665, lon:  126.9780 },
    // ---- Oceania ----
    City { name: "Sydney",        lat: -33.8688, lon:  151.2093 },
    // ---- South America ----
    City { name: "Sao Paulo",     lat: -23.5505, lon:  -46.6333 },
    City { name: "Buenos Aires",  lat: -34.6037, lon:  -58.3816 },
    City { name: "Lima",          lat: -12.0464, lon:  -77.0428 },
    City { name: "Bogota",        lat:   4.7110, lon:  -74.0721 },
];

/// Frequencies to try from high to low — higher frequencies give cleaner
/// signals when MUF supports them, so we prefer them.
const FREQ_SWEEP: &[f64] = &[21.0, 15.0, 10.0, 7.0];

/// Initial bearing from point 1 to point 2 in degrees (0 = north, clockwise).
fn initial_bearing(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    let (la1, lo1) = (lat1.to_radians(), lon1.to_radians());
    let (la2, lo2) = (lat2.to_radians(), lon2.to_radians());
    let dlon = lo2 - lo1;
    let x = dlon.sin() * la2.cos();
    let y = la1.cos() * la2.sin() - la1.sin() * la2.cos() * dlon.cos();
    (x.atan2(y).to_degrees() + 360.0) % 360.0
}

/// Haversine great-circle distance in km.
fn haversine_km(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    let (la1, lo1) = (lat1.to_radians(), lon1.to_radians());
    let (la2, lo2) = (lat2.to_radians(), lon2.to_radians());
    let dlat = la2 - la1;
    let dlon = lo2 - lo1;
    let a = (dlat / 2.0).sin().powi(2) + la1.cos() * la2.cos() * (dlon / 2.0).sin().powi(2);
    2.0 * 6371.0 * a.sqrt().asin()
}

fn make_params() -> ModelParams {
    let mut p = ModelParams::default();
    p.earth_model = EarthModel::Sphere;
    p.mag_model = MagneticFieldModel::Dipole;
    p.rindex_model = RefractiveIndexModel::NoFieldWithCollisions;
    p.ed_model = ElectronDensityModel::Chapman;

    // Solar-max Chapman ionosphere: higher foF2 supports longer hops
    p.fc = 14.0;
    p.hm = 300.0;
    p.ym = 100.0;
    p
}

#[allow(dead_code)]
struct LinkResult {
    tx: String,
    rx: String,
    dist_km: f64,
    elev: f64,
    error_km: f64,
    hops: i32,
    absorption_db: f64,
    max_height_km: f64,
    freq_mhz: f64,
    path_type: &'static str, // "short" or "long"
    success: bool,
}

/// Try to solve a target at a given frequency, bearing, and hop limit.
fn try_solve(
    tx: &City,
    rx: &City,
    bearing: f64,
    freq: f64,
    max_hops: u8,
) -> Option<(TargetSolution, f64)> {
    let lon_diff = rx.lon - tx.lon;

    let config = TargetConfig {
        target_lat_deg: rx.lat,
        target_lon_deg: lon_diff,
        tx_lat_deg: tx.lat,
        freq_mhz: SearchSpec::Fixed(freq),
        azimuth_deg: SearchSpec::Fixed(bearing),
        ray_mode: 1.0,
        error_limit_km: 10.0,
        max_hops,
        params: make_params(),
        elev_min: 1.0,
        elev_max: 85.0,
        coarse_step: 0.5,
        ..TargetConfig::default()
    };

    match solve_target(&config) {
        Ok(result) => result.best.map(|sol| (sol, freq)),
        Err(_) => None,
    }
}

/// Multi-strategy solver: tries multiple frequencies on the short path,
/// then tries the long path (bearing + 180°) if short path fails.
fn solve_multi(
    tx: &City,
    rx: &City,
) -> Option<(TargetSolution, f64, &'static str)> {
    let short_bearing = initial_bearing(tx.lat, tx.lon, rx.lat, rx.lon);
    let long_bearing = (short_bearing + 180.0) % 360.0;

    // Strategy 1: Short path — try each frequency with 12 hops
    for &freq in FREQ_SWEEP {
        if let Some((sol, f)) = try_solve(tx, rx, short_bearing, freq, 12) {
            return Some((sol, f, "short"));
        }
    }

    // Strategy 2: Long path — flip bearing, try each frequency with 12 hops
    for &freq in FREQ_SWEEP {
        if let Some((sol, f)) = try_solve(tx, rx, long_bearing, freq, 12) {
            return Some((sol, f, "long"));
        }
    }

    None
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut file = File::create("city_bank_results.csv")?;
    writeln!(file, "tx_name,rx_name,tx_lat,tx_lon,rx_lat,rx_lon,azimuth,target_dist_km,best_elev_deg,freq_mhz,hops,error_km,absorption_db,max_height_km,path_type")?;

    let total_pairs = CITIES.len() * (CITIES.len() - 1);

    println!();
    println!("  ╔══════════════════════════════════════════════════════════════════════╗");
    println!("  ║                City-to-City HF Link Test Bank                       ║");
    println!("  ║  {} cities · {} pairs · Chapman (foF2=14, hmF2=300, ym=100)          ║", CITIES.len(), total_pairs);
    println!("  ║  Frequencies: {}                       ║",
        FREQ_SWEEP.iter().map(|f| format!("{:.0} MHz", f)).collect::<Vec<_>>().join(", "));
    println!("  ║  Max hops: 12 · Short path + long path fallback                     ║");
    println!("  ╚══════════════════════════════════════════════════════════════════════╝");
    println!();

    let mut results: Vec<LinkResult> = Vec::new();

    // ── Live results table header ──
    println!("  ┌────┬────────────────┬────────────────┬────────┬───────┬──────┬────────┬─────────┬────────┬────────┬───────┐");
    println!("  │    │ TX             │ RX             │ Dist   │ Elev  │ Hops │ Error  │ Absorp  │ MaxAlt │ Freq   │ Path  │");
    println!("  │    │                │                │ (km)   │ (°)   │      │ (km)   │ (dB)    │ (km)   │ (MHz)  │       │");
    println!("  ├────┼────────────────┼────────────────┼────────┼───────┼──────┼────────┼─────────┼────────┼────────┼───────┤");

    for tx in CITIES {
        for rx in CITIES {
            if tx.name == rx.name {
                continue;
            }

            let dist_km = haversine_km(tx.lat, tx.lon, rx.lat, rx.lon);

            match solve_multi(tx, rx) {
                Some((best, freq, path_type)) => {
                    let abs_db = best.absorption.abs();
                    let bearing = initial_bearing(tx.lat, tx.lon, rx.lat, rx.lon);
                    let effective_bearing = if path_type == "long" {
                        (bearing + 180.0) % 360.0
                    } else {
                        bearing
                    };

                    // ── Sanity checks ──────────────────────────────────
                    let mut warnings: Vec<String> = Vec::new();

                    if !best.max_height_km.is_finite() || best.max_height_km < 0.0 || best.max_height_km > 2000.0 {
                        warnings.push(format!("max_height={:.1}km (expected < 2000)", best.max_height_km));
                    }
                    if !abs_db.is_finite() || abs_db > 5000.0 {
                        warnings.push(format!("absorption={:.1}dB (expected < 5000)", abs_db));
                    }
                    if !best.range_km.is_finite() || best.range_km < 0.0 || best.range_km > 50000.0 {
                        warnings.push(format!("range={:.1}km (expected < 50000)", best.range_km));
                    }
                    if !best.elevation_deg.is_finite() || best.elevation_deg < 0.0 || best.elevation_deg > 90.0 {
                        warnings.push(format!("elevation={:.1}° (expected 0–90)", best.elevation_deg));
                    }
                    if !best.error_km.is_finite() {
                        warnings.push(format!("error={:.1}km (NaN/Inf)", best.error_km));
                    }

                    // Clamp bogus values for output
                    let safe_max_h = if best.max_height_km.is_finite() && best.max_height_km >= 0.0 && best.max_height_km <= 2000.0 {
                        best.max_height_km
                    } else {
                        -1.0
                    };
                    let safe_abs = if abs_db.is_finite() && abs_db <= 5000.0 { abs_db } else { -1.0 };

                    if !warnings.is_empty() {
                        println!("  │ ⚠️  │ {:<14} │ {:<14} │ {:>6.0} │ {:>5.1} │ {:>4} │ {:>6.1} │    ⚠️   │   ⚠️   │ {:>6.0} │ {:>5} │  {}",
                            tx.name, rx.name, dist_km, best.elevation_deg, best.hops,
                            best.error_km, freq, path_type, warnings.join(", "));
                    } else {
                        println!("  │ ✅ │ {:<14} │ {:<14} │ {:>6.0} │ {:>5.1} │ {:>4} │ {:>6.1} │ {:>7.1} │ {:>6.0} │ {:>6.0} │ {:>5} │",
                            tx.name, rx.name, dist_km, best.elevation_deg, best.hops,
                            best.error_km, safe_abs, safe_max_h, freq, path_type);
                    }

                    writeln!(file, "{},{},{:.4},{:.4},{:.4},{:.4},{:.4},{:.4},{:.4},{:.1},{},{:.4},{:.4},{:.1},{}",
                        tx.name, rx.name,
                        tx.lat, tx.lon, rx.lat, rx.lon,
                        effective_bearing,
                        best.range_km - best.error_km,
                        best.elevation_deg,
                        freq,
                        best.hops,
                        best.error_km,
                        safe_abs,
                        safe_max_h,
                        path_type
                    )?;

                    results.push(LinkResult {
                        tx: tx.name.to_string(), rx: rx.name.to_string(),
                        dist_km, elev: best.elevation_deg, error_km: best.error_km,
                        hops: best.hops as i32, absorption_db: safe_abs,
                        max_height_km: safe_max_h, freq_mhz: freq,
                        path_type, success: true,
                    });
                }
                None => {
                    println!("  │ ❌ │ {:<14} │ {:<14} │ {:>6.0} │     — │    — │      — │       — │      — │      — │     — │",
                        tx.name, rx.name, dist_km);
                    results.push(LinkResult {
                        tx: tx.name.to_string(), rx: rx.name.to_string(),
                        dist_km, elev: 0.0, error_km: 0.0, hops: 0,
                        absorption_db: 0.0, max_height_km: 0.0, freq_mhz: 0.0,
                        path_type: "-", success: false,
                    });
                }
            }
        }
    }
    println!("  └────┴────────────────┴────────────────┴────────┴───────┴──────┴────────┴─────────┴────────┴────────┴───────┘");

    // ── Summary ────────────────────────────────────────────
    let successes: Vec<&LinkResult> = results.iter().filter(|r| r.success).collect();
    let failures: Vec<&LinkResult> = results.iter().filter(|r| !r.success).collect();
    let num_tested = results.len();
    let num_success = successes.len();
    let short_count = successes.iter().filter(|r| r.path_type == "short").count();
    let long_count = successes.iter().filter(|r| r.path_type == "long").count();
    let avg_err: f64 = if num_success > 0 { successes.iter().map(|r| r.error_km).sum::<f64>() / num_success as f64 } else { 0.0 };
    let avg_abs: f64 = if num_success > 0 { successes.iter().map(|r| r.absorption_db).sum::<f64>() / num_success as f64 } else { 0.0 };
    let min_abs: f64 = successes.iter().map(|r| r.absorption_db).fold(f64::MAX, f64::min);
    let max_abs: f64 = successes.iter().map(|r| r.absorption_db).fold(0.0f64, f64::max);

    // Frequency breakdown
    let mut freq_counts: std::collections::BTreeMap<String, usize> = std::collections::BTreeMap::new();
    for s in &successes {
        *freq_counts.entry(format!("{:.0}", s.freq_mhz)).or_insert(0) += 1;
    }
    let freq_str = freq_counts.iter().map(|(f, c)| format!("{}MHz={}", f, c)).collect::<Vec<_>>().join("  ");

    // ── SUMMARY BOX ──
    println!();
    println!("  ┌──────────────────────────────────────────────────────────────────────┐");
    println!("  │                             SUMMARY                                  │");
    println!("  ├────────────────────┬─────────────────────────────────────────────────┤");
    println!("  │ Pairs tested       │ {:>6}                                          │", num_tested);
    println!("  │ Paths solved       │ {:>6} ({:.1}%)                                  │", num_success, 100.0 * num_success as f64 / num_tested as f64);
    println!("  │ Unsolved           │ {:>6}                                          │", num_tested - num_success);
    println!("  ├────────────────────┼─────────────────────────────────────────────────┤");
    println!("  │ Short path         │ {:>6}                                          │", short_count);
    println!("  │ Long path          │ {:>6}                                          │", long_count);
    println!("  ├────────────────────┼─────────────────────────────────────────────────┤");
    println!("  │ Avg error          │ {:>6.2} km                                      │", avg_err);
    println!("  │ Avg absorption     │ {:>6.1} dB                                      │", avg_abs);
    println!("  │ Absorption range   │ {:>6.1} – {:.1} dB                              │", min_abs, max_abs);
    println!("  ├────────────────────┼─────────────────────────────────────────────────┤");
    println!("  │ By frequency       │ {:<45} │", freq_str);
    println!("  └────────────────────┴─────────────────────────────────────────────────┘");

    // ── UNSOLVED PAIRS TABLE ──
    if !failures.is_empty() {
        println!();
        println!("  Unsolved Pairs ({}):", failures.len());
        println!("  ┌────────────────┬────────────────┬────────┐");
        println!("  │ TX             │ RX             │ Dist   │");
        println!("  │                │                │ (km)   │");
        println!("  ├────────────────┼────────────────┼────────┤");
        for f in &failures {
            println!("  │ {:<14} │ {:<14} │ {:>6.0} │", f.tx, f.rx, f.dist_km);
        }
        println!("  └────────────────┴────────────────┴────────┘");
    }

    println!();
    println!("  Results saved to city_bank_results.csv");

    Ok(())
}
