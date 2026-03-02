"""HF propagation analysis tools.

Provides three key capabilities built on the Rust ray tracing engine:
1. Homing — find the elevation angle that connects TX to a target range
2. MUF/LUF — find Maximum/Lowest Usable Frequencies for a given path
3. Coverage — map ground coverage by sweeping elevation and azimuth
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Optional

import numpy as np


# ============================================================
# Shared Rust tracer wrapper
# ============================================================

def _trace_one(
    freq_mhz: float, elev: float, azimuth: float = 0.0,
    ray_mode: float = -1.0, tx_lat: float = 40.0,
    fc: float = 10.0, hm: float = 250.0, sh: float = 100.0,
    fh: float = 0.8, step_size: float = 5.0, max_steps: int = 500,
) -> dict:
    """Trace a single ray via Rust engine. Returns the result dict."""
    import raytrace_core
    return raytrace_core.trace_ray_py(
        freq_mhz=freq_mhz, ray_mode=ray_mode,
        elevation_deg=elev, azimuth_deg=azimuth,
        tx_lat_deg=tx_lat, int_mode=2, step_size=step_size,
        max_steps=max_steps, e1max=1e-4, e1min=2e-6, e2max=100.0,
        earth_r=6370.0,
        fc=fc, hm=hm, sh=sh, alpha=0.5,
        ed_a=0.0, ed_b=0.0, ed_c=0.0, ed_e=0.0,
        fh=fh,
        nu1=1050000.0, h1=100.0, a1=0.148,
        nu2=30.0, h2=140.0, a2=0.0183,
        print_every=1,
    )


def _ground_range(result: dict) -> Optional[float]:
    """Extract ground range (km) from a ray that returned to ground.

    Uses the last point's group path (t) as approximation of ground range.
    Returns None if ray didn't return.
    """
    if not result["returned_to_ground"]:
        return None
    pts = result["points"]
    if not pts:
        return None
    return pts[-1]["t"]


# ============================================================
# 1. Homing — find elevation for a target ground range
# ============================================================

@dataclass
class HomingResult:
    """Result of a homing search."""
    elevation_deg: float
    ground_range_km: float
    max_height_km: float
    n_iterations: int
    converged: bool
    error_km: float  # |actual - target| range


def find_elevation(
    target_range_km: float,
    freq_mhz: float = 10.0,
    azimuth_deg: float = 0.0,
    ray_mode: float = -1.0,
    tx_lat: float = 40.0,
    fc: float = 10.0,
    hm: float = 250.0,
    sh: float = 100.0,
    fh: float = 0.8,
    elev_min: float = 1.0,
    elev_max: float = 85.0,
    tolerance_km: float = 5.0,
    max_iter: int = 50,
) -> HomingResult:
    """Find the elevation angle that produces a given ground range.

    Phase 1: Coarse scan (2° steps) to find bracket where range crosses target.
    Phase 2: Bisection within the bracket to refine.

    Range vs elevation is non-monotonic (skip zone), so we scan to find
    the best crossing point.
    """
    kwargs = dict(
        freq_mhz=freq_mhz, azimuth=azimuth_deg,
        ray_mode=ray_mode, tx_lat=tx_lat,
        fc=fc, hm=hm, sh=sh, fh=fh,
    )

    # Phase 1: Coarse scan
    scan_step = 2.0
    prev_elev, prev_range = None, None
    best_elev, best_range, best_height = elev_min, 0.0, 0.0
    best_error = float('inf')
    bracket = None
    iters = 0

    elev = elev_min
    while elev <= elev_max:
        result = _trace_one(elev=elev, **kwargs)
        iters += 1
        gr = _ground_range(result)

        if gr is not None:
            error = abs(gr - target_range_km)
            if error < best_error:
                best_error = error
                best_elev = elev
                best_range = gr
                best_height = result["max_height"]

            if error < tolerance_km:
                return HomingResult(
                    elevation_deg=round(elev, 2),
                    ground_range_km=round(gr, 1),
                    max_height_km=round(result["max_height"], 1),
                    n_iterations=iters, converged=True,
                    error_km=round(error, 1),
                )

            # Check for bracket (range crosses target between prev and current)
            if prev_range is not None and bracket is None:
                if (prev_range - target_range_km) * (gr - target_range_km) < 0:
                    bracket = (prev_elev, elev)

            prev_elev, prev_range = elev, gr

        elev += scan_step

    # Phase 2: Bisection within bracket (if found)
    if bracket:
        lo, hi = bracket
        for _ in range(max_iter - iters):
            mid = (lo + hi) / 2
            result = _trace_one(elev=mid, **kwargs)
            iters += 1
            gr = _ground_range(result)

            if gr is None:
                hi = mid
                continue

            error = abs(gr - target_range_km)
            if error < best_error:
                best_error = error
                best_elev = mid
                best_range = gr
                best_height = result["max_height"]

            if error < tolerance_km:
                return HomingResult(
                    elevation_deg=round(mid, 2),
                    ground_range_km=round(gr, 1),
                    max_height_km=round(result["max_height"], 1),
                    n_iterations=iters, converged=True,
                    error_km=round(error, 1),
                )

            # Determine direction based on bracket endpoints
            lo_result = _trace_one(elev=lo, **kwargs)
            lo_gr = _ground_range(lo_result)
            if lo_gr and (lo_gr - target_range_km) * (gr - target_range_km) < 0:
                hi = mid
            else:
                lo = mid

    return HomingResult(
        elevation_deg=round(best_elev, 2),
        ground_range_km=round(best_range, 1),
        max_height_km=round(best_height, 1),
        n_iterations=iters, converged=best_error < tolerance_km,
        error_km=round(best_error, 1),
    )


# ============================================================
# 2. MUF / LUF — frequency sweep for a path
# ============================================================

@dataclass
class FrequencyAnalysis:
    """Result of MUF/LUF analysis for a given path."""
    muf_mhz: Optional[float]       # Maximum usable frequency (highest that returns)
    luf_mhz: Optional[float]       # Lowest usable frequency (lowest that returns)
    optimal_mhz: Optional[float]   # 85% of MUF (standard operating frequency)
    results: list[dict]             # Per-frequency results


def analyze_frequencies(
    elevation_deg: float = 20.0,
    azimuth_deg: float = 0.0,
    ray_mode: float = -1.0,
    tx_lat: float = 40.0,
    fc: float = 10.0,
    hm: float = 250.0,
    sh: float = 100.0,
    fh: float = 0.8,
    freq_min: float = 2.0,
    freq_max: float = 30.0,
    freq_step: float = 0.5,
) -> FrequencyAnalysis:
    """Sweep frequencies to find MUF and LUF for a given path.

    Traces rays at each frequency and checks if they return to ground.
    MUF = highest frequency that still returns.
    LUF = lowest frequency that returns (below this, absorption is too high).

    Args:
        elevation_deg: Fixed elevation angle
        freq_min/max/step: Frequency sweep range in MHz

    Returns:
        FrequencyAnalysis with MUF, LUF, and per-frequency data
    """
    freqs = list(np.arange(freq_min, freq_max + 0.01, freq_step))
    results = []
    returning_freqs = []

    for f in freqs:
        result = _trace_one(
            freq_mhz=f, elev=elevation_deg, azimuth=azimuth_deg,
            ray_mode=ray_mode, tx_lat=tx_lat,
            fc=fc, hm=hm, sh=sh, fh=fh,
        )

        gr = _ground_range(result)
        entry = {
            "freq_mhz": round(f, 1),
            "ground_return": result["returned_to_ground"],
            "max_height_km": round(result["max_height"], 1),
            "ground_range_km": round(gr, 1) if gr else None,
        }
        results.append(entry)

        if result["returned_to_ground"]:
            returning_freqs.append(f)

    muf = max(returning_freqs) if returning_freqs else None
    luf = min(returning_freqs) if returning_freqs else None
    optimal = round(muf * 0.85, 1) if muf else None

    return FrequencyAnalysis(
        muf_mhz=round(muf, 1) if muf else None,
        luf_mhz=round(luf, 1) if luf else None,
        optimal_mhz=optimal,
        results=results,
    )


# ============================================================
# 3. Coverage mapping — elevation × azimuth sweep
# ============================================================

@dataclass
class CoveragePoint:
    """One point in a coverage map."""
    elevation_deg: float
    azimuth_deg: float
    ground_range_km: Optional[float]
    max_height_km: float
    returned: bool


@dataclass
class CoverageMap:
    """Full coverage map result."""
    points: list[CoveragePoint]
    freq_mhz: float
    n_rays: int
    elapsed_ms: float


def compute_coverage(
    freq_mhz: float = 10.0,
    ray_mode: float = -1.0,
    tx_lat: float = 40.0,
    fc: float = 10.0,
    hm: float = 250.0,
    sh: float = 100.0,
    fh: float = 0.8,
    elev_min: float = 5.0,
    elev_max: float = 60.0,
    elev_step: float = 2.0,
    az_min: float = 0.0,
    az_max: float = 360.0,
    az_step: float = 15.0,
) -> CoverageMap:
    """Compute ground coverage by sweeping elevation and azimuth.

    For each (elevation, azimuth) pair, traces a ray and records
    where it lands. This produces a polar coverage map.

    Args:
        elev_min/max/step: Elevation sweep (degrees)
        az_min/max/step: Azimuth sweep (degrees)

    Returns:
        CoverageMap with all traced points
    """
    import time
    t0 = time.perf_counter()

    elevations = list(np.arange(elev_min, elev_max + 0.01, elev_step))
    azimuths = list(np.arange(az_min, az_max, az_step))
    points = []

    for az in azimuths:
        for elev in elevations:
            result = _trace_one(
                freq_mhz=freq_mhz, elev=elev, azimuth=az,
                ray_mode=ray_mode, tx_lat=tx_lat,
                fc=fc, hm=hm, sh=sh, fh=fh,
            )

            gr = _ground_range(result)
            points.append(CoveragePoint(
                elevation_deg=round(elev, 1),
                azimuth_deg=round(az, 1),
                ground_range_km=round(gr, 1) if gr else None,
                max_height_km=round(result["max_height"], 1),
                returned=result["returned_to_ground"],
            ))

    elapsed = (time.perf_counter() - t0) * 1000.0

    return CoverageMap(
        points=points,
        freq_mhz=freq_mhz,
        n_rays=len(points),
        elapsed_ms=round(elapsed, 1),
    )
