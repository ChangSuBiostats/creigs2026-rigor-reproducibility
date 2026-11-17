# fig14c: the PBMC 3k cells after cell type annotation.
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
# Seed:   none here (the layout's seed is Seurat's default, 42). The names are
#         placed by hand.
# Output: output/fig14c.png, output/fig14c.svg
# Run from the repository root: Rscript figures/fig14c_umap_cell_types.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

p <- named_layout_plot(read_cells(), setNames(names(type_colors), names(type_colors)), label_size = 12,
                       spots = name_spots)
save_fig(p, "fig14c", c(3.6, 3.6))
