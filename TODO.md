# TODO

Tracked issues for the ionospheric ray tracing engine, ordered by priority.

---

## ~~1. Polar Coordinate Singularity (Refactor to ECEF)~~ ✅

Integrating the Hamiltonian natively in spherical coordinates caused mathematical
instability when a ray approaches the geographic poles. Refactored the RK4
integrator to operate in Cartesian ECEF coordinates to eliminate this singularity.

**Resolved in v0.4.0** — `ecef.rs`, `hamiltonian_ecef.rs`, ECEF integrator
wrappers in `tracer.rs`. Selectable via `CoordinateSystem::Ecef`.

---

## 2. Hardcoded IGRF-14 Coefficients
- [ ] Implement a parser to read standard IGRF `.COF` files at runtime
- [ ] Remove hardcoded coefficients from the binary (current expiration ~2030)

## ~~3. Ingest Empirical Ionosphere Models (e.g., IRI-2020)~~ ✅

Added a model-agnostic 3D grid-interpolation module for real-world empirical data.
Supports CSV and JSON input — any tool that outputs `fp(alt, lat, lon)` works
(IRI-2020, NeQuick, SAMI3, custom).

**Resolved in v0.4.0** — `grid.rs`, `GridInterp` variant in `ElectronDensityModel`,
`ed_grid` field on `ModelParams`.

---

## ~~4. Spherical Earth Assumption (Upgrade to WGS-84)~~ ✅

Surface geometry assumed a perfect sphere with radius 6370 km. Upgraded to WGS-84
oblate spheroid to eliminate ~20 km ground-range errors over long hops.

**Resolved in v0.4.0** — `wgs84.rs`, `EarthModel` enum in `params.rs`. Selectable
via `EarthModel::Wgs84`.

---

## ~~5. Sen-Wyller Magneto-Ionic Theory~~ ✅

Implemented the generalized Sen-Wyller dispersion relation with velocity-dependent
collision frequencies via Dingle integral Padé approximations. Provides more
accurate D-region absorption than standard Appleton-Hartree at LF/MF.

**Resolved in v0.4.0** — `SenWyller` variant in `RefractiveIndexModel`, Dingle
integrals `G₁`, `G₂`, `G₃` and `swwfwc` function in `refractive_index.rs`.

## 6. Dynamic Magnetic Field Modeling 🔮 *Deferred*
- [ ] Add support for external current models (e.g., Tsyganenko)
- [ ] Enable accurate high-altitude ray tracing and propagation during geomagnetic storms
- *Note: Deferred to a future release — niche use case for magnetospheric/storm-time propagation.*
