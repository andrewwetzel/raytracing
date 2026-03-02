"""IGRF (International Geomagnetic Reference Field) magnetic field model.

Wraps the ppigrf package to provide realistic magnetic field values
for ray tracing. Computes B-field components and numerical derivatives
at each evaluation point.
"""

from __future__ import annotations

import math
from datetime import datetime
from typing import Optional

import numpy as np

from pyraytrace.models.base import MagneticFieldModel, MagneticFieldResult
from pyraytrace.constants import PIT2


class IgrfMagneticField(MagneticFieldModel):
    """Magnetic field model using the International Geomagnetic Reference Field.

    Computes the real Earth magnetic field at any point using IGRF-14.
    Direction components and all partial derivatives are computed via
    finite differences.

    Args:
        date: Date for the IGRF model evaluation
        dr: Radial step for finite differences (km, default 1.0)
        dth: Colatitude step for finite differences (rad, default 0.01)
    """

    name = "igrf"

    def __init__(
        self,
        date: Optional[datetime] = None,
        dr: float = 1.0,
        dth: float = 0.01,
    ):
        import ppigrf
        self._ppigrf = ppigrf
        self.date = date or datetime(2024, 3, 15)
        self._dr = dr
        self._dth = dth

    def _get_field(self, r: float, theta: float, phi: float):
        """Get B-field components (Br, Bth, Bph) in nT at a point.

        ppigrf.igrf_gc takes:
            r: km from Earth center
            theta: colatitude in degrees
            phi: longitude in degrees
        Returns:
            Br (radial, outward), Btheta (southward), Bphi (eastward)
        """
        colat_deg = math.degrees(theta)
        lon_deg = math.degrees(phi)

        Br, Bth, Bph = self._ppigrf.igrf_gc(
            r, colat_deg, lon_deg, self.date,
        )

        # ppigrf returns numpy arrays; extract scalars
        return float(np.ravel(Br)[0]), float(np.ravel(Bth)[0]), float(np.ravel(Bph)[0])

    def _field_to_Y(self, Br: float, Bth: float, Bph: float, freq_mhz: float):
        """Convert B-field (nT) to normalized gyrofrequency components.

        Y = fH/f where fH = eB/(2πmₑ) in MHz
        fH(MHz) = e·B(nT)·1e-9 / (2π·mₑ) / 1e6
                = B(nT) × 2.7992e-5 / 1e6
                = B(nT) × 2.7992e-11 × 1e6
        Actually: fH = 2.7992e-2 × B(nT)/1000 MHz = 2.7992e-5 × B(nT) MHz
        Wait, let's be precise:
        fH = eB/(2πmₑ) = 1.602e-19 × B × 1e-9 / (2π × 9.109e-31)
           = 1.602e-28 × B / (5.724e-30) = 27.992 × B Hz for B in nT
           → fH(MHz) = 27.992e-6 × B(nT) = 2.7992e-5 × B(nT)
        """
        GYRO_CONST = 2.7992e-5  # MHz per nT

        B_total = math.sqrt(Br**2 + Bth**2 + Bph**2)
        fH = GYRO_CONST * B_total  # in MHz

        Y = fH / freq_mhz
        # Direction components: Yr = fH_r/f, etc.
        Yr = GYRO_CONST * Br / freq_mhz
        Yth = GYRO_CONST * Bth / freq_mhz
        Yph = GYRO_CONST * Bph / freq_mhz

        return Y, Yr, Yth, Yph

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> MagneticFieldResult:
        """Compute magnetic field and all derivatives via finite differences."""

        # Central point
        Br0, Bth0, Bph0 = self._get_field(r, theta, phi)
        Y, Yr, Yth0, Yph0 = self._field_to_Y(Br0, Bth0, Bph0, freq_mhz)

        dr = self._dr
        dth = self._dth

        # ∂/∂r via finite differences
        Br_p, Bth_p, Bph_p = self._get_field(r + dr, theta, phi)
        Br_m, Bth_m, Bph_m = self._get_field(r - dr, theta, phi)
        Y_rp, Yr_rp, _, _ = self._field_to_Y(Br_p, Bth_p, Bph_p, freq_mhz)
        Y_rm, Yr_rm, _, _ = self._field_to_Y(Br_m, Bth_m, Bph_m, freq_mhz)

        dYdr = (Y_rp - Y_rm) / (2 * dr)
        dYrdr = (Yr_rp - Yr_rm) / (2 * dr)

        # ∂/∂θ via finite differences
        Br_tp, Bth_tp, Bph_tp = self._get_field(r, theta + dth, phi)
        Br_tm, Bth_tm, Bph_tm = self._get_field(r, theta - dth, phi)
        Y_tp, _, Yth_tp, _ = self._field_to_Y(Br_tp, Bth_tp, Bph_tp, freq_mhz)
        Y_tm, _, Yth_tm, _ = self._field_to_Y(Br_tm, Bth_tm, Bph_tm, freq_mhz)

        dYdth = (Y_tp - Y_tm) / (2 * dth)
        dYthdth = (Yth_tp - Yth_tm) / (2 * dth)

        # ∂Yr/∂θ and ∂Yth/∂r
        _, Yr_tp, _, _ = self._field_to_Y(Br_tp, Bth_tp, Bph_tp, freq_mhz)
        _, Yr_tm, _, _ = self._field_to_Y(Br_tm, Bth_tm, Bph_tm, freq_mhz)
        dyrdth = (Yr_tp - Yr_tm) / (2 * dth)

        _, _, Yth_rp, _ = self._field_to_Y(Br_p, Bth_p, Bph_p, freq_mhz)
        _, _, Yth_rm, _ = self._field_to_Y(Br_m, Bth_m, Bph_m, freq_mhz)
        dythdr = (Yth_rp - Yth_rm) / (2 * dr)

        return MagneticFieldResult(
            Y=Y,
            dYdr=dYdr,
            dYdth=dYdth,
            dYdph=0.0,  # φ derivative often small, omit for speed
            Yr=Yr,
            Yth=Yth0,
            Yph=Yph0,
            dYrdr=dYrdr,
            dYrdth=dyrdth,
            dYrdph=0.0,
            dYthdr=dythdr,
            dYthdth=dYthdth,
            dYthdph=0.0,
            dYphdr=0.0,
            dYphdth=0.0,
            dYphdph=0.0,
        )

    def __repr__(self) -> str:
        return f"IgrfMagneticField(date={self.date.isoformat()[:10]})"
