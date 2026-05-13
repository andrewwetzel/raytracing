#!/usr/bin/env python3
"""
City-to-City HF Link Test Bank
===============================
Runs 600 city-pair link evaluations in parallel using the ionotrace
Python bindings and displays results with rich tables.

Usage:
    just test-bank          # via justfile
    python scripts/city_bank.py   # direct
"""

import csv
import math
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from rich.console import Console
from rich.live import Live
from rich.panel import Panel
from rich.progress import BarColumn, Progress, SpinnerColumn, TextColumn, TimeElapsedColumn
from rich.table import Table
from rich.text import Text

# ─── ensure ionotrace is importable from the workspace venv ──────
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "packages" / "ionotrace-python" / ".venv" / "lib" / "python3.12" / "site-packages"))
import ionotrace

# ═══════════════════════════════════════════════════════════════════
# Cities
# ═══════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class City:
    name: str
    lat: float
    lon: float

CITIES = [
    # ── North America ──
    City("New York",      40.7128,  -74.0060),
    City("Chicago",       41.8781,  -87.6298),
    City("Los Angeles",   34.0522, -118.2437),
    City("Miami",         25.7617,  -80.1918),
    City("Mexico City",   19.4326,  -99.1332),
    # ── Europe ──
    City("London",        51.5074,   -0.1278),
    City("Paris",         48.8566,    2.3522),
    City("Berlin",        52.5200,   13.4050),
    City("Moscow",        55.7558,   37.6173),
    City("Rome",          41.9028,   12.4964),
    City("Madrid",        40.4168,   -3.7038),
    City("Istanbul",      41.0082,   28.9784),
    # ── Middle East / Africa ──
    City("Cairo",         30.0444,   31.2357),
    City("Johannesburg", -26.2041,   28.0473),
    City("Nairobi",       -1.2921,   36.8219),
    # ── Asia ──
    City("Mumbai",        19.0760,   72.8777),
    City("Singapore",      1.3521,  103.8198),
    City("Tokyo",         35.6762,  139.6503),
    City("Beijing",       39.9042,  116.4074),
    City("Seoul",         37.5665,  126.9780),
    # ── Oceania ──
    City("Sydney",       -33.8688,  151.2093),
    # ── South America ──
    City("Sao Paulo",    -23.5505,  -46.6333),
    City("Buenos Aires", -34.6037,  -58.3816),
    City("Lima",         -12.0464,  -77.0428),
    City("Bogota",         4.7110,  -74.0721),
]

FREQ_SWEEP = [21.0, 15.0, 10.0, 7.0]

# ═══════════════════════════════════════════════════════════════════
# Geometry helpers
# ═══════════════════════════════════════════════════════════════════

def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    la1, lo1 = math.radians(lat1), math.radians(lon1)
    la2, lo2 = math.radians(lat2), math.radians(lon2)
    dlat, dlon = la2 - la1, lo2 - lo1
    a = math.sin(dlat / 2) ** 2 + math.cos(la1) * math.cos(la2) * math.sin(dlon / 2) ** 2
    return 2 * 6371.0 * math.asin(math.sqrt(a))


def initial_bearing(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    la1, lo1 = math.radians(lat1), math.radians(lon1)
    la2, lo2 = math.radians(lat2), math.radians(lon2)
    dlon = lo2 - lo1
    x = math.sin(dlon) * math.cos(la2)
    y = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dlon)
    return (math.degrees(math.atan2(x, y)) + 360) % 360


# ═══════════════════════════════════════════════════════════════════
# Solver
# ═══════════════════════════════════════════════════════════════════

def make_params() -> ionotrace.ModelParams:
    return ionotrace.ModelParams(
        earth_model=ionotrace.EarthModel.Sphere,
        mag_model=ionotrace.MagneticFieldModel.Dipole,
        rindex_model=ionotrace.RefractiveIndexModel.NoFieldWithCollisions,
        ed_model=ionotrace.ElectronDensityModel.Chapman,
        fc=14.0,
        hm=300.0,
        ym=100.0,
    )


@dataclass
class LinkResult:
    tx: str
    rx: str
    dist_km: float
    elev: float = 0.0
    error_km: float = 0.0
    hops: int = 0
    absorption_db: float = 0.0
    max_height_km: float = 0.0
    freq_mhz: float = 0.0
    path_type: str = "-"
    success: bool = False
    warnings: list[str] | None = None


def _try_solve(tx: City, rx: City, bearing: float, freq: float, max_hops: int) -> Optional[tuple]:
    """Try to solve a single freq/bearing combo. Returns (TargetSolution, freq) or None."""
    lon_diff = rx.lon - tx.lon
    params = make_params()
    config = ionotrace.TargetConfig(
        target_lat_deg=rx.lat,
        target_lon_deg=lon_diff,
        tx_lat_deg=tx.lat,
        freq_mhz=freq,
        azimuth_deg=bearing,
        ray_mode=1.0,
        error_limit_km=10.0,
        max_hops=max_hops,
        elev_min=1.0,
        elev_max=85.0,
        coarse_step=0.5,
        params=params,
    )
    try:
        result = ionotrace.solve_target(config)
        if result.best is not None:
            return (result.best, freq)
    except Exception:
        pass
    return None


def solve_pair(tx: City, rx: City) -> LinkResult:
    """Multi-strategy solver: tries 4 freqs × short path, then 4 freqs × long path."""
    dist_km = haversine_km(tx.lat, tx.lon, rx.lat, rx.lon)
    short_bearing = initial_bearing(tx.lat, tx.lon, rx.lat, rx.lon)
    long_bearing = (short_bearing + 180.0) % 360.0

    for path_type, bearing in [("short", short_bearing), ("long", long_bearing)]:
        for freq in FREQ_SWEEP:
            result = _try_solve(tx, rx, bearing, freq, max_hops=12)
            if result is not None:
                sol, f = result

                # Sanity checks
                warnings = []
                abs_db = abs(sol.absorption)
                max_h = sol.max_height_km

                if not math.isfinite(max_h) or max_h < 0 or max_h > 2000:
                    warnings.append(f"max_height={max_h:.0f}km")
                    max_h = -1.0
                if not math.isfinite(abs_db) or abs_db > 5000:
                    warnings.append(f"absorption={abs_db:.0f}dB")
                    abs_db = -1.0
                if not math.isfinite(sol.range_km) or sol.range_km < 0 or sol.range_km > 50000:
                    warnings.append(f"range={sol.range_km:.0f}km")
                if not math.isfinite(sol.elevation_deg) or sol.elevation_deg < 0 or sol.elevation_deg > 90:
                    warnings.append(f"elev={sol.elevation_deg:.1f}°")

                return LinkResult(
                    tx=tx.name, rx=rx.name, dist_km=dist_km,
                    elev=sol.elevation_deg, error_km=sol.error_km,
                    hops=sol.hops, absorption_db=abs_db,
                    max_height_km=max_h, freq_mhz=f,
                    path_type=path_type, success=True,
                    warnings=warnings if warnings else None,
                )

    return LinkResult(tx=tx.name, rx=rx.name, dist_km=dist_km)


# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

def main():
    console = Console()
    pairs = [(tx, rx) for tx in CITIES for rx in CITIES if tx.name != rx.name]
    total = len(pairs)

    console.print()
    console.print(Panel.fit(
        f"[bold cyan]City-to-City HF Link Test Bank[/]\n"
        f"[dim]{len(CITIES)} cities · {total} pairs · Chapman (foF2=14, hmF2=300, ym=100)[/]\n"
        f"[dim]Frequencies: {', '.join(f'{f:.0f} MHz' for f in FREQ_SWEEP)}[/]\n"
        f"[dim]Max hops: 12 · Short path + long path fallback[/]",
        border_style="bright_blue",
    ))
    console.print()

    results: list[LinkResult] = []
    t0 = time.time()

    # Run in parallel with threads — Rust releases the GIL so threads give
    # true parallelism without the massive RAM overhead of forking processes.
    max_workers = min(8, len(pairs))
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(bar_width=40),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TextColumn("({task.completed}/{task.total})"),
        TimeElapsedColumn(),
        console=console,
    ) as progress:
        task = progress.add_task("Solving city pairs...", total=total)

        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(solve_pair, tx, rx): (tx, rx) for tx, rx in pairs}
            for future in as_completed(futures):
                result = future.result()
                results.append(result)
                progress.advance(task)

    elapsed = time.time() - t0

    # ── Build results table ──────────────────────────────
    successes = [r for r in results if r.success]
    failures  = [r for r in results if not r.success]
    warned    = [r for r in successes if r.warnings]
    successes.sort(key=lambda r: r.error_km)

    # ── Summary panel ────────────────────────────────────
    freq_counts: dict[str, int] = {}
    for r in successes:
        key = f"{r.freq_mhz:.0f} MHz"
        freq_counts[key] = freq_counts.get(key, 0) + 1

    short_count = sum(1 for r in successes if r.path_type == "short")
    long_count  = sum(1 for r in successes if r.path_type == "long")
    avg_err = sum(r.error_km for r in successes) / len(successes) if successes else 0
    valid_abs = [r.absorption_db for r in successes if r.absorption_db >= 0]
    avg_abs = sum(valid_abs) / len(valid_abs) if valid_abs else 0
    min_abs = min(valid_abs) if valid_abs else 0
    max_abs = max(valid_abs) if valid_abs else 0

    summary = Table(show_header=False, box=None, padding=(0, 2))
    summary.add_column(style="bold")
    summary.add_column()
    summary.add_row("Pairs tested",     f"{total}")
    summary.add_row("Paths solved",     f"[bold green]{len(successes)}[/] ({100*len(successes)/total:.1f}%)")
    summary.add_row("Unsolved",         f"[bold red]{len(failures)}[/]")
    summary.add_row("Warnings",         f"[bold yellow]{len(warned)}[/]" if warned else "0")
    summary.add_row("", "")
    summary.add_row("Short path",       f"{short_count}")
    summary.add_row("Long path",        f"{long_count}")
    summary.add_row("", "")
    summary.add_row("Avg error",        f"{avg_err:.2f} km")
    summary.add_row("Avg absorption",   f"{avg_abs:.1f} dB")
    summary.add_row("Absorption range", f"{min_abs:.1f} – {max_abs:.1f} dB")
    summary.add_row("", "")
    summary.add_row("By frequency",     "  ".join(f"{f}={c}" for f, c in sorted(freq_counts.items())))
    summary.add_row("", "")
    summary.add_row("Elapsed",          f"{elapsed:.1f}s")

    console.print()
    console.print(Panel(summary, title="[bold]Summary[/]", border_style="green", width=60))

    # ── Solved paths table ───────────────────────────────
    table = Table(
        title=f"Solved Paths ({len(successes)}, sorted by error)",
        title_style="bold cyan",
        show_lines=False,
        row_styles=["", "dim"],
    )
    table.add_column("", width=2)
    table.add_column("TX",          min_width=14)
    table.add_column("RX",          min_width=14)
    table.add_column("Dist (km)",   justify="right")
    table.add_column("Elev (°)",    justify="right")
    table.add_column("Hops",        justify="right")
    table.add_column("Error (km)",  justify="right")
    table.add_column("Absorp (dB)", justify="right")
    table.add_column("MaxAlt (km)", justify="right")
    table.add_column("Freq (MHz)",  justify="right")
    table.add_column("Path",        justify="center")

    for r in successes:
        icon = "⚠️" if r.warnings else "✅"
        abs_str = f"{r.absorption_db:.1f}" if r.absorption_db >= 0 else "⚠️"
        alt_str = f"{r.max_height_km:.0f}" if r.max_height_km >= 0 else "⚠️"
        table.add_row(
            icon,
            r.tx, r.rx,
            f"{r.dist_km:.0f}",
            f"{r.elev:.1f}",
            str(r.hops),
            f"{r.error_km:.1f}",
            abs_str, alt_str,
            f"{r.freq_mhz:.0f}",
            r.path_type,
        )

    console.print()
    console.print(table)

    # ── Unsolved table ───────────────────────────────────
    if failures:
        fail_table = Table(
            title=f"Unsolved Pairs ({len(failures)})",
            title_style="bold red",
            show_lines=False,
        )
        fail_table.add_column("TX", min_width=14)
        fail_table.add_column("RX", min_width=14)
        fail_table.add_column("Dist (km)", justify="right")
        failures.sort(key=lambda r: r.dist_km, reverse=True)
        for r in failures:
            fail_table.add_row(r.tx, r.rx, f"{r.dist_km:.0f}")
        console.print()
        console.print(fail_table)

    # ── Warnings table ───────────────────────────────────
    if warned:
        warn_table = Table(
            title=f"Sanity Warnings ({len(warned)})",
            title_style="bold yellow",
        )
        warn_table.add_column("TX", min_width=14)
        warn_table.add_column("RX", min_width=14)
        warn_table.add_column("Issues")
        for r in warned:
            warn_table.add_row(r.tx, r.rx, ", ".join(r.warnings))
        console.print()
        console.print(warn_table)

    # ── CSV export ───────────────────────────────────────
    csv_path = Path("city_bank_results.csv")
    with open(csv_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["tx", "rx", "dist_km", "elev_deg", "hops", "error_km",
                     "absorption_db", "max_height_km", "freq_mhz", "path_type", "success"])
        for r in results:
            w.writerow([r.tx, r.rx, f"{r.dist_km:.1f}", f"{r.elev:.1f}", r.hops,
                         f"{r.error_km:.1f}", f"{r.absorption_db:.1f}",
                         f"{r.max_height_km:.0f}", f"{r.freq_mhz:.0f}",
                         r.path_type, r.success])

    console.print()
    console.print(f"  [dim]Results saved to {csv_path}[/]")
    console.print()


if __name__ == "__main__":
    main()
