"""Tests for the ionotrace Python bindings."""

import ionotrace


class TestEnums:
    """Verify enum types work correctly."""

    def test_electron_density_models(self):
        assert ionotrace.ElectronDensityModel.Chapman is not None
        assert ionotrace.ElectronDensityModel.DualChapman is not None
        assert "Chapman" in repr(ionotrace.ElectronDensityModel.Chapman)

    def test_magnetic_field_models(self):
        assert ionotrace.MagneticFieldModel.Dipole is not None
        assert ionotrace.MagneticFieldModel.Igrf14 is not None

    def test_ray_mode(self):
        assert ionotrace.RayMode.Ordinary is not None
        assert ionotrace.RayMode.Extraordinary is not None

    def test_perturbation_model(self):
        assert ionotrace.PerturbationModel.Torus is not None

    def test_collision_model(self):
        assert ionotrace.CollisionModel.DoubleExponential is not None

    def test_refractive_index_model(self):
        assert ionotrace.RefractiveIndexModel.Full is not None


class TestModelParams:
    """Verify ModelParams construction and defaults."""

    def test_defaults(self):
        p = ionotrace.ModelParams()
        assert p.fc == 10.0
        assert p.hm == 250.0
        assert p.sh == 100.0
        assert p.earth_r == 6370.0

    def test_custom(self):
        p = ionotrace.ModelParams(
            fc=8.0,
            hm=300.0,
            ed_model=ionotrace.ElectronDensityModel.DualChapman,
        )
        assert p.fc == 8.0
        assert p.hm == 300.0
        assert p.ed_model == ionotrace.ElectronDensityModel.DualChapman

    def test_repr(self):
        p = ionotrace.ModelParams()
        assert "ModelParams" in repr(p)


class TestTraceConfig:
    """Verify single-ray trace configuration."""

    def test_construction(self):
        cfg = ionotrace.TraceConfig(10.0, 20.0)
        assert cfg.freq_mhz == 10.0
        assert cfg.elevation_deg == 20.0

    def test_trace_basic(self):
        result = ionotrace.TraceConfig(10.0, 20.0).trace()
        assert isinstance(result, ionotrace.TraceResult)
        assert result.max_height > 0
        assert result.n_steps > 0
        assert len(result.points) > 0

    def test_trace_returns_to_ground(self):
        result = ionotrace.TraceConfig(10.0, 30.0).trace()
        assert result.returned_to_ground is True
        assert result.ground_range_km > 0

    def test_trace_with_custom_params(self):
        params = ionotrace.ModelParams(fc=8.0, hm=300.0)
        result = ionotrace.TraceConfig(10.0, 25.0, params=params).trace()
        assert result.max_height > 0

    def test_trace_points_have_fields(self):
        result = ionotrace.TraceConfig(10.0, 25.0).trace()
        pt = result.points[1]  # skip initial point
        assert hasattr(pt, "step")
        assert hasattr(pt, "height_km")
        assert hasattr(pt, "lat_deg")
        assert hasattr(pt, "lon_deg")
        assert hasattr(pt, "ground_range_km")
        assert hasattr(pt, "absorption")

    def test_invalid_frequency_raises(self):
        try:
            ionotrace.TraceConfig(-1.0, 20.0).trace()
            assert False, "Should have raised"
        except ValueError:
            pass

    def test_repr(self):
        cfg = ionotrace.TraceConfig(10.0, 20.0)
        assert "10" in repr(cfg)


class TestFanTrace:
    """Verify fan trace functionality."""

    def test_default_fan(self):
        config = ionotrace.FanTraceConfig()
        result = ionotrace.fan_trace(config)
        assert isinstance(result, ionotrace.FanTraceResult)
        assert result.n_rays > 0
        assert len(result.rays) == result.n_rays

    def test_custom_fan(self):
        config = ionotrace.FanTraceConfig(
            freq_mhz=15.0,
            elev_min=10.0,
            elev_max=40.0,
            elev_step=10.0,
        )
        result = ionotrace.fan_trace(config)
        assert result.n_rays >= 3  # 10, 20, 30, 40 degrees

    def test_fan_ray_fields(self):
        config = ionotrace.FanTraceConfig(elev_min=20.0, elev_max=30.0, elev_step=10.0)
        result = ionotrace.fan_trace(config)
        ray = result.rays[0]
        assert hasattr(ray, "elev")
        assert hasattr(ray, "max_h")
        assert hasattr(ray, "ground")
        assert hasattr(ray, "range_km")
        assert hasattr(ray, "pts")
        assert hasattr(ray, "hop_summaries")


class TestTargetSolver:
    """Verify target solver."""

    def test_basic_solve(self):
        config = ionotrace.TargetConfig(
            target_lat_deg=50.0,
            target_lon_deg=0.0,
            error_limit_km=50.0,
        )
        result = ionotrace.solve_target(config)
        assert isinstance(result, ionotrace.TargetResult)
        assert result.rays_traced > 0
        assert result.status is not None

    def test_repr(self):
        config = ionotrace.TargetConfig()
        assert "TargetConfig" in repr(config)


class TestExport:
    """Verify export methods."""

    def test_to_json(self):
        result = ionotrace.TraceConfig(10.0, 20.0).trace()
        json_str = result.to_json()
        assert "max_height" in json_str
        assert "points" in json_str

    def test_to_csv(self):
        result = ionotrace.TraceConfig(10.0, 20.0).trace()
        csv_str = result.to_csv()
        assert "height_km" in csv_str
        assert "step" in csv_str
