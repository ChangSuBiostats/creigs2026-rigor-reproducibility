# Notes

Findings, differences from the existing deck images, and gaps in the sources.
Numbers come from the snapshot logged in `data/SOURCES.md` (downloaded
2026-11-15; 2,202 studies dated 2002-07-26 to 2026-09-30).

## Data source

- The README path `github.com/vals/single_cell_studies` does not exist. The
  repository is `github.com/vals/single-cell-studies` (hyphens), and it holds
  only the analysis notebooks, last changed 2024-12-02. The table itself is a
  live Google Sheet served at `https://nxn.se/single-cell-studies/data.tsv`.
  That is the latest version and is what `data/get_data.py` downloads.
- The table is live, so a later download can differ. Figures are built from the
  committed snapshot in `data/raw/`.
- nxn.se answers Python's default `urllib` client with HTTP 403, so the download
  script calls the system `curl`.
- **Curation thins out after 2021.** Studies per year: 474 (2020), 328 (2021),
  216 (2022), 86 (2023), 77 (2024), 127 (2025), 34 (2026, to September). This
  reflects how much has been entered into the database, not how many studies
  were published. Recent entries are also less complete: the cell count is
  filled in for 98% of 2018 studies but 35% of 2025 studies. Yearly medians
  from 2023 onward rest on 8 to 45 studies.

## Slide 2

### fig02a (existing panel 1: cells per study over time)

Reconstructed from the database and it matches.

- What the existing panel shows: every study with a reported cell count, all
  measurement types (not only RNA-seq), dated 2009 or later; 1,539 studies.
  Eight earlier studies (2002 to 2008) with cell counts are left out.
- Check: `reference/check_slide02_a.py` locates the 18 median markers in the
  deck image and compares them with the medians computed here. All 18 agree to
  within 0.4 pixels on both axes (0.36 px on the y-axis is under 1% in cell
  count). The yearly medians are in `data/processed/fig02a_yearly_median.csv`.
- Axes: log y-axis from 1 to above 100M, x-axis 2009 to 2026; same in both.
- The labelled maximum is right: Tahoe-100M (Zhang et al., bioRxiv, 2025-02-24)
  reports 152,915,189 cells.
- **The title on the existing image overstates the trend.** "Cells per study
  grew ~1,000-fold in a decade" holds only for the most favourable window. The
  ratio of yearly medians ten years apart ranges from 165 to 926:
  2012 to 2022 is 926-fold, 2013 to 2023 is 761, 2014 to 2024 is 649,
  2015 to 2025 is 422, 2016 to 2026 is 556. "Several hundred-fold" is
  supported; "1,000-fold" is not. `fig02a` has no in-figure title (deck style),
  so the wording on the slide should be chosen with this in mind.
- The medians for 2009 to 2012 come from 2 to 4 studies each, and 2026 from 8.
  They are drawn as in the existing panel.

### fig02b (existing panel 2: tissues)

Reconstructed from the database and it matches: all 13 percentages agree to
the printed 0.1%, as do "Other" (31.7%) and its 197 tissues.

- What the existing panel shows: studies dated 2009 or later; the Tissue field
  split on commas; 2,365 tissue mentions across 210 distinct tissues.
- **The percentages are shares of tissue mentions, not of studies.** A study
  listing three tissues counts three times. The existing axis label,
  "Proportion (%)", does not say this; `fig02b` labels it "Share of tissue
  mentions (%)".
- 403 of the 2,202 studies have no tissue recorded and are not in the figure.
- "Culture" is the database's label for in vitro samples, so it is not a tissue
  in the same sense as the others; it is coloured separately, as in the
  existing panel.
- Style deviation: tissue names and value labels are 9 pt, not the 12 pt in the
  README. Fourteen rows do not fit in a 2.85 in panel at 12 pt. At 12 pt the
  figure would have to drop to about the top 8 tissues plus "Other".

### fig02c (new: individuals per study over time)

- The database does record this, in a column named "Number individuals". No
  alternative source was needed.
- Coverage: 714 of 2,202 studies have a value. It is filled in only for studies
  that include human samples (714 of 1,038 human studies; none of the
  non-human studies). The figure is therefore about human studies.
- The figure shows 713 studies from 2012 on; one 2004 study (2 individuals) is
  outside the x-axis range.
- Yearly median individuals per study: 3 (2016), 6 (2018), 10 (2020),
  11 (2022), 38 (2024), 23 (2025). The largest studies grew faster: the yearly
  maximum went from 88 (2016) to 259 (2020) to 1,047 (2025).
- The median line is drawn only for years with at least 5 studies (2015 to
  2025). The 2023 to 2025 medians rest on 23, 16 and 17 studies, so the jump in
  2024 is not firm evidence of a step change.
- The typical study is still small: the median over all 714 studies is 9
  individuals, and a quarter have 4 or fewer.

## Slide 3 (scoping only; nothing built yet)

What the Svensson database covers:

| Dimension | Field | Coverage | Usable? |
|---|---|---|---|
| Number of individuals | Number individuals | 714 studies, human only | Yes (this is fig02c) |
| Platform or technique | Technique | 94% of 2019 studies, 70% of 2022, 26% of 2025 | Yes, up to about 2022 |
| Platforms per study | Technique, split on " & " | 140 studies list more than one | Yes, but there is no upward trend (at most 15% of studies in any year) |
| Disease vs. control | Disease, Contrasts | Disease in 194 studies, Contrasts in 275, free text | Partly; too sparse and unstructured for a trend without recoding by hand |
| Longitudinal design | none (22 Contrasts entries mention time) | not recorded | No |
| Number of batches | none | not recorded | No |
| Tissues per study | Tissue, split on commas | 1,799 studies | Yes |

Batches, longitudinal design and a structured disease/control flag would need
another source (CELLxGENE Census sample metadata is the most promising: it has
donor, disease, assay and development stage per cell) or manual curation.
