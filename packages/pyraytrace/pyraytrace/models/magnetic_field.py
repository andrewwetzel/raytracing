"""Magnetic field models.

Each model computes the normalized gyrofrequency Y = fH/f and its
partial derivatives, plus direction components needed for the wave-field
angle calculation in the refractive index.

Direct ports of the Fortran MAGY-entry subroutines.
"""

from __future__ import annotations

import math

from pyraytrace.constants import PID2, EARTH_RADIUS
from pyraytrace.models.base import MagneticFieldModel, MagneticFieldResult


class Dipoly(MagneticFieldModel):
    """Dipole magnetic field model.

    Port of DIPOLY.f. Earth's magnetic field approximated as a centered
    dipole aligned with the rotation axis.

    Parameters:
        fh (w201): Equatorial gyrofrequency at Earth's surface (MHz)
    """

    name = "dipoly"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> MagneticFieldResult:
        fh = w.get("fh", 0.8)
        earth_r = w.get("earth_r", EARTH_RADIUS)

        sinth = math.sin(theta)
        costh = math.cos(theta)
        term9 = math.sqrt(1.0 + 3.0 * costh ** 2)

        t1 = fh * (earth_r / r) ** 3 / freq_mhz

        Y = t1 * term9
        Yr = 2.0 * t1 * costh
        Yth = t1 * sinth

        dYrdr = -3.0 * Yr / r
        dYrdth = -2.0 * Yth
        dYthdr = -3.0 * Yth / r
        dYthdth = 0.5 * Yr

        dYdr = -3.0 * Y / r
        dYdth = -3.0 * Y * sinth * costh / (term9 ** 2)

        return MagneticFieldResult(
            Y=Y, dYdr=dYdr, dYdth=dYdth, dYdph=0.0,
            Yr=Yr, Yth=Yth, Yph=0.0,
            dYrdr=dYrdr, dYrdth=dYrdth, dYrdph=0.0,
            dYthdr=dYthdr, dYthdth=dYthdth, dYthdph=0.0,
            dYphdr=0.0, dYphdth=0.0, dYphdph=0.0,
        )


class Consty(MagneticFieldModel):
    """Constant magnetic field model.

    Port of CONSTY.f. Magnetic field with constant magnitude, directed
    along the local vertical (r-direction).
    """

    name = "consty"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> MagneticFieldResult:
        fh = w.get("fh", 0.8)

        Y = fh / freq_mhz
        Yr = Y  # field along radial

        return MagneticFieldResult(
            Y=Y, dYdr=0.0, dYdth=0.0, dYdph=0.0,
            Yr=Yr, Yth=0.0, Yph=0.0,
            dYrdr=0.0, dYrdth=0.0, dYrdph=0.0,
            dYthdr=0.0, dYthdth=0.0, dYthdph=0.0,
            dYphdr=0.0, dYphdth=0.0, dYphdph=0.0,
        )
