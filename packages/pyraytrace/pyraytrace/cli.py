"""Command-line interface for pyraytrace.

Usage:
    python -m pyraytrace run configs/sample_case.yaml
    python -m pyraytrace run configs/sample_case.yaml --output results.json
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

import yaml

from pyraytrace.constants import EARTH_RADIUS
from pyraytrace.core.tracer import SimulationConfig, RayResult, run_ray
from pyraytrace.models.electron_density import Chapx, Elect1, Linear, Qparab
from pyraytrace.models.magnetic_field import Dipoly, Consty
from pyraytrace.models.collision import Expz2, Constz, Expz
from pyraytrace.models.refractive_index import Ahwfwc


# Model registries
ELECTRON_MODELS = {
    "chapx": Chapx,
    "elect1": Elect1,
    "linear": Linear,
    "qparab": Qparab,
}

MAGNETIC_MODELS = {
    "dipoly": Dipoly,
    "consty": Consty,
}

COLLISION_MODELS = {
    "expz2": Expz2,
    "constz": Constz,
    "expz": Expz,
}


def load_config(yaml_path: str) -> SimulationConfig:
    """Load simulation config from YAML file."""
    with open(yaml_path) as f:
        data = yaml.safe_load(f)

    tx = data.get("transmitter", {})
    ray = data.get("ray", {})
    integ = data.get("integration", {})
    output = data.get("output", {})

    # Build model params from the YAML
    model_params = {}
    for section in ["electron_density_params", "magnetic_field_params",
                    "collision_params"]:
        if section in data.get("models", {}):
            model_params.update(data["models"][section])

    return SimulationConfig(
        earth_r=tx.get("earth_radius", EARTH_RADIUS),
        xmtr_height=tx.get("height", 0.0),
        tx_lat_deg=tx.get("latitude", 40.0),
        tx_lon_deg=tx.get("longitude", -105.0),
        freq_mhz=tx.get("frequency", 10.0),
        ray_mode=-1.0 if ray.get("mode", "extraordinary") == "extraordinary" else 1.0,
        elevation_deg=ray.get("elevation", 20.0),
        azimuth_deg=ray.get("azimuth", 45.0),
        max_steps=integ.get("max_steps", 200),
        int_mode=integ.get("mode", 3),
        step_size=integ.get("step_size", 1.0),
        e1max=integ.get("e1max", 1.0e-4),
        e1min=integ.get("e1min", 2.0e-6),
        e2max=integ.get("e2max", 100.0),
        e2min=integ.get("e2min", 1.0e-8),
        fact=integ.get("fact", 0.5),
        print_every=output.get("print_every", 10),
        compute_phase_path=output.get("phase_path", True),
        compute_absorption=output.get("absorption", True),
        model_params=model_params,
    )


def build_rindex_model(yaml_path: str) -> Ahwfwc:
    """Build the refractive index model from YAML config."""
    with open(yaml_path) as f:
        data = yaml.safe_load(f)

    models = data.get("models", {})

    e_name = models.get("electron_density", "chapx")
    m_name = models.get("magnetic_field", "dipoly")
    c_name = models.get("collision", "expz2")

    e_model = ELECTRON_MODELS[e_name]()
    m_model = MAGNETIC_MODELS[m_name]()
    c_model = COLLISION_MODELS[c_name]()

    return Ahwfwc(e_model, m_model, c_model)


def print_results(result: RayResult, elapsed_ms: float):
    """Print ray tracing results to stdout."""
    print()
    print("=" * 60)
    print("  pyraytrace — Ray Tracing Results")
    print("=" * 60)
    print()
    print(f"  {'Step':>5}  {'Height(km)':>12}  {'T':>10}  {'Phase':>10}  {'Absorb':>10}  {'Event'}")
    print(f"  {'----':>5}  {'----------':>12}  {'--------':>10}  {'--------':>10}  {'--------':>10}  {'-----'}")

    for pt in result.points:
        print(f"  {pt.step:5d}  {pt.height_km:12.4f}  {pt.t:10.2f}  "
              f"{pt.phase_path:10.3f}  {pt.absorption:10.5f}  {pt.event}")

    print()
    print("=" * 30)
    print(f"  Max height:     {result.max_height:.2f} km")
    print(f"  Steps taken:    {result.n_steps}")
    print(f"  Ground return:  {result.returned_to_ground}")
    print(f"  Penetrated:     {result.penetrated}")
    print(f"  CPU time:       {elapsed_ms:.2f} ms")
    print("=" * 30)


def cmd_run(args):
    """Run a ray trace from a YAML config."""
    config = load_config(args.config)
    rindex_model = build_rindex_model(args.config)

    t_start = time.perf_counter()
    result = run_ray(config, rindex_model)
    elapsed_ms = (time.perf_counter() - t_start) * 1000.0

    print_results(result, elapsed_ms)

    if args.output:
        out_data = {
            "max_height_km": result.max_height,
            "n_steps": result.n_steps,
            "returned_to_ground": result.returned_to_ground,
            "penetrated": result.penetrated,
            "elapsed_ms": elapsed_ms,
            "points": [
                {
                    "step": pt.step, "t": pt.t,
                    "height_km": pt.height_km,
                    "phase_path": pt.phase_path,
                    "absorption": pt.absorption,
                    "event": pt.event,
                }
                for pt in result.points
            ],
        }
        with open(args.output, "w") as f:
            json.dump(out_data, f, indent=2)
        print(f"\n  Results saved to {args.output}")


def main():
    parser = argparse.ArgumentParser(
        prog="pyraytrace",
        description="3D ionospheric ray tracing engine",
    )
    sub = parser.add_subparsers(dest="command")

    run_parser = sub.add_parser("run", help="Run a ray trace simulation")
    run_parser.add_argument("config", help="Path to YAML config file")
    run_parser.add_argument("-o", "--output", help="Output JSON file path")

    args = parser.parse_args()

    if args.command == "run":
        cmd_run(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
