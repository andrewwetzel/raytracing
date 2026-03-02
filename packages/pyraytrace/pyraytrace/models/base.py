"""Abstract base classes for physics models.

Each model implements a `compute()` method that returns the model value
and its partial derivatives with respect to position coordinates.
This replaces the Fortran approach of swapping subroutine names via ENTRY points.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass

import numpy as np


@dataclass
class ElectronDensityResult:
    """Output from an electron density model (ELECTX entry).

    X = (fp/f)^2 where fp is the plasma frequency, f is the wave frequency.
    """
    X: float       # Normalized electron density
    dXdr: float    # ∂X/∂r
    dXdth: float   # ∂X/∂θ
    dXdph: float   # ∂X/∂φ
    dXdt: float    # ∂X/∂t (time variation, 0 for static models)
    hmax: float    # Height of electron density maximum (km)


@dataclass
class MagneticFieldResult:
    """Output from a magnetic field model (MAGY entry).

    Y = fH/f where fH is the gyrofrequency, f is the wave frequency.
    Also provides direction components and their derivatives for
    computing the angle between the wave vector and the field.
    """
    Y: float        # Normalized gyrofrequency magnitude
    dYdr: float     # ∂Y/∂r
    dYdth: float    # ∂Y/∂θ
    dYdph: float    # ∂Y/∂φ
    # Direction components (Y⃗ = Yr r̂ + Yθ θ̂ + Yφ φ̂)
    Yr: float
    Yth: float
    Yph: float
    # Partial derivatives of direction components
    # ∂Yr/∂r, ∂Yr/∂θ, ∂Yr/∂φ
    dYrdr: float
    dYrdth: float
    dYrdph: float
    # ∂Yθ/∂r, ∂Yθ/∂θ, ∂Yθ/∂φ
    dYthdr: float
    dYthdth: float
    dYthdph: float
    # ∂Yφ/∂r, ∂Yφ/∂θ, ∂Yφ/∂φ
    dYphdr: float
    dYphdth: float
    dYphdph: float


@dataclass
class CollisionResult:
    """Output from a collision frequency model (COLFRZ entry).

    Z = ν/ω where ν is the collision frequency, ω is the wave angular freq.
    """
    Z: float       # Normalized collision frequency
    dZdr: float    # ∂Z/∂r
    dZdth: float   # ∂Z/∂θ
    dZdph: float   # ∂Z/∂φ


@dataclass
class RefractiveIndexResult:
    """Output from a refractive index calculation (RINDEX entry).

    Contains the Hamiltonian H and all its partial derivatives needed
    by Hamilton's equations.
    """
    # Core outputs
    n_squared: complex      # n² (refractive index squared)
    H: complex              # Hamiltonian = 0.5 * (c²k²/ω² - n²)
    space: bool             # True if in free space (n²≈1)

    # ∂H/∂ (spatial coordinates)
    dHdt: complex           # ∂H/∂t
    dHdr: complex           # ∂H/∂r
    dHdth: complex          # ∂H/∂θ
    dHdph: complex          # ∂H/∂φ

    # ∂H/∂ω (angular frequency)
    dHdom: complex

    # ∂H/∂ (wave vector components)
    dHdkr: complex          # ∂H/∂kr
    dHdkth: complex         # ∂H/∂kθ
    dHdkph: complex         # ∂H/∂kφ

    # For phase path and absorption
    kphpk: complex          # k · ∂H/∂k (= n²)
    kphpki: complex = 0.0   # imaginary part for absorption

    # Polarization (optional)
    polar: complex = 0.0 + 0.0j
    lpolar: complex = 0.0 + 0.0j


class ElectronDensityModel(ABC):
    """Abstract base for electron density models (replaces ELECTX entry)."""

    name: str = "base"

    @abstractmethod
    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> ElectronDensityResult:
        """Compute electron density and its gradients.

        Args:
            r: Radial distance from Earth center (km)
            theta: Colatitude (radians)
            phi: Longitude (radians)
            freq_mhz: Wave frequency (MHz)
            w: Configuration parameters dict
        """
        ...


class MagneticFieldModel(ABC):
    """Abstract base for magnetic field models (replaces MAGY entry)."""

    name: str = "base"

    @abstractmethod
    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> MagneticFieldResult:
        """Compute magnetic field strength, direction, and gradients."""
        ...


class CollisionModel(ABC):
    """Abstract base for collision frequency models (replaces COLFRZ entry)."""

    name: str = "base"

    @abstractmethod
    def compute(
        self, r: float, theta: float, phi: float,
        freq_mhz: float, w: dict,
    ) -> CollisionResult:
        """Compute collision frequency and its gradients."""
        ...
