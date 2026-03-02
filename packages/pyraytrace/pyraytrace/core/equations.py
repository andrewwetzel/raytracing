"""Hamilton's equations for ionospheric ray tracing.

Port of HAMLTN.f. Computes the time derivatives of the ray state vector
(r, θ, φ, kr, kθ, kφ) plus optional auxiliary quantities (phase path,
absorption, Doppler shift, geometric path length).
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field

from pyraytrace.constants import C, PIT2, LOGTEN
from pyraytrace.models.refractive_index import Ahwfwc


@dataclass
class RayState:
    """Full ray state vector.

    Corresponds to R(1..20) in the Fortran COMMON block.
    """
    r: float        # R(1): radial distance (km)
    theta: float    # R(2): colatitude (radians)
    phi: float      # R(3): longitude (radians)
    kr: float       # R(4): radial wave vector component
    kth: float      # R(5): theta wave vector component
    kph: float      # R(6): phi wave vector component
    # Auxiliary integrated quantities (R(7..10))
    phase_path: float = 0.0
    absorption: float = 0.0
    doppler: float = 0.0
    geom_path: float = 0.0

    def to_array(self, n: int) -> list[float]:
        """Convert to flat list of first n components."""
        all_vals = [
            self.r, self.theta, self.phi,
            self.kr, self.kth, self.kph,
            self.phase_path, self.absorption,
            self.doppler, self.geom_path,
        ]
        return all_vals[:n]

    @classmethod
    def from_array(cls, arr: list[float]) -> "RayState":
        """Build from flat list."""
        return cls(
            r=arr[0], theta=arr[1], phi=arr[2],
            kr=arr[3], kth=arr[4], kph=arr[5],
            phase_path=arr[6] if len(arr) > 6 else 0.0,
            absorption=arr[7] if len(arr) > 7 else 0.0,
            doppler=arr[8] if len(arr) > 8 else 0.0,
            geom_path=arr[9] if len(arr) > 9 else 0.0,
        )


@dataclass
class HamltnConfig:
    """Configuration for which auxiliary quantities to integrate."""
    compute_phase_path: bool = True
    compute_absorption: bool = True
    compute_doppler: bool = False
    compute_geom_path: bool = False

    @property
    def n_equations(self) -> int:
        """Number of ODEs (6 base + optional auxiliaries)."""
        n = 6
        if self.compute_phase_path:
            n += 1
        if self.compute_absorption:
            n += 1
        if self.compute_doppler:
            n += 1
        if self.compute_geom_path:
            n += 1
        return n


def compute_derivatives(
    state: RayState,
    rindex_model: Ahwfwc,
    freq_mhz: float,
    ray_mode: float,
    w: dict,
    config: HamltnConfig,
    rstart: float = 0.0,
) -> tuple[list[float], bool, RayState]:
    """Compute Hamilton's equations for ray tracing.

    Port of HAMLTN.f subroutine.

    Args:
        state: Current ray state
        rindex_model: Refractive index model (with sub-models)
        freq_mhz: Wave frequency (MHz)
        ray_mode: +1 ordinary, -1 extraordinary
        w: Model configuration parameters
        config: Which auxiliary quantities to integrate
        rstart: Nonzero on first call (rescales k-vector)

    Returns:
        (derivatives, space_flag, updated_state)
        - derivatives: list of dr/dt values for each equation
        - space_flag: True if ray is in free space
        - updated_state: state with possibly rescaled k-vector (on first call)
    """
    om = PIT2 * 1.0e6 * freq_mhz
    sth = math.sin(state.theta)
    cth = math.cos(state.theta)

    rsth = state.r * sth
    rcth = state.r * cth

    # Compute refractive index and all Hamiltonian partials
    rindex_result, new_kr, new_kth, new_kph = rindex_model.compute(
        r=state.r, theta=state.theta, phi=state.phi,
        kr=state.kr, kth=state.kth, kph=state.kph,
        freq_mhz=freq_mhz, ray_mode=ray_mode, w=w,
        rstart=rstart,
    )

    # Update state if k-vector was rescaled
    updated_state = RayState(
        r=state.r, theta=state.theta, phi=state.phi,
        kr=new_kr, kth=new_kth, kph=new_kph,
        phase_path=state.phase_path, absorption=state.absorption,
        doppler=state.doppler, geom_path=state.geom_path,
    )

    ri = rindex_result

    # Use real parts of complex derivatives for integration
    phpom = ri.dHdom.real if isinstance(ri.dHdom, complex) else ri.dHdom
    phpkr = ri.dHdkr.real if isinstance(ri.dHdkr, complex) else ri.dHdkr
    phpkth = ri.dHdkth.real if isinstance(ri.dHdkth, complex) else ri.dHdkth
    phpkph = ri.dHdkph.real if isinstance(ri.dHdkph, complex) else ri.dHdkph
    phpr = ri.dHdr.real if isinstance(ri.dHdr, complex) else ri.dHdr
    phpth = ri.dHdth.real if isinstance(ri.dHdth, complex) else ri.dHdth
    phpph = ri.dHdph.real if isinstance(ri.dHdph, complex) else ri.dHdph
    phpt = ri.dHdt.real if isinstance(ri.dHdt, complex) else ri.dHdt

    kr = updated_state.kr
    kth = updated_state.kth
    kph = updated_state.kph

    # Hamilton's equations (6 core ODEs)
    drdt = -phpkr / (phpom * C) if phpom != 0.0 else 0.0
    dthdt = -phpkth / (phpom * state.r * C) if (phpom != 0.0 and state.r != 0.0) else 0.0
    dphdt = -phpkph / (phpom * rsth * C) if (phpom != 0.0 and rsth != 0.0) else 0.0

    dkrdt = phpr / (phpom * C) + kth * dthdt + kph * sth * dphdt if phpom != 0.0 else 0.0
    dkthdt = (phpth / (phpom * C) - (kth * drdt + kph * rcth * dphdt) / state.r
              if (phpom != 0.0 and state.r != 0.0) else 0.0)
    dkphdt_val = phpph / (phpom * C) - kph * sth * drdt / rsth if (phpom != 0.0 and rsth != 0.0) else 0.0
    dkphdt_val -= kph * rcth * dthdt / rsth if rsth != 0.0 else 0.0

    derivatives = [drdt, dthdt, dphdt, dkrdt, dkthdt, dkphdt_val]

    # Auxiliary quantities
    nr = 6

    # Phase path
    if config.compute_phase_path:
        nr += 1
        kphpk_r = ri.kphpk.real if isinstance(ri.kphpk, complex) else ri.kphpk
        d_phase = kphpk_r / phpom / om if phpom != 0.0 else 0.0
        derivatives.append(d_phase)

    # Absorption
    if config.compute_absorption:
        nr += 1
        kphpki = ri.kphpk.imag if isinstance(ri.kphpk, complex) else 0.0
        k2 = kr * kr + kth * kth + kph * kph
        if phpom != 0.0 and k2 != 0.0:
            kay2i = (om * om / (C * C) * ri.n_squared).imag
            d_absorb = (10.0 / LOGTEN * kphpki * kay2i
                        / k2 / phpom / C)
        else:
            d_absorb = 0.0
        derivatives.append(d_absorb)

    # Doppler shift
    if config.compute_doppler:
        nr += 1
        d_doppler = -phpt / phpom / C / PIT2 if phpom != 0.0 else 0.0
        derivatives.append(d_doppler)

    # Geometric path length
    if config.compute_geom_path:
        nr += 1
        d_geom = (math.sqrt(phpkr ** 2 + phpkth ** 2 + phpkph ** 2) / phpom
                   if phpom != 0.0 else 0.0)
        derivatives.append(d_geom)

    return derivatives, rindex_result.space, updated_state
