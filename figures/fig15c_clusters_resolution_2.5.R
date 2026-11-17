# fig15c: clusters of the PBMC 3k cells at resolution 2.5.
#
# Slide:  15, "Clustering ... at what resolution?" (also slides 16 and 18)
# Shows:  the default UMAP of the 2,638 PBMC 3k cells, colored by Louvain
#         cluster at resolution 2.5. The three figures fig15a (0.1), fig15b
#         (0.5, the tutorial's) and fig15c (2.5) use the same cells, the same
#         neighbor graph and the same layout; only the resolution differs.
#         They give 5, 9 and 18 clusters. Colors are assigned per figure and
#         do not correspond between figures.
# Data:   data/processed/pbmc3k_resolutions.csv, built by data/make_pbmc3k.R.
# Cite:   Seurat tutorial, satijalab.org/seurat/articles/pbmc3k_tutorial.
#         Louvain: Blondel et al. (2008), J. Stat. Mech. P10008.
# Seed:   none here (clustering uses Seurat's default seed, 0).
# Output: output/fig15c.png, output/fig15c.svg
# Run from the repository root: Rscript figures/fig15c_clusters_resolution_2.5.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

cells <- read_csv(file.path(processed, "pbmc3k_resolutions.csv"), show_col_types = FALSE) |>
  mutate(cluster = factor(.data[["resolution_2.5"]]))
message("resolution 2.5: ", nlevels(cells$cluster), " clusters")

p <- ggplot(cells, aes(umap1, umap2, colour = cluster)) +
  geom_point(size = 0.9, stroke = 0, shape = 16) +
  scale_colour_manual(values = cluster_colors(nlevels(cells$cluster))) +
  labs(x = "UMAP 1", y = "UMAP 2") +
  theme_layout()

save_fig(p, "fig15c", c(3.3, 3.3))
