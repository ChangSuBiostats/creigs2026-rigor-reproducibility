# fig08: the PBMC 3k cells plotted by two genes drawn at random.
#
# Slide:  8, "Ex.1: Dimension reduction"
# Shows:  2,638 blood cells, each a point, placed by their log-normalized
#         expression of two genes drawn at random from all 13,714 genes, and
#         colored by cell type as in fig09a to fig09c. Most cells have no
#         reads of either gene and sit on top of each other at zero; their
#         number is written on the plot. The pair shown is the first of three
#         drawn; the other two are in the table and look the same.
# Data:   data/processed/pbmc3k_gene_pairs.csv, built by data/make_pbmc3k.R.
# Cite:   Seurat tutorial, satijalab.org/seurat/articles/pbmc3k_tutorial.
# Seed:   20261118 (the lecture date) for drawing the genes, set in
#         data/make_pbmc3k.R. Nothing random here.
# Output: output/fig08.png, output/fig08.svg
# Run from the repository root: Rscript figures/fig08_random_gene_pair.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

cells <- read_csv(file.path(processed, "pbmc3k_gene_pairs.csv"), show_col_types = FALSE) |>
  filter(pair == 1) |>
  mutate(cell_type = factor(cell_type, levels = names(type_colors)))
both_zero <- sum(cells$x == 0 & cells$y == 0)
message(cells$gene_x[1], " and ", cells$gene_y[1], ": ", both_zero, " of ", nrow(cells),
        " cells at zero for both genes")

top <- ceiling(max(cells$x, cells$y))
p <- ggplot(cells, aes(x, y, colour = cell_type)) +
  geom_point(size = 1.6, stroke = 0, shape = 16) +
  annotate("segment", x = 0.75, y = 0.75, xend = 0.12, yend = 0.12, colour = deck$text, linewidth = 0.4,
           arrow = arrow(length = unit(5, "pt"), type = "closed")) +
  annotate("text", x = 0.8, y = 0.8, hjust = 0, vjust = 0, family = deck$font, size = 14 / .pt,
           colour = deck$text, lineheight = 0.9,
           label = paste0(format(both_zero, big.mark = ","), " of ", format(nrow(cells), big.mark = ","),
                          "\ncells are here")) +
  scale_colour_manual(values = type_colors) +
  scale_x_continuous(limits = c(-0.15, top), breaks = 0:top) +
  scale_y_continuous(limits = c(-0.15, top), breaks = 0:top) +
  labs(x = paste(cells$gene_x[1], "expression"), y = paste(cells$gene_y[1], "expression")) +
  theme_deck() +
  theme(axis.title = element_text(size = 14), axis.text = element_text(size = 13))

save_fig(p, "fig08", c(3.6, 3.6))
