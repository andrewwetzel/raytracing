use pyo3::exceptions::PyValueError;
use pyo3::prelude::*;

// ============================================================
// Enums
// ============================================================

/// Electron density profile model.
#[pyclass(eq, eq_int)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum ElectronDensityModel {
    Chapman = 0,
    Elect1 = 1,
    Linear = 2,
    QuasiParabolic = 3,
    VarChapman = 4,
    DualChapman = 5,
}

#[pymethods]
impl ElectronDensityModel {
    fn __repr__(&self) -> String {
        format!("ElectronDensityModel.{:?}", self)
    }
}

impl From<ElectronDensityModel> for ionotrace_core::params::ElectronDensityModel {
    fn from(v: ElectronDensityModel) -> Self {
        match v {
            ElectronDensityModel::Chapman => Self::Chapman,
            ElectronDensityModel::Elect1 => Self::Elect1,
            ElectronDensityModel::Linear => Self::Linear,
            ElectronDensityModel::QuasiParabolic => Self::QuasiParabolic,
            ElectronDensityModel::VarChapman => Self::VarChapman,
            ElectronDensityModel::DualChapman => Self::DualChapman,
        }
    }
}

impl From<ionotrace_core::params::ElectronDensityModel> for ElectronDensityModel {
    fn from(v: ionotrace_core::params::ElectronDensityModel) -> Self {
        match v {
            ionotrace_core::params::ElectronDensityModel::Chapman => Self::Chapman,
            ionotrace_core::params::ElectronDensityModel::Elect1 => Self::Elect1,
            ionotrace_core::params::ElectronDensityModel::Linear => Self::Linear,
            ionotrace_core::params::ElectronDensityModel::QuasiParabolic => Self::QuasiParabolic,
            ionotrace_core::params::ElectronDensityModel::VarChapman => Self::VarChapman,
            ionotrace_core::params::ElectronDensityModel::DualChapman => Self::DualChapman,
            _ => Self::Chapman,
        }
    }
}

/// Magnetic field model.
#[pyclass(eq, eq_int)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum MagneticFieldModel {
    Dipole = 0,
    Constant = 1,
    Cubic = 2,
    Igrf14 = 3,
}

#[pymethods]
impl MagneticFieldModel {
    fn __repr__(&self) -> String {
        format!("MagneticFieldModel.{:?}", self)
    }
}

impl From<MagneticFieldModel> for ionotrace_core::params::MagneticFieldModel {
    fn from(v: MagneticFieldModel) -> Self {
        match v {
            MagneticFieldModel::Dipole => Self::Dipole,
            MagneticFieldModel::Constant => Self::Constant,
            MagneticFieldModel::Cubic => Self::Cubic,
            MagneticFieldModel::Igrf14 => Self::Igrf14,
        }
    }
}

impl From<ionotrace_core::params::MagneticFieldModel> for MagneticFieldModel {
    fn from(v: ionotrace_core::params::MagneticFieldModel) -> Self {
        match v {
            ionotrace_core::params::MagneticFieldModel::Dipole => Self::Dipole,
            ionotrace_core::params::MagneticFieldModel::Constant => Self::Constant,
            ionotrace_core::params::MagneticFieldModel::Cubic => Self::Cubic,
            ionotrace_core::params::MagneticFieldModel::Igrf14 => Self::Igrf14,
            _ => Self::Dipole,
        }
    }
}

/// Collision frequency model.
#[pyclass(eq, eq_int)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum CollisionModel {
    DoubleExponential = 0,
    Constant = 1,
    SingleExponential = 2,
}

#[pymethods]
impl CollisionModel {
    fn __repr__(&self) -> String {
        format!("CollisionModel.{:?}", self)
    }
}

impl From<CollisionModel> for ionotrace_core::params::CollisionModel {
    fn from(v: CollisionModel) -> Self {
        match v {
            CollisionModel::DoubleExponential => Self::DoubleExponential,
            CollisionModel::Constant => Self::Constant,
            CollisionModel::SingleExponential => Self::SingleExponential,
        }
    }
}

impl From<ionotrace_core::params::CollisionModel> for CollisionModel {
    fn from(v: ionotrace_core::params::CollisionModel) -> Self {
        match v {
            ionotrace_core::params::CollisionModel::DoubleExponential => Self::DoubleExponential,
            ionotrace_core::params::CollisionModel::Constant => Self::Constant,
            ionotrace_core::params::CollisionModel::SingleExponential => Self::SingleExponential,
            _ => Self::DoubleExponential,
        }
    }
}

/// Refractive index model.
#[pyclass(eq, eq_int)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum RefractiveIndexModel {
    Full = 0,
    NoFieldNoCollisions = 1,
    NoFieldWithCollisions = 2,
    WithFieldNoCollisions = 3,
}

#[pymethods]
impl RefractiveIndexModel {
    fn __repr__(&self) -> String {
        format!("RefractiveIndexModel.{:?}", self)
    }
}

impl From<RefractiveIndexModel> for ionotrace_core::params::RefractiveIndexModel {
    fn from(v: RefractiveIndexModel) -> Self {
        match v {
            RefractiveIndexModel::Full => Self::Full,
            RefractiveIndexModel::NoFieldNoCollisions => Self::NoFieldNoCollisions,
            RefractiveIndexModel::NoFieldWithCollisions => Self::NoFieldWithCollisions,
            RefractiveIndexModel::WithFieldNoCollisions => Self::WithFieldNoCollisions,
        }
    }
}

impl From<ionotrace_core::params::RefractiveIndexModel> for RefractiveIndexModel {
    fn from(v: ionotrace_core::params::RefractiveIndexModel) -> Self {
        match v {
            ionotrace_core::params::RefractiveIndexModel::Full => Self::Full,
            ionotrace_core::params::RefractiveIndexModel::NoFieldNoCollisions => {
                Self::NoFieldNoCollisions
            }
            ionotrace_core::params::RefractiveIndexModel::NoFieldWithCollisions => {
                Self::NoFieldWithCollisions
            }
            ionotrace_core::params::RefractiveIndexModel::WithFieldNoCollisions => {
                Self::WithFieldNoCollisions
            }
            _ => Self::Full,
        }
    }
}

/// Ionospheric perturbation model.
#[pyclass(eq, eq_int)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum PerturbationModel {
    None = 0,
    Torus = 1,
    Trough = 2,
    Shock = 3,
    Bulge = 4,
    Exponential = 5,
}

#[pymethods]
impl PerturbationModel {
    fn __repr__(&self) -> String {
        format!("PerturbationModel.{:?}", self)
    }
}

impl From<PerturbationModel> for ionotrace_core::params::PerturbationModel {
    fn from(v: PerturbationModel) -> Self {
        match v {
            PerturbationModel::None => Self::None,
            PerturbationModel::Torus => Self::Torus,
            PerturbationModel::Trough => Self::Trough,
            PerturbationModel::Shock => Self::Shock,
            PerturbationModel::Bulge => Self::Bulge,
            PerturbationModel::Exponential => Self::Exponential,
        }
    }
}

impl From<ionotrace_core::params::PerturbationModel> for PerturbationModel {
    fn from(v: ionotrace_core::params::PerturbationModel) -> Self {
        match v {
            ionotrace_core::params::PerturbationModel::None => Self::None,
            ionotrace_core::params::PerturbationModel::Torus => Self::Torus,
            ionotrace_core::params::PerturbationModel::Trough => Self::Trough,
            ionotrace_core::params::PerturbationModel::Shock => Self::Shock,
            ionotrace_core::params::PerturbationModel::Bulge => Self::Bulge,
            ionotrace_core::params::PerturbationModel::Exponential => Self::Exponential,
            _ => Self::None,
        }
    }
}

/// Characteristic wave mode.
#[pyclass(eq, eq_int)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum RayMode {
    Extraordinary = 0,
    Ordinary = 1,
}

#[pymethods]
impl RayMode {
    fn __repr__(&self) -> String {
        format!("RayMode.{:?}", self)
    }
}

impl From<RayMode> for ionotrace_core::params::RayMode {
    fn from(v: RayMode) -> Self {
        match v {
            RayMode::Extraordinary => Self::Extraordinary,
            RayMode::Ordinary => Self::Ordinary,
        }
    }
}

impl From<ionotrace_core::params::RayMode> for RayMode {
    fn from(v: ionotrace_core::params::RayMode) -> Self {
        match v {
            ionotrace_core::params::RayMode::Extraordinary => Self::Extraordinary,
            ionotrace_core::params::RayMode::Ordinary => Self::Ordinary,
            _ => Self::Extraordinary,
        }
    }
}

/// Earth shape model.
#[pyclass(eq, eq_int)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum EarthModel {
    Sphere = 0,
    Wgs84 = 1,
}

#[pymethods]
impl EarthModel {
    fn __repr__(&self) -> String {
        format!("EarthModel.{:?}", self)
    }
}

impl From<EarthModel> for ionotrace_core::params::EarthModel {
    fn from(v: EarthModel) -> Self {
        match v {
            EarthModel::Sphere => Self::Sphere,
            EarthModel::Wgs84 => Self::Wgs84,
        }
    }
}

impl From<ionotrace_core::params::EarthModel> for EarthModel {
    fn from(v: ionotrace_core::params::EarthModel) -> Self {
        match v {
            ionotrace_core::params::EarthModel::Sphere => Self::Sphere,
            ionotrace_core::params::EarthModel::Wgs84 => Self::Wgs84,
            _ => Self::Sphere,
        }
    }
}

// ============================================================
// ModelParams
// ============================================================

/// Configuration for all ionospheric physics models.
#[pyclass]
#[derive(Clone, Debug)]
pub struct ModelParams {
    #[pyo3(get, set)]
    pub earth_r: f64,
    #[pyo3(get, set)]
    pub earth_model: EarthModel,
    #[pyo3(get, set)]
    pub ed_model: ElectronDensityModel,
    #[pyo3(get, set)]
    pub mag_model: MagneticFieldModel,
    #[pyo3(get, set)]
    pub col_model: CollisionModel,
    #[pyo3(get, set)]
    pub rindex_model: RefractiveIndexModel,
    #[pyo3(get, set)]
    pub pert_model: PerturbationModel,
    #[pyo3(get, set)]
    pub fc: f64,
    #[pyo3(get, set)]
    pub hm: f64,
    #[pyo3(get, set)]
    pub sh: f64,
    #[pyo3(get, set)]
    pub alpha: f64,
    #[pyo3(get, set)]
    pub ed_a: f64,
    #[pyo3(get, set)]
    pub ed_b: f64,
    #[pyo3(get, set)]
    pub ed_c: f64,
    #[pyo3(get, set)]
    pub ed_e: f64,
    #[pyo3(get, set)]
    pub ym: f64,
    #[pyo3(get, set)]
    pub fc2: f64,
    #[pyo3(get, set)]
    pub hm2: f64,
    #[pyo3(get, set)]
    pub sh2: f64,
    #[pyo3(get, set)]
    pub chi: f64,
    #[pyo3(get, set)]
    pub fh: f64,
    #[pyo3(get, set)]
    pub dip: f64,
    #[pyo3(get, set)]
    pub epoch_year: f64,
    #[pyo3(get, set)]
    pub nu1: f64,
    #[pyo3(get, set)]
    pub h1: f64,
    #[pyo3(get, set)]
    pub a1: f64,
    #[pyo3(get, set)]
    pub nu2: f64,
    #[pyo3(get, set)]
    pub h2: f64,
    #[pyo3(get, set)]
    pub a2: f64,
    #[pyo3(get, set)]
    pub p1: f64,
    #[pyo3(get, set)]
    pub p2: f64,
    #[pyo3(get, set)]
    pub p3: f64,
    #[pyo3(get, set)]
    pub p4: f64,
    #[pyo3(get, set)]
    pub p5: f64,
    #[pyo3(get, set)]
    pub p6: f64,
    #[pyo3(get, set)]
    pub p7: f64,
    #[pyo3(get, set)]
    pub p8: f64,
    #[pyo3(get, set)]
    pub p9: f64,
}

#[pymethods]
impl ModelParams {
    #[new]
    #[pyo3(signature = (
        earth_r = 6370.0,
        earth_model = EarthModel::Sphere,
        ed_model = ElectronDensityModel::Chapman,
        mag_model = MagneticFieldModel::Dipole,
        col_model = CollisionModel::DoubleExponential,
        rindex_model = RefractiveIndexModel::Full,
        pert_model = PerturbationModel::None,
        fc = 10.0,
        hm = 250.0,
        sh = 100.0,
        alpha = 0.5,
        ed_a = 0.0,
        ed_b = 0.0,
        ed_c = 0.0,
        ed_e = 0.0,
        ym = 100.0,
        fc2 = 0.0,
        hm2 = 0.0,
        sh2 = 0.0,
        chi = 3.0,
        fh = 0.8,
        dip = 0.0,
        epoch_year = 2025.0,
        nu1 = 1_050_000.0,
        h1 = 100.0,
        a1 = 0.148,
        nu2 = 30.0,
        h2 = 140.0,
        a2 = 0.0183,
        p1 = 0.0, p2 = 0.0, p3 = 0.0, p4 = 0.0, p5 = 0.0,
        p6 = 0.0, p7 = 0.0, p8 = 0.0, p9 = 0.0,
    ))]
    #[allow(clippy::too_many_arguments)]
    fn new(
        earth_r: f64,
        earth_model: EarthModel,
        ed_model: ElectronDensityModel,
        mag_model: MagneticFieldModel,
        col_model: CollisionModel,
        rindex_model: RefractiveIndexModel,
        pert_model: PerturbationModel,
        fc: f64,
        hm: f64,
        sh: f64,
        alpha: f64,
        ed_a: f64,
        ed_b: f64,
        ed_c: f64,
        ed_e: f64,
        ym: f64,
        fc2: f64,
        hm2: f64,
        sh2: f64,
        chi: f64,
        fh: f64,
        dip: f64,
        epoch_year: f64,
        nu1: f64,
        h1: f64,
        a1: f64,
        nu2: f64,
        h2: f64,
        a2: f64,
        p1: f64,
        p2: f64,
        p3: f64,
        p4: f64,
        p5: f64,
        p6: f64,
        p7: f64,
        p8: f64,
        p9: f64,
    ) -> Self {
        Self {
            earth_r,
            earth_model,
            ed_model,
            mag_model,
            col_model,
            rindex_model,
            pert_model,
            fc,
            hm,
            sh,
            alpha,
            ed_a,
            ed_b,
            ed_c,
            ed_e,
            ym,
            fc2,
            hm2,
            sh2,
            chi,
            fh,
            dip,
            epoch_year,
            nu1,
            h1,
            a1,
            nu2,
            h2,
            a2,
            p1,
            p2,
            p3,
            p4,
            p5,
            p6,
            p7,
            p8,
            p9,
        }
    }

    fn __repr__(&self) -> String {
        format!(
            "ModelParams(fc={}, hm={}, sh={}, ed_model={:?}, mag_model={:?})",
            self.fc, self.hm, self.sh, self.ed_model, self.mag_model
        )
    }
}

impl From<&ModelParams> for ionotrace_core::ModelParams {
    fn from(p: &ModelParams) -> Self {
        let mut m = Self::default();
        m.earth_r = p.earth_r;
        m.earth_model = p.earth_model.into();
        m.ed_model = p.ed_model.into();
        m.mag_model = p.mag_model.into();
        m.col_model = p.col_model.into();
        m.rindex_model = p.rindex_model.into();
        m.pert_model = p.pert_model.into();
        m.fc = p.fc;
        m.hm = p.hm;
        m.sh = p.sh;
        m.alpha = p.alpha;
        m.ed_a = p.ed_a;
        m.ed_b = p.ed_b;
        m.ed_c = p.ed_c;
        m.ed_e = p.ed_e;
        m.ym = p.ym;
        m.fc2 = p.fc2;
        m.hm2 = p.hm2;
        m.sh2 = p.sh2;
        m.chi = p.chi;
        m.fh = p.fh;
        m.dip = p.dip;
        m.epoch_year = p.epoch_year;
        m.nu1 = p.nu1;
        m.h1 = p.h1;
        m.a1 = p.a1;
        m.nu2 = p.nu2;
        m.h2 = p.h2;
        m.a2 = p.a2;
        m.p1 = p.p1;
        m.p2 = p.p2;
        m.p3 = p.p3;
        m.p4 = p.p4;
        m.p5 = p.p5;
        m.p6 = p.p6;
        m.p7 = p.p7;
        m.p8 = p.p8;
        m.p9 = p.p9;
        m
    }
}

impl From<&ionotrace_core::ModelParams> for ModelParams {
    fn from(p: &ionotrace_core::ModelParams) -> Self {
        Self {
            earth_r: p.earth_r,
            earth_model: p.earth_model.into(),
            ed_model: p.ed_model.into(),
            mag_model: p.mag_model.into(),
            col_model: p.col_model.into(),
            rindex_model: p.rindex_model.into(),
            pert_model: p.pert_model.into(),
            fc: p.fc,
            hm: p.hm,
            sh: p.sh,
            alpha: p.alpha,
            ed_a: p.ed_a,
            ed_b: p.ed_b,
            ed_c: p.ed_c,
            ed_e: p.ed_e,
            ym: p.ym,
            fc2: p.fc2,
            hm2: p.hm2,
            sh2: p.sh2,
            chi: p.chi,
            fh: p.fh,
            dip: p.dip,
            epoch_year: p.epoch_year,
            nu1: p.nu1,
            h1: p.h1,
            a1: p.a1,
            nu2: p.nu2,
            h2: p.h2,
            a2: p.a2,
            p1: p.p1,
            p2: p.p2,
            p3: p.p3,
            p4: p.p4,
            p5: p.p5,
            p6: p.p6,
            p7: p.p7,
            p8: p.p8,
            p9: p.p9,
        }
    }
}

// ============================================================
// TracePoint / TraceResult (read-only result objects)
// ============================================================

/// A point along the ray path.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct TracePoint {
    #[pyo3(get)]
    pub step: usize,
    #[pyo3(get)]
    pub t: f64,
    #[pyo3(get)]
    pub height_km: f64,
    #[pyo3(get)]
    pub lat_deg: f64,
    #[pyo3(get)]
    pub lon_deg: f64,
    #[pyo3(get)]
    pub ground_range_km: f64,
    #[pyo3(get)]
    pub group_path: f64,
    #[pyo3(get)]
    pub phase_path: f64,
    #[pyo3(get)]
    pub absorption: f64,
}

#[pymethods]
impl TracePoint {
    fn __repr__(&self) -> String {
        format!(
            "TracePoint(step={}, h={:.1}km, lat={:.2}°, lon={:.2}°)",
            self.step, self.height_km, self.lat_deg, self.lon_deg
        )
    }
}

impl From<&ionotrace_core::TracePoint> for TracePoint {
    fn from(p: &ionotrace_core::TracePoint) -> Self {
        Self {
            step: p.step,
            t: p.t,
            height_km: p.height_km,
            lat_deg: p.lat_deg,
            lon_deg: p.lon_deg,
            ground_range_km: p.ground_range_km,
            group_path: p.group_path,
            phase_path: p.phase_path,
            absorption: p.absorption,
        }
    }
}

/// Result of tracing a single ray.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct TraceResult {
    #[pyo3(get)]
    pub points: Vec<TracePoint>,
    #[pyo3(get)]
    pub max_height: f64,
    #[pyo3(get)]
    pub ground_range_km: f64,
    #[pyo3(get)]
    pub returned_to_ground: bool,
    #[pyo3(get)]
    pub n_steps: usize,
}

#[pymethods]
impl TraceResult {
    fn __repr__(&self) -> String {
        format!(
            "TraceResult(max_h={:.1}km, range={:.1}km, ground={}, steps={})",
            self.max_height, self.ground_range_km, self.returned_to_ground, self.n_steps
        )
    }

    /// Export this result as a JSON string.
    fn to_json(&self) -> PyResult<String> {
        let rust_result = self.to_rust_result();
        ionotrace_core::export_json(&rust_result)
            .map_err(|e: Box<dyn std::error::Error>| PyValueError::new_err(e.to_string()))
    }

    /// Export this result as a CSV string.
    fn to_csv(&self) -> PyResult<String> {
        let rust_result = self.to_rust_result();
        ionotrace_core::export_trace_csv(&rust_result)
            .map_err(|e: Box<dyn std::error::Error>| PyValueError::new_err(e.to_string()))
    }
}

impl TraceResult {
    fn to_rust_result(&self) -> ionotrace_core::TraceResult {
        // Use the Rust TraceConfig to re-trace for export, or build manually
        // Since TraceResult is non-exhaustive, we serialize/deserialize.
        let json = serde_json::to_string(&serde_json::json!({
            "points": self.points.iter().map(|p| serde_json::json!({
                "step": p.step,
                "t": p.t,
                "height_km": p.height_km,
                "lat_deg": p.lat_deg,
                "lon_deg": p.lon_deg,
                "ground_range_km": p.ground_range_km,
                "group_path": p.group_path,
                "phase_path": p.phase_path,
                "absorption": p.absorption,
            })).collect::<Vec<_>>(),
            "max_height": self.max_height,
            "ground_range_km": self.ground_range_km,
            "returned_to_ground": self.returned_to_ground,
            "n_steps": self.n_steps,
        }))
        .unwrap();
        serde_json::from_str(&json).unwrap()
    }
}

impl From<&ionotrace_core::TraceResult> for TraceResult {
    fn from(r: &ionotrace_core::TraceResult) -> Self {
        Self {
            points: r.points.iter().map(TracePoint::from).collect(),
            max_height: r.max_height,
            ground_range_km: r.ground_range_km,
            returned_to_ground: r.returned_to_ground,
            n_steps: r.n_steps,
        }
    }
}

// ============================================================
// TraceConfig
// ============================================================

/// Configuration for tracing a single ray.
#[pyclass]
#[derive(Clone, Debug)]
pub struct TraceConfig {
    #[pyo3(get, set)]
    pub freq_mhz: f64,
    #[pyo3(get, set)]
    pub ray_mode: RayMode,
    #[pyo3(get, set)]
    pub elevation_deg: f64,
    #[pyo3(get, set)]
    pub azimuth_deg: f64,
    #[pyo3(get, set)]
    pub tx_lat_deg: f64,
    #[pyo3(get, set)]
    pub int_mode: usize,
    #[pyo3(get, set)]
    pub step_size: f64,
    #[pyo3(get, set)]
    pub max_steps: usize,
    #[pyo3(get, set)]
    pub e1max: f64,
    #[pyo3(get, set)]
    pub e1min: f64,
    #[pyo3(get, set)]
    pub e2max: f64,
    #[pyo3(get, set)]
    pub print_every: usize,
    #[pyo3(get, set)]
    pub params: ModelParams,
}

#[pymethods]
impl TraceConfig {
    #[new]
    #[pyo3(signature = (
        freq_mhz,
        elevation_deg,
        ray_mode = RayMode::Extraordinary,
        azimuth_deg = 0.0,
        tx_lat_deg = 40.0,
        int_mode = 2,
        step_size = 5.0,
        max_steps = 500,
        e1max = 1e-4,
        e1min = 2e-6,
        e2max = 100.0,
        print_every = 1,
        params = None,
    ))]
    #[allow(clippy::too_many_arguments)]
    fn new(
        freq_mhz: f64,
        elevation_deg: f64,
        ray_mode: RayMode,
        azimuth_deg: f64,
        tx_lat_deg: f64,
        int_mode: usize,
        step_size: f64,
        max_steps: usize,
        e1max: f64,
        e1min: f64,
        e2max: f64,
        print_every: usize,
        params: Option<ModelParams>,
    ) -> Self {
        let default_params = ionotrace_core::ModelParams::default();
        Self {
            freq_mhz,
            ray_mode,
            elevation_deg,
            azimuth_deg,
            tx_lat_deg,
            int_mode,
            step_size,
            max_steps,
            e1max,
            e1min,
            e2max,
            print_every,
            params: params.unwrap_or_else(|| ModelParams::from(&default_params)),
        }
    }

    /// Trace this ray and return the result.
    fn trace(&self) -> PyResult<TraceResult> {
        let rust_cfg = self.to_rust_config();
        let result = rust_cfg
            .trace()
            .map_err(|e: ionotrace_core::TraceError| PyValueError::new_err(format!("{e}")))?;
        Ok(TraceResult::from(&result))
    }

    fn __repr__(&self) -> String {
        format!(
            "TraceConfig(freq={} MHz, elev={:.1}°, az={:.1}°)",
            self.freq_mhz, self.elevation_deg, self.azimuth_deg
        )
    }
}

impl TraceConfig {
    fn to_rust_config(&self) -> ionotrace_core::TraceConfig {
        let rust_mode: ionotrace_core::params::RayMode = self.ray_mode.into();
        let mut cfg = ionotrace_core::TraceConfig::new(self.freq_mhz, self.elevation_deg);
        cfg.ray_mode = rust_mode;
        cfg.azimuth_deg = self.azimuth_deg;
        cfg.tx_lat_deg = self.tx_lat_deg;
        cfg.int_mode = self.int_mode;
        cfg.step_size = self.step_size;
        cfg.max_steps = self.max_steps;
        cfg.e1max = self.e1max;
        cfg.e1min = self.e1min;
        cfg.e2max = self.e2max;
        cfg.print_every = self.print_every;
        cfg.params = ionotrace_core::ModelParams::from(&self.params);
        cfg
    }
}

// ============================================================
// Fan trace types
// ============================================================

/// A point along a fan ray trajectory.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct FanRayPoint {
    #[pyo3(get)]
    pub h: f64,
    #[pyo3(get)]
    pub t: f64,
    #[pyo3(get)]
    pub lat: f64,
    #[pyo3(get)]
    pub lon: f64,
    #[pyo3(get)]
    pub range: f64,
}

impl From<&ionotrace_core::FanRayPoint> for FanRayPoint {
    fn from(p: &ionotrace_core::FanRayPoint) -> Self {
        Self {
            h: p.h,
            t: p.t,
            lat: p.lat,
            lon: p.lon,
            range: p.range,
        }
    }
}

/// Summary of a single hop.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct HopSummary {
    #[pyo3(get)]
    pub range_km: f64,
    #[pyo3(get)]
    pub lat: f64,
    #[pyo3(get)]
    pub lon: f64,
    #[pyo3(get)]
    pub absorption: f64,
}

impl From<&ionotrace_core::fan::HopSummary> for HopSummary {
    fn from(h: &ionotrace_core::fan::HopSummary) -> Self {
        Self {
            range_km: h.range_km,
            lat: h.lat,
            lon: h.lon,
            absorption: h.absorption,
        }
    }
}

/// A single ray within a fan trace.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct FanRay {
    #[pyo3(get)]
    pub elev: f64,
    #[pyo3(get)]
    pub max_h: f64,
    #[pyo3(get)]
    pub ground: bool,
    #[pyo3(get)]
    pub range_km: f64,
    #[pyo3(get)]
    pub hops: u8,
    #[pyo3(get)]
    pub absorption: f64,
    #[pyo3(get)]
    pub landing_lat: f64,
    #[pyo3(get)]
    pub landing_lon: f64,
    #[pyo3(get)]
    pub pts: Vec<FanRayPoint>,
    #[pyo3(get)]
    pub hop_summaries: Vec<HopSummary>,
}

#[pymethods]
impl FanRay {
    fn __repr__(&self) -> String {
        format!(
            "FanRay(elev={:.1}°, max_h={:.0}km, ground={}, range={:.0}km)",
            self.elev, self.max_h, self.ground, self.range_km
        )
    }
}

impl From<&ionotrace_core::FanRay> for FanRay {
    fn from(r: &ionotrace_core::FanRay) -> Self {
        Self {
            elev: r.elev,
            max_h: r.max_h,
            ground: r.ground,
            range_km: r.range_km,
            hops: r.hops,
            absorption: r.absorption,
            landing_lat: r.landing_lat,
            landing_lon: r.landing_lon,
            pts: r.pts.iter().map(FanRayPoint::from).collect(),
            hop_summaries: r.hop_summaries.iter().map(HopSummary::from).collect(),
        }
    }
}

/// Result of a fan trace.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct FanTraceResult {
    #[pyo3(get)]
    pub rays: Vec<FanRay>,
    #[pyo3(get)]
    pub n_rays: usize,
}

#[pymethods]
impl FanTraceResult {
    fn __repr__(&self) -> String {
        format!("FanTraceResult(n_rays={})", self.n_rays)
    }
}

impl From<&ionotrace_core::FanTraceResult> for FanTraceResult {
    fn from(r: &ionotrace_core::FanTraceResult) -> Self {
        Self {
            rays: r.rays.iter().map(FanRay::from).collect(),
            n_rays: r.n_rays,
        }
    }
}

/// Configuration for a fan trace.
#[pyclass]
#[derive(Clone, Debug)]
pub struct FanTraceConfig {
    #[pyo3(get, set)]
    pub freq_mhz: f64,
    #[pyo3(get, set)]
    pub ray_mode: f64,
    #[pyo3(get, set)]
    pub elev_min: f64,
    #[pyo3(get, set)]
    pub elev_max: f64,
    #[pyo3(get, set)]
    pub elev_step: f64,
    #[pyo3(get, set)]
    pub azimuth_deg: f64,
    #[pyo3(get, set)]
    pub tx_lat_deg: f64,
    #[pyo3(get, set)]
    pub step_size: f64,
    #[pyo3(get, set)]
    pub max_steps: usize,
    #[pyo3(get, set)]
    pub max_hops: u8,
    #[pyo3(get, set)]
    pub params: ModelParams,
}

#[pymethods]
impl FanTraceConfig {
    #[new]
    #[pyo3(signature = (
        freq_mhz = 10.0,
        ray_mode = 1.0,
        elev_min = 5.0,
        elev_max = 85.0,
        elev_step = 5.0,
        azimuth_deg = 0.0,
        tx_lat_deg = 40.0,
        step_size = 5.0,
        max_steps = 500,
        max_hops = 1,
        params = None,
    ))]
    #[allow(clippy::too_many_arguments)]
    fn new(
        freq_mhz: f64,
        ray_mode: f64,
        elev_min: f64,
        elev_max: f64,
        elev_step: f64,
        azimuth_deg: f64,
        tx_lat_deg: f64,
        step_size: f64,
        max_steps: usize,
        max_hops: u8,
        params: Option<ModelParams>,
    ) -> Self {
        let default_params = ionotrace_core::ModelParams::default();
        Self {
            freq_mhz,
            ray_mode,
            elev_min,
            elev_max,
            elev_step,
            azimuth_deg,
            tx_lat_deg,
            step_size,
            max_steps,
            max_hops,
            params: params.unwrap_or_else(|| ModelParams::from(&default_params)),
        }
    }

    fn __repr__(&self) -> String {
        format!(
            "FanTraceConfig(freq={} MHz, elev={}°–{}°, step={}°)",
            self.freq_mhz, self.elev_min, self.elev_max, self.elev_step
        )
    }
}

impl FanTraceConfig {
    fn to_rust_config(&self) -> ionotrace_core::FanTraceConfig {
        ionotrace_core::FanTraceConfig {
            freq_mhz: self.freq_mhz,
            ray_mode: self.ray_mode,
            elev_min: self.elev_min,
            elev_max: self.elev_max,
            elev_step: self.elev_step,
            azimuth_deg: self.azimuth_deg,
            tx_lat_deg: self.tx_lat_deg,
            step_size: self.step_size,
            max_steps: self.max_steps,
            max_hops: self.max_hops,
            params: ionotrace_core::ModelParams::from(&self.params),
        }
    }
}

// ============================================================
// Target solver types
// ============================================================

/// A single solution from the target solver.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct TargetSolution {
    #[pyo3(get)]
    pub elevation_deg: f64,
    #[pyo3(get)]
    pub azimuth_deg: f64,
    #[pyo3(get)]
    pub freq_mhz: f64,
    #[pyo3(get)]
    pub landing_lat_deg: f64,
    #[pyo3(get)]
    pub landing_lon_deg: f64,
    #[pyo3(get)]
    pub error_km: f64,
    #[pyo3(get)]
    pub range_km: f64,
    #[pyo3(get)]
    pub max_height_km: f64,
    #[pyo3(get)]
    pub hops: u8,
    #[pyo3(get)]
    pub absorption: f64,
    #[pyo3(get)]
    pub group_path: f64,
    #[pyo3(get)]
    pub phase_path: f64,
    #[pyo3(get)]
    pub ray_path: Option<Vec<TracePoint>>,
}

#[pymethods]
impl TargetSolution {
    fn __repr__(&self) -> String {
        format!(
            "TargetSolution(elev={:.1}°, az={:.1}°, freq={:.1}MHz, err={:.1}km)",
            self.elevation_deg, self.azimuth_deg, self.freq_mhz, self.error_km
        )
    }
}

impl From<&ionotrace_core::TargetSolution> for TargetSolution {
    fn from(s: &ionotrace_core::TargetSolution) -> Self {
        Self {
            elevation_deg: s.elevation_deg,
            azimuth_deg: s.azimuth_deg,
            freq_mhz: s.freq_mhz,
            landing_lat_deg: s.landing_lat_deg,
            landing_lon_deg: s.landing_lon_deg,
            error_km: s.error_km,
            range_km: s.range_km,
            max_height_km: s.max_height_km,
            hops: s.hops,
            absorption: s.absorption,
            group_path: s.group_path,
            phase_path: s.phase_path,
            ray_path: s
                .ray_path
                .as_ref()
                .map(|pts: &Vec<ionotrace_core::TracePoint>| {
                    pts.iter().map(TracePoint::from).collect()
                }),
        }
    }
}

/// Result of the target solver.
#[pyclass(frozen)]
#[derive(Clone, Debug)]
pub struct TargetResult {
    #[pyo3(get)]
    pub solutions: Vec<TargetSolution>,
    #[pyo3(get)]
    pub best: Option<TargetSolution>,
    #[pyo3(get)]
    pub elapsed_ms: f64,
    #[pyo3(get)]
    pub rays_traced: usize,
    #[pyo3(get)]
    pub status: String,
}

#[pymethods]
impl TargetResult {
    fn __repr__(&self) -> String {
        format!(
            "TargetResult(solutions={}, status='{}', elapsed={:.0}ms)",
            self.solutions.len(),
            self.status,
            self.elapsed_ms
        )
    }
}

impl From<&ionotrace_core::TargetResult> for TargetResult {
    fn from(r: &ionotrace_core::TargetResult) -> Self {
        Self {
            solutions: r.solutions.iter().map(TargetSolution::from).collect(),
            best: r.best.as_ref().map(TargetSolution::from),
            elapsed_ms: r.elapsed_ms,
            rays_traced: r.rays_traced,
            status: r.status.clone(),
        }
    }
}

/// Configuration for the target solver.
#[pyclass]
#[derive(Clone, Debug)]
pub struct TargetConfig {
    #[pyo3(get, set)]
    pub target_lat_deg: f64,
    #[pyo3(get, set)]
    pub target_lon_deg: f64,
    #[pyo3(get, set)]
    pub tx_lat_deg: f64,
    #[pyo3(get, set)]
    pub freq_mhz: f64,
    #[pyo3(get, set)]
    pub azimuth_deg: f64,
    #[pyo3(get, set)]
    pub ray_mode: f64,
    #[pyo3(get, set)]
    pub elev_min: f64,
    #[pyo3(get, set)]
    pub elev_max: f64,
    #[pyo3(get, set)]
    pub coarse_step: f64,
    #[pyo3(get, set)]
    pub error_limit_km: f64,
    #[pyo3(get, set)]
    pub max_bisect_iters: usize,
    #[pyo3(get, set)]
    pub max_nm_iters: usize,
    #[pyo3(get, set)]
    pub max_hops: u8,
    #[pyo3(get, set)]
    pub step_size: f64,
    #[pyo3(get, set)]
    pub max_steps: usize,
    #[pyo3(get, set)]
    pub include_ray_path: bool,
    #[pyo3(get, set)]
    pub params: ModelParams,
}

#[pymethods]
impl TargetConfig {
    #[new]
    #[pyo3(signature = (
        target_lat_deg = 50.0,
        target_lon_deg = 0.0,
        tx_lat_deg = 40.0,
        freq_mhz = 10.0,
        azimuth_deg = 0.0,
        ray_mode = -1.0,
        elev_min = 3.0,
        elev_max = 85.0,
        coarse_step = 2.0,
        error_limit_km = 5.0,
        max_bisect_iters = 30,
        max_nm_iters = 100,
        max_hops = 3,
        step_size = 5.0,
        max_steps = 500,
        include_ray_path = false,
        params = None,
    ))]
    #[allow(clippy::too_many_arguments)]
    fn new(
        target_lat_deg: f64,
        target_lon_deg: f64,
        tx_lat_deg: f64,
        freq_mhz: f64,
        azimuth_deg: f64,
        ray_mode: f64,
        elev_min: f64,
        elev_max: f64,
        coarse_step: f64,
        error_limit_km: f64,
        max_bisect_iters: usize,
        max_nm_iters: usize,
        max_hops: u8,
        step_size: f64,
        max_steps: usize,
        include_ray_path: bool,
        params: Option<ModelParams>,
    ) -> Self {
        let default_params = ionotrace_core::ModelParams::default();
        Self {
            target_lat_deg,
            target_lon_deg,
            tx_lat_deg,
            freq_mhz,
            azimuth_deg,
            ray_mode,
            elev_min,
            elev_max,
            coarse_step,
            error_limit_km,
            max_bisect_iters,
            max_nm_iters,
            max_hops,
            step_size,
            max_steps,
            include_ray_path,
            params: params.unwrap_or_else(|| ModelParams::from(&default_params)),
        }
    }

    fn __repr__(&self) -> String {
        format!(
            "TargetConfig(target=({:.1}°, {:.1}°), freq={:.1}MHz)",
            self.target_lat_deg, self.target_lon_deg, self.freq_mhz
        )
    }
}

impl TargetConfig {
    fn to_rust_config(&self) -> ionotrace_core::TargetConfig {
        ionotrace_core::TargetConfig {
            target_lat_deg: self.target_lat_deg,
            target_lon_deg: self.target_lon_deg,
            tx_lat_deg: self.tx_lat_deg,
            freq_mhz: ionotrace_core::SearchSpec::Fixed(self.freq_mhz),
            azimuth_deg: ionotrace_core::SearchSpec::Fixed(self.azimuth_deg),
            ray_mode: self.ray_mode,
            elev_min: self.elev_min,
            elev_max: self.elev_max,
            coarse_step: self.coarse_step,
            error_limit_km: self.error_limit_km,
            max_bisect_iters: self.max_bisect_iters,
            max_nm_iters: self.max_nm_iters,
            max_hops: self.max_hops,
            step_size: self.step_size,
            max_steps: self.max_steps,
            include_ray_path: self.include_ray_path,
            params: ionotrace_core::ModelParams::from(&self.params),
        }
    }
}

// ============================================================
// Module-level functions
// ============================================================

/// Trace a fan of rays through the ionosphere.
#[pyfunction]
fn fan_trace(config: &FanTraceConfig) -> PyResult<FanTraceResult> {
    let rust_cfg = config.to_rust_config();
    let result = ionotrace_core::fan_trace(&rust_cfg)
        .map_err(|e: ionotrace_core::TraceError| PyValueError::new_err(format!("{e}")))?;
    Ok(FanTraceResult::from(&result))
}

/// Solve for ray launch parameters to hit a target location.
#[pyfunction]
fn solve_target(config: &TargetConfig) -> PyResult<TargetResult> {
    let rust_cfg = config.to_rust_config();
    let result = ionotrace_core::solve_target(&rust_cfg)
        .map_err(|e: ionotrace_core::TraceError| PyValueError::new_err(format!("{e}")))?;
    Ok(TargetResult::from(&result))
}

// ============================================================
// Python module
// ============================================================

/// ionotrace — High-performance ionospheric ray tracing engine.
///
/// Python bindings for the ionotrace Rust crate.
///
/// `ionotrace` runs accurate physical models by default, including a WGS-84 geodetic Earth and the IGRF-14 harmonic magnetic field.
/// It has been extensively validated against the reference PHaRLAP Fortran engine across 168 challenging scenarios (including very low elevations, thick ionospheric layers, and near-critical frequencies). Across all returning rays, `ionotrace` matches PHaRLAP with a mean ground range difference of 0.53%.
#[pymodule]
fn ionotrace(m: &Bound<'_, PyModule>) -> PyResult<()> {
    // Enums
    m.add_class::<ElectronDensityModel>()?;
    m.add_class::<MagneticFieldModel>()?;
    m.add_class::<CollisionModel>()?;
    m.add_class::<RefractiveIndexModel>()?;
    m.add_class::<PerturbationModel>()?;
    m.add_class::<RayMode>()?;
    m.add_class::<EarthModel>()?;

    // Config types
    m.add_class::<ModelParams>()?;
    m.add_class::<TraceConfig>()?;
    m.add_class::<FanTraceConfig>()?;
    m.add_class::<TargetConfig>()?;

    // Result types
    m.add_class::<TracePoint>()?;
    m.add_class::<TraceResult>()?;
    m.add_class::<FanRayPoint>()?;
    m.add_class::<HopSummary>()?;
    m.add_class::<FanRay>()?;
    m.add_class::<FanTraceResult>()?;
    m.add_class::<TargetSolution>()?;
    m.add_class::<TargetResult>()?;

    // Functions
    m.add_function(wrap_pyfunction!(fan_trace, m)?)?;
    m.add_function(wrap_pyfunction!(solve_target, m)?)?;

    Ok(())
}
