"""Refractive index models.

Compute the complex refractive index n² and the Hamiltonian H plus all
its partial derivatives needed by Hamilton's equations.

Direct ports of the Fortran RINDEX-entry subroutines.
"""

from __future__ import annotations

import cmath
import math

from pyraytrace.constants import C, PIT2
from pyraytrace.models.base import (
    ElectronDensityModel,
    ElectronDensityResult,
    MagneticFieldModel,
    MagneticFieldResult,
    CollisionModel,
    CollisionResult,
    RefractiveIndexResult,
)


class Ahwfwc:
    """Appleton-Hartree refractive index with field and collisions.

    Port of AHWFWC.f. This is the most general form of the
    Appleton-Hartree formula, supporting both ordinary and extraordinary
    rays in a magnetized, collisional plasma.

    The Hamiltonian is: H = 0.5 * (c²k²/ω² - n²)
    """

    name = "ahwfwc"

    ABSLIM = 1.0e-5

    def __init__(
        self,
        electron_model: ElectronDensityModel,
        magnetic_model: MagneticFieldModel,
        collision_model: CollisionModel,
    ):
        self.electron_model = electron_model
        self.magnetic_model = magnetic_model
        self.collision_model = collision_model

    def compute(
        self,
        r: float, theta: float, phi: float,
        kr: float, kth: float, kph: float,
        freq_mhz: float,
        ray_mode: float,
        w: dict,
        rstart: float = 0.0,
    ) -> RefractiveIndexResult:
        """Compute refractive index and Hamiltonian derivatives.

        Args:
            r, theta, phi: Position (spherical)
            kr, kth, kph: Wave vector components
            freq_mhz: Wave frequency (MHz)
            ray_mode: +1 ordinary, -1 extraordinary
            w: Model parameters dict
            rstart: Nonzero on first call to rescale k-vector

        Returns:
            RefractiveIndexResult with all Hamiltonian partials.
            Also modifies kr, kth, kph on first call (rstart != 0).
        """
        om = PIT2 * freq_mhz * 1.0e6
        C2 = C * C
        k2 = kr * kr + kth * kth + kph * kph
        om2 = om * om

        # Wave vector direction (velocity-like)
        vr = C / om * kr
        vth = C / om * kth
        vph = C / om * kph

        # Get electron density
        ex = self.electron_model.compute(r, theta, phi, freq_mhz, w)
        X = ex.X

        # Get magnetic field
        mag = self.magnetic_model.compute(r, theta, phi, freq_mhz, w)
        Y_mag = mag.Y

        v2 = vr ** 2 + vth ** 2 + vph ** 2
        vdoty = vr * mag.Yr + vth * mag.Yth + vph * mag.Yph

        # sin²ψ and cos²ψ (angle between wave vector and magnetic field)
        ylv = 0.0
        yl2 = 0.0
        if v2 != 0.0:
            ylv = vdoty / v2
            yl2 = vdoty ** 2 / v2

        yt2 = Y_mag ** 2 - yl2
        yt4 = yt2 * yt2

        # Get collision frequency
        col = self.collision_model.compute(r, theta, phi, freq_mhz, w)
        Z = col.Z

        # Complex Appleton-Hartree formula
        U = complex(1.0, -Z)
        UX = U - X
        UX2 = UX * UX

        rad = ray_mode * cmath.sqrt(yt4 + 4.0 * yl2 * UX2)
        D = 2.0 * U * UX - yt2 + rad
        D2 = D * D
        n2 = 1.0 - 2.0 * X * UX / D

        # Partial derivatives of n² w.r.t. plasma parameters
        if rad != 0.0:
            pnpps = 2.0 * X * UX * (-1.0 + (yt2 - 2.0 * UX2) / rad) / D2

            pnpx = -(2.0 * U * UX2 - yt2 * (U - 2.0 * X)
                      + (yt4 * (U - 2.0 * X) + 4.0 * yl2 * UX * UX2) / rad) / D2

            pnpy = 0.0
            if Y_mag != 0.0:
                pnpy = 2.0 * X * UX * (-yt2 + (yt4 + 2.0 * yl2 * UX2) / rad) / (D2 * Y_mag)

            pnpz = 1j * X * (-2.0 * UX2 - yt2 + yt4 / rad) / D2
        else:
            pnpps = -2.0 * X * UX / D2
            pnpx = -2.0 * U * UX2 / D2
            pnpy = 0.0
            pnpz = 1j * X * (-2.0 * UX2) / D2

        # Partial derivatives of sin²ψ w.r.t. position
        ppspr = 0.0
        ppspth = 0.0
        ppspph = 0.0
        if Y_mag != 0.0:
            ppspr = (yl2 / Y_mag * mag.dYdr
                     - (vr * mag.dYrdr + vth * mag.dYthdr + vph * mag.dYphdr) * ylv)
            ppspth = (yl2 / Y_mag * mag.dYdth
                      - (vr * mag.dYrdth + vth * mag.dYthdth + vph * mag.dYphdth) * ylv)
            ppspph = (yl2 / Y_mag * mag.dYdph
                      - (vr * mag.dYrdph + vth * mag.dYthdph + vph * mag.dYphdph) * ylv)

        # ∂n²/∂(r, θ, φ) via chain rule
        pnpr = pnpx * ex.dXdr + pnpy * mag.dYdr + pnpz * col.dZdr + pnpps * ppspr
        pnpth = pnpx * ex.dXdth + pnpy * mag.dYdth + pnpz * col.dZdth + pnpps * ppspth
        pnpph = pnpx * ex.dXdph + pnpy * mag.dYdph + pnpz * col.dZdph + pnpps * ppspph

        # ∂n²/∂(vr, vθ, vφ) for wave vector derivatives
        pnpvr = 0.0
        pnpvth = 0.0
        pnpvph = 0.0
        if v2 != 0.0:
            pnpvr = pnpps * (vr * yl2 / v2 - ylv * mag.Yr)
            pnpvth = pnpps * (vth * yl2 / v2 - ylv * mag.Yth)
            pnpvph = pnpps * (vph * yl2 / v2 - ylv * mag.Yph)

        # NNP = n² - (2X·∂n²/∂X + Y·∂n²/∂Y + Z·∂n²/∂Z)
        nnp = n2 - (2.0 * X * pnpx + Y_mag * pnpy + Z * pnpz)

        # ∂n²/∂t
        pnpt = pnpx * ex.dXdt

        # Free space check
        space = (n2.real == 1.0 and abs(n2.imag) < self.ABSLIM)

        # Polarization
        polar = 0.0 + 0.0j
        lpolar = 0.0 + 0.0j
        if vdoty != 0.0 and UX != 0.0:
            polar = -1j * math.sqrt(v2) * (-yt2 + rad) / (2.0 * vdoty * UX)
            gam = (-yt2 + rad) / (2.0 * UX)
            denom = UX * (U + gam)
            if denom != 0.0:
                lpolar = 1j * X * math.sqrt(yt2) / denom

        # k² in the medium
        kay2 = om2 / C2 * n2

        # Rescale k-vector on first call (Fortran does this BEFORE computing H derivatives)
        new_kr, new_kth, new_kph = kr, kth, kph
        if rstart != 0.0 and k2 != 0.0:
            scale = math.sqrt(kay2.real / k2)
            new_kr = scale * kr
            new_kth = scale * kth
            new_kph = scale * kph

        # Hamiltonian and its derivatives
        # NOTE: H uses original k2, but dHdkr uses rescaled kr (matching Fortran)
        H = 0.5 * (C2 * k2 / om2 - n2)

        dHdt = -pnpt
        dHdr = -pnpr
        dHdth = -pnpth
        dHdph = -pnpph
        dHdom = -nnp / om
        dHdkr = C2 / om2 * new_kr - C / om * pnpvr
        dHdkth = C2 / om2 * new_kth - C / om * pnpvth
        dHdkph = C2 / om2 * new_kph - C / om * pnpvph

        return RefractiveIndexResult(
            n_squared=n2,
            H=H,
            space=space,
            dHdt=dHdt,
            dHdr=dHdr,
            dHdth=dHdth,
            dHdph=dHdph,
            dHdom=dHdom,
            dHdkr=dHdkr,
            dHdkth=dHdkth,
            dHdkph=dHdkph,
            kphpk=n2,
            polar=polar,
            lpolar=lpolar,
        ), new_kr, new_kth, new_kph
