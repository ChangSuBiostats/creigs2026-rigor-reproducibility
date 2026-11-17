# The two-gene thought experiment of Example 2 (fig21a to fig21c).
#
# Usage (from the repository root): Rscript data/make_two_gene_example.R
#
# 1,000 cells from one homogeneous population: the expression of two genes is
# drawn independently from the same standard normal distribution for every
# cell, so no subtypes exist. k-means is asked for two clusters, and each gene
# is then compared between the two clusters with a t-test ("is this gene a
# marker of cluster 1?"). The clusters and the test use the same data.
#
# After the notebook behind Chang's own slides (same steps: kmeans with two
# centers, seed 42). The notebook's code for drawing the cells is not in the
# deck, so the cells here are a new draw and the pictures differ in detail.
# Seed:   42, set once, before the cells are drawn.
# Output: data/processed/two_gene_example.csv        one row per cell
#         data/processed/two_gene_example_tests.csv  one row per gene

suppressPackageStartupMessages(library(readr))
processed <- file.path("data", "processed")

set.seed(42)
n <- 1000
cells <- data.frame(cell = seq_len(n), gene1 = rnorm(n), gene2 = rnorm(n))
km <- kmeans(cells[, c("gene1", "gene2")], centers = 2)
# Cluster 1 is the one with the higher average of gene 1 (k-means numbers
# clusters arbitrarily).
high <- which.max(km$centers[, "gene1"])
cells$cluster <- ifelse(km$cluster == high, 1L, 2L)
write_csv(cells, file.path(processed, "two_gene_example.csv"))

tests <- do.call(rbind, lapply(c("gene1", "gene2"), function(g) {
  test <- t.test(cells[[g]][cells$cluster == 1], cells[[g]][cells$cluster == 2])
  data.frame(gene = g, mean_cluster1 = test$estimate[[1]], mean_cluster2 = test$estimate[[2]],
             p_value = test$p.value)
}))
write_csv(tests, file.path(processed, "two_gene_example_tests.csv"))
message("clusters of ", paste(table(cells$cluster), collapse = " and "), " cells; t-test p-values: gene 1 ",
        signif(tests$p_value[1], 2), ", gene 2 ", signif(tests$p_value[2], 2))
