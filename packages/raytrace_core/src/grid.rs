//! 3D grid-interpolated ionosphere model.
//!
//! Enables ingestion of empirical ionosphere data (IRI-2020, NeQuick, SAMI3, etc.)
//! by interpolating plasma frequency on a regular (altitude × latitude × longitude)
//! grid and computing spatial gradients via finite differences.
//!
//! # Grid Format
//!
//! The grid stores plasma frequency `fp` (MHz) on a regular 3D mesh:
//! - **Altitudes** in km above the surface
//! - **Latitudes** in degrees (geodetic, −90 to +90)
//! - **Longitudes** in degrees (−180 to +180 or 0 to 360)
//!
//! # CSV Format
//!
//! One row per grid point, four columns (header required):
//! ```text
//! alt_km,lat_deg,lon_deg,fp_mhz
//! 100.0,-90.0,-180.0,2.5
//! 100.0,-90.0,-170.0,2.6
//! ...
//! ```
//!
//! # Example
//!
//! ```no_run
//! use ionotrace::grid::IonosphereGrid;
//! use ionotrace::{TraceConfig, ModelParams};
//! use ionotrace::params::ElectronDensityModel;
//! use std::sync::Arc;
//!
//! let grid = IonosphereGrid::from_csv_file("iri_2020_grid.csv").unwrap();
//!
//! let mut config = TraceConfig::new(10.0, 20.0);
//! config.params.ed_model = ElectronDensityModel::GridInterp;
//! config.params.ed_grid = Some(Arc::new(grid));
//! let result = config.trace().unwrap();
//! ```

use std::f64::consts::PI;
use std::io::Read;

use crate::models::electron_density::ElectronDensityResult;
use crate::params::*;
use crate::wgs84;

// ============================================================
// Finite-difference step sizes
// ============================================================

/// Altitude step for ∂X/∂r (km).
const DR: f64 = 0.5;
/// Colatitude step for ∂X/∂θ (radians, ≈ 0.06° ≈ 6 km).
const DTH: f64 = 0.001;
/// Longitude step for ∂X/∂φ (radians).
const DPH: f64 = 0.001;

// ============================================================
// IonosphereGrid
// ============================================================

/// A 3D regular grid of plasma frequency values for interpolation.
///
/// Thread-safe: wrap in `Arc` for parallel fan traces.
#[derive(Debug, Clone)]
pub struct IonosphereGrid {
    /// Altitude nodes in km (ascending).
    pub altitudes: Vec<f64>,
    /// Latitude nodes in degrees (ascending, geodetic).
    pub latitudes: Vec<f64>,
    /// Longitude nodes in degrees (ascending).
    pub longitudes: Vec<f64>,
    /// Plasma frequency fp in MHz, stored row-major as
    /// `data[alt_idx * nlat * nlon + lat_idx * nlon + lon_idx]`.
    pub data: Vec<f64>,
}

impl IonosphereGrid {
    /// Create a new grid from axis vectors and a flat data array.
    ///
    /// # Panics
    /// Panics if `data.len() != altitudes.len() * latitudes.len() * longitudes.len()`.
    pub fn new(
        altitudes: Vec<f64>,
        latitudes: Vec<f64>,
        longitudes: Vec<f64>,
        data: Vec<f64>,
    ) -> Self {
        let expected = altitudes.len() * latitudes.len() * longitudes.len();
        assert_eq!(
            data.len(),
            expected,
            "Grid data length {} != expected {} ({}×{}×{})",
            data.len(),
            expected,
            altitudes.len(),
            latitudes.len(),
            longitudes.len()
        );
        Self {
            altitudes,
            latitudes,
            longitudes,
            data,
        }
    }

    /// Number of altitude nodes.
    #[inline]
    pub fn nalt(&self) -> usize {
        self.altitudes.len()
    }

    /// Number of latitude nodes.
    #[inline]
    pub fn nlat(&self) -> usize {
        self.latitudes.len()
    }

    /// Number of longitude nodes.
    #[inline]
    pub fn nlon(&self) -> usize {
        self.longitudes.len()
    }

    /// Get fp at a grid index.
    #[inline]
    fn get(&self, ai: usize, li: usize, oi: usize) -> f64 {
        self.data[ai * self.nlat() * self.nlon() + li * self.nlon() + oi]
    }

    /// Trilinear interpolation of plasma frequency fp (MHz).
    ///
    /// Points outside the grid are clamped to the nearest boundary value.
    pub fn interpolate(&self, alt_km: f64, lat_deg: f64, lon_deg: f64) -> f64 {
        let (ai, at) = Self::find_interval(&self.altitudes, alt_km);
        let (li, lt) = Self::find_interval(&self.latitudes, lat_deg);
        let (oi, ot) = Self::find_interval(&self.longitudes, lon_deg);

        // 8 corner values
        let c000 = self.get(ai, li, oi);
        let c100 = self.get(ai + 1, li, oi);
        let c010 = self.get(ai, li + 1, oi);
        let c110 = self.get(ai + 1, li + 1, oi);
        let c001 = self.get(ai, li, oi + 1);
        let c101 = self.get(ai + 1, li, oi + 1);
        let c011 = self.get(ai, li + 1, oi + 1);
        let c111 = self.get(ai + 1, li + 1, oi + 1);

        // Trilinear
        let c00 = c000 * (1.0 - at) + c100 * at;
        let c10 = c010 * (1.0 - at) + c110 * at;
        let c01 = c001 * (1.0 - at) + c101 * at;
        let c11 = c011 * (1.0 - at) + c111 * at;

        let c0 = c00 * (1.0 - lt) + c10 * lt;
        let c1 = c01 * (1.0 - lt) + c11 * lt;

        c0 * (1.0 - ot) + c1 * ot
    }

    /// Find the interval index and fractional position for a value in a sorted axis.
    /// Returns `(index, t)` where `index` is clamped to `[0, len-2]` and `t` ∈ [0, 1].
    fn find_interval(axis: &[f64], value: f64) -> (usize, f64) {
        if axis.len() < 2 {
            return (0, 0.0);
        }
        if value <= axis[0] {
            return (0, 0.0);
        }
        if value >= axis[axis.len() - 1] {
            return (axis.len() - 2, 1.0);
        }
        // Binary search for the interval
        let mut lo = 0;
        let mut hi = axis.len() - 1;
        while hi - lo > 1 {
            let mid = (lo + hi) / 2;
            if axis[mid] <= value {
                lo = mid;
            } else {
                hi = mid;
            }
        }
        let t = (value - axis[lo]) / (axis[hi] - axis[lo]);
        (lo, t)
    }

    // ============================================================
    // I/O
    // ============================================================

    /// Load a grid from a CSV reader.
    ///
    /// Expected columns: `alt_km`, `lat_deg`, `lon_deg`, `fp_mhz`.
    /// Order of rows does not matter — the grid axes are inferred from unique sorted values.
    pub fn from_csv<R: Read>(reader: R) -> Result<Self, String> {
        let mut rdr = csv::ReaderBuilder::new()
            .has_headers(true)
            .flexible(true)
            .from_reader(reader);

        let mut points: Vec<(f64, f64, f64, f64)> = Vec::new();

        for result in rdr.records() {
            let record = result.map_err(|e| format!("CSV parse error: {e}"))?;
            if record.len() < 4 {
                return Err(format!("Expected 4 columns, got {}", record.len()));
            }
            let alt: f64 = record[0]
                .trim()
                .parse()
                .map_err(|e| format!("Bad alt_km: {e}"))?;
            let lat: f64 = record[1]
                .trim()
                .parse()
                .map_err(|e| format!("Bad lat_deg: {e}"))?;
            let lon: f64 = record[2]
                .trim()
                .parse()
                .map_err(|e| format!("Bad lon_deg: {e}"))?;
            let fp: f64 = record[3]
                .trim()
                .parse()
                .map_err(|e| format!("Bad fp_mhz: {e}"))?;
            points.push((alt, lat, lon, fp));
        }

        if points.is_empty() {
            return Err("CSV contains no data rows".to_string());
        }

        // Extract unique sorted axes
        let mut alts: Vec<f64> = points.iter().map(|p| p.0).collect();
        let mut lats: Vec<f64> = points.iter().map(|p| p.1).collect();
        let mut lons: Vec<f64> = points.iter().map(|p| p.2).collect();

        alts.sort_by(|a, b| a.partial_cmp(b).unwrap());
        alts.dedup_by(|a, b| (*a - *b).abs() < 1e-10);
        lats.sort_by(|a, b| a.partial_cmp(b).unwrap());
        lats.dedup_by(|a, b| (*a - *b).abs() < 1e-10);
        lons.sort_by(|a, b| a.partial_cmp(b).unwrap());
        lons.dedup_by(|a, b| (*a - *b).abs() < 1e-10);

        let expected = alts.len() * lats.len() * lons.len();
        if points.len() != expected {
            return Err(format!(
                "Grid incomplete: got {} points but axes suggest {}×{}×{} = {}",
                points.len(),
                alts.len(),
                lats.len(),
                lons.len(),
                expected
            ));
        }

        // Fill data array
        let mut data = vec![0.0f64; expected];
        for (alt, lat, lon, fp) in &points {
            let ai = alts
                .binary_search_by(|v| v.partial_cmp(alt).unwrap())
                .map_err(|_| format!("Alt {alt} not on axis"))?;
            let li = lats
                .binary_search_by(|v| v.partial_cmp(lat).unwrap())
                .map_err(|_| format!("Lat {lat} not on axis"))?;
            let oi = lons
                .binary_search_by(|v| v.partial_cmp(lon).unwrap())
                .map_err(|_| format!("Lon {lon} not on axis"))?;
            data[ai * lats.len() * lons.len() + li * lons.len() + oi] = *fp;
        }

        Ok(Self::new(alts, lats, lons, data))
    }

    /// Load a grid from a CSV file on disk.
    pub fn from_csv_file(path: &str) -> Result<Self, String> {
        let file = std::fs::File::open(path).map_err(|e| format!("Cannot open {path}: {e}"))?;
        Self::from_csv(std::io::BufReader::new(file))
    }

    /// Load a grid from a JSON reader.
    ///
    /// Expected format:
    /// ```json
    /// {
    ///   "altitudes": [100.0, 150.0, ...],
    ///   "latitudes": [-90.0, -80.0, ...],
    ///   "longitudes": [-180.0, -170.0, ...],
    ///   "fp": [2.5, 2.6, ...]
    /// }
    /// ```
    /// where `fp` is row-major `[alt][lat][lon]`.
    pub fn from_json<R: Read>(reader: R) -> Result<Self, String> {
        #[derive(serde::Deserialize)]
        struct GridJson {
            altitudes: Vec<f64>,
            latitudes: Vec<f64>,
            longitudes: Vec<f64>,
            fp: Vec<f64>,
        }
        let g: GridJson =
            serde_json::from_reader(reader).map_err(|e| format!("JSON parse error: {e}"))?;
        if g.altitudes.is_empty() || g.latitudes.is_empty() || g.longitudes.is_empty() {
            return Err("Empty axis in JSON grid".to_string());
        }
        Ok(Self::new(g.altitudes, g.latitudes, g.longitudes, g.fp))
    }
}

// ============================================================
// Electron Density from Grid
// ============================================================

/// Spherical `(r, θ, φ)` → grid `(alt_km, lat_deg, lon_deg)`.
fn spherical_to_grid(r: f64, theta: f64, phi: f64, p: &ModelParams) -> (f64, f64, f64) {
    let alt = match p.earth_model {
        EarthModel::Wgs84 => wgs84::geodetic_altitude(r, theta),
        EarthModel::Sphere => r - p.earth_r,
    };
    let lat_deg = match p.earth_model {
        EarthModel::Wgs84 => {
            let (lat_rad, _) = wgs84::geocentric_to_geodetic(r, theta);
            lat_rad * 180.0 / PI
        }
        EarthModel::Sphere => (PI / 2.0 - theta) * 180.0 / PI,
    };
    let lon_deg = phi * 180.0 / PI;
    (alt, lat_deg, lon_deg)
}

/// Compute X = (fp/f)² from grid interpolation at a single point.
fn x_from_grid(
    grid: &IonosphereGrid,
    alt_km: f64,
    lat_deg: f64,
    lon_deg: f64,
    freq_mhz: f64,
) -> f64 {
    let fp = grid.interpolate(alt_km, lat_deg, lon_deg);
    let ratio = fp / freq_mhz;
    ratio * ratio
}

/// Compute normalized electron density X and spatial derivatives from a grid.
///
/// Uses central finite differences for ∂X/∂r, ∂X/∂θ, ∂X/∂φ.
pub fn grid_ed(
    r: f64,
    theta: f64,
    phi: f64,
    freq_mhz: f64,
    p: &ModelParams,
    grid: &IonosphereGrid,
) -> ElectronDensityResult {
    let (alt, lat, lon) = spherical_to_grid(r, theta, phi, p);
    let x = x_from_grid(grid, alt, lat, lon, freq_mhz);

    // ∂X/∂r via central difference in r (radial = altitude direction)
    let (alt_p, lat_p, lon_p) = spherical_to_grid(r + DR, theta, phi, p);
    let (alt_m, lat_m, lon_m) = spherical_to_grid(r - DR, theta, phi, p);
    let x_rp = x_from_grid(grid, alt_p, lat_p, lon_p, freq_mhz);
    let x_rm = x_from_grid(grid, alt_m, lat_m, lon_m, freq_mhz);
    let dxdr = (x_rp - x_rm) / (2.0 * DR);

    // ∂X/∂θ via central difference in theta
    let (alt_tp, lat_tp, lon_tp) = spherical_to_grid(r, theta + DTH, phi, p);
    let (alt_tm, lat_tm, lon_tm) = spherical_to_grid(r, theta - DTH, phi, p);
    let x_tp = x_from_grid(grid, alt_tp, lat_tp, lon_tp, freq_mhz);
    let x_tm = x_from_grid(grid, alt_tm, lat_tm, lon_tm, freq_mhz);
    let dxdth = (x_tp - x_tm) / (2.0 * DTH);

    // ∂X/∂φ via central difference in phi
    let (alt_pp, lat_pp, lon_pp) = spherical_to_grid(r, theta, phi + DPH, p);
    let (alt_pm, lat_pm, lon_pm) = spherical_to_grid(r, theta, phi - DPH, p);
    let x_pp = x_from_grid(grid, alt_pp, lat_pp, lon_pp, freq_mhz);
    let x_pm = x_from_grid(grid, alt_pm, lat_pm, lon_pm, freq_mhz);
    let dxdph = (x_pp - x_pm) / (2.0 * DPH);

    ElectronDensityResult {
        x,
        dxdr,
        dxdth,
        dxdph,
        dxdt: 0.0,
    }
}

// ============================================================
// Tests
// ============================================================

#[cfg(test)]
mod tests {
    use super::*;

    /// Build a small test grid from a known analytical function:
    /// fp(alt, lat, lon) = 5.0 * exp(-(alt - 300)² / (2 * 100²))
    /// (Chapman-like profile, lat/lon independent for simplicity)
    fn test_grid() -> IonosphereGrid {
        let alts: Vec<f64> = (0..=10).map(|i| 100.0 + i as f64 * 50.0).collect(); // 100..600 km
        let lats: Vec<f64> = (-4..=4).map(|i| i as f64 * 10.0).collect(); // -40..40 deg
        let lons: Vec<f64> = (-4..=4).map(|i| i as f64 * 10.0).collect(); // -40..40 deg

        let mut data = Vec::with_capacity(alts.len() * lats.len() * lons.len());
        for &alt in &alts {
            for &_lat in &lats {
                for &_lon in &lons {
                    let z = (alt - 300.0) / 100.0;
                    let fp = 5.0 * (-0.5 * z * z).exp();
                    data.push(fp);
                }
            }
        }

        IonosphereGrid::new(alts, lats, lons, data)
    }

    #[test]
    fn test_trilinear_exact_node() {
        let grid = test_grid();
        // At an exact grid node: alt=300, lat=0, lon=0 → fp = 5.0
        let fp = grid.interpolate(300.0, 0.0, 0.0);
        assert!(
            (fp - 5.0).abs() < 1e-10,
            "At peak (300 km), fp should be 5.0, got {fp}"
        );
    }

    #[test]
    fn test_trilinear_midpoint() {
        let grid = test_grid();
        // Midpoint between two altitude nodes (325 km = midpoint of 300..350)
        let fp_300 = grid.interpolate(300.0, 0.0, 0.0);
        let fp_350 = grid.interpolate(350.0, 0.0, 0.0);
        let fp_mid = grid.interpolate(325.0, 0.0, 0.0);
        let expected_mid = (fp_300 + fp_350) / 2.0;
        assert!(
            (fp_mid - expected_mid).abs() < 1e-10,
            "Midpoint should be average of nodes: got {fp_mid}, expected {expected_mid}"
        );
    }

    #[test]
    fn test_trilinear_clamping() {
        let grid = test_grid();
        // Below the grid (alt=50 km) — should clamp to alt=100
        let fp_below = grid.interpolate(50.0, 0.0, 0.0);
        let fp_bottom = grid.interpolate(100.0, 0.0, 0.0);
        assert!(
            (fp_below - fp_bottom).abs() < 1e-10,
            "Below-grid should clamp to bottom: got {fp_below}, expected {fp_bottom}"
        );
        // Above the grid (alt=700 km) — should clamp to alt=600
        let fp_above = grid.interpolate(700.0, 0.0, 0.0);
        let fp_top = grid.interpolate(600.0, 0.0, 0.0);
        assert!(
            (fp_above - fp_top).abs() < 1e-10,
            "Above-grid should clamp to top: got {fp_above}, expected {fp_top}"
        );
    }

    #[test]
    fn test_gradient_vs_analytical() {
        let grid = test_grid();
        let mut p = ModelParams::default();
        p.earth_model = EarthModel::Sphere; // Grid tests are earth-model-independent
        let freq = 10.0;

        // At 300 km, the analytical fp = 5.0*exp(-z²/2), so X = (5/10)² = 0.25
        // ∂fp/∂alt = 5.0 * exp(-z²/2) * (-z/100) = 0 at z=0
        // ∂²fp/∂alt² < 0 → gradient should be near zero at the peak
        let r = p.earth_r + 300.0;
        let theta = PI / 2.0 - 40.0_f64.to_radians(); // 40°N
        let phi = 0.0;

        let ed = grid_ed(r, theta, phi, freq, &p, &grid);

        // X at peak should be (5.0/10.0)² = 0.25
        assert!(
            (ed.x - 0.25).abs() < 0.01,
            "X at peak should be ~0.25, got {}",
            ed.x
        );

        // ∂X/∂r at peak should be near 0 (peak of Gaussian)
        assert!(
            ed.dxdr.abs() < 0.01,
            "dX/dr at peak should be ~0, got {}",
            ed.dxdr
        );

        // Since this grid is lat/lon-independent, ∂X/∂θ and ∂X/∂φ should be ~0
        assert!(
            ed.dxdth.abs() < 0.01,
            "dX/dth should be ~0 for lat-independent grid, got {}",
            ed.dxdth
        );
        assert!(
            ed.dxdph.abs() < 0.01,
            "dX/dph should be ~0 for lon-independent grid, got {}",
            ed.dxdph
        );
    }

    #[test]
    fn test_gradient_off_peak() {
        let grid = test_grid();
        let mut p = ModelParams::default();
        p.earth_model = EarthModel::Sphere;
        let freq = 10.0;

        // At 200 km (below peak), ∂X/∂r should be positive (X increases toward peak)
        let r = p.earth_r + 200.0;
        let theta = PI / 2.0;
        let phi = 0.0;

        let ed = grid_ed(r, theta, phi, freq, &p, &grid);
        assert!(
            ed.dxdr > 0.0,
            "dX/dr below peak should be positive, got {}",
            ed.dxdr
        );

        // At 400 km (above peak), ∂X/∂r should be negative
        let r = p.earth_r + 400.0;
        let ed = grid_ed(r, theta, phi, freq, &p, &grid);
        assert!(
            ed.dxdr < 0.0,
            "dX/dr above peak should be negative, got {}",
            ed.dxdr
        );
    }

    #[test]
    fn test_csv_roundtrip() {
        let grid = test_grid();

        // Write to CSV in memory
        let mut csv_buf = Vec::new();
        csv_buf.extend_from_slice(b"alt_km,lat_deg,lon_deg,fp_mhz\n");
        for (ai, &alt) in grid.altitudes.iter().enumerate() {
            for (li, &lat) in grid.latitudes.iter().enumerate() {
                for (oi, &lon) in grid.longitudes.iter().enumerate() {
                    let fp = grid.get(ai, li, oi);
                    csv_buf.extend_from_slice(format!("{alt},{lat},{lon},{fp}\n").as_bytes());
                }
            }
        }

        // Read back
        let grid2 = IonosphereGrid::from_csv(csv_buf.as_slice()).unwrap();
        assert_eq!(grid2.nalt(), grid.nalt());
        assert_eq!(grid2.nlat(), grid.nlat());
        assert_eq!(grid2.nlon(), grid.nlon());

        // Spot-check
        let fp1 = grid.interpolate(300.0, 0.0, 0.0);
        let fp2 = grid2.interpolate(300.0, 0.0, 0.0);
        assert!((fp1 - fp2).abs() < 1e-6, "CSV roundtrip: {fp1} != {fp2}");
    }

    #[test]
    fn test_json_roundtrip() {
        let grid = test_grid();

        // Build JSON
        let json = serde_json::json!({
            "altitudes": grid.altitudes,
            "latitudes": grid.latitudes,
            "longitudes": grid.longitudes,
            "fp": grid.data,
        });
        let json_str = serde_json::to_string(&json).unwrap();

        let grid2 = IonosphereGrid::from_json(json_str.as_bytes()).unwrap();
        assert_eq!(grid2.nalt(), grid.nalt());
        assert_eq!(grid2.data.len(), grid.data.len());

        let fp1 = grid.interpolate(250.0, 10.0, 5.0);
        let fp2 = grid2.interpolate(250.0, 10.0, 5.0);
        assert!((fp1 - fp2).abs() < 1e-10, "JSON roundtrip: {fp1} != {fp2}");
    }

    #[test]
    fn test_grid_peak_profile_shape() {
        let grid = test_grid();
        // fp should be maximum at 300 km and decrease both ways
        let fp_200 = grid.interpolate(200.0, 0.0, 0.0);
        let fp_300 = grid.interpolate(300.0, 0.0, 0.0);
        let fp_400 = grid.interpolate(400.0, 0.0, 0.0);
        assert!(
            fp_300 > fp_200 && fp_300 > fp_400,
            "Peak at 300 km: fp_200={fp_200}, fp_300={fp_300}, fp_400={fp_400}"
        );
    }
}
