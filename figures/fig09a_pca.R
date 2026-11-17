# fig09a: the first two principal components of the PBMC 3k cells.
#
# Slide:  9, "Dimension reduction for visualizing single-cell data"
# Shows:  2,638 blood cells from one donor, each a point, placed by its first two principal components
#         and colored by the cell type of the Seurat tutorial (no names on
#         the plot). The three
#         figures fig09a (PCA), fig09b (t-SNE) and fig09c (UMAP) show the same
#         cells with the same colors.
# Data:   data/processed/pbmc3k_cells.csv, built by data/make_pbmc3k.R from the
#         10x Genomics PBMC 3k dataset with the Seurat tutorial pipeline.
# Cite:   Seurat tutorial, satijalab.org/seurat/articles/pbmc3k_tutorial
#         (Hao et al. 2024, Nature Biotechnology 42:293). 
# Seed:   the layout uses Seurat's default (42, in data/make_pbmc3k.R).
# Output: output/fig09a.png, output/fig09a.svg
# Run from the repository root: Rscript figures/fig09a_pca.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

p <- layout_plot(read_cells(), "pc1", "pc2", "PC 1", "PC 2")
save_fig(p, "fig09a", c(3.6, 3.6))
