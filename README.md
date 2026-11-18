# Rigor and Reproducibility in Single-Cell Genomics: figure code

Code and data for the figures in the lecture "Rigor and Reproducibility in Single-Cell
Genomics" by Chang Su (Emory University), given at CREiGS 2026, Icahn School of Medicine
at Mount Sinai, on Nov 18, 2026.

Every figure that was generated for the lecture can be rebuilt from this repository with
one command. The slides themselves are not in the repository, and figures borrowed from
published papers are not redrawn here (they are listed below with their sources).

## Rebuild the figures

Requirements: R 4.5.2 and the packages recorded in `renv.lock` (restore them with
`renv::restore()`), and an internet connection for the first run.

```
Rscript run_all.R        # or: make all
```

This downloads any raw data that is missing and checks it against a recorded checksum,
builds the derived tables in `data/processed/`, runs every script in `figures/`, and
writes a PNG (300 dpi) and an SVG per figure to `output/`. It takes about 3 minutes on a
laptop. The download step adds an entry with the new access date to `data/SOURCES.md`;
no other tracked file changes. All random steps use fixed seeds, so the files in `output/` and `data/processed/`
come out identical on a second run with the same package versions.

To rebuild one figure, run its script from the repository root, for example
`Rscript figures/fig09c_umap.R`.

## Figures and where they appear

Figure names were given while the lecture was being written, so the number in a file name
does not always match the final slide number. This table gives the final slide.

| Slide | Slide title | Figure | Script |
|---|---|---|---|
| 2 | Rapid Growth in Single Cell Studies | `fig02c` publications per year | `figures/fig02c_publications_per_year.R` |
| 2 | | `fig02a` cells per study | `figures/fig02a_cells_per_study.R` |
| 2 | | `fig02b` tissues profiled | `figures/fig02b_tissues.R` |
| 3 | Increasing Complexity of Single Cell Studies | `fig03a` individuals per study | `figures/fig03a_donors_per_study.R` |
| 3 | | `fig03b` share of studies with more complex designs | `figures/fig03b_design_complexity.R` |
| 5 | Rapid Growth in Single Cell Analysis Tools | `fig05a` number of tools over time | `figures/fig05a_tools_over_time.R` |
| 5 | | `fig05b` tools per category of analysis | `figures/fig05b_tools_per_category.R` |
| 8 | Ex. 1: Dimension reduction | `fig08` cells plotted by two genes picked at random | `figures/fig08_random_gene_pair.R` |
| 9 | Dimension reduction for visualizing single-cell data | `fig09a` PCA, `fig09b` t-SNE, `fig09c` UMAP | `figures/fig09a_pca.R`, `fig09b_tsne.R`, `fig09c_umap.R` |
| 11 | Distance between clusters can be misleading | `fig12a` two distances on the UMAP | `figures/fig12a_umap_two_distances.R` |
| 11 | | `fig12b` distance in expression against distance on the UMAP, 36 pairs of cell types | `figures/fig12b_umap_distance_scatter.R` |
| 14 | Ex. 2: Clustering and cell type annotation | `fig14a` cells, `fig14b` clusters, `fig14c` cell types | `figures/fig14a_umap_unclustered.R`, `fig14b_umap_clusters.R`, `fig14c_umap_cell_types.R` |
| 15, 16, 18 | Clustering … at what resolution? | `fig15a`, `fig15b`, `fig15c` clusters at resolution 0.1, 0.5 and 2.5 | `figures/fig15a_clusters_resolution_0.1.R`, `fig15b_…0.5.R`, `fig15c_…2.5.R` |
| 19 to 21 | Thought experiment | `fig21a`, `fig21b`, `fig21c` one group of cells, split in two, and the "marker gene" | `figures/fig21a_two_genes_cells.R`, `fig21b_two_genes_clusters.R`, `fig21c_two_genes_marker.R` |
| 25 | Case study with real T cell data | `fig07d_1` each cell as a unit, `fig07d_2` each individual as a unit | `figures/fig07d_1_null_volcano_cell.R`, `fig07d_2_null_volcano_pseudobulk.R` |
| 26 | False positives across datasets and methods | `fig07d_3` all 35 random splits | `figures/fig07d_3_null_discoveries.R` |
| 28 | Why: cells from the same person are not independent | `fig07d_4` GAPDH, person by person | `figures/fig07d_4_null_example_gene.R` |

Notes on the table:

- Slides 19 to 21 show the author's original drawings of the thought experiment;
  `fig21a` to `fig21c` reproduce them from code.
- Three figures were made and are not in the final deck: `fig11` (five UMAP layouts of the
  same cells under different settings and starting positions) and `fig07d_5`, `fig07d_6`
  (the two "bursts" of a single-cell volcano plot).

### Figures on the slides that are not generated here

| Slide | Figure | Source |
|---|---|---|
| 4 | UMAPs from the Seurat and Scanpy PBMC 3k tutorials (copies in `reference/`) | satijalab.org/seurat, scanpy-tutorials.readthedocs.io |
| 10 | Published UMAPs | Yazar et al., Science 2022; Green et al., Nature 2024; All of Us Research Program Genomics Investigators, Nature 2024 |
| 12 | Simulation and genotype examples | R. Irizarry, "Biologists, stop putting UMAP plots in your papers", Simply Statistics 2024 |
| 17 | Marker gene table and plot | Seurat PBMC 3k tutorial |
| 24 | Stylized volcano plot | Gibson, PLoS Genetics 2022, Fig. 1A |
| 26, 27, 29 | False discoveries in 14 studies, spike-ins, pseudobulk schematic | Squair et al., Nature Communications 2021, Figs. 4e, 2e, 2a |

## Data

All raw data is public. `data/get_data.R` downloads it, and `data/SOURCES.md` records the
URL, access date and SHA-256 checksum of each file.

| Used for | Data | Reference |
|---|---|---|
| Slide 2 | Single-cell studies database; PubMed record counts | Svensson, da Veiga Beltrame & Pachter, Database 2020 |
| Slide 3 | CZ CELLxGENE Discover collection and dataset metadata | CZI Cell Science Program et al., Nucleic Acids Research 2025 |
| Slide 5 | scRNA-tools database | Zappia & Theis, Genome Biology 2021 |
| Examples 1 and 2 | PBMC 3k, 2,700 blood cells from one donor | 10x Genomics |
| Example 3 | Untreated blood cells of 8 individuals (GEO GSE96583) | Kang et al., Nature Biotechnology 2018 |

Several of these sources change over time (the studies database, CELLxGENE, PubMed), so
the snapshots used for the lecture are kept in `data/raw/`. The one exception is the
Kang et al. count matrix (28 MB), which is downloaded on the first run and verified
against its checksum.

The single-cell analysis of PBMC 3k follows the Seurat tutorial
(satijalab.org/seurat/articles/pbmc3k_tutorial): 2,638 cells after quality control,
2,000 variable genes, 10 principal components, Louvain clustering.

## How the repository is organized

```
data/get_data.R              downloads raw data, writes data/SOURCES.md
data/make_processed.R        derived tables for slides 2, 3 and 5
data/make_pbmc3k.R           PBMC 3k pipeline, layouts and distances (Examples 1 and 2)
data/make_two_gene_example.R the two-gene thought experiment (Example 2)
data/make_null_de.R          differential expression with no true difference (Example 3)
data/raw/                    downloaded files, never edited by hand
data/processed/              tables written by the scripts above
figures/                     one script per figure, plus shared style files
output/                      the figures (PNG and SVG)
reference/                   images the figures were checked against
run_all.R, Makefile          rebuild everything
renv.lock                    package versions
NOTES.md                     findings, decisions and known gaps, figure by figure
```

Rules the code follows:

- One script per figure. A script reads from `data/`, writes to `output/`, and changes
  nothing else. Its header gives the slide, what the figure shows, the data source and the
  seed.
- Raw data is never edited by hand. Every derived number comes from a script.
- Seeds are fixed in the scripts and were chosen before looking at the results.
- No data is invented. Where a source does not record something, `NOTES.md` says so.

`NOTES.md` is the place to look for what a figure does and does not show: the exact
numbers behind each slide, the choices made, and analyses that were tried and dropped.

## Figure style

- Font: Georgia, falling back to serif. Text in black, at least 14 pt at the size the
  figure has on the slide. No titles inside figures; the slide carries the title.
- Colors: blue #4472C4 for the series that carries the message, orange #ED7D31 for the
  contrast, gray #A5A5A5 for context.
- No top or right axis lines. Light gray (#E7E6E6) gridlines on line and scatter charts,
  none on bar charts. Series are labeled directly where possible.
- Standard sizes in inches: 3.9 × 2.85 for a half-slide panel, 10.2 × 4.8 for the full
  content area. Other sizes are noted in the script and in `NOTES.md`.
- White background, 300 dpi PNG and SVG.

## License and citation

The code is released under the MIT License (see `LICENSE`). The data in `data/raw/`
belongs to its sources and keeps their terms; please cite the references above when using
it. Figures borrowed from published papers are not part of this repository.

If you use the figures or the code, please cite the lecture: Chang Su, "Rigor and
Reproducibility in Single-Cell Genomics", CREiGS 2026, Icahn School of Medicine at Mount
Sinai.
