//! Minimal example: trace a single ray and print the results.

use ionotrace::TraceConfig;

fn main() {
    // Trace a 10 MHz X-mode ray at 20° elevation from 40°N latitude
    let result = TraceConfig::new(10.0, 20.0).trace().unwrap();

    println!("── Single Ray Trace ──");
    println!("  Frequency:      10 MHz");
    println!("  Elevation:      20°");
    println!("  Max height:     {:.1} km", result.max_height);
    println!("  Ground range:   {:.1} km", result.ground_range_km);
    println!("  Returned:       {}", result.returned_to_ground);
    println!("  Steps taken:    {}", result.n_steps);
    println!("  Path points:    {}", result.points.len());

    if let Some(last) = result.points.last() {
        println!("  Final lat:      {:.2}°", last.lat_deg);
        println!("  Final lon:      {:.2}°", last.lon_deg);
        println!("  Absorption:     {:.4} dB", last.absorption);
    }
}
