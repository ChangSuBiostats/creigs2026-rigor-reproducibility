# fig21b: the same cells split into two clusters by k-means.
#
# Slide:  21, the thought experiment of Example 2 ("cells with no subtypes")
# Shows:  1,000 simulated cells from one homogeneous population, two genes.
#         fig21a: the cells. fig21b: the same cells split into two clusters by
#         k-means. fig21c: gene 1 in the two clusters, with the p-value of a
#         t-test between them. No subtypes exist, yet gene 1 looks like a
#         marker gene, because the clusters were formed from the same values
#         that are then tested (double dipping).
# Data:   data/processed/two_gene_example.csv (and _tests.csv for fig21c), built
#         by data/make_two_gene_example.R. Simulated; no real data.
# Cite:   the illustration follows Chang Su's own lecture notebook.
# Seed:   none here; the simulation's seed (42) is set in
#         data/make_two_gene_example.R.
# Output: output/fig21b.png, output/fig21b.svg
# Run from the repository root: Rscript figures/fig21b_two_genes_clusters.R

source(file.path("figures", "deck_style.R"))

size <- c(3.8, 3.6)
cluster_colors <- c("1" = deck$orange, "2" = deck$blue)
cells <- read_csv(file.path(processed, "two_gene_example.csv"), show_col_types = FALSE) |>
  mutate(cluster = factor(cluster))
theme_two <- theme_deck() + theme(axis.title = element_text(size = 16), axis.text = element_text(size = 14))

p <- ggplot(cells, aes(gene1, gene2, colour = cluster)) +
  geom_point(size = 0.9, stroke = 0, shape = 16) +
  annotate("text", x = 3.9, y = -3.6, label = "Cluster 1", hjust = 1, family = deck$font,
           size = 14 / .pt, fontface = "bold", colour = cluster_colors[["1"]]) +
  annotate("text", x = -3.9, y = 3.6, label = "Cluster 2", hjust = 0, family = deck$font,
           size = 14 / .pt, fontface = "bold", colour = cluster_colors[["2"]]) +
  scale_colour_manual(values = cluster_colors) +
  coord_fixed(xlim = c(-4, 4), ylim = c(-4, 4)) +
  labs(x = "Gene 1", y = "Gene 2") +
  theme_two

save_fig(p, "fig21b", size)
