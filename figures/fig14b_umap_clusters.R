# fig14b: the PBMC 3k cells after clustering.
#
# Slide:  14, "Ex. 2: Clustering and cell type annotation"
# Shows:  the default UMAP of the 2,638 PBMC 3k cells, three times, for the
#         three steps of the standard analysis: fig14a before clustering (one
#         color), fig14b after clustering (nine clusters, numbered as Seurat
#         numbers them), fig14c after annotation (the tutorial's cell type
#         names). fig14b and fig14c use the same colors.
# Data:   data/processed/pbmc3k_cells.csv, built by data/make_pbmc3k.R with the
#         Seurat tutorial pipeline (Louvain clustering, resolution 0.5).
# Cite:   Seurat tutorial, satijalab.org/seurat/articles/pbmc3k_tutorial.
# Seed:   none here (the layout's seed is Seurat's default, 42). The numbers are
#         placed by hand.
# Output: output/fig14b.png, output/fig14b.svg
# Run from the repository root: Rscript figures/fig14b_umap_clusters.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

cells <- read_cells()
numbers <- distinct(cells, cell_type, cluster)
p <- named_layout_plot(cells, setNames(as.character(numbers$cluster), numbers$cell_type), label_size = 16)
save_fig(p, "fig14b", c(3.6, 3.6))
