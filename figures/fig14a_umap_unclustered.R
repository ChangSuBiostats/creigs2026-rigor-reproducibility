# fig14a: the PBMC 3k cells before clustering.
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
# Seed:   none here (the layout's seed is Seurat's default, 42).
# Output: output/fig14a.png, output/fig14a.svg
# Run from the repository root: Rscript figures/fig14a_umap_unclustered.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

p <- ggplot(read_cells(), aes(umap1, umap2)) +
  geom_point(colour = "#595959", size = 0.9, stroke = 0, shape = 16) +
  scale_x_continuous(limits = c(-13.5, 13.5), expand = c(0, 0)) +
  scale_y_continuous(limits = c(-13.5, 10), expand = c(0, 0)) +
  labs(x = "UMAP 1", y = "UMAP 2") +
  theme_layout()
save_fig(p, "fig14a", c(3.6, 3.6))
