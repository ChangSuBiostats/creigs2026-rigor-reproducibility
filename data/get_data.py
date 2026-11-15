"""Download raw data for the CREiGS 2026 lecture figures.

Usage:
    python data/get_data.py            # download only what is missing
    python data/get_data.py --refresh  # re-download everything (new snapshot)

Each download is written to data/raw/ and logged in data/SOURCES.md with its
source URL, access date (UTC) and SHA-256 checksum. Files in data/raw/ are
never edited by hand.

The Svensson database is a live Google Sheet, so a re-download can differ from
the committed snapshot. Figures are built from the committed snapshot; use
--refresh only when you intend to update the figures to a newer version.
"""

from __future__ import annotations

import argparse
import hashlib
import subprocess
from datetime import datetime, timezone
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent
RAW_DIR = DATA_DIR / "raw"
SOURCES_MD = DATA_DIR / "SOURCES.md"

DATASETS = {
    "svensson_single_cell_studies.tsv": {
        "url": "https://nxn.se/single-cell-studies/data.tsv",
        "description": (
            "Single-cell studies database (Svensson, da Veiga Beltrame & Pachter "
            "2020, Database, doi:10.1093/database/baaa073). Live table; the URL "
            "redirects to a published Google Sheet."
        ),
    },
}

SOURCES_HEADER = """# Data sources

Written by `data/get_data.py`. One entry per download; do not edit by hand.
The newest entry for a file describes the copy currently in `data/raw/`.
"""


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def download(name: str, spec: dict) -> None:
    dest = RAW_DIR / name
    # nxn.se answers Python's default urllib client with HTTP 403 but serves
    # curl, so the download goes through the system curl (follows the redirect).
    payload = subprocess.run(
        ["curl", "--silent", "--show-error", "--fail", "--location",
         "--max-time", "120", spec["url"]],
        check=True, capture_output=True,
    ).stdout
    if not payload.strip():
        raise RuntimeError(f"{spec['url']} returned an empty file")
    dest.write_bytes(payload)
    accessed = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    n_lines = payload.count(b"\n")
    entry = (
        f"\n## {name}\n"
        f"- Description: {spec['description']}\n"
        f"- URL: {spec['url']}\n"
        f"- Accessed: {accessed}\n"
        f"- SHA-256: {sha256(dest)}\n"
        f"- Size: {len(payload)} bytes, {n_lines} lines\n"
    )
    if not SOURCES_MD.exists():
        SOURCES_MD.write_text(SOURCES_HEADER, encoding="utf-8")
    with SOURCES_MD.open("a", encoding="utf-8") as f:
        f.write(entry)
    print(f"downloaded {name} ({len(payload)} bytes)")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--refresh", action="store_true", help="re-download existing files")
    args = parser.parse_args()

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    for name, spec in DATASETS.items():
        if (RAW_DIR / name).exists() and not args.refresh:
            print(f"have {name}, skipping (use --refresh to update)")
            continue
        download(name, spec)


if __name__ == "__main__":
    main()
