"""Build derived tables in data/processed/ from the raw Svensson snapshot.

Input:  data/raw/svensson_single_cell_studies.tsv  (never edited by hand)
Output: data/processed/svensson_studies.csv   one row per study, parsed fields
        data/processed/svensson_tissues.csv   one row per (study, tissue) mention

Nothing is imputed: fields missing in the source stay missing.
No randomness, so no seed.
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd

DATA_DIR = Path(__file__).resolve().parent
RAW = DATA_DIR / "raw" / "svensson_single_cell_studies.tsv"
PROCESSED = DATA_DIR / "processed"


def to_number(col: pd.Series) -> pd.Series:
    """'1,234' -> 1234.0; fail loudly on anything that is not a number."""
    cleaned = col.str.replace(",", "", regex=False).str.strip()
    return pd.to_numeric(cleaned, errors="raise")


def main() -> None:
    raw = pd.read_csv(RAW, sep="\t", dtype=str)
    assert raw["DOI"].is_unique, "expected one row per DOI"

    studies = pd.DataFrame({
        "doi": raw["DOI"],
        "shorthand": raw["Shorthand"],
        "title": raw["Title"],
        "journal": raw["Journal"],
        "date": pd.to_datetime(raw["Date"], format="%Y%m%d", errors="raise"),
        "cells": to_number(raw["Reported cells total"]),
        "n_individuals": to_number(raw["Number individuals"]),
        "organism": raw["Organism"],
        "tissue": raw["Tissue"],
        "technique": raw["Technique"],
        "measurement": raw["Measurement"],
        "disease": raw["Disease"],
        "contrasts": raw["Contrasts"],
    })
    studies["year"] = studies["date"].dt.year
    studies = studies.sort_values(["date", "doi"]).reset_index(drop=True)

    # A study can list several tissues separated by commas; one row per mention.
    tissues = (
        studies[["doi", "date", "year", "tissue"]]
        .dropna(subset=["tissue"])
        .assign(tissue=lambda d: d["tissue"].str.split(","))
        .explode("tissue")
        .assign(tissue=lambda d: d["tissue"].str.strip())
        .query("tissue != ''")
        .reset_index(drop=True)
    )

    PROCESSED.mkdir(exist_ok=True)
    studies.to_csv(PROCESSED / "svensson_studies.csv", index=False, date_format="%Y-%m-%d")
    tissues.to_csv(PROCESSED / "svensson_tissues.csv", index=False, date_format="%Y-%m-%d")
    print(f"wrote svensson_studies.csv ({len(studies)} studies, "
          f"{studies['date'].min():%Y-%m-%d} to {studies['date'].max():%Y-%m-%d}; "
          f"{studies['cells'].notna().sum()} with cell counts, "
          f"{studies['n_individuals'].notna().sum()} with number of individuals)")
    print(f"wrote svensson_tissues.csv ({len(tissues)} tissue mentions, "
          f"{tissues['tissue'].nunique()} distinct)")


if __name__ == "__main__":
    main()
