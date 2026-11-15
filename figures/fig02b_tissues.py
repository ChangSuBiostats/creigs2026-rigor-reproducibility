"""fig02b: which tissues single-cell studies profile.

Slide:   2, "Rapid Growth in Single Cell Studies" (second panel)
Shows:   share of tissue mentions for the 13 most common tissues, with all
         remaining tissues pooled as "Other". A study that lists several
         tissues counts once per tissue, so the denominator is tissue mentions,
         not studies. Reconstruction of the existing panel
         reference/slide02_2.png, which uses studies dated 2009 or later.
Data:    data/processed/svensson_tissues.csv, built from the single-cell
         studies database snapshot logged in data/SOURCES.md.
Cite:    Svensson V, da Veiga Beltrame E, Pachter L (2020). A curated database
         reveals trends in single-cell transcriptomics. Database, baaa073.
Seed:    none (no randomness).
Output:  output/fig02b.png, output/fig02b.svg,
         data/processed/fig02b_tissue_share.csv
"""

import matplotlib.pyplot as plt
import pandas as pd

import deckstyle as ds

START = pd.Timestamp("2009-01-01")  # same cut as the existing panel
TOP_N = 13
IN_VITRO = "Culture"


def main() -> None:
    tissues = pd.read_csv(ds.PROCESSED / "svensson_tissues.csv", parse_dates=["date"])
    d = tissues.query("date >= @START")

    counts = d["tissue"].value_counts()
    top = counts.head(TOP_N)
    n_other = len(counts) - TOP_N
    other_label = f"Other ({n_other} tissues)"
    table = pd.concat([top, pd.Series({other_label: counts.iloc[TOP_N:].sum()})])
    table = table.rename_axis("tissue").reset_index(name="mentions")
    table["share_pct"] = 100 * table["mentions"] / len(d)
    table.to_csv(ds.PROCESSED / "fig02b_tissue_share.csv", index=False)

    colors = [ds.GRAY if t == other_label else ds.ORANGE if t == IN_VITRO else ds.BLUE
              for t in table["tissue"]]

    ds.apply(grid=False)
    fig, ax = plt.subplots(figsize=ds.HALF, layout="constrained")
    y = range(len(table))
    ax.barh(y, table["share_pct"], color=colors, height=0.72)
    ax.set_yticks(y, table["tissue"], fontsize=9)  # 14 rows do not fit at 12 pt
    ax.invert_yaxis()
    ax.tick_params(axis="y", length=0)
    ax.set_ylim(len(table) - 0.45, -0.55)
    for yi, (tissue, share, color) in enumerate(zip(table["tissue"], table["share_pct"], colors)):
        label = f"{share:.1f}%" + ("  in vitro" if tissue == IN_VITRO else "")
        ax.text(share + 0.5, yi, label, va="center", ha="left", fontsize=9,
                color=ds.ORANGE if tissue == IN_VITRO else ds.TEXT)
    ax.set_xlim(0, 39)
    ax.set_xticks([0, 10, 20, 30])
    ax.set_xlabel("Share of tissue mentions (%)")

    ds.save(fig, "fig02b")


if __name__ == "__main__":
    main()
