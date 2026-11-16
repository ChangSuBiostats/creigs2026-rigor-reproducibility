# fig07d_5: the inner burst: genes detected in many cells.
#
# Slide:  Example 3, differential expression (README: fig07d), the slide that
#         returns to the two bursts of Gibson's drawing.
# Shows:  cell-level volcano plot of the donor split of fig07d_1, for the genes
#         detected in at least 10% of cells (the genes of fig07d_1), with the
#         fold change computed without Seurat's offset. First of two frames;
#         fig07d_6 adds the rarely detected genes on identical axes.
# Data:   data/processed/kang_null_rare_genes.csv, built by data/make_null_de.R
#         from the control sample of Kang et al. (GEO GSE96583, logged in
#         data/SOURCES.md).
# Cite:   Kang HM, et al. (2018). Nature Biotechnology 36:89-94. The "double
#         volcano": Gibson G (2022). PLoS Genetics 18:e1010210, Fig. 1A.
# Seed:   none (no randomness).
# Output: output/fig07d_5.png, output/fig07d_5.svg
# Run from the repository root: Rscript figures/fig07d_5_double_volcano_inner.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "volcano_double.R"))

save_fig(double_volcano(show_rare = FALSE), "fig07d_5")
