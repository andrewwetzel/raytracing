"""Electron density models.

Each model computes the normalized electron density X = (fp/f)² and its
partial derivatives with respect to position (r, θ, φ).

Direct ports of the Fortran ELECTX-entry subroutines.
"""

from __future__ import annotations

import math

from pyraytrace.constants import PIT2, PID2, EARTH_RADIUS
from pyraytrace.models.base import ElectronDensityModel, ElectronDensityResult


class Chapx(ElectronDensityModel):
    """Chapman layer electron density model.

    Port of CHAPX.f. The Chapman function describes a layer whose electron
    density profile depends on the scale height and a Chapman exponent α.

    W-array parameters (dict keys):
        fc (w101): Critical frequency (MHz)
        hm (w102): Height of maximum electron density (km)
        sh (w103): Scale height (km)
        alpha (w104): Chapman exponent (typically 0.5)
        a (w105): Latitude variation coefficient
        b (w106): Period parameter for latitude variation
        c_coeff (w107): Latitude variation coefficient
        e (w108): Tilt parameter
    """

    name = "chapx"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> ElectronDensityResult:
        fc = w.get("fc", 10.0)
        hm = w.get("hm", 250.0)
        sh = w.get("sh", 100.0)
        alpha = w.get("alpha", 0.5)
        a = w.get("a", 0.0)
        b = w.get("b", 0.0)
        c_coeff = w.get("c_coeff", 0.0)
        e = w.get("e", 0.0)
        earth_r = w.get("earth_r", EARTH_RADIUS)

        theta2 = theta - PID2
        hmax = hm + earth_r * e * theta2
        h = r - earth_r
        z = (h - hmax) / sh

        d = 0.0
        if b != 0.0:
            d = PIT2 / b

        temp = 1.0 + a * math.sin(d * theta2) + c_coeff * theta2
        exz = 1.0 - math.exp(-z)

        X = (fc / freq_mhz) ** 2 * temp * math.exp(alpha * (exz - z))

        dXdr = -alpha * X * exz / sh

        dXdth = X * (d * a * math.sin(PID2 - d * theta2) + c_coeff) / temp
        dXdth -= dXdr * earth_r * e

        return ElectronDensityResult(
            X=X, dXdr=dXdr, dXdth=dXdth, dXdph=0.0, dXdt=0.0, hmax=hmax,
        )


class Elect1(ElectronDensityModel):
    """Simple electron density model.

    Port of ELECT1.f. A basic single-layer model using a simple
    exponential profile.
    """

    name = "elect1"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> ElectronDensityResult:
        fc = w.get("fc", 10.0)
        hm = w.get("hm", 250.0)
        sh = w.get("sh", 100.0)
        earth_r = w.get("earth_r", EARTH_RADIUS)

        h = r - earth_r
        z = (h - hm) / sh
        X = (fc / freq_mhz) ** 2 * math.exp(1.0 - z - math.exp(-z))
        dXdr = -X * (1.0 - math.exp(-z)) / sh

        return ElectronDensityResult(
            X=X, dXdr=dXdr, dXdth=0.0, dXdph=0.0, dXdt=0.0, hmax=hm,
        )


class Linear(ElectronDensityModel):
    """Linear electron density model.

    Port of LINEAR.f. Piecewise-linear electron density.
    """

    name = "linear"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> ElectronDensityResult:
        fc = w.get("fc", 10.0)
        hm = w.get("hm", 250.0)
        ym = w.get("ym", 100.0)
        earth_r = w.get("earth_r", EARTH_RADIUS)

        h = r - earth_r
        hmax = hm

        if h <= hm:
            X = (fc / freq_mhz) ** 2 * h / hm
            dXdr = (fc / freq_mhz) ** 2 / hm
        else:
            semi = ym / 2.0
            z = (h - hm) / semi
            X = (fc / freq_mhz) ** 2 * (1.0 - z * z) if z < 1.0 else 0.0
            dXdr = (fc / freq_mhz) ** 2 * (-2.0 * z / semi) if z < 1.0 else 0.0

        return ElectronDensityResult(
            X=X, dXdr=dXdr, dXdth=0.0, dXdph=0.0, dXdt=0.0, hmax=hmax,
        )


class Qparab(ElectronDensityModel):
    """Quasi-parabolic electron density model.

    Port of QPARAB.f. Uses a quasi-parabolic profile with optional
    latitude variation.
    """

    name = "qparab"

    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> ElectronDensityResult:
        fc = w.get("fc", 10.0)
        hm = w.get("hm", 250.0)
        ym = w.get("ym", 100.0)
        earth_r = w.get("earth_r", EARTH_RADIUS)

        rm = earth_r + hm
        rb = rm - ym / 2.0
        h = r - earth_r
        hmax = hm

        if r <= rb or r <= 0.0:
            return ElectronDensityResult(
                X=0.0, dXdr=0.0, dXdth=0.0, dXdph=0.0, dXdt=0.0, hmax=hmax,
            )

        X = (fc / freq_mhz) ** 2 * (1.0 - ((r - rm) / (r * ym / (2.0 * rm))) ** 2)
        # Simplified derivative
        term = (r - rm) * 2.0 * rm / (ym * r)
        dterm_dr = 2.0 * rm / (ym * r) - (r - rm) * 2.0 * rm / (ym * r * r)
        dXdr = -(fc / freq_mhz) ** 2 * term * dterm_dr / (2.0 * rm / (ym * r)) ** 2

        if X < 0.0:
            X = 0.0
            dXdr = 0.0

        return ElectronDensityResult(
            X=X, dXdr=dXdr, dXdth=0.0, dXdph=0.0, dXdt=0.0, hmax=hmax,
        )
