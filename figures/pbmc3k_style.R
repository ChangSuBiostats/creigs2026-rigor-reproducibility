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

# One layout, cells colored by type. No names or legend on the plot: the names
# covered the cells, and the colors are explained aloud (Chang, Nov 16, 2026).
layout_plot <- function(cells, x, y, xlab, ylab) {
  ggplot(cells, aes(.data[[x]], .data[[y]], colour = cell_type)) +
    geom_point(size = 0.9, stroke = 0, shape = 16) +
    scale_colour_manual(values = type_colors) +
    labs(x = xlab, y = ylab) +
    theme_layout()
}

# The default UMAP with a name for each group, placed by hand beside the group
# (not on top of the cells). `names` maps cell type to the text to show.
label_spots <- tribble(
  ~cell_type,      ~x,    ~y, ~hjust,
  "Memory CD4 T",  -5.0,   8.6, 1,
  "Naive CD4 T",    1.6,   5.6, 0,
  "CD8 T",         -7.4,   4.6, 1,
  "NK",            -8.3,  -1.6, 0.5,
  "B",             -1.5, -10.6, 0,
  "CD14+ Mono",     9.3,  -1.2, 0.5,
  "FCGR3A+ Mono",   6.3,  -8.6, 0.5,
  "DC",             5.4,  -1.4, 1,
  "Platelet",       7.4,   4.1, 0.5
)
# Longer text (the cell type names of fig14c) needs a few other spots.
name_spots <- tribble(
  ~cell_type,      ~x,    ~y, ~hjust,
  "Memory CD4 T",  -2.9,   9.2, 0.5,
  "Naive CD4 T",    1.6,   6.6, 0,
  "CD8 T",         -7.4,   4.6, 1,
  "NK",            -8.3,  -1.6, 0.5,
  "B",             -1.5, -10.6, 0,
  "CD14+ Mono",    13.2,  -0.9, 1,
  "FCGR3A+ Mono",   6.3,  -8.9, 0.5,
  "DC",             5.2,  -3.4, 1,
  "Platelet",       7.4,   4.1, 0.5
)
named_layout_plot <- function(cells, names, label_size = 13, spots = label_spots) {
  spots <- mutate(spots, name = unname(names[cell_type]))
  stopifnot(!anyNA(spots$name))
  ggplot(cells, aes(umap1, umap2)) +
    geom_point(aes(colour = cell_type), size = 0.9, stroke = 0, shape = 16) +
    geom_text(data = spots, aes(x, y, label = name, hjust = hjust), family = deck$font,
              size = label_size / .pt, colour = deck$text, fontface = "bold") +
    scale_colour_manual(values = type_colors) +
    scale_x_continuous(limits = c(-13.5, 13.5), expand = c(0, 0)) +
    scale_y_continuous(limits = c(-13.5, 10), expand = c(0, 0)) +
    labs(x = "UMAP 1", y = "UMAP 2") +
    theme_layout()
}

# Colors for n clusters without names: the nine cell type colors first, then
# further distinct colors (fig15c has 18 clusters).
cluster_colors <- function(n) {
  more <- c("#E6AB02", "#1B9E77", "#D95F02", "#E7298A", "#66A61E", "#A6761D", "#17BECF", "#BCBD22",
            "#FF9896", "#9467BD", "#000000", "#AEC7E8", "#98DF8A", "#F7B6D2")
  stopifnot(n <= length(type_colors) + length(more))
  unname(c(type_colors, more))[seq_len(n)]
}
