"""Simulation runner and ray tracer.

Port of TRACE.f / NITIAL.f logic. Manages the high-level ray propagation
loop: initialization, integration stepping, ground reflection, receiver
crossing, and output collection.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Optional

from pyraytrace.constants import C, PIT2, PID2, RADIAN, EARTH_RADIUS
from pyraytrace.core.equations import (
    RayState, HamltnConfig, compute_derivatives,
)
from pyraytrace.core.integrator import (
    IntegratorState, init_integrator, integrator_step,
)
from pyraytrace.models.refractive_index import Ahwfwc


@dataclass
class RayPoint:
    """A single recorded point along the ray path."""
    step: int
    t: float
    height_km: float
    theta: float
    phi: float
    kr: float
    kth: float
    kph: float
    phase_path: float = 0.0
    absorption: float = 0.0
    event: str = ""


@dataclass
class RayResult:
    """Complete result of tracing one ray."""
    points: list[RayPoint] = field(default_factory=list)
    max_height: float = 0.0
    returned_to_ground: bool = False
    penetrated: bool = False
    final_state: Optional[RayState] = None
    n_steps: int = 0


@dataclass
class SimulationConfig:
    """Configuration for a ray tracing simulation."""
    # Transmitter
    earth_r: float = EARTH_RADIUS
    xmtr_height: float = 0.0
    tx_lat_deg: float = 40.0
    tx_lon_deg: float = -105.0

    # Ray parameters
    freq_mhz: float = 10.0
    ray_mode: float = -1.0    # +1 ordinary, -1 extraordinary
    elevation_deg: float = 20.0
    azimuth_deg: float = 45.0

    # Integration
    max_steps: int = 200
    int_mode: int = 3         # 1=RK, 2=RK+AM, 3=RK+AM+error
    step_size: float = 1.0
    e1max: float = 1.0e-4
    e1min: float = 2.0e-6
    e2max: float = 100.0
    e2min: float = 1.0e-8
    fact: float = 0.5

    # Output
    print_every: int = 10
    compute_phase_path: bool = True
    compute_absorption: bool = True

    # Model parameters (passed to models as dict)
    model_params: dict = field(default_factory=dict)


def run_ray(
    config: SimulationConfig,
    rindex_model: Ahwfwc,
) -> RayResult:
    """Trace a single ray through the ionosphere.

    Simplified port of NITIAL.f + TRACE.f flow.

    Args:
        config: Simulation configuration
        rindex_model: Refractive index model (with sub-models)

    Returns:
        RayResult with the ray path and diagnostics.
    """
    result = RayResult()

    # Build model params dict (merge defaults with overrides)
    w = {"earth_r": config.earth_r, **config.model_params}

    # Hamltn config
    hconfig = HamltnConfig(
        compute_phase_path=config.compute_phase_path,
        compute_absorption=config.compute_absorption,
    )
    nn = hconfig.n_equations

    # Initial ray state
    elev_rad = config.elevation_deg * RADIAN
    az_rad = config.azimuth_deg * RADIAN

    state = RayState(
        r=config.earth_r + config.xmtr_height,
        theta=PID2 - config.tx_lat_deg * RADIAN,  # colatitude
        phi=config.tx_lon_deg * RADIAN,
        kr=math.sin(elev_rad),
        kth=math.cos(elev_rad) * math.cos(math.pi - az_rad),
        kph=math.cos(elev_rad) * math.sin(math.pi - az_rad),
    )

    # Compute initial derivatives and rescale k-vector
    derivs, space, state = compute_derivatives(
        state, rindex_model, config.freq_mhz, config.ray_mode,
        w, hconfig, rstart=1.0,
    )

    # Record initial point
    result.points.append(RayPoint(
        step=0, t=0.0,
        height_km=state.r - config.earth_r,
        theta=state.theta, phi=state.phi,
        kr=state.kr, kth=state.kth, kph=state.kph,
        event="START",
    ))

    # Initialize integrator
    y0 = state.to_array(nn)
    int_state = init_integrator(
        y0=y0, t0=0.0, nn=nn,
        mode=config.int_mode, step=config.step_size,
        e1max=config.e1max, e1min=config.e1min,
        e2max=config.e2max, e2min=config.e2min,
        fact=config.fact,
    )

    # hamltn wrapper for the integrator
    def hamltn_fn(y: list[float], t: float, rstart: float) -> list[float]:
        s = RayState.from_array(y)
        derivs, _, _ = compute_derivatives(
            s, rindex_model, config.freq_mhz, config.ray_mode,
            w, hconfig, rstart=rstart,
        )
        return derivs

    # Compute initial derivatives for the integrator (rstart=0: k already rescaled)
    int_state.dydt = hamltn_fn(int_state.y, int_state.t, 0.0)
    for i in range(nn):
        int_state.fv[int_state.mm][i] = int_state.dydt[i]
        int_state.yu[int_state.mm][i] = int_state.y[i]
    int_state.rstart = 0.0

    went_up = False

    # Main integration loop
    for step_num in range(1, config.max_steps + 1):
        int_state = integrator_step(int_state, hamltn_fn)

        h_val = int_state.y[0] - config.earth_r
        result.max_height = max(result.max_height, h_val)

        if h_val > 10.0:
            went_up = True

        # Check for NaN
        if math.isnan(int_state.y[0]) or abs(h_val) > 50000.0:
            break

        # Record point
        event = ""
        if went_up and h_val < 0.0:
            event = "GROUND"
            result.returned_to_ground = True

        if step_num % config.print_every == 0 or event:
            phase = int_state.y[6] if nn > 6 else 0.0
            absorb = int_state.y[7] if nn > 7 else 0.0
            result.points.append(RayPoint(
                step=step_num, t=int_state.t,
                height_km=h_val,
                theta=int_state.y[1], phi=int_state.y[2],
                kr=int_state.y[3], kth=int_state.y[4], kph=int_state.y[5],
                phase_path=phase, absorption=absorb,
                event=event,
            ))

        if result.returned_to_ground:
            break

        # Check penetration
        if h_val > w.get("hmax", 500.0) and int_state.dydt[0] > 0:
            result.penetrated = True

    result.n_steps = step_num
    result.final_state = RayState.from_array(int_state.y)

    return result
