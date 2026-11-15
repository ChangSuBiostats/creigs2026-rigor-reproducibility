"""fig02a: cells reported per study over time.

Slide:   2, "Rapid Growth in Single Cell Studies" (first panel)
Shows:   one point per study (publication date vs. reported total cells, log
         scale) and the median per calendar year, drawn at mid-year.
         Reconstruction of the existing panel reference/slide02_1.png, which
         uses all measurement types and studies dated 2009 or later.
Data:    data/processed/svensson_studies.csv, built from the single-cell
         studies database snapshot logged in data/SOURCES.md.
Cite:    Svensson V, da Veiga Beltrame E, Pachter L (2020). A curated database
         reveals trends in single-cell transcriptomics. Database, baaa073.
Seed:    none (no randomness).
Output:  output/fig02a.png, output/fig02a.svg,
         data/processed/fig02a_yearly_median.csv
"""

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.ticker import FixedLocator, FuncFormatter, NullLocator

import deckstyle as ds

START = pd.Timestamp("2009-01-01")  # same cut as the existing panel


def si(value: float, _pos=None) -> str:
    for size, suffix in ((1e6, "M"), (1e3, "k")):
        if value >= size:
            return f"{value / size:g}{suffix}"
    return f"{value:g}"


def main() -> None:
    studies = pd.read_csv(ds.PROCESSED / "svensson_studies.csv", parse_dates=["date"])
    d = studies.dropna(subset=["cells"]).query("date >= @START")

    yearly = (
        d.groupby("year")["cells"].agg(n_studies="size", median_cells="median").reset_index()
    )
    yearly.to_csv(ds.PROCESSED / "fig02a_yearly_median.csv", index=False)
    mid_year = pd.to_datetime(yearly["year"].astype(str) + "-07-01")

    ds.apply(grid=True)
    fig, ax = plt.subplots(figsize=ds.HALF, layout="constrained")
    ax.scatter(d["date"], d["cells"], s=4, color=ds.GRAY, alpha=0.45, linewidths=0,
               rasterized=True)
    ax.plot(mid_year, yearly["median_cells"], color=ds.BLUE, lw=2, marker="o", ms=3.5)

    ax.set_yscale("log")
    ax.set_ylim(1, 4e8)
    ax.yaxis.set_major_locator(FixedLocator([1, 1e2, 1e4, 1e6, 1e8]))
    ax.yaxis.set_minor_locator(NullLocator())
    ax.yaxis.set_major_formatter(FuncFormatter(si))
    ax.set_xlim(pd.Timestamp("2008-10-01"), pd.Timestamp("2027-03-01"))
    ax.xaxis.set_major_locator(mdates.YearLocator(base=5))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
    ax.set_xlabel("Publication date")
    ax.set_ylabel("Cells per study")

    # Direct labels instead of a legend.
    ax.annotate("Median per year", xy=(pd.Timestamp("2020-07-01"), 3.4e4),
                xytext=(pd.Timestamp("2018-03-01"), 12), ha="left", va="center",
                fontsize=10, color=ds.BLUE,
                arrowprops=dict(arrowstyle="-", color=ds.BLUE, lw=0.8, shrinkA=1, shrinkB=3))
    top = d.loc[d["cells"].idxmax()]
    ax.annotate(f"Tahoe-100M\n{top['cells'] / 1e6:.0f}M cells", xy=(top["date"], top["cells"]),
                xytext=(-8, 0), textcoords="offset points", ha="right", va="center",
                fontsize=10, color=ds.TEXT2, linespacing=1.0)

    ds.save(fig, "fig02a")


if __name__ == "__main__":
    main()
