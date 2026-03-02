"""Tests for IRI and IGRF model adapters."""

import math
import pytest
import numpy as np

from pyraytrace.constants import PID2, RADIAN, EARTH_RADIUS


class TestIriElectronDensity:
    """Tests for the IRI electron density model."""

    @pytest.fixture(scope="class")
    def iri_model(self):
        """Create IRI model (slow, reuse across tests)."""
        from pyraytrace.models.iri import IriElectronDensity
        return IriElectronDensity(
            year=2024, month=3, day=15, hour_ut=14.0,
            lat=40.0, lon=-105.0, f107=150.0,
        )

    def test_iri_foF2_reasonable(self, iri_model):
        """foF2 should be in a reasonable range (2-15 MHz)."""
        assert 2.0 < iri_model.foF2 < 15.0

    def test_iri_hmF2_reasonable(self, iri_model):
        """hmF2 should be in a reasonable range (150-400 km)."""
        assert 150.0 < iri_model.hmF2 < 400.0

    def test_iri_density_at_peak(self, iri_model):
        """X should be close to 1.0 at the peak height when f ≈ foF2."""
        r_peak = EARTH_RADIUS + iri_model.hmF2
        freq = iri_model.foF2  # At critical frequency, X ≈ 1
        result = iri_model.compute(r_peak, PID2, 0.0, freq, {"earth_r": EARTH_RADIUS})
        assert abs(result.X - 1.0) < 0.3  # Within 30% of 1.0

    def test_iri_density_above_ionosphere(self, iri_model):
        """X should be essentially zero above 1000 km."""
        r_high = EARTH_RADIUS + 1100.0
        result = iri_model.compute(r_high, PID2, 0.0, 10.0, {"earth_r": EARTH_RADIUS})
        assert result.X == 0.0  # Outside profile range

    def test_iri_gradient_negative_above_peak(self, iri_model):
        """dX/dr should be negative above the peak."""
        r_above = EARTH_RADIUS + iri_model.hmF2 + 50.0
        result = iri_model.compute(r_above, PID2, 0.0, 10.0, {"earth_r": EARTH_RADIUS})
        assert result.dXdr < 0.0


class TestIgrfMagneticField:
    """Tests for the IGRF magnetic field model."""

    @pytest.fixture(scope="class")
    def igrf_model(self):
        """Create IGRF model."""
        from pyraytrace.models.igrf import IgrfMagneticField
        from datetime import datetime
        return IgrfMagneticField(date=datetime(2024, 3, 15))

    def test_igrf_Y_reasonable(self, igrf_model):
        """Y = fH/f should be reasonable at Earth's surface."""
        # At 40°N, |B| ≈ 55,000 nT → fH ≈ 1.54 MHz
        # At f = 10 MHz, Y ≈ 0.154
        result = igrf_model.compute(
            EARTH_RADIUS, PID2 - 40.0 * RADIAN, -105.0 * RADIAN,
            10.0, {},
        )
        assert 0.05 < result.Y < 0.3

    def test_igrf_Y_decreases_with_altitude(self, igrf_model):
        """Magnetic field should decrease with altitude."""
        theta = PID2 - 40.0 * RADIAN
        phi = -105.0 * RADIAN

        y_low = igrf_model.compute(EARTH_RADIUS, theta, phi, 10.0, {})
        y_high = igrf_model.compute(EARTH_RADIUS + 500, theta, phi, 10.0, {})
        assert y_high.Y < y_low.Y

    def test_igrf_has_direction_components(self, igrf_model):
        """Should provide non-zero Yr and Yth components."""
        result = igrf_model.compute(
            EARTH_RADIUS, PID2 - 40.0 * RADIAN, -105.0 * RADIAN,
            10.0, {},
        )
        # At mid-latitudes, both radial and theta components should be non-zero
        assert result.Yr != 0.0
        assert result.Yth != 0.0


class TestIriIgrfIntegration:
    """End-to-end test with IRI + IGRF."""

    def test_ray_reaches_ionosphere(self):
        """A 10 MHz ray should reach ionospheric heights with IRI+IGRF."""
        from pyraytrace.models.iri import IriElectronDensity
        from pyraytrace.models.igrf import IgrfMagneticField
        from pyraytrace.models.collision import Expz2
        from pyraytrace.models.refractive_index import Ahwfwc
        from pyraytrace.core.tracer import SimulationConfig, run_ray
        from datetime import datetime

        e = IriElectronDensity(year=2024, month=3, day=15, hour_ut=14.0,
                               lat=40.0, lon=-105.0, f107=150.0)
        m = IgrfMagneticField(date=datetime(2024, 3, 15))
        c = Expz2()
        rindex = Ahwfwc(e, m, c)

        config = SimulationConfig(
            freq_mhz=10.0, ray_mode=-1.0,
            elevation_deg=20.0, azimuth_deg=45.0,
            tx_lat_deg=40.0, max_steps=200,
            int_mode=2, step_size=10.0,
            model_params={
                "nu1": 1050000.0, "h1": 100.0, "a1": 0.148,
                "nu2": 30.0, "h2": 140.0, "a2": 0.0183,
            },
        )

        result = run_ray(config, rindex)
        assert result.max_height > 50.0  # Should reach at least 50 km
        assert result.returned_to_ground  # Should bend back
