"""Tests for propagation analysis tools (homing, MUF/LUF, coverage)."""

import pytest


class TestHoming:
    """Tests for elevation homing algorithm."""

    def test_homing_converges_for_reachable_range(self):
        """Should find elevation for a reachable ground range."""
        from pyraytrace.propagation import find_elevation
        result = find_elevation(target_range_km=500.0, fc=10.0, hm=250.0, sh=100.0)
        assert result.converged
        assert abs(result.ground_range_km - 500.0) < 10.0

    def test_homing_returns_best_for_skip_zone(self):
        """Range in skip zone should return best available (not crash)."""
        from pyraytrace.propagation import find_elevation
        # 300 km is likely in the skip zone for 10 MHz
        result = find_elevation(target_range_km=300.0, fc=10.0, hm=250.0, sh=100.0)
        assert result.elevation_deg > 0
        assert result.ground_range_km > 0

    def test_homing_long_range(self):
        """Should find elevation for longer range (1000 km)."""
        from pyraytrace.propagation import find_elevation
        result = find_elevation(target_range_km=1000.0, fc=10.0, hm=250.0, sh=100.0)
        assert result.converged
        assert abs(result.ground_range_km - 1000.0) < 10.0


class TestMufLuf:
    """Tests for MUF/LUF frequency analysis."""

    def test_muf_exists(self):
        """MUF should exist for typical ionospheric conditions."""
        from pyraytrace.propagation import analyze_frequencies
        result = analyze_frequencies(
            elevation_deg=20.0, fc=10.0, hm=250.0, sh=100.0,
            freq_step=1.0,
        )
        assert result.muf_mhz is not None
        assert result.muf_mhz > 5.0  # Should be well above minimum

    def test_luf_below_muf(self):
        """LUF should be below MUF."""
        from pyraytrace.propagation import analyze_frequencies
        result = analyze_frequencies(
            elevation_deg=20.0, fc=10.0, hm=250.0, sh=100.0,
            freq_step=1.0,
        )
        if result.luf_mhz and result.muf_mhz:
            assert result.luf_mhz <= result.muf_mhz

    def test_optimal_is_85_percent_muf(self):
        """Optimal frequency should be 85% of MUF."""
        from pyraytrace.propagation import analyze_frequencies
        result = analyze_frequencies(
            elevation_deg=20.0, fc=10.0, hm=250.0, sh=100.0,
            freq_step=1.0,
        )
        if result.muf_mhz and result.optimal_mhz:
            expected = round(result.muf_mhz * 0.85, 1)
            assert result.optimal_mhz == expected

    def test_above_muf_penetrates(self):
        """Frequencies above MUF should not return to ground."""
        from pyraytrace.propagation import analyze_frequencies
        result = analyze_frequencies(
            elevation_deg=20.0, fc=10.0, hm=250.0, sh=100.0,
            freq_step=1.0,
        )
        if result.muf_mhz:
            # Find results above MUF
            above_muf = [r for r in result.results
                        if r["freq_mhz"] > result.muf_mhz + 1.0]
            for r in above_muf:
                assert not r["ground_return"]


class TestCoverage:
    """Tests for coverage mapping."""

    def test_coverage_produces_points(self):
        """Should produce non-empty coverage map."""
        from pyraytrace.propagation import compute_coverage
        result = compute_coverage(
            freq_mhz=10.0, fc=10.0, hm=250.0, sh=100.0,
            elev_step=10.0, az_step=90.0,
        )
        assert result.n_rays > 0
        assert len(result.points) == result.n_rays

    def test_coverage_symmetric_in_azimuth(self):
        """Ground range should be roughly similar across azimuths (simple models)."""
        from pyraytrace.propagation import compute_coverage
        result = compute_coverage(
            freq_mhz=10.0, fc=10.0, hm=250.0, sh=100.0,
            elev_min=20.0, elev_max=20.0, elev_step=1.0,
            az_step=90.0,
        )
        ranges = [p.ground_range_km for p in result.points if p.ground_range_km]
        if len(ranges) > 1:
            # All should be roughly the same (within 20%)
            avg = sum(ranges) / len(ranges)
            for r in ranges:
                assert abs(r - avg) / avg < 0.2

    def test_coverage_fast(self):
        """96 rays should complete in under 500 ms."""
        from pyraytrace.propagation import compute_coverage
        result = compute_coverage(
            freq_mhz=10.0, fc=10.0, hm=250.0, sh=100.0,
            elev_step=5.0, az_step=45.0,
        )
        assert result.elapsed_ms < 500
