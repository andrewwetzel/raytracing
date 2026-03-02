"""Runge-Kutta / Adams-Moulton numerical integrator.

Port of RKAM.f. Implements a 4th-order Runge-Kutta starter transitioning
to a 4th-order Adams-Moulton predictor-corrector with adaptive step-size
control.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable

import copy


@dataclass
class IntegratorState:
    """State of the RKAM integrator.

    Maintains the multi-step history required for Adams-Moulton,
    corresponding to the SAVE'd arrays in RKAM.f.
    """
    # Integration parameters
    nn: int = 6              # Number of equations
    mode: int = 3            # 1=RK only, 2=RK+AM, 3=RK+AM+error control
    e1max: float = 1.0e-4    # Max error tolerance
    e1min: float = 2.0e-6    # Min error (below = try doubling step)
    e2max: float = 100.0     # Max step size
    e2min: float = 1.0e-8    # Min step size
    fact: float = 0.5        # Step reduction factor
    step: float = 1.0        # Current step size

    # Internal state
    t: float = 0.0           # Current time
    alpha: float = 0.0       # Starting time
    epm: float = 0.0         # Max |t - alpha| seen
    ll: int = 1              # State flag (1=starting, 2=running)
    mm: int = 1              # History index
    rstart: float = 1.0      # Nonzero = starting/restart

    # Multi-step history: YU[step][eq], FV[step][eq], XV[step]
    yu: list[list[float]] = field(default_factory=list)
    fv: list[list[float]] = field(default_factory=list)
    xv: list[float] = field(default_factory=lambda: [0.0] * 6)

    # Current y and derivatives
    y: list[float] = field(default_factory=list)
    dydt: list[float] = field(default_factory=list)


def init_integrator(
    y0: list[float],
    t0: float,
    nn: int,
    mode: int = 3,
    step: float = 1.0,
    e1max: float = 1.0e-4,
    e1min: float = 2.0e-6,
    e2max: float = 100.0,
    e2min: float = 1.0e-8,
    fact: float = 0.5,
) -> IntegratorState:
    """Initialize the integrator state.

    Corresponds to the RSTART != 0 branch of RKAM.f.
    """
    state = IntegratorState(
        nn=nn, mode=mode, step=step,
        e1max=e1max, e1min=e1min, e2max=e2max, e2min=e2min, fact=fact,
        t=t0, alpha=t0, epm=0.0, ll=1, rstart=1.0,
    )

    if e1min <= 0.0:
        state.e1min = e1max / 55.0
    if fact <= 0.0:
        state.fact = 0.5

    state.mm = 1
    if mode == 1:
        state.mm = 4

    # Initialize history arrays (5 slots × nn equations)
    state.yu = [[0.0] * nn for _ in range(6)]
    state.fv = [[0.0] * nn for _ in range(6)]
    state.xv = [0.0] * 6

    state.y = list(y0[:nn])
    state.dydt = [0.0] * nn

    state.xv[state.mm] = t0

    return state


def integrator_step(
    state: IntegratorState,
    hamltn_fn: Callable[[list[float], float, float], list[float]],
) -> IntegratorState:
    """Perform one integration step.

    Port of the main RKAM.f logic. Calls hamltn_fn to compute derivatives.

    Args:
        state: Current integrator state
        hamltn_fn: Function(y, t, rstart) → derivatives list[float]
                   Also receives rstart (nonzero on first/restart calls).

    Returns:
        Updated integrator state after one step.
    """
    s = state  # shorthand
    nn = s.nn

    # --- INITIALIZATION (first call) ---
    if s.rstart != 0.0:
        s.step = s.step  # keep current step
        s.xv[s.mm] = s.t

        # Compute initial derivatives
        s.dydt = hamltn_fn(s.y, s.t, s.rstart)

        for i in range(nn):
            s.fv[s.mm][i] = s.dydt[i]
            s.yu[s.mm][i] = s.y[i]

        s.rstart = 0.0
        # Fall through to RK

    # --- RUNGE-KUTTA (mode 1, or startup for modes 2-3) ---
    if s.mm < 4 or s.mode == 1:
        return _runge_kutta_step(s, hamltn_fn)

    # --- ADAMS-MOULTON (modes 2-3, after 4 points) ---
    return _adams_moulton_step(s, hamltn_fn)


def _runge_kutta_step(
    s: IntegratorState,
    hamltn_fn: Callable,
) -> IntegratorState:
    """RK4 step — either standalone (mode 1) or as starter (modes 2-3)."""
    nn = s.nn
    bet = [0.5, 0.5, 1.0, 0.0]
    dely = [[0.0] * nn for _ in range(4)]

    # 4 stages of RK4
    for k in range(4):
        for i in range(nn):
            dely[k][i] = s.step * s.fv[s.mm][i]
            s.y[i] = s.yu[s.mm][i] + bet[k] * dely[k][i]

        s.t = bet[k] * s.step + s.xv[s.mm]
        s.dydt = hamltn_fn(s.y, s.t, 0.0)

        for i in range(nn):
            s.fv[s.mm][i] = s.dydt[i]

    # Combine RK4 result
    for i in range(nn):
        delta = (dely[0][i] + 2.0 * dely[1][i]
                 + 2.0 * dely[2][i] + dely[3][i]) / 6.0
        s.yu[s.mm + 1][i] = s.yu[s.mm][i] + delta

    s.mm += 1
    s.xv[s.mm] = s.xv[s.mm - 1] + s.step

    for i in range(nn):
        s.y[i] = s.yu[s.mm][i]

    s.t = s.xv[s.mm]
    s.dydt = hamltn_fn(s.y, s.t, 0.0)

    if s.mode == 1:
        # RK-only mode: exit
        return _exit_routine(s)

    for i in range(nn):
        s.fv[s.mm][i] = s.dydt[i]

    if s.mm <= 3:
        # Need more RK steps to build history
        return _runge_kutta_step(s, hamltn_fn)

    # Have 4 points, switch to Adams-Moulton
    return _adams_moulton_step(s, hamltn_fn)


def _adams_moulton_step(
    s: IntegratorState,
    hamltn_fn: Callable,
) -> IntegratorState:
    """Adams-Moulton predictor-corrector step."""
    nn = s.nn
    dely1 = [0.0] * nn

    # Predictor (Adams-Bashforth)
    for i in range(nn):
        delta = s.step * (
            55.0 * s.fv[4][i] - 59.0 * s.fv[3][i]
            + 37.0 * s.fv[2][i] - 9.0 * s.fv[1][i]
        ) / 24.0
        s.y[i] = s.yu[4][i] + delta
        dely1[i] = s.y[i]

    s.t = s.xv[4] + s.step
    s.dydt = hamltn_fn(s.y, s.t, 0.0)
    s.xv[5] = s.t

    # Corrector (Adams-Moulton)
    for i in range(nn):
        delta = s.step * (
            9.0 * s.dydt[i] + 19.0 * s.fv[4][i]
            - 5.0 * s.fv[3][i] + s.fv[2][i]
        ) / 24.0
        s.yu[5][i] = s.yu[4][i] + delta
        s.y[i] = s.yu[5][i]

    s.dydt = hamltn_fn(s.y, s.t, 0.0)

    if s.mode <= 2:
        return _exit_routine(s)

    # --- ERROR ANALYSIS (mode 3) ---
    sse = 0.0
    for i in range(nn):
        epsil = 8.0 * abs(s.y[i] - dely1[i])
        if s.mode == 3 and abs(s.y[i]) > 1.0e-8:
            # Relative error, but only when |y| is large enough to be meaningful.
            # The Fortran used float32 where rounding noise didn't affect tiny values.
            epsil = epsil / abs(s.y[i])
        sse = max(sse, epsil)

    if s.e1max <= sse:
        # Error too large: halve step and restart RK
        if abs(s.step) <= s.e2min:
            return _exit_routine(s)
        s.ll = 1
        s.mm = 1
        s.step = s.step * s.fact
        return _runge_kutta_step(s, hamltn_fn)

    if s.ll <= 1 or sse >= s.e1min or s.e2max <= abs(s.step):
        return _exit_routine(s)

    # Error small enough: try doubling step
    s.ll = 2
    s.mm = 3
    s.xv[2] = s.xv[3]
    s.xv[3] = s.xv[5]

    for i in range(nn):
        s.fv[2][i] = s.fv[3][i]
        s.fv[3][i] = s.dydt[i]
        s.yu[2][i] = s.yu[3][i]
        s.yu[3][i] = s.yu[5][i]

    s.step = 2.0 * s.step
    return _runge_kutta_step(s, hamltn_fn)


def _exit_routine(s: IntegratorState) -> IntegratorState:
    """Shift history and prepare for next step."""
    nn = s.nn
    s.ll = 2
    s.mm = 4

    # Shift history: slots 2→1, 3→2, 4→3
    for k in range(1, 4):
        s.xv[k] = s.xv[k + 1]
        for i in range(nn):
            s.fv[k][i] = s.fv[k + 1][i]
            s.yu[k][i] = s.yu[k + 1][i]

    # Store current result in slot 4
    s.xv[4] = s.xv[5]
    for i in range(nn):
        s.fv[4][i] = s.dydt[i]
        s.yu[4][i] = s.yu[5][i]

    if s.mode <= 2:
        return s

    # Update max distance
    e = abs(s.xv[4] - s.alpha)
    if e <= s.epm:
        # Rollback and try Adams-Moulton again (recursive step)
        pass
    s.epm = e

    return s
