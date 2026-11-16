# CREiGS 2026 — Rigor and Reproducibility in Single-Cell Genomics: figures

Lecture: Chang Su, CREiGS 2026 (Icahn School of Medicine at Mount Sinai), Nov 18, 2026.
This repo makes every figure in the lecture deck reproducible. It does not edit the deck;
figures are placed into the .pptx separately.

## Ground rules
- All code is R (tidyverse and ggplot2). One script per figure:
  `figures/figNN_short_name.R`. The script reads from `data/`, writes to `output/`, and
  makes no other changes. Run scripts from the repository root.
- Raw data in `data/raw/` is never edited by hand. Downloads are scripted in
  `data/get_data.R`, which records the source URL, access date and file checksum in
  `data/SOURCES.md`.
- Derived tables go in `data/processed/` and are produced by scripts.
- `make all` (or `Rscript run_all.R`) rebuilds every figure from scratch.
- Pin the environment (`renv.lock`; restore with `renv::restore()`). Set seeds for anything random,
  and record the seed in the script header.
- Commit after each figure is working. Message format: `figNN: <what changed>`.
- Each script starts with a header that gives the slide number, what the figure shows,
  the data source and citation, and the seed.
- Never invent data. If a field isn't in the source, say so in `NOTES.md` rather than
  imputing it.

## Figure style (must match the deck)
- Font: Georgia, falling back to serif. Axis labels 14 pt, tick labels 12 pt; no
  in-figure titles (the slide carries the title).
- Colors: highlight color #4472C4 (blue), secondary color #ED7D31 (orange), neutral
  #A5A5A5, text #000000, secondary text #44546A. Use gray for context and blue for the
  series that carries the message.
- No top or right spines, no gridlines on bar charts, light gray (#E7E6E6) horizontal
  gridlines on line and scatter charts. Label series directly, with no legend where possible.
- Sizes (in inches, at 300 dpi):
  - half-slide panel: 3.9 × 2.85 (matches the existing figures on slide 2)
  - full content area: 10.2 × 4.8
- Export both `output/figNN.png` (300 dpi) and `output/figNN.svg`.
- White background, no transparency.

## Tasks

### Slide 2: "Rapid Growth in Single Cell Studies" (done; see `NOTES.md`)
Source: Svensson, da Veiga Beltrame & Pachter (2020), *A curated database reveals trends in
single-cell transcriptomics*, Database. The live table is at
nxn.se/single-cell-studies/data.tsv (the notebooks are at github.com/vals/single-cell-studies).
Final design, three panels: `fig02c` publications per year (PubMed count), `fig02a` cells
per study, `fig02b` tissue share. Original tasks, kept for the record:
1. **Verify the two existing figures.** Another agent made them. Reconstruct each one
   from the database (copies of the current images go in `reference/slide02_*.png`),
   then compare and record any differences in `NOTES.md`: axes, counts, date range,
   log scale.
   - `fig02a`: the first existing panel, reproduced
   - `fig02b`: the second existing panel, reproduced
2. **New figure: number of subjects (individuals) per study over time.** Built first
   from the Svensson database, then moved to slide 3 as `fig03a` using CELLxGENE.
   Publication date on the x-axis, subjects per study on the y-axis (log scale if the
   range calls for it); points plus a smoothed trend or yearly median. First check
   whether the database records the number of individuals or donors. If it doesn't,
   report that and propose an alternative (e.g., samples per study, or a manually
   curated subset) before building anything.

### Slide 3: "Increasing Complexity of Single Cell Studies" (done; see `NOTES.md`)
Decision (Chang, Nov 16): use CELLxGENE Discover only. `fig03a` donors per study over
time; `fig03b` share of studies with disease and control donors, and with more than one
assay. Batches and longitudinal design are not recorded there. Original brief:
Summarize how study design has become more complex over time:
- Technical: number of batches, sequencing platform or technique (and how many
  platforms per study)
- Biological: number of individuals, disease vs. control design, longitudinal design
Start with what the Svensson database already has (technique, date, tissue, and
possibly sample counts). List which dimensions are covered and which would need
manual curation or another source (e.g., CELLxGENE Census metadata, HCA). Propose
1–2 figures (`fig03a`, `fig03b`) and confirm with Chang before curating anything by hand.

### Slide 5: "Rapid Growth in Single Cell Analysis Tools" (done; see `NOTES.md`)
Redrawn from the scRNA-tools database, because the paper figure ends in 2021. Original brief:
The plan is to reuse a figure from a review. If Chang wants it redrawn in deck style,
use the scRNA-tools database (Zappia & Theis 2021, *Over 1000 tools reveal trends in the
single-cell RNA-seq analysis landscape*, Genome Biology; data believed to be at
github.com/scRNA-tools/scRNA-tools) for `fig05a`: cumulative tools over time, and
`fig05b`: tools per analysis category.

### Example 3, differential expression: `fig07d_1` to `fig07d_6` (done; see `NOTES.md`)
Request (Chang, Nov 16): a bulk-style contrast to the single-cell volcano plot in Gibson
(2022) Fig. 1A, and the null experiment of Squair et al. (2021), in R. Built from the
untreated donors of Kang et al. (2018): `data/make_null_de.R`, then four figures.

### Slide 7: four examples where the standard pipeline compromises rigor
Don't work on this slide for now. I have materials from my own course. You could help me evaluate
later if we should add anything to my slides.
Simulation-based. Use Seurat or Scanpy defaults as the "standard pipeline" and keep
every simulation small enough to run in minutes. One script per example, with a fixed seed:
- `fig07a` **Dimension reduction**: how UMAP can mislead interpretation (e.g., distances
  between clusters and cluster sizes are not meaningful; the result depends on
  n_neighbors and min_dist).
- `fig07b` **Clustering**: how spurious clusters arise (e.g., clustering homogeneous
  data at high resolution, and double dipping when the same data is used to find
  clusters and then test for markers).
- `fig07c` **Batch correction**: how over-correction removes biological signal (a
  simulated condition effect that is confounded with batch, before vs. after
  integration).
- `fig07d` **Differential expression**: how pseudo-replication leads to over-confidence
  (cell-level tests vs. pseudobulk on simulated data with no true effect: p-value
  histograms and false positive rate).
Each example may need two panels (the problem, and what the rigorous approach shows);
name them `fig07a_1`, `fig07a_2`, and so on.

## Repo layout
```
data/raw/  data/processed/  data/get_data.R  data/make_processed.R  data/make_null_de.R
data/SOURCES.md
figures/   output/          reference/
NOTES.md   run_all.R  Makefile  renv.lock  README.md
