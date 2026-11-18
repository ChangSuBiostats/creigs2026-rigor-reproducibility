# fig11: the same cells, five UMAP layouts.
#
# Slide:  not in the final deck (backup for Example 1; the slide "UMAP layout
#         is sensitive to parameter settings" was dropped)
# Shows:  UMAP of the 2,638 PBMC 3k cells, run five times on the same 10
#         principal components:
#           1. Seurat's default (30 neighbors, minimum distance 0.3, seed 42)
#           2. the default with another seed (1)
#           3. 5 neighbors, minimum distance 0.1
#           4. 100 neighbors, minimum distance 0.8
#           5. the default settings with random instead of spectral starting
#              positions (seed 1)
#         Each layout is centered and drawn at its own scale, with the same
#         scale on both axes (UMAP coordinates have no units).
# Data:   data/processed/pbmc3k_layouts.csv, built by data/make_pbmc3k.R.
# Cite:   McInnes, Healy & Melville (2018), arXiv:1802.03426. On starting
#         positions: Kobak & Linderman (2021), Nature Biotechnology 39:156.
# Seed:   none here; the seeds of the layouts are set in data/make_pbmc3k.R and
#         were fixed before looking at the layouts.
# Output: output/fig11.png, output/fig11.svg
# Run from the repository root: Rscript figures/fig11_umap_settings.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "pbmc3k_style.R"))

size <- c(11.4, 3.5)  # full width of the slide's content area

titles <- c(
  default = "Default",
  another_seed = "Default,\nanother seed",
  few_neighbors = "5 neighbors,\nmin. distance 0.1",
  many_neighbors = "100 neighbors,\nmin. distance 0.8",
  random_start_1 = "Default,\nrandom start"
)

layouts <- read_csv(file.path(processed, "pbmc3k_layouts.csv"), show_col_types = FALSE) |>
  filter(layout %in% names(titles)) |>
  group_by(layout) |>
  mutate(
    # center each layout and divide both axes by the same number
    half = max(diff(range(umap1)), diff(range(umap2))) / 2,
    x = (umap1 - mean(range(umap1))) / half,
    y = (umap2 - mean(range(umap2))) / half
  ) |>
  ungroup() |>
  mutate(
    panel = factor(titles[layout], levels = titles),
    cell_type = factor(cell_type, levels = names(type_colors))
  )

p <- ggplot(layouts, aes(x, y, colour = cell_type)) +
  geom_point(size = 0.8, stroke = 0, shape = 16) +
  facet_wrap(vars(panel), nrow = 1) +
  coord_fixed(xlim = c(-1.05, 1.05), ylim = c(-1.05, 1.05), expand = FALSE) +
  scale_colour_manual(values = type_colors, name = NULL) +
  guides(colour = guide_legend(nrow = 1, override.aes = list(size = 4))) +
  theme_deck() +
  theme(
    axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
    axis.line = element_blank(),
    panel.border = element_rect(colour = deck$gray, fill = NA, linewidth = 0.4),
    panel.spacing = unit(8, "pt"),
    strip.background = element_blank(),
    strip.text = element_text(size = 14, colour = deck$text, lineheight = 0.95, vjust = 0,
                              margin = margin(b = 4)),
    legend.position = "bottom",
    legend.text = element_text(size = 13, colour = deck$text, margin = margin(l = 1, r = 4)),
    legend.key.spacing.x = unit(1, "pt"),
    legend.margin = margin(t = 0), legend.box.spacing = unit(4, "pt"),
    plot.margin = margin(2, 2, 2, 2)
  )

save_fig(p, "fig11", size)
