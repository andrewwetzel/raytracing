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
        )

        # Compute ground range from theta changes
        # Each point has height; we reconstruct position from t (group path)
        points = []
        for pt in result["points"]:
            h = pt["height_km"]
            t = pt["t"]  # group path in km
            # Approximate ground range from geometry
            r = earth_r + h
            # For visualization: use t as horizontal dist, h as vertical
            points.append({"h": round(h, 2), "t": round(t, 2)})

        rays.append({
            "elev": round(elev, 1),
            "max_h": round(result["max_height"], 2),
            "ground": result["returned_to_ground"],
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
