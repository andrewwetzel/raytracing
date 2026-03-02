"""Multi-ray fan tracing module.

Traces fans of rays at different elevation angles using the Rust engine
for high performance (~0.028 ms/ray = ~3 ms for 100 rays).
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Optional

import numpy as np

from pyraytrace.constants import EARTH_RADIUS


@dataclass
class RayPath:
    """A single ray path through the ionosphere."""
    elevation_deg: float
    azimuth_deg: float
    max_height_km: float
    returned_to_ground: bool
    n_steps: int
    points: list[dict]  # [{height_km, ground_range_km, r, theta, ...}]


@dataclass
class FanResult:
    """Result of a fan trace — multiple rays."""
    rays: list[RayPath]
    freq_mhz: float
    azimuth_deg: float
    tx_lat_deg: float
    elapsed_ms: float


def trace_fan_rust(
    freq_mhz: float = 10.0,
    ray_mode: float = -1.0,
    elevations: Optional[list[float]] = None,
    azimuth_deg: float = 0.0,
    tx_lat_deg: float = 40.0,
    int_mode: int = 2,
    step_size: float = 10.0,
    max_steps: int = 500,
    earth_r: float = EARTH_RADIUS,
    # Chapman params (defaults for sample case)
    fc: float = 10.0,
    hm: float = 250.0,
    sh: float = 100.0,
    alpha: float = 0.5,
    ed_a: float = 0.0,
    ed_b: float = 0.0,
    ed_c: float = 0.0,
    ed_e: float = 0.0,
    # Dipole params
    fh: float = 0.8,
    # Collision params
    nu1: float = 1050000.0,
    h1: float = 100.0,
    a1: float = 0.148,
    nu2: float = 30.0,
    h2: float = 140.0,
    a2: float = 0.0183,
) -> FanResult:
    """Trace a fan of rays using the Rust engine.

    Args:
        freq_mhz: Wave frequency in MHz
        ray_mode: -1.0 for extraordinary, +1.0 for ordinary
        elevations: List of elevation angles in degrees (default: 5-80° in 1° steps)
        azimuth_deg: Azimuth angle in degrees
        tx_lat_deg: Transmitter latitude in degrees
        ... (model params)

    Returns:
        FanResult with all traced rays
    """
    import time

    try:
        import raytrace_core
    except ImportError:
        raise ImportError(
            "raytrace_core not installed. Build with: "
            "cd packages/raytrace_core && maturin develop --release"
        )

    if elevations is None:
        elevations = list(np.arange(5.0, 81.0, 1.0))

    t0 = time.perf_counter()
    rays = []

    for elev in elevations:
        result = raytrace_core.trace_ray_py(
            freq_mhz=freq_mhz,
            ray_mode=ray_mode,
            elevation_deg=elev,
            azimuth_deg=azimuth_deg,
            tx_lat_deg=tx_lat_deg,
            int_mode=int_mode,
            step_size=step_size,
            max_steps=max_steps,
            e1max=1e-4, e1min=2e-6, e2max=100.0,
            earth_r=earth_r,
            fc=fc, hm=hm, sh=sh, alpha=alpha,
            ed_a=ed_a, ed_b=ed_b, ed_c=ed_c, ed_e=ed_e,
            fh=fh,
            nu1=nu1, h1=h1, a1=a1,
            nu2=nu2, h2=h2, a2=a2,
            print_every=1,  # Every step for smooth curves
        )

        # Convert points to include ground range
        points = []
        theta0 = math.radians(90.0 - tx_lat_deg)

        for pt in result["points"]:
            h = pt["height_km"]
            # Ground range from theta difference
            # Each step moves in theta; compute cumulative range
            r = earth_r + h
            points.append({
                "height_km": h,
                "t": pt["t"],
                "step": pt["step"],
            })

        rays.append(RayPath(
            elevation_deg=elev,
            azimuth_deg=azimuth_deg,
            max_height_km=result["max_height"],
            returned_to_ground=result["returned_to_ground"],
            n_steps=result["n_steps"],
            points=points,
        ))

    elapsed = (time.perf_counter() - t0) * 1000.0

    return FanResult(
        rays=rays,
        freq_mhz=freq_mhz,
        azimuth_deg=azimuth_deg,
        tx_lat_deg=tx_lat_deg,
        elapsed_ms=elapsed,
    )
