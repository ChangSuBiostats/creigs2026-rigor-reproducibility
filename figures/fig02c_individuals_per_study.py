"""fig02c: number of individuals (subjects) per study over time.

Slide:   2, "Rapid Growth in Single Cell Studies" (new panel)
Shows:   one point per study (publication date vs. number of individuals, log
         scale) and the median per calendar year, drawn at mid-year. The median
         is drawn only for years with at least MIN_PER_YEAR studies.
         Only studies where the database records "Number individuals" are
         included; that field is filled in for human studies only (see NOTES.md).
Data:    data/processed/svensson_studies.csv, built from the single-cell
         studies database snapshot logged in data/SOURCES.md.
Cite:    Svensson V, da Veiga Beltrame E, Pachter L (2020). A curated database
         reveals trends in single-cell transcriptomics. Database, baaa073.
Seed:    none (no randomness).
Output:  output/fig02c.png, output/fig02c.svg,
         data/processed/fig02c_yearly_median.csv
"""

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.ticker import FixedLocator, NullLocator, ScalarFormatter

import deckstyle as ds

START = pd.Timestamp("2012-01-01")  # drops one earlier study (2004, 2 individuals)
MIN_PER_YEAR = 5  # do not draw a median from fewer studies than this


def main() -> None:
    studies = pd.read_csv(ds.PROCESSED / "svensson_studies.csv", parse_dates=["date"])
    d = studies.dropna(subset=["n_individuals"]).query("date >= @START")

    yearly = (
        d.groupby("year")["n_individuals"]
        .agg(n_studies="size", median_individuals="median", max_individuals="max")
        .reset_index()
    )
    yearly["median_drawn"] = yearly["n_studies"] >= MIN_PER_YEAR
    yearly.to_csv(ds.PROCESSED / "fig02c_yearly_median.csv", index=False)
    line = yearly[yearly["median_drawn"]]
    mid_year = pd.to_datetime(line["year"].astype(str) + "-07-01")

    ds.apply(grid=True)
    fig, ax = plt.subplots(figsize=ds.HALF, layout="constrained")
    ax.scatter(d["date"], d["n_individuals"], s=5, color=ds.GRAY, alpha=0.5, linewidths=0,
               rasterized=True)
    ax.plot(mid_year, line["median_individuals"], color=ds.BLUE, lw=2, marker="o", ms=3.5)

    ax.set_yscale("log")
    ax.set_ylim(0.8, 2000)
    ax.yaxis.set_major_locator(FixedLocator([1, 10, 100, 1000]))
    ax.yaxis.set_minor_locator(NullLocator())
    ax.yaxis.set_major_formatter(ScalarFormatter())
    ax.set_xlim(START, pd.Timestamp("2027-03-01"))
    ax.xaxis.set_major_locator(mdates.YearLocator(base=4))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
    ax.set_xlabel("Publication date")
    ax.set_ylabel("Individuals per study")

    ax.annotate("Median per year", xy=(pd.Timestamp("2015-07-01"), 7.5),
                xytext=(pd.Timestamp("2012-05-01"), 60), ha="left", va="center",
                fontsize=10, color=ds.BLUE,
                arrowprops=dict(arrowstyle="-", color=ds.BLUE, lw=0.8, shrinkA=1, shrinkB=3))

    ds.save(fig, "fig02c")


if __name__ == "__main__":
    main()
