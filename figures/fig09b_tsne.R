# fig09b: t-SNE layout of the PBMC 3k cells.
#
# Slide:  9, "Dimension reduction for visualizing single-cell data"
# Shows:  2,638 blood cells from one donor, each a point, placed by t-SNE (on 10 principal components)
#         and colored by the cell type of the Seurat tutorial. The three
#         figures fig09a (PCA), fig09b (t-SNE) and fig09c (UMAP) show the same
#         cells with the same colors.
# Data:   data/processed/pbmc3k_cells.csv, built by data/make_pbmc3k.R from the
#         10x Genomics PBMC 3k dataset with the Seurat tutorial pipeline.
# Cite:   Seurat tutorial, satijalab.org/seurat/articles/pbmc3k_tutorial
#         (Hao et al. 2024, Nature Biotechnology 42:293). t-SNE: van der Maaten & Hinton
#         (2008), Journal of Machine Learning Research 9:2579.
# Seed:   the layout uses Seurat's default (1, in data/make_pbmc3k.R). Here: 1, for the placement of
#         the cell type names only.
# Output: output/fig09b.png, output/fig09b.svg
# Run from the repository root: Rscript figures/fig09b_tsne.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

p <- layout_plot(read_cells(), "tsne1", "tsne2", "t-SNE 1", "t-SNE 2")
save_fig(p, "fig09b", c(3.6, 3.6))
