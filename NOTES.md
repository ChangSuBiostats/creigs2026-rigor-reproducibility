# Notes

Findings, differences from the existing deck images, and gaps in the sources.
All numbers come from the snapshots logged in `data/SOURCES.md`.

## Code and environment

- All code is R (tidyverse, ggplot2), run with R 4.5.2. Package versions are in
  `renv.lock`; restore them with `renv::restore()`. The project is not
  renv-activated (no `renv/` folder), so the scripts use whichever library is
  on the path; the lockfile records what the committed figures were built with.
- The first version of this repository was Python (commits up to `2875ee9`).
  The R port reproduces the same processed numbers.
- `Rscript run_all.R` twice in a row gives byte-identical files in `output/`
  and `data/processed/`.

## Data sources

### Svensson single-cell studies database (slide 2)

- Snapshot of 2026-11-15: 2,202 studies dated 2002-07-26 to 2026-09-30.
- The path in the original brief, `github.com/vals/single_cell_studies`, does
  not exist. The repository is `github.com/vals/single-cell-studies`
  (hyphens) and holds only notebooks. The table is a live Google Sheet served
  at `https://nxn.se/single-cell-studies/data.tsv`.
- nxn.se answers the default R and Python download clients with HTTP 403, so
  `data/get_data.R` calls the system `curl`.
- **Curation thins out after 2021.** Studies per year: 474 (2020), 328 (2021),
  216 (2022), 86 (2023), 77 (2024), 127 (2025), 34 (2026, to September). This
  reflects how much has been entered, not how many studies were published.
  Recent entries are also less complete: the cell count is filled in for 98% of
  2018 studies but 35% of 2025 studies. Yearly medians from 2023 onward rest on
  8 to 45 studies, and the recent entries may be skewed towards notable large
  studies (not tested). Decision (Chang, Nov 16): keep all years in the figure
  and say on the slide that 2023 onward is sparsely curated.

### PubMed (slide 2)

- One record count per publication year, 2009 to 2025, from NCBI E-utilities.
  The query (title or abstract; reviews excluded) is in `data/get_data.R` and
  `data/SOURCES.md`.
- The count depends on the query. It shows the trend, not an exact number of
  studies: it misses papers that do not name the method in the title or
  abstract, and it includes methods and reanalysis papers.
- 2026 is left out because the year is incomplete.
- The script stops if PubMed reports that it could not match a phrase as
  written, since PubMed otherwise rewrites the query silently.

### CELLxGENE Discover (slide 3)

- Snapshot of 2026-11-16 from the public curation API: 406 collections holding
  2,295 datasets, 343 collections with human data.
- **Unit of analysis is the collection**, which corresponds to one publication.
  Datasets are not used as the unit because one study is often split into many
  datasets (for example one per cell type) that share donors.
- Publication date is the paper's date from the publisher metadata, not the
  date the data were added to CELLxGENE. 11 collections have no publication
  metadata and are left out of the figures. 35 collections are preprints.
- **This is not a census of the literature.** CELLxGENE holds data that authors
  or consortia chose to deposit and that met its schema, so it leans towards
  human, 10x and atlas-scale studies. Trends describe studies in CELLxGENE.
- 2026 is a partial year (to mid-November).

## Slide 2

### fig02a (cells per study over time; existing panel 1)

Reconstructed from the database and it matches the existing panel.

- What the existing panel shows: every study with a reported cell count, all
  measurement types (not only RNA-seq), dated 2009 or later; 1,539 studies.
  Eight earlier studies (2002 to 2008) with cell counts are left out.
- Check: `reference/check_slide02_a.R` locates the 18 median markers in the
  deck image and compares them with the medians computed here. All 18 agree to
  within 0.4 pixels on both axes (0.36 px on the y-axis is under 1% in cell
  count). The build fails if they ever differ by more than a pixel.
- The largest study is Tahoe-100M (Zhang et al., bioRxiv, 2025-02-24) with
  152,915,189 cells. The existing panel labels it; `fig02a` does not, to keep
  the figure clean.
- **The title on the existing image overstates the trend.** "Cells per study
  grew ~1,000-fold in a decade" holds only for the most favourable window. The
  ratio of yearly medians ten years apart ranges from 165 to 926:
  2012 to 2022 is 926-fold, 2013 to 2023 is 761, 2014 to 2024 is 649,
  2015 to 2025 is 422, 2016 to 2026 is 556. "Several hundred-fold" is
  supported; "1,000-fold" is not.
- The medians for 2009 to 2012 come from 2 to 4 studies each, and 2026 from 8.
  They are drawn as in the existing panel.

### fig02b (tissues; existing panel 2)

Reconstructed from the database and it matches: all 13 percentages agree to
the printed 0.1%, as do "Other" (31.7%) and its 197 tissues.

- What the existing panel shows: studies dated 2009 or later; the Tissue field
  split on commas; 2,365 tissue mentions across 210 distinct tissues.
- **The percentages are shares of tissue mentions, not of studies.** A study
  listing three tissues counts three times. The existing axis label,
  "Proportion (%)", does not say this; `fig02b` labels it "Share of tissue
  mentions (%)".
- 403 of the 2,202 studies have no tissue recorded and are not in the figure.
- "Culture" is the database's label for in vitro samples, so it is coloured
  separately, as in the existing panel.
- Style deviation: tissue names and value labels are 9 pt, not the 12 pt in the
  README. Fourteen rows do not fit in a 2.85 in panel at 12 pt.

### fig02c (publications per year; new)

- PubMed records rise from 19 (2013) to 1,100 (2019) to 11,744 (2025).
- Caveats are under "PubMed" above.

### Individuals per study from the Svensson database (dropped)

The Svensson table has a "Number individuals" column (714 studies, human
only). A figure from it was built in the Python version (commit `0132de0`) and
then replaced by `fig03a`, which uses CELLxGENE, following the decision to
build slide 3 from CELLxGENE only. The two sources agree on the scale: the
Svensson yearly median was 10 in 2020 and 11 in 2022; CELLxGENE gives 11 and 18.

## Slide 3

### What CELLxGENE covers

| Dimension | Field | Usable? |
|---|---|---|
| Number of individuals | `donor_id` | Yes (`fig03a`) |
| Disease vs. control | `disease` ("normal" marks unaffected donors) | Yes (`fig03b`) |
| Platform | `assay` | Yes (`fig03b`) |
| Number of batches | `batch_condition` | No. It names the columns the authors declared as batch variables, is filled in for 475 of 2,295 datasets, and does not give a number of batches. |
| Longitudinal design | none | No. `development_stage` gives donor age, not repeated sampling of the same donor. |

Batches and longitudinal design would need manual curation or reading the
per-cell data of each dataset. Neither was done.

### fig03a (donors per study over time)

- 330 human collections with a publication date and at least one donor
  (3 human collections have only placeholder donor labels and are left out).
- Donor labels "pooled", "unknown", "na" and similar are not counted.
- Yearly median donors per study: 5 (2019), 11 (2020), 11.5 (2021), 18 (2022),
  18 (2023), 20 (2024), 19 (2025), 23 (2026). The largest study per year grew
  from 57 (2020) to 981 (2022) to 1,606 (2026).
- The median roughly doubled between 2020 and 2022 and has risen slowly since.
  The upper tail grew much faster than the median.
- The median line is drawn for years with at least 5 collections (2018 on).
  2018 has 6 collections and 2019 has 11, so the dip in 2019 is noise.
- Donor identifiers are the authors' labels. If one collection uses two
  labels for the same person, that person is counted twice.

### fig03b (design complexity by period)

Share of human collections, by publication period:

| Period | Collections | Disease and control donors | More than one assay |
|---|---|---|---|
| 2018 to 2020 | 47 | 23% | 23% |
| 2021 to 2023 | 135 | 43% | 47% |
| 2024 to 2026 | 148 | 41% | 41% |

- **Both shares rose after 2020 and then levelled off.** The data support
  "more complex than in 2018 to 2020", not "still increasing".
- Years are pooled into three-year periods because single years have as few as
  6 collections and the yearly lines were noisy.
- "Disease and control donors" means the collection has at least one donor
  labelled "normal" and at least one labelled with a disease. It does not
  check that the comparison is the aim of the study.
- "More than one assay" counts distinct assay labels, so two chemistry
  versions of the same platform (10x 3' v2 and v3) count as two. It is a
  measure of technical heterogeneity within a study, not strictly of the
  number of platforms.
- Style deviation: period labels are 8 pt, not 12 pt, to fit six labels.

## Slide 4 (no generated figures)

Decision (Chang, Nov 16): the slide uses screenshots of the official tutorial
outputs, not figures built here. Copies are in `reference/`:

- `UMAP_seurat_pbmc3k.png`: Seurat PBMC 3k tutorial,
  https://satijalab.org/seurat/articles/pbmc3k_tutorial (page compiled
  2026-11-06 with Seurat 6.0.0).
- `UMAP_scanpy_pbmc3k.png`: Scanpy PBMC 3k tutorial,
  https://scanpy-tutorials.readthedocs.io/en/multiomics/pbmc3k.html (an old
  branch of the docs, run with scanpy 1.4.5).

Both tutorials run the same steps on the same data and end with the same 2,638
cells and 13,714 genes, but the UMAPs look different and the cluster counts
differ (9 vs. 8). The difference is kept on purpose as a lead-in to the later
slides. Reasons read from the two pages:

- Variable genes: top 2,000 by `vst` (Seurat) vs. dispersion thresholds giving
  1,838 (Scanpy).
- Scanpy regresses out total counts and percent mitochondrial; Seurat does not.
- PCs used for the neighbor graph: 10 (Seurat) vs. 40 (Scanpy).
- Clustering: Louvain at resolution 0.5 (Seurat) vs. Leiden at its default
  resolution (Scanpy). Seurat splits CD4 T cells into naive and memory.
- Neighbors: 10 in Scanpy; Seurat uses its defaults.
- UMAP layout: different implementations, defaults and seeds, so position,
  orientation and spacing of the islands are not comparable.

The biology agrees: both show an isolated B-cell island, a monocyte group with
dendritic cells and platelets, and a T-to-NK continuum.

## Slide 5

Source: scRNA-tools database (Zappia & Theis 2021, Genome Biology 22:301;
scrna-tools.org; data on GitHub under the MIT licence). Snapshot of 2026-11-16:
1,856 tools in 33 analysis categories.

Why the figures are redrawn and not copied from the paper: the paper's Fig. 1
(CC BY 4.0, so reuse would be allowed) ends in 2021 at about 1,000 tools. The
database has grown by about 70% since, so the paper figure is out of date.
`fig05a` and `fig05b` are updated versions of its panels A and D.

### fig05a (tools over time)

- Cumulative tools by the date each was added to the database, which is not
  the tool's release date. The database started in September 2016.
- Counts: 164 (start of 2018), 540 (start of 2020), 1,087 (when the paper was
  published, 2021-10-29), 1,786 (end of May 2024), 1,856 (now).
- **The x-axis stops at the end of May 2024** (decision: Chang, Nov 16). The
  site states the database has been in low-maintenance mode since May 2024, and
  only 70 tools have been added since. Showing that flat tail would suggest
  tool development stopped, which the data cannot support. The figure shows
  1,786 tools by May 2024; the cut-off and the reason are stated on the slide.
  `fig05b` uses the same 1,786 tools (see below).

### fig05b (tools per analysis category)

- Same content as Fig. 1D of the paper, updated to the current database and
  laid out horizontally (request: Chang, Nov 16): number of tools
  assigned to each of the 33 categories, grouped by workflow phase from left
  to right. The table is `data/processed/fig05b_tools_per_category.csv`.
- Size is 7.8 x 2.85 in, not one of the two README sizes, so that it sits
  beside the half-slide `fig05a` at the same height.
- The database only numbers the phases (Phase 1 to 4, Multiple, Other). The
  names (data acquisition, data cleaning, cell assignment, gene
  identification) are taken from the paper's figure.
- Bars and labels are tool counts, not percentages (request: Chang, Nov 16);
  the paper shows both. Percentages are in the table.
- **Only the 1,786 tools added by the end of May 2024 are counted**, the same
  cut-off as `fig05a` (decision: Chang, Nov 16), so both panels describe the
  same set of tools. The 70 tools added later are left out. The cut-off is set
  once, as `scrna_tools_cutoff` in `figures/deck_style.R`.
- Caveat: the categories are the ones recorded in the current snapshot. The
  database files hold no history of category edits, so a tool whose categories
  were changed after May 2024 is counted under its current ones.
- A tool can be in several categories (4,424 assignments), so the counts sum
  to more than 1,786.
- Most common: visualization 729 (41%), dimensionality reduction 448 (25%),
  clustering 391 (22%), integration 285 (16%).
- Category names are the database's, with spaces added and US spelling; three
  are abbreviated as in the paper (Dim., Diff., Alt.). "Ordering" is the
  database's name for trajectory or pseudotime inference.
- Style deviation: category names are 9 pt and value labels 7 pt.

## Slide 6 (no generated figures)

"Single-Cell Data Analysis: Art Rather Than Science?" The slide asked whether
any paper documents a lack of reproducibility or rigor in single-cell analysis,
with statistics to borrow. It carries quoted statistics, so there is no script
and no data file. Every number below was checked on Nov 16, 2026 against the
paper's full text (Europe PMC open-access XML), except where marked.

The slide title comes from Gibson (2022): "students new to the field ... soon
realize that single cell data analysis is as much an art as a science."

| Topic | Statistic, as stated in the paper | Source |
|---|---|---|
| Validation | "I scanned approximately fifty single cell transcriptomic studies in high impact journals in the past year, and found evidence for external validation in just a handful." | Gibson 2022 |
| Clustering | "it is not unusual for reanalysis to find 20% fewer or more clusters in datasets downloaded from public repositories, with between 50% and 70% equivalence of cell-type assignments." | Gibson 2022 |
| Data sharing | 72 published scRNA-seq datasets; "only 35 (49%) could be fully reconstructed from publicly available data"; 31 of 69 (45%) had no cell type annotations. | Skinnider et al. 2021 |
| Software | Seurat and Scanpy with defaults: differences "comparable to the variability introduced by sequencing fewer than 5% of reads or analyzing fewer than 20% of cells." | Rich et al. 2026 (abstract) |
| Visualization | 2D t-SNE/UMAP embeddings: Jaccard distance between each cell's 30 nearest neighbors in the embedding and in the original space "with an average consistently above 0.7". | Chari & Pachter 2023 |
| Differential expression | "single-cell methods identified hundreds of DE genes in the absence of any perturbation" (replicates assigned at random to two groups). | Squair et al. 2021 |
| Differential expression | Re-analysis of the first Alzheimer's snRNA-seq dataset with pseudobulk: 26 DEGs, "549 times fewer DEGs than that reported originally at an FDR of 0.05". | Murphy et al. 2023 |
| Replication | 17 Alzheimer's snRNA-seq studies: "over 85% of the AD DEGs we detected in one individual dataset failed to reproduce in any of the 16 others". | Nakatsuka et al. 2025 |

Caveats to keep with the numbers:

- Gibson's figures are his own experience and an informal scan, not a
  systematic survey. The paper is a perspective.
- A Jaccard distance of 0.7 means the two neighbor sets share 30% of their
  union, which is fewer than half of each cell's 30 neighbors. Do not restate
  it as "70% of neighbors are lost". The paper's conclusions have been
  disputed in print (not checked further).
- Murphy et al. is one dataset (Mathys et al. 2019). The original authors'
  final list was 1,031 DEGs, which required significance in both a cell-level
  and a patient-level test; the "549 times" compares against the cell-level
  result at FDR 0.05.
- Nakatsuka et al.: the 85% is for Alzheimer's with pseudobulk DESeq2 at FDR
  0.05. Parkinson's, Huntington's and COVID-19 studies reproduced better, and
  the authors attribute part of the gap to low power in single studies.
- Rich et al.: only the abstract of the journal version was checked. The
  preprint gives a Jaccard index of 0.22 for highly variable genes and an
  adjusted Rand index of 0.53 for clusters between the two tools; these two
  were read through an automated summary, not verified by hand.
- Also relevant, not used: Zimmerman et al. 2021 (type I error of cell-level
  tests in simulation, Table 1).

References:

- Gibson G (2022). Perspectives on rigor and reproducibility in single cell
  genomics. PLoS Genetics 18:e1010210.
- Skinnider MA, Squair JW, Courtine G (2021). Enabling reproducible
  re-analysis of single-cell data. Genome Biology 22:215.
- Rich JM, Moses L, Einarsson PH, et al., Pachter L (2026). The impact of
  package selection and versioning on single-cell RNA-seq analysis. Cell
  Systems 17(4):101560. Preprint: bioRxiv 10.1101/2024.04.04.588111.
- Chari T, Pachter L (2023). The specious art of single-cell genomics. PLoS
  Computational Biology 19:e1011288.
- Squair JW, et al. (2021). Confronting false discoveries in single-cell
  differential expression. Nature Communications 12:5692.
- Murphy AE, Fancy N, Skene N (2023). Avoiding false discoveries in
  single-cell RNA-seq by revisiting the first Alzheimer's disease dataset.
  eLife 12:RP90214.
- Nakatsuka N, et al., Satija R (2025). Improving reproducibility of
  differentially expressed genes in single-cell transcriptomic studies of
  neurodegenerative diseases through meta-analysis. Nature Communications
  16:7436.
- Zimmerman KD, Espeland MA, Langefeld CD (2021). A practical solution to
  pseudoreplication bias in single-cell studies. Nature Communications 12:738.

## Example 3: pseudo-replication in differential expression (fig07d)

Purpose: a bulk-style contrast for the single-cell volcano plot in Gibson
(2022) Fig. 1A, and an R version of the null experiment in Squair et al.
(2021). Request: Chang, Nov 16.

- Gibson's Fig. 1A is a "stylized volcano plot typical of single cell
  results" (his caption): a drawing, not data. The paper is CC BY 4.0, so the
  panel can be shown with credit.
- Instead of borrowing a bulk volcano plot from an unrelated study, the
  contrast is made from one real dataset analyzed two ways, so that only the
  unit of analysis differs.

### Data and design (data/make_null_de.R)

- Kang et al. 2018 (GEO GSE96583, batch 2): blood cells of eight lupus
  patients. Only the untreated control sample is used. Squair et al. ran
  their random-split experiment on these same control samples.
- Cells: 5,161 singlet CD4 T cells, the most abundant cell type (144 to 1,182
  per donor). Genes: 1,106 detected in at least 10% of these cells.
- Normalization: log(1 + counts per 10,000), with each cell's total taken
  over all genes. (Until Nov 16 the total was taken over the 1,106 tested
  genes only, which is not what the standard pipeline does. A consistency
  check added with the rare-gene analysis caught it. The fix moved the
  numbers slightly and changed which split is the median one, so figures
  made before that commit show a different split: 211 against 0, example
  gene HLA-C.)
- All 35 ways to split the eight donors four against four are tested. No
  treatment separates the groups, so every gene called is a false discovery.
- Cell level: Wilcoxon rank-sum test on log-normalized counts (Seurat's
  default). Individual level: counts summed per donor, DESeq2. Both at a
  Benjamini-Hochberg false discovery rate of 5%.
- Results over the 35 splits: cell level, median 212 genes called (range 81
  to 464; 7% to 42% of the genes tested); individual level, median 0 (range 0
  to 51; 27 of 35 splits give 0). Smallest cell-level p-value per split:
  median about 1e-97, range 1e-38 to 1e-293.
- Seurat reports Bonferroni-adjusted p-values by default. With that stricter
  correction the cell-level test still calls a median of 86 genes
  (`n_de_cell_bonferroni` in `kang_null_splits.csv`).
- Some splits give individual-level discoveries (up to 51). These were not
  investigated; real differences between the donors of a split (for example
  sex, or HLA type) would produce them.

### Terminology (decision: Chang, Nov 16)

- The lecture does not use "pseudo-replication". The contrast is stated as
  the unit of analysis: cells as independent units (cell-level test) against
  individuals as independent units (individual-level test).
- Reason: Squair et al. use "pseudo-replicates" for something narrower,
  bulk-style samples made by shuffling which replicate each cell belongs to.
  Chang's earlier wording matched the usual meaning (Zimmerman et al. 2021),
  but the two would be confused on slides that cite Squair.
- Figure labels say "individual". The scripts and tables say "donor", the
  dataset's own term; `fig03a` also keeps "donors", which is CELLxGENE's term.

### Figures

- The split shown in the per-split figures is the one with the median number
  of cell-level discoveries (split 20), chosen by that rule and not by eye.
  The rule was fixed before the results were seen and was kept when the
  normalization fix changed which split it selects.
- `fig07d_1`, `fig07d_2`: volcano plots of that split, cell level and
  individual level, on the same axes. 212 genes called against 7. Smallest
  p-value 1.6e-145 against 1.7e-8.
- The 7 individual-level genes include HLA-C, the top gene of both tests
  (individual-level FDR 0.001): the two groups of people do differ in it.
  With four people per group, a few real differences between the groups are
  expected; they are differences between these people, not a treatment effect.
- The y-axis of both volcano plots stops at 50, the lowest multiple of 10
  that leaves at most one gene off the scale. That gene, HLA-C (145), is
  drawn as a triangle on the top edge with its value in the label. Chang
  asked for a cropped axis on Nov 16 (then 20, for the earlier split).
- `fig07d_3`: genes called in each of the 35 splits, both tests.
- `fig07d_4`: GAPDH by individual. It is the most significant cell-level
  discovery not called at the individual level (cell-level p = 1.2e-48;
  individual-level p = 0.015, FDR 1.0), and is circled in both volcano plots.
  Three of the four people in group B have lower levels; the fourth is in the
  range of group A. Many cells have no GAPDH reads (points at 0).
- `fig07d_5`, `fig07d_6`: Gibson's drawing is a "double volcano": an inner
  burst (small fold change, extreme significance) and an outer burst (larger
  fold change, lower significance). `fig07d_1` shows only the inner one,
  because it follows Seurat's defaults: genes in at least 10% of cells, and a
  fold change that adds 1 to each mean. These two figures redo the cell-level
  test of the same split for all 6,146 genes detected in at least 1% of cells,
  with the fold change as the plain ratio of means. `fig07d_5` shows the 1,106
  well-detected genes; `fig07d_6` adds the 5,040 rarely detected ones in
  orange, on identical axes so the two can be superimposed (request: Chang,
  Nov 16). The 1% threshold is a round number chosen for illustration.
  At a 5% false discovery rate over all 6,146 genes, 162 well-detected and
  149 rarely detected genes are called. `figures/volcano_double.R` holds the
  shared plotting code.
- Squair et al. Fig. 4d is the same experiment on T cells of this dataset,
  shown with edgeR on biological replicates against pseudo-replicates; their
  Fig. 4e repeats the random split in 14 studies. Here the cell-level test is
  the Wilcoxon test, because it is what the standard pipeline runs.
- The count matrix (28 MB) is not committed. `data/get_data.R` downloads it
  and stops if its SHA-256 differs from the recorded value.
- The individual-level volcano omits two genes for which DESeq2 returns no
  p-value.
