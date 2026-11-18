# fig12a: two distances on the default UMAP.
#
# Slide:  11, "Distance between clusters can be misleading"
# Shows:  the default UMAP of the PBMC 3k cells (as fig09c), with lines between
#         the centers of two pairs of cell types: NK and CD8 T, and B and naive
#         CD4 T. In the data the two pairs are about equally far apart (11.1
#         and 11.6); on the UMAP one pair is drawn several times farther apart
#         than the other. The numbers on the lines are the UMAP distances.
#         The center of a cell type is its average cell.
# Data:   data/processed/pbmc3k_cells.csv and pbmc3k_type_distances.csv, built
#         by data/make_pbmc3k.R.
# Cite:   Chari & Pachter (2023), PLoS Computational Biology 19:e1011288.
# Seed:   none here (the layout's seed is Seurat's default, 42).
# Output: output/fig12a.png, output/fig12a.svg
# Run from the repository root: Rscript figures/fig12a_umap_two_distances.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

size <- c(4.6, 4.2)

cells <- read_cells()
centers <- cells |>
  group_by(cell_type) |>
  summarise(x = mean(umap1), y = mean(umap2), .groups = "drop")
distances <- read_csv(file.path(processed, "pbmc3k_type_distances.csv"), show_col_types = FALSE)
shown <- data.frame(type_a = c("CD8 T", "Naive CD4 T"), type_b = c("NK", "B")) |>
  left_join(distances, by = c("type_a", "type_b")) |>
  left_join(centers, by = c("type_a" = "cell_type")) |>
  left_join(centers, by = c("type_b" = "cell_type"), suffix = c("_a", "_b"))
stopifnot(!anyNA(shown$umap_default))
message(paste0(shown$type_a, " to ", shown$type_b, ": data ", round(shown$data_10_pcs, 1),
               ", UMAP ", round(shown$umap_default, 1), collapse = "; "))

# Names and numbers are placed by hand, clear of the cells and the lines.
named <- centers |>
  inner_join(tribble(
    ~cell_type,    ~dx,  ~dy, ~hjust,
    "NK",          -0.3, -1.6, 0.5,
    "CD8 T",       -0.4,  1.7, 0.5,
    "Naive CD4 T",  2.4,  1.6, 0,
    "B",            2.0,  0.0, 0,
    "Platelet",     0.0, -1.4, 0.5
  ), by = "cell_type")
numbers <- shown |>
  mutate(x = (x_a + x_b) / 2 + c(1.2, 1.9), y = (y_a + y_b) / 2 + c(-1.3, 0),
         label = sprintf("%.1f", umap_default))

p <- ggplot(cells, aes(umap1, umap2)) +
  geom_point(aes(colour = cell_type), size = 0.9, stroke = 0, shape = 16) +
  geom_segment(data = shown, aes(x = x_a, y = y_a, xend = x_b, yend = y_b), linewidth = 0.9,
               colour = deck$text) +
  geom_point(data = data.frame(x = c(shown$x_a, shown$x_b), y = c(shown$y_a, shown$y_b)),
             aes(x, y), size = 1.8, colour = deck$text) +
  geom_text(data = numbers, aes(x, y, label = label), family = deck$font, size = 16 / .pt,
            fontface = "bold", colour = deck$text) +
  geom_text(data = named, aes(x + dx, y + dy, label = cell_type, hjust = hjust), family = deck$font,
            size = 13 / .pt, colour = deck$text) +
  scale_colour_manual(values = type_colors) +
  labs(x = "UMAP 1", y = "UMAP 2") +
  theme_layout()

save_fig(p, "fig12a", size)
