//! Comprehensive stress test: compare ionotrace vs PHaRLAP across 12 scenarios.
//!
//! Reads pharlap_stress_results.csv and runs matched traces.
//! Run: cargo run --example stress_test_comparison

use ionotrace::params::*;
use ionotrace::tracer::trace_ray;
use ionotrace::CoordinateSystem;
use std::fs;

#[derive(Debug)]
struct PhRecord {
    test_name: String,
    lat: f64,
    freq: f64,
    fo_f2: f64,
    hm_f2: f64,
    ym_f2: f64,
    elev: f64,
    ph_range: f64,
    ph_max_ht: f64,
    ph_returned: bool,
}

fn main() {
    let csv_path = std::env::var("STRESS_CSV")
        .unwrap_or_else(|_| "scripts/pharlap_stress_results.csv".to_string());
    let csv = fs::read_to_string(&csv_path).expect(&format!(
        "Cannot read {}. Set STRESS_CSV env var or run pharlap_stress_test.m first",
        csv_path
    ));

    let mut records: Vec<PhRecord> = Vec::new();
    for line in csv.lines().skip(1) {
        let f: Vec<&str> = line.split(',').collect();
        if f.len() < 11 {
            continue;
        }
        records.push(PhRecord {
            test_name: f[0].to_string(),
            lat: f[1].parse().unwrap(),
            freq: f[2].parse().unwrap(),
            fo_f2: f[3].parse().unwrap(),
            hm_f2: f[4].parse().unwrap(),
            ym_f2: f[5].parse().unwrap(),
            elev: f[6].parse().unwrap(),
            ph_range: f[7].parse().unwrap(),
            ph_max_ht: f[9].parse().unwrap(),
            ph_returned: f[10].trim() == "1",
        });
    }

    println!("Loaded {} PHaRLAP reference records\n", records.len());

    let mut current_test = String::new();
    let mut total_returned = 0usize;
    let mut total_agree_return = 0usize;
    let mut range_errors: Vec<f64> = Vec::new();
    let mut ht_errors: Vec<f64> = Vec::new();
    let mut worst_range_pct: f64 = 0.0;
    let mut worst_range_case = String::new();

    for rec in &records {
        if rec.test_name != current_test {
            current_test = rec.test_name.clone();
            println!(
                "=== {} (lat={}, freq={}, foF2={}, hmF2={}, ymF2={}) ===",
                rec.test_name, rec.lat, rec.freq, rec.fo_f2, rec.hm_f2, rec.ym_f2
            );
            println!(
                "{:>5} {:>10} {:>10} {:>7} {:>10} {:>10} {:>7}",
                "Elev", "PH_Range", "IT_Range", "Rng%", "PH_Ht", "IT_Ht", "Ret"
            );
        }

        // Set up matched ionotrace params (no-field, no-collisions, spherical 2D NRT like PHaRLAP)
        let mut params = ModelParams::default();
        params.fc = rec.fo_f2;
        params.hm = rec.hm_f2;
        params.sh = rec.ym_f2;
        params.rindex_model = RefractiveIndexModel::NoFieldNoCollisions;
        params.earth_model = EarthModel::Sphere; // match PHaRLAP's WGS84 as closely as possible

        let result = trace_ray(
            rec.freq,
            -1.0,
            rec.elev,
            0.0,
            rec.lat,
            2,
            CoordinateSystem::Spherical,
            1.0,
            2000,
            1e-4,
            2e-6,
            100.0,
            &params,
            1,
        );

        match result {
            Ok(r) => {
                let it_returned = r.returned_to_ground;
                let return_match = it_returned == rec.ph_returned;

                if rec.ph_returned {
                    total_returned += 1;
                    if return_match {
                        total_agree_return += 1;
                        let rng_pct = if rec.ph_range > 0.0 {
                            (r.ground_range_km - rec.ph_range) / rec.ph_range * 100.0
                        } else {
                            0.0
                        };
                        let ht_diff = r.max_height - rec.ph_max_ht;

                        range_errors.push(rng_pct.abs());
                        ht_errors.push(ht_diff.abs());

                        if rng_pct.abs() > worst_range_pct.abs() {
                            worst_range_pct = rng_pct;
                            worst_range_case = format!("{} elev={}", rec.test_name, rec.elev);
                        }

                        println!(
                            "{:>5.0} {:>10.1} {:>10.1} {:>+6.1}% {:>10.1} {:>10.1} {:>4}{:>3}",
                            rec.elev,
                            rec.ph_range,
                            r.ground_range_km,
                            rng_pct,
                            rec.ph_max_ht,
                            r.max_height,
                            if it_returned { "Y" } else { "N" },
                            if return_match { "=" } else { "!" }
                        );
                    } else {
                        println!(
                            "{:>5.0} {:>10.1} {:>10} {:>7} {:>10.1} {:>10.1} {:>4}{:>3}",
                            rec.elev,
                            rec.ph_range,
                            "escaped",
                            "-",
                            rec.ph_max_ht,
                            r.max_height,
                            if it_returned { "Y" } else { "N" },
                            "!"
                        );
                    }
                } else {
                    if !it_returned {
                        total_agree_return += 1;
                    }
                    total_returned += 0; // don't count escaped in range stats
                    println!(
                        "{:>5.0} {:>10} {:>10} {:>7} {:>10.1} {:>10.1} {:>4}{:>3}",
                        rec.elev,
                        "escaped",
                        "escaped",
                        "-",
                        rec.ph_max_ht,
                        r.max_height,
                        if it_returned { "Y" } else { "N" },
                        if return_match { "=" } else { "!" }
                    );
                }
            }
            Err(e) => {
                println!("{:>5.0}  ERROR: {}", rec.elev, e);
            }
        }
    }

    // Summary statistics
    println!("\n╔══════════════════════════════════════════════════════════════════════╗");
    println!(
        "║  STRESS TEST SUMMARY: {} scenarios, {} total rays     ║",
        12,
        records.len()
    );
    println!("╠══════════════════════════════════════════════════════════════════════╣");

    if !range_errors.is_empty() {
        let mean_rng = range_errors.iter().sum::<f64>() / range_errors.len() as f64;
        let max_rng = range_errors.iter().cloned().fold(0.0_f64, f64::max);
        let median_rng = {
            let mut s = range_errors.clone();
            s.sort_by(|a, b| a.partial_cmp(b).unwrap());
            s[s.len() / 2]
        };
        let mean_ht = ht_errors.iter().sum::<f64>() / ht_errors.len() as f64;
        let max_ht = ht_errors.iter().cloned().fold(0.0_f64, f64::max);

        println!(
            "║  Return agreement: {}/{} ({:.0}%)                 ║",
            total_agree_return,
            records.len(),
            total_agree_return as f64 / records.len() as f64 * 100.0
        );
        println!("║  Range error (returned rays):                                    ║");
        println!(
            "║    Mean:   {:.2}%                                                ║",
            mean_rng
        );
        println!(
            "║    Median: {:.2}%                                                ║",
            median_rng
        );
        println!(
            "║    Max:    {:.2}% ({})           ║",
            max_rng, worst_range_case
        );
        println!("║  Height error:                                                   ║");
        println!(
            "║    Mean:   {:.1} km                                              ║",
            mean_ht
        );
        println!(
            "║    Max:    {:.1} km                                              ║",
            max_ht
        );
    }
    println!("╚══════════════════════════════════════════════════════════════════════╝");
}
