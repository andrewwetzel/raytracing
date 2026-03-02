"""Coordinate conversion utilities.

Direct port of POLCAR.f — spherical ↔ Cartesian coordinate transforms
for ray state vectors (position + wave vector direction).
"""

from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np


@dataclass
class CartesianState:
    """Cartesian position and wave vector direction."""
    x: float
    y: float
    z: float
    kx: float
    ky: float
    kz: float


def spherical_to_cartesian(
    r: float, theta: float, phi: float,
    kr: float, kth: float, kph: float,
) -> CartesianState:
    """Convert spherical ray state to Cartesian.

    Corresponds to the first part of POLCAR.f (POLCAR entry).

    Args:
        r: Radial distance (km)
        theta: Colatitude (radians)
        phi: Longitude (radians)
        kr, kth, kph: Wave vector components in spherical coords

    Returns:
        CartesianState with position and wave vector in Cartesian coords
    """
    sina = math.sin(theta)
    cosa = math.cos(theta)
    sinp = math.sin(phi)
    cosp = math.cos(phi)

    # Position
    x = r * sina * cosp
    y = r * sina * sinp
    z = r * cosa

    # Wave vector direction
    kx = kr * sina * cosp + kth * cosa * cosp - kph * sinp
    ky = kr * sina * sinp + kth * cosa * sinp + kph * cosp
    kz = kr * cosa - kth * sina

    return CartesianState(x=x, y=y, z=z, kx=kx, ky=ky, kz=kz)


def cartesian_to_spherical(
    x: float, y: float, z: float,
    kx: float, ky: float, kz: float,
) -> tuple[float, float, float, float, float, float]:
    """Convert Cartesian ray state back to spherical.

    Corresponds to the CARPOL entry in POLCAR.f.

    Returns:
        (r, theta, phi, kr, kth, kph)
    """
    temp = math.sqrt(x * x + y * y)
    r = math.sqrt(x * x + y * y + z * z)
    theta = math.atan2(temp, z)
    phi = math.atan2(y, x)

    kr = (x * kx + y * ky + z * kz) / r
    kth = (z * (x * kx + y * ky) - (x * x + y * y) * kz) / (r * temp)
    kph = (x * ky - y * kx) / temp

    return r, theta, phi, kr, kth, kph


def step_ray_straight(
    r: float, theta: float, phi: float,
    kr: float, kth: float, kph: float,
    distance: float,
) -> tuple[float, float, float, float, float, float]:
    """Step a ray in a straight line for a given distance, then convert back.

    Handles vertical incidence as a special case (following POLCAR.f).

    Args:
        r, theta, phi: Current spherical position
        kr, kth, kph: Wave vector direction
        distance: Distance to step (km)

    Returns:
        (r, theta, phi, kr, kth, kph) — new state after stepping
    """
    # Vertical incidence special case
    if kth == 0.0 and kph == 0.0:
        sign_kr = 1.0 if kr >= 0.0 else -1.0
        return r + sign_kr * distance, theta, phi, sign_kr, 0.0, 0.0

    # General case: convert to Cartesian, step, convert back
    cart = spherical_to_cartesian(r, theta, phi, kr, kth, kph)
    new_x = cart.x + distance * cart.kx
    new_y = cart.y + distance * cart.ky
    new_z = cart.z + distance * cart.kz

    return cartesian_to_spherical(new_x, new_y, new_z, cart.kx, cart.ky, cart.kz)
