"""Shared figure style for the CREiGS 2026 deck (see README, "Figure style").

Imported by every figNN script so that all figures match the slides.
"""

from __future__ import annotations

from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
PROCESSED = ROOT / "data" / "processed"
OUTPUT = ROOT / "output"

BLUE = "#4472C4"      # highlight: the series that carries the message
ORANGE = "#ED7D31"    # secondary
GRAY = "#A5A5A5"      # neutral / context
TEXT = "#000000"
TEXT2 = "#44546A"     # secondary text
GRID = "#E7E6E6"

HALF = (3.9, 2.85)    # half-slide panel, inches
FULL = (10.2, 4.8)    # full content area, inches
DPI = 300


def apply(grid: bool = False) -> None:
    """Set rcParams. grid=True adds light horizontal gridlines (line/scatter charts)."""
    mpl.rcParams.update({
        "font.family": "serif",
        "font.serif": ["Georgia", "DejaVu Serif"],
        "axes.labelsize": 14,
        "xtick.labelsize": 12,
        "ytick.labelsize": 12,
        "axes.labelcolor": TEXT,
        "text.color": TEXT,
        "xtick.color": TEXT,
        "ytick.color": TEXT,
        "axes.edgecolor": TEXT,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.grid": grid,
        "axes.grid.axis": "y",
        "grid.color": GRID,
        "grid.linewidth": 0.8,
        "axes.axisbelow": True,
        "legend.frameon": False,
        "figure.facecolor": "white",
        "axes.facecolor": "white",
        "savefig.facecolor": "white",
        "savefig.transparent": False,
        "svg.fonttype": "none",   # keep text as text in the SVG
        "svg.hashsalt": "creigs2026",  # stable SVG ids across rebuilds
    })


def save(fig: plt.Figure, name: str) -> None:
    """Write output/<name>.png (300 dpi) and output/<name>.svg at the exact figure size."""
    OUTPUT.mkdir(exist_ok=True)
    fig.savefig(OUTPUT / f"{name}.png", dpi=DPI)
    fig.savefig(OUTPUT / f"{name}.svg", metadata={"Date": None})
    plt.close(fig)
    print(f"wrote output/{name}.png and output/{name}.svg")
