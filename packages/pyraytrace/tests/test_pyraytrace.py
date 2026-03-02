"""Tests for the pyraytrace simulation against Fortran reference outputs."""

import math
import pytest

from pyraytrace.constants import PID2, RADIAN, EARTH_RADIUS
from pyraytrace.core.equations import RayState, HamltnConfig, compute_derivatives
from pyraytrace.core.integrator import init_integrator, integrator_step
from pyraytrace.core.tracer import SimulationConfig, run_ray
from pyraytrace.models.electron_density import Chapx, Elect1
from pyraytrace.models.magnetic_field import Dipoly, Consty
from pyraytrace.models.collision import Expz2, Constz
from pyraytrace.models.refractive_index import Ahwfwc
from pyraytrace.geometry import (
    spherical_to_cartesian,
    cartesian_to_spherical,
    step_ray_straight,
)


# ===== Geometry Tests =====

class TestGeometry:
    def test_round_trip(self):
        """Spherical → Cartesian → Spherical should be identity."""
        r, theta, phi = 6370.0, 0.8727, -1.8326
        kr, kth, kph = 0.342, -0.664, 0.664

        cart = spherical_to_cartesian(r, theta, phi, kr, kth, kph)
        r2, th2, ph2, kr2, kth2, kph2 = cartesian_to_spherical(
            cart.x, cart.y, cart.z, cart.kx, cart.ky, cart.kz,
        )

        assert abs(r2 - r) < 1e-6
        assert abs(th2 - theta) < 1e-6
        assert abs(ph2 - phi) < 1e-6
        assert abs(kr2 - kr) < 1e-4
        assert abs(kth2 - kth) < 1e-4
        assert abs(kph2 - kph) < 1e-4

    def test_vertical_step(self):
        """Vertical incidence should move radially."""
        r, theta, phi = 6370.0, 1.0, 0.0
        r2, th2, ph2, kr2, kth2, kph2 = step_ray_straight(
            r, theta, phi, 1.0, 0.0, 0.0, 10.0,
        )
        assert abs(r2 - 6380.0) < 1e-6
        assert abs(th2 - theta) < 1e-10
        assert abs(ph2 - phi) < 1e-10


# ===== Model Tests =====

class TestElectronDensity:
    def test_chapx_at_max(self):
        """Chapman model should have maximum at hm."""
        model = Chapx()
        w = {"fc": 10.0, "hm": 250.0, "sh": 100.0, "alpha": 0.5}
        freq = 10.0

        # At max height, X should be close to (fc/f)^2 = 1.0
        r_max = EARTH_RADIUS + 250.0
        result = model.compute(r_max, PID2, 0.0, freq, w)
        assert abs(result.X - 1.0) < 0.01  # Should be close to 1

        # Gradient at max should be near zero
        assert abs(result.dXdr) < 0.01

    def test_chapx_above_max(self):
        """Density should decrease above the maximum."""
        model = Chapx()
        w = {"fc": 10.0, "hm": 250.0, "sh": 100.0, "alpha": 0.5}
        r_above = EARTH_RADIUS + 400.0
        result = model.compute(r_above, PID2, 0.0, 10.0, w)
        assert result.X < 1.0
        assert result.dXdr < 0.0  # Decreasing

    def test_chapx_below_max(self):
        """Density should decrease below the maximum."""
        model = Chapx()
        w = {"fc": 10.0, "hm": 250.0, "sh": 100.0, "alpha": 0.5}
        r_below = EARTH_RADIUS + 100.0
        result = model.compute(r_below, PID2, 0.0, 10.0, w)
        assert result.X < 1.0


class TestMagneticField:
    def test_dipoly_equator(self):
        """Dipole at equator should give Y = fH/f × (Re/r)^3."""
        model = Dipoly()
        w = {"fh": 0.8}
        result = model.compute(EARTH_RADIUS, PID2, 0.0, 10.0, w)

        # At equator, Y = fH/f * sqrt(1 + 3cos²(π/2)) = fH/f * 1
        expected_Y = 0.8 / 10.0
        assert abs(result.Y - expected_Y) < 1e-6

    def test_dipoly_pole(self):
        """Dipole at pole should be 2× equatorial."""
        model = Dipoly()
        w = {"fh": 0.8}
        result = model.compute(EARTH_RADIUS, 0.01, 0.0, 10.0, w)

        # At pole, sqrt(1 + 3cos²(0)) = 2
        expected_Y = 0.8 / 10.0 * 2.0
        assert abs(result.Y - expected_Y) < 1e-3


class TestCollision:
    def test_expz2_at_ground(self):
        """Collision frequency should be high at ground level."""
        model = Expz2()
        w = {"nu1": 1050000.0, "h1": 100.0, "a1": 0.148,
             "nu2": 30.0, "h2": 140.0, "a2": 0.0183}
        result = model.compute(EARTH_RADIUS, PID2, 0.0, 10.0, w)
        assert result.Z > 0.0  # Collisions present

    def test_expz2_decreases_with_height(self):
        """Collision freq should decrease with altitude."""
        model = Expz2()
        w = {"nu1": 1050000.0, "h1": 100.0, "a1": 0.148,
             "nu2": 30.0, "h2": 140.0, "a2": 0.0183}
        z_low = model.compute(EARTH_RADIUS + 50.0, PID2, 0.0, 10.0, w)
        z_high = model.compute(EARTH_RADIUS + 300.0, PID2, 0.0, 10.0, w)
        assert z_low.Z > z_high.Z


# ===== Core Engine Tests =====

class TestEquations:
    def test_derivatives_at_ground(self):
        """Hamilton's equations should give upward motion at 20° elevation."""
        e = Chapx(); m = Dipoly(); c = Expz2()
        rindex = Ahwfwc(e, m, c)

        w = {"earth_r": EARTH_RADIUS, "fc": 10.0, "hm": 250.0,
             "sh": 100.0, "alpha": 0.5, "fh": 0.8,
             "nu1": 1050000.0, "h1": 100.0, "a1": 0.148,
             "nu2": 30.0, "h2": 140.0, "a2": 0.0183}

        state = RayState(
            r=EARTH_RADIUS, theta=PID2, phi=0.0,
            kr=math.sin(20 * RADIAN),
            kth=math.cos(20 * RADIAN),
            kph=0.0,
        )

        hconfig = HamltnConfig(compute_phase_path=True, compute_absorption=True)
        derivs, space, new_state = compute_derivatives(
            state, rindex, 10.0, -1.0, w, hconfig, rstart=1.0,
        )

        # dr/dt should be positive (going up) and approximately sin(20°)
        assert derivs[0] > 0.0
        assert abs(derivs[0] - math.sin(20 * RADIAN)) < 0.01


# ===== End-to-End Test =====

class TestE2ESampleCase:
    """Reproduce the OT 75-76 sample case and validate against Fortran."""

    def _build_sample_case(self):
        e = Chapx(); m = Dipoly(); c = Expz2()
        rindex = Ahwfwc(e, m, c)

        config = SimulationConfig(
            freq_mhz=10.0,
            ray_mode=-1.0,
            elevation_deg=20.0,
            azimuth_deg=45.0,
            tx_lat_deg=40.0,
            max_steps=200,
            int_mode=2,
            step_size=10.0,
            model_params={
                "fc": 10.0, "hm": 250.0, "sh": 100.0, "alpha": 0.5,
                "a": 0.0, "b": 0.0, "c_coeff": 0.0, "e": 0.0,
                "fh": 0.8,
                "nu1": 1050000.0, "h1": 100.0, "a1": 0.148,
                "nu2": 30.0, "h2": 140.0, "a2": 0.0183,
            },
        )
        return config, rindex

    def test_max_height(self):
        """Max height should match Fortran: ~74 km."""
        config, rindex = self._build_sample_case()
        result = run_ray(config, rindex)

        # Fortran gives max height = 74.12 km
        assert result.max_height > 60.0
        assert result.max_height < 90.0
        assert abs(result.max_height - 74.12) / 74.12 < 0.05  # 5% tolerance

    def test_returns_to_ground(self):
        """Ray should return to ground (not penetrate or escape)."""
        config, rindex = self._build_sample_case()
        result = run_ray(config, rindex)
        assert result.returned_to_ground is True

    def test_reasonable_step_count(self):
        """Should complete in a reasonable number of steps."""
        config, rindex = self._build_sample_case()
        result = run_ray(config, rindex)
        assert result.n_steps < 100  # Fortran takes ~46 steps at step=10
