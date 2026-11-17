# fig12b: distances between cell types, in the data and on the UMAP.
#
# Slide:  12, "Global distance can be misleading"
# Shows:  one point for each of the 36 pairs of the nine PBMC 3k cell types.
#         x: distance between the two types in the data UMAP is given (10
#         principal components). y: distance between them on the default UMAP.
#         The distance between two types is the distance between their average
#         cells. If the UMAP kept distances, the points would rise from left
#         to right. Marked: the two pairs of fig12a (same distance in the
#         data, very different on the UMAP) and the eight pairs with platelets
#         (by far the most distant type in the data, drawn at ordinary
#         distances).
# Data:   data/processed/pbmc3k_type_distances.csv, built by
#         data/make_pbmc3k.R. The same distances in larger gene spaces agree
#         with the 10 components (see NOTES.md).
# Cite:   Chari & Pachter (2023), PLoS Computational Biology 19:e1011288.
# Seed:   none here (the layout's seed is Seurat's default, 42).
# Output: output/fig12b.png, output/fig12b.svg
# Run from the repository root: Rscript figures/fig12b_umap_distance_scatter.R

source(file.path("figures", "deck_style.R"))

size <- c(5.2, 4.2)

distances <- read_csv(file.path(processed, "pbmc3k_type_distances.csv"), show_col_types = FALSE) |>
  mutate(
    pair = paste(type_a, type_b),
    group = case_when(
      pair %in% c("CD8 T NK", "Naive CD4 T B") ~ "shown",
      type_a == "Platelet" | type_b == "Platelet" ~ "platelet",
      TRUE ~ "other"
    )
  )
stopifnot(nrow(distances) == 36, sum(distances$group == "shown") == 2, sum(distances$group == "platelet") == 8)
message("rank correlation, all 36 pairs: ",
        round(cor(distances$data_10_pcs, distances$umap_default, method = "spearman"), 2))

shown <- filter(distances, group == "shown") |>
  mutate(label = ifelse(pair == "CD8 T NK", "NK and CD8 T", "B and naive CD4 T"),
         # names placed by hand, clear of the other points
         label_x = ifelse(pair == "CD8 T NK", data_10_pcs + 2, 1),
         label_y = ifelse(pair == "CD8 T NK", 1.3, umap_default + 5.6),
         # a thin line from each name to its point
         line_x = ifelse(pair == "CD8 T NK", data_10_pcs + 1.6, data_10_pcs - 2.2),
         line_y = ifelse(pair == "CD8 T NK", 1.6, umap_default + 4.6))
platelet <- filter(distances, group == "platelet")

p <- ggplot(distances, aes(data_10_pcs, umap_default)) +
  geom_point(data = filter(distances, group == "other"), colour = deck$gray, size = 2.6) +
  geom_point(data = platelet, colour = deck$orange, size = 2.6) +
  geom_segment(data = shown, aes(x = line_x, y = line_y, xend = data_10_pcs, yend = umap_default),
               colour = deck$text, linewidth = 0.3) +
  geom_point(data = shown, colour = deck$blue, size = 3.4) +
  geom_text(data = shown, aes(label_x, label_y, label = label), family = deck$font, size = 14 / .pt,
            colour = deck$text, hjust = 0) +
  annotate("text", x = mean(platelet$data_10_pcs), y = max(platelet$umap_default) + 1.6,
           label = "Pairs with\nplatelets", family = deck$font, size = 14 / .pt, colour = deck$text,
           lineheight = 0.9, vjust = 0) +
  scale_x_continuous(limits = c(0, 58), breaks = seq(0, 50, 10), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 25), breaks = seq(0, 20, 5), expand = c(0, 0)) +
  labs(x = "Distance in the data", y = "Distance on the UMAP") +
  theme_deck(grid = TRUE) +
  theme(axis.title = element_text(size = 16), axis.text = element_text(size = 14))

save_fig(p, "fig12b", size)
