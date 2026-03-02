"""IRI (International Reference Ionosphere) electron density model.

Wraps the PyIRI package to provide realistic electron density profiles
for ray tracing. Pre-computes a Ne(altitude) profile on initialization,
then uses cubic spline interpolation during ray tracing.
"""

from __future__ import annotations

import math
from typing import Optional

import numpy as np
from scipy.interpolate import CubicSpline

from pyraytrace.models.base import ElectronDensityModel, ElectronDensityResult
from pyraytrace.constants import EARTH_RADIUS


class IriElectronDensity(ElectronDensityModel):
    """Electron density model using the International Reference Ionosphere.

    On initialization, computes a full Ne(altitude) profile using PyIRI
    for the specified date/time/location. During ray tracing, evaluates
    X = (fp/f)² via spline interpolation.

    Args:
        year: Year (e.g. 2024)
        month: Month (1-12)
        day: Day of month (1-31)
        hour_ut: Hour in Universal Time (0-24, float)
        lat: Geographic latitude (degrees, -90 to 90)
        lon: Geographic longitude (degrees, -180 to 180)
        f107: F10.7 solar flux index (default 150, typical solar max)
        alt_min: Minimum altitude for profile (km, default 60)
        alt_max: Maximum altitude for profile (km, default 1000)
        alt_step: Altitude step for profile (km, default 5)
    """

    name = "iri"

    def __init__(
        self,
        year: int = 2024,
        month: int = 3,
        day: int = 15,
        hour_ut: float = 14.0,
        lat: float = 40.0,
        lon: float = -105.0,
        f107: float = 150.0,
        alt_min: float = 60.0,
        alt_max: float = 1000.0,
        alt_step: float = 5.0,
    ):
        import PyIRI.sh_library as sh

        self.year = year
        self.month = month
        self.day = day
        self.hour_ut = hour_ut
        self.lat = lat
        self.lon = lon
        self.f107 = f107

        # Build altitude grid
        self._alts = np.arange(alt_min, alt_max + alt_step, alt_step)

        # Compute electron density profile via PyIRI
        aUT = np.array([hour_ut])
        alon = np.array([lon])
        alat = np.array([lat])

        F2, F1, E, sun, mag, EDP = sh.IRI_density_1day(
            year, month, day, aUT, alon, alat, self._alts, f107,
        )

        # EDP shape: (n_UT, n_alt, n_loc) — extract our single profile
        self._ne_profile = EDP[0, :, 0]  # Ne in electrons/m³

        # Compute plasma frequency squared: fp² = Ne·e²/(4π²ε₀mₑ)
        # fp² in Hz² = Ne × 80.6164 (SI constant)
        # X = (fp/f)² — we store fp² in MHz² for convenience
        # fp²(MHz²) = Ne × 80.6164e-12
        self._fp2_mhz2 = self._ne_profile * 80.6164e-12

        # Build cubic splines of fp² vs altitude
        self._spline_fp2 = CubicSpline(
            self._alts, self._fp2_mhz2, bc_type="natural",
        )

        # Store IRI layer parameters for info
        self.foF2 = float(F2["fo"].ravel()[0])
        self.hmF2 = float(F2["hm"].ravel()[0])

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> ElectronDensityResult:
        """Compute X = (fp/f)² and dX/dr from the IRI profile."""
        h = r - w.get("earth_r", EARTH_RADIUS)

        # Clamp to profile range
        alt_min = float(self._alts[0])
        alt_max = float(self._alts[-1])

        if h < alt_min or h > alt_max:
            return ElectronDensityResult(
                X=0.0, dXdr=0.0, dXdth=0.0, dXdph=0.0, dXdt=0.0,
                hmax=self.hmF2,
            )

        # Evaluate spline
        f2 = freq_mhz * freq_mhz
        fp2 = float(self._spline_fp2(h))
        dfp2_dh = float(self._spline_fp2(h, 1))  # first derivative

        X = fp2 / f2
        dXdr = dfp2_dh / f2  # dh/dr = 1

        return ElectronDensityResult(
            X=X,
            dXdr=dXdr,
            dXdth=0.0,   # Horizontal gradients assumed zero (single-profile)
            dXdph=0.0,
            dXdt=0.0,
            hmax=self.hmF2,
        )

    def __repr__(self) -> str:
        return (
            f"IriElectronDensity({self.year}-{self.month:02d}-{self.day:02d} "
            f"{self.hour_ut:.1f}UT, {self.lat}°N {self.lon}°E, "
            f"F10.7={self.f107}, foF2={self.foF2:.2f} MHz, hmF2={self.hmF2:.0f} km)"
        )
