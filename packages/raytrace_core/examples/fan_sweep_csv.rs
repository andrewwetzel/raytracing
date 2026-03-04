use ionotrace::params::{ElectronDensityModel, MagneticFieldModel, RayMode};
use ionotrace::{export_fan_trace_csv, fan_trace, FanTraceConfig, ModelParams};
use std::fs::File;
use std::io::Write;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Enable tracing output to standard out
    tracing_subscriber::fmt::init();

    // 1. Configure the physical environment using the ergonomic Builder pattern
    let params = ModelParams::builder()
        .ed_model(ElectronDensityModel::DualChapman)
        .mag_model(MagneticFieldModel::Dipole)
        .fc(12.0)
        .hm(300.0)
        .build()
        .unwrap();

    // 2. Configure a sweep of elevation angles
    let config = FanTraceConfig {
        freq_mhz: 15.0,
        ray_mode: RayMode::Ordinary.to_sign(),
        elev_min: 5.0,
        elev_max: 85.0,
        elev_step: 1.0, // 81 distinct rays
        azimuth_deg: 45.0,
        tx_lat_deg: 40.0,
        step_size: 5.0,
        max_steps: 1000,
        max_hops: 1,
        params,
    };

    println!("Starting parallel fan trace calculation...");

    // 3. Execute the trace (Parallelized via Rayon automatically on native builds!)
    let result = fan_trace(&config)?;

    println!("Computed {} rays.", result.n_rays);

    // 4. Export the entire sweep to a CSV
    println!("Exporting to sweep_results.csv...");
    let csv_data = export_fan_trace_csv(&result)?;

    let mut file = File::create("sweep_results.csv")?;
    file.write_all(csv_data.as_bytes())?;

    println!("Done!");
    Ok(())
}
