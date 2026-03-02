"""FastAPI backend for ionospheric ray tracing visualization.

Serves the web UI and provides API endpoints for fan tracing.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
from typing import Optional
import math
import sys
import os

# Add pyraytrace to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "pyraytrace"))

app = FastAPI(title="Ionospheric Ray Tracer", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class FanTraceRequest(BaseModel):
    """Request body for fan trace."""
    freq_mhz: float = Field(10.0, ge=1.0, le=30.0, description="Frequency in MHz")
    ray_mode: float = Field(-1.0, description="-1 extraordinary, +1 ordinary")
    elev_min: float = Field(5.0, ge=1.0, le=89.0, description="Min elevation (deg)")
    elev_max: float = Field(80.0, ge=2.0, le=89.0, description="Max elevation (deg)")
    elev_step: float = Field(2.0, ge=0.5, le=10.0, description="Elevation step (deg)")
    azimuth_deg: float = Field(0.0, ge=0.0, le=360.0, description="Azimuth (deg)")
    tx_lat_deg: float = Field(40.0, ge=-90.0, le=90.0, description="TX latitude (deg)")
    # Model params
    fc: float = Field(10.0, description="Critical frequency (MHz)")
    hm: float = Field(250.0, description="Height of max density (km)")
    sh: float = Field(100.0, description="Scale height (km)")
    fh: float = Field(0.8, description="Gyrofrequency at surface (MHz)")
    step_size: float = Field(5.0, ge=1.0, le=50.0, description="Integration step")
    max_steps: int = Field(500, ge=50, le=2000, description="Max integration steps")
    # Model selectors
    ed_model: int = Field(0, ge=0, le=5, description="Electron density model")
    mag_model: int = Field(0, ge=0, le=3, description="Magnetic field model")
    col_model: int = Field(0, ge=0, le=2, description="Collision model")
    rindex_model: int = Field(0, ge=0, le=3, description="Refractive index model")
    pert_model: int = Field(0, ge=0, le=5, description="Perturbation model")


@app.post("/api/trace/fan")
def trace_fan(req: FanTraceRequest):
    """Trace a fan of rays and return paths."""
    import numpy as np

    try:
        import raytrace_core
    except ImportError:
        return {"error": "raytrace_core not installed", "rays": []}

    import time
    t0 = time.perf_counter()

    elevations = list(np.arange(req.elev_min, req.elev_max + 0.01, req.elev_step))
    earth_r = 6370.0
    rays = []

    for elev in elevations:
        result = raytrace_core.trace_ray_py(
            freq_mhz=req.freq_mhz,
            ray_mode=req.ray_mode,
            elevation_deg=elev,
            azimuth_deg=req.azimuth_deg,
            tx_lat_deg=req.tx_lat_deg,
            int_mode=2,
            step_size=req.step_size,
            max_steps=req.max_steps,
            e1max=1e-4, e1min=2e-6, e2max=100.0,
            earth_r=earth_r,
            fc=req.fc, hm=req.hm, sh=req.sh, alpha=0.5,
            ed_a=0.0, ed_b=0.0, ed_c=0.0, ed_e=0.0,
            fh=req.fh,
            nu1=1050000.0, h1=100.0, a1=0.148,
            nu2=30.0, h2=140.0, a2=0.0183,
            print_every=1,
            ed_model=req.ed_model,
            mag_model=req.mag_model,
            col_model=req.col_model,
            rindex_model=req.rindex_model,
            pert_model=req.pert_model,
        )

        # Compute ground range from theta changes
        # Each point has height; we reconstruct position from t (group path)
        points = []
        for pt in result["points"]:
            h = pt["height_km"]
            t = pt["t"]
            points.append({
                "h": round(h, 2), "t": round(t, 2),
                "lat": round(pt["lat_deg"], 4),
                "lon": round(pt["lon_deg"], 4),
                "range": round(pt["ground_range_km"], 1),
            })

        rays.append({
            "elev": round(elev, 1),
            "max_h": round(result["max_height"], 2),
            "ground": result["returned_to_ground"],
            "range_km": round(result["ground_range_km"], 1),
            "pts": points,
        })

    elapsed = (time.perf_counter() - t0) * 1000.0

    return {
        "rays": rays,
        "n_rays": len(rays),
        "elapsed_ms": round(elapsed, 2),
        "freq_mhz": req.freq_mhz,
        "fc": req.fc,
        "hm": req.hm,
    }


# ============================================================
# Propagation analysis endpoints
# ============================================================

class HomingRequest(BaseModel):
    """Find elevation angle for a target ground range."""
    target_range_km: float = Field(500.0, ge=50, le=5000, description="Target ground range (km)")
    freq_mhz: float = Field(10.0, ge=1, le=30)
    ray_mode: float = Field(-1.0)
    fc: float = Field(10.0)
    hm: float = Field(250.0)
    sh: float = Field(100.0)
    fh: float = Field(0.8)
    tolerance_km: float = Field(5.0, ge=1, le=50)


class MufRequest(BaseModel):
    """Find MUF/LUF for a given path."""
    elevation_deg: float = Field(20.0, ge=1, le=89)
    ray_mode: float = Field(-1.0)
    fc: float = Field(10.0)
    hm: float = Field(250.0)
    sh: float = Field(100.0)
    fh: float = Field(0.8)
    freq_min: float = Field(2.0, ge=1, le=30)
    freq_max: float = Field(30.0, ge=2, le=50)
    freq_step: float = Field(0.5, ge=0.1, le=5)


class CoverageRequest(BaseModel):
    """Compute ground coverage map."""
    freq_mhz: float = Field(10.0, ge=1, le=30)
    ray_mode: float = Field(-1.0)
    fc: float = Field(10.0)
    hm: float = Field(250.0)
    sh: float = Field(100.0)
    fh: float = Field(0.8)
    elev_min: float = Field(5.0, ge=1, le=40)
    elev_max: float = Field(60.0, ge=10, le=89)
    elev_step: float = Field(2.0, ge=0.5, le=10)
    az_min: float = Field(0.0, ge=0, le=360)
    az_max: float = Field(360.0, ge=0, le=360)
    az_step: float = Field(15.0, ge=1, le=90)


@app.post("/api/propagation/home")
def api_homing(req: HomingRequest):
    """Find elevation angle for a target ground range via bisection."""
    from pyraytrace.propagation import find_elevation
    result = find_elevation(
        target_range_km=req.target_range_km,
        freq_mhz=req.freq_mhz, ray_mode=req.ray_mode,
        fc=req.fc, hm=req.hm, sh=req.sh, fh=req.fh,
        tolerance_km=req.tolerance_km,
    )
    return {
        "elevation_deg": result.elevation_deg,
        "ground_range_km": result.ground_range_km,
        "max_height_km": result.max_height_km,
        "converged": result.converged,
        "error_km": result.error_km,
        "n_iterations": result.n_iterations,
    }


@app.post("/api/propagation/muf")
def api_muf(req: MufRequest):
    """Find MUF/LUF by sweeping frequencies."""
    from pyraytrace.propagation import analyze_frequencies
    result = analyze_frequencies(
        elevation_deg=req.elevation_deg, ray_mode=req.ray_mode,
        fc=req.fc, hm=req.hm, sh=req.sh, fh=req.fh,
        freq_min=req.freq_min, freq_max=req.freq_max,
        freq_step=req.freq_step,
    )
    return {
        "muf_mhz": result.muf_mhz,
        "luf_mhz": result.luf_mhz,
        "optimal_mhz": result.optimal_mhz,
        "results": result.results,
    }


@app.post("/api/propagation/coverage")
def api_coverage(req: CoverageRequest):
    """Compute ground coverage map."""
    from pyraytrace.propagation import compute_coverage
    result = compute_coverage(
        freq_mhz=req.freq_mhz, ray_mode=req.ray_mode,
        fc=req.fc, hm=req.hm, sh=req.sh, fh=req.fh,
        elev_min=req.elev_min, elev_max=req.elev_max,
        elev_step=req.elev_step,
        az_min=req.az_min, az_max=req.az_max,
        az_step=req.az_step,
    )
    return {
        "points": [
            {
                "elev": p.elevation_deg, "az": p.azimuth_deg,
                "range": p.ground_range_km, "max_h": p.max_height_km,
                "returned": p.returned,
            }
            for p in result.points
        ],
        "n_rays": result.n_rays,
        "elapsed_ms": result.elapsed_ms,
    }


# ============================================================
# Export endpoints
# ============================================================

@app.post("/api/export/kml")
def export_kml(req: FanTraceRequest):
    """Export fan trace as KML for Google Earth visualization."""
    from fastapi.responses import Response

    # Re-use the trace logic
    fan_result = trace_fan(req)
    rays = fan_result["rays"]

    kml_lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<kml xmlns="http://www.opengis.net/kml/2.2">',
        '<Document>',
        f'  <name>Ray Trace {req.freq_mhz} MHz</name>',
        '  <Style id="rayReturned"><LineStyle><color>ff00ff00</color><width>2</width></LineStyle></Style>',
        '  <Style id="rayEscaped"><LineStyle><color>ff0000ff</color><width>1</width></LineStyle></Style>',
    ]

    for ray in rays:
        style = "rayReturned" if ray["ground"] else "rayEscaped"
        kml_lines.append(f'  <Placemark>')
        kml_lines.append(f'    <name>Elev {ray["elev"]}°</name>')
        kml_lines.append(f'    <description>Max height: {ray["max_h"]} km, Range: {ray.get("range_km", 0)} km</description>')
        kml_lines.append(f'    <styleUrl>#{style}</styleUrl>')
        kml_lines.append(f'    <LineString>')
        kml_lines.append(f'      <altitudeMode>absolute</altitudeMode>')
        coords = []
        for pt in ray["pts"]:
            lon = pt.get("lon", 0.0)
            lat = pt.get("lat", req.tx_lat_deg)
            alt = pt["h"] * 1000  # km → m
            coords.append(f'{lon},{lat},{alt:.0f}')
        kml_lines.append(f'      <coordinates>{" ".join(coords)}</coordinates>')
        kml_lines.append(f'    </LineString>')
        kml_lines.append(f'  </Placemark>')

    kml_lines.extend(['</Document>', '</kml>'])

    return Response(
        content="\n".join(kml_lines),
        media_type="application/vnd.google-earth.kml+xml",
        headers={"Content-Disposition": "attachment; filename=raytrace.kml"},
    )


@app.post("/api/export/geojson")
def export_geojson(req: FanTraceRequest):
    """Export fan trace as GeoJSON for mapping tools."""
    fan_result = trace_fan(req)
    rays = fan_result["rays"]

    features = []
    for ray in rays:
        coords = []
        for pt in ray["pts"]:
            lon = pt.get("lon", 0.0)
            lat = pt.get("lat", req.tx_lat_deg)
            alt = pt["h"]
            coords.append([lon, lat, alt])
        features.append({
            "type": "Feature",
            "properties": {
                "elevation_deg": ray["elev"],
                "max_height_km": ray["max_h"],
                "ground_range_km": ray.get("range_km", 0),
                "returned": ray["ground"],
            },
            "geometry": {
                "type": "LineString",
                "coordinates": coords,
            },
        })

    return {
        "type": "FeatureCollection",
        "features": features,
        "properties": {
            "freq_mhz": req.freq_mhz,
            "n_rays": len(rays),
        },
    }

# Serve frontend
frontend_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "apps", "frontend")
)

@app.get("/")
def serve_index():
    path = os.path.join(frontend_dir, "index.html")
    if os.path.isfile(path):
        return FileResponse(path)
    return {"error": f"Frontend not found at {frontend_dir}"}

@app.get("/{filename:path}")
def serve_static(filename: str):
    # Don't catch API routes
    if filename.startswith("api/"):
        return {"error": "Not found"}
    filepath = os.path.join(frontend_dir, filename)
    if os.path.isfile(filepath):
        return FileResponse(filepath)
    return FileResponse(os.path.join(frontend_dir, "404.html"), status_code=404)
