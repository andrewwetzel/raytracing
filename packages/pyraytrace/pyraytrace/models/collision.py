"""Collision frequency models.

Each model computes the normalized collision frequency Z = ν/ω and its
partial derivatives.

Direct ports of the Fortran COLFRZ-entry subroutines.
"""

from __future__ import annotations

import math

from pyraytrace.constants import PIT2, EARTH_RADIUS
from pyraytrace.models.base import CollisionModel, CollisionResult


class Expz2(CollisionModel):
    """Two-term exponential collision frequency model.

    Port of EXPZ2.f. Sum of two exponential profiles:
        ν(h) = ν₁·exp(-a₁·(h-h₁)) + ν₂·exp(-a₂·(h-h₂))

    Parameters:
        nu1 (w251): Collision frequency at height h1 (/sec)
        h1 (w252): Reference height for first term (km)
        a1 (w253): Exponential decay rate for first term (/km)
        nu2 (w254): Collision frequency for second term (/sec)
        h2 (w255): Reference height for second term (km)
        a2 (w256): Exponential decay rate for second term (/km)
    """

    name = "expz2"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> CollisionResult:
        nu1 = w.get("nu1", 1.05e6)
        h1 = w.get("h1", 100.0)
        a1 = w.get("a1", 0.148)
        nu2 = w.get("nu2", 30.0)
        h2 = w.get("h2", 140.0)
        a2 = w.get("a2", 0.0183)
        earth_r = w.get("earth_r", EARTH_RADIUS)

        h = r - earth_r
        omega = PIT2 * freq_mhz * 1.0e6

        exp1 = nu1 * math.exp(-a1 * (h - h1))
        exp2 = nu2 * math.exp(-a2 * (h - h2))

        Z = (exp1 + exp2) / omega
        dZdr = (-a1 * exp1 - a2 * exp2) / omega

        return CollisionResult(Z=Z, dZdr=dZdr, dZdth=0.0, dZdph=0.0)


class Constz(CollisionModel):
    """Constant collision frequency model.

    Port of CONSTZ.f.

    Parameters:
        nu (w251): Collision frequency (/sec)
    """

    name = "constz"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> CollisionResult:
        nu = w.get("nu", 0.0)
        omega = PIT2 * freq_mhz * 1.0e6

        Z = nu / omega if omega != 0.0 else 0.0

        return CollisionResult(Z=Z, dZdr=0.0, dZdth=0.0, dZdph=0.0)


class Expz(CollisionModel):
    """Single exponential collision frequency model.

    Port of EXPZ.f.
        ν(h) = ν₁·exp(-a₁·(h-h₁))

    Parameters:
        nu1 (w251): Collision frequency at height h1 (/sec)
        h1 (w252): Reference height (km)
        a1 (w253): Exponential decay rate (/km)
    """

    name = "expz"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> CollisionResult:
        nu1 = w.get("nu1", 1.05e6)
        h1 = w.get("h1", 100.0)
        a1 = w.get("a1", 0.148)
        earth_r = w.get("earth_r", EARTH_RADIUS)

        h = r - earth_r
        omega = PIT2 * freq_mhz * 1.0e6

        exp1 = nu1 * math.exp(-a1 * (h - h1))

        Z = exp1 / omega
        dZdr = -a1 * exp1 / omega

        return CollisionResult(Z=Z, dZdr=dZdr, dZdth=0.0, dZdph=0.0)
