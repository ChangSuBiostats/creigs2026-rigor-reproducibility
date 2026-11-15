"""Rebuild every figure from the committed raw data snapshot.

Usage: python run_all.py   (inside the environment from environment.yml)

Steps: fetch any missing raw data, build derived tables, run each figure
script, then run the checks against the existing deck images.
"""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent

STEPS = [
    "data/get_data.py",
    "data/make_processed.py",
    *sorted(str(p.relative_to(ROOT)) for p in (ROOT / "figures").glob("fig[0-9][0-9]*.py")),
    "reference/check_slide02_a.py",
]

for step in STEPS:
    print(f"== {step}", flush=True)
    subprocess.run([sys.executable, str(ROOT / step)], check=True, cwd=ROOT)
print("all figures rebuilt")
