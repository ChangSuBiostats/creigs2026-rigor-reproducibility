# Shared by the Example 1 figures (fig09a to fig09c, fig11, fig12a, fig12b);
# not a figure script itself. Colors of the nine PBMC 3k cell types and the
# drawing of one two-dimensional layout.
#
# Text in these figures is black and at least 14 pt at the size the figure is
# placed on the slide (request: Chang, Nov 16, 2026).

type_colors <- c(
  "Naive CD4 T" = "#4472C4", "Memory CD4 T" = "#8FB4E8", "CD8 T" = "#00A087", "NK" = "#70AD47",
  "B" = "#ED7D31", "CD14+ Mono" = "#C00000", "FCGR3A+ Mono" = "#7030A0", "DC" = "#8B5A2B",
  "Platelet" = "#595959"
)

read_cells <- function() {
  read_csv(file.path(processed, "pbmc3k_cells.csv"), show_col_types = FALSE) |>
    mutate(cell_type = factor(cell_type, levels = names(type_colors)))
}

# Layout coordinates have no units, so the axes carry a name but no numbers.
theme_layout <- function() {
  theme_deck() +
    theme(axis.text = element_blank(), axis.ticks = element_blank(),
          axis.title = element_text(size = 14, colour = deck$text))
}

# One layout, cells colored by type, each type named at its median position.
# Names are black with a white outline. ggrepel moves overlapping names apart;
# its seed only affects name placement.
layout_plot <- function(cells, x, y, xlab, ylab, label_seed = 1) {
  centers <- cells |>
    group_by(cell_type) |>
    summarise(x = median(.data[[x]]), y = median(.data[[y]]), .groups = "drop")
  ggplot(cells, aes(.data[[x]], .data[[y]], colour = cell_type)) +
    geom_point(size = 0.9, stroke = 0, shape = 16) +
    ggrepel::geom_text_repel(
      data = centers, aes(x, y, label = cell_type), inherit.aes = FALSE,
      family = deck$font, size = 12 / .pt, colour = deck$text, bg.color = "white", bg.r = 0.18,
      min.segment.length = Inf, point.size = NA, box.padding = 0.15, max.overlaps = Inf,
      seed = label_seed
    ) +
    scale_colour_manual(values = type_colors) +
    labs(x = xlab, y = ylab) +
    theme_layout()
}
