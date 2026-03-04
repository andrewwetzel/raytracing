//! Export utilities for formatting trace results into standard formats
//! like CSV and JSON.

use crate::fan::{FanRayPoint, FanTraceResult};
use crate::tracer::TraceResult;
use serde::Serialize;
use std::error::Error;

/// Formats a TraceResult into a CSV string.
///
/// The resulting CSV contains all points along the ray path.
pub fn export_trace_csv(result: &TraceResult) -> Result<String, Box<dyn Error>> {
    let mut wtr = csv::Writer::from_writer(vec![]);
    for point in &result.points {
        wtr.serialize(point)?;
    }
    let data = String::from_utf8(wtr.into_inner()?)?;
    Ok(data)
}

/// Formats a FanTraceResult into a CSV string.
///
/// Since a fan trace contains multiple rays, each point is prefixed with
/// the ray index and its launch elevation to distinguish them.
pub fn export_fan_trace_csv(result: &FanTraceResult) -> Result<String, Box<dyn Error>> {
    #[derive(Serialize)]
    struct FanExportRow<'a> {
        /// The index of the ray in the fan sweep.
        ray_index: usize,
        /// The initial launch elevation of this ray.
        ray_elev: f64,
        /// The internal point details.
        #[serde(flatten)]
        point: &'a FanRayPoint,
    }

    let mut wtr = csv::Writer::from_writer(vec![]);
    for (i, ray) in result.rays.iter().enumerate() {
        for pt in &ray.pts {
            let row = FanExportRow {
                ray_index: i,
                ray_elev: ray.elev,
                point: pt,
            };
            wtr.serialize(&row)?;
        }
    }
    let data = String::from_utf8(wtr.into_inner()?)?;
    Ok(data)
}

/// Formats any serializable result (like TraceResult or FanTraceResult) into a pretty JSON string.
pub fn export_json<T: Serialize>(result: &T) -> Result<String, Box<dyn Error>> {
    let json = serde_json::to_string_pretty(result)?;
    Ok(json)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::tracer::{TraceConfig, TracePoint};

    #[test]
    fn test_export_trace_csv() {
        let mut result = TraceResult {
            points: vec![],
            max_height: 100.0,
            ground_range_km: 50.0,
            returned_to_ground: true,
            n_steps: 1,
        };
        result.points.push(TracePoint {
            step: 1,
            t: 0.1,
            height_km: 50.0,
            lat_deg: 40.0,
            lon_deg: -80.0,
            ground_range_km: 10.0,
            group_path: 15.0,
            phase_path: 14.0,
            absorption: 0.5,
        });

        let csv_str = export_trace_csv(&result).unwrap();
        assert!(csv_str.contains("step"));
        assert!(csv_str.contains("height_km"));
        assert!(
            csv_str.contains("1,0.1,50.0,40.0,-80.0,10.0,15.0,14.0,0.5")
                || csv_str.contains("1,0.1,50,40,-80,10,15,14,0.5"),
            "Actual CSV: {}",
            csv_str
        );
    }

    #[test]
    fn test_export_json_valid() {
        let config = TraceConfig::new(10.0, 45.0);
        let json = export_json(&config).unwrap();
        assert!(json.contains("\"freq_mhz\": 10.0"));
        assert!(json.contains("\"elevation_deg\": 45.0"));
    }
}
