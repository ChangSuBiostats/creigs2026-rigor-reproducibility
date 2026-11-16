# fig05b: analysis tasks covered by single-cell RNA-seq tools.
#
# Slide:  5, "Rapid Growth in Single Cell Analysis Tools"
# Shows:  number of tools in the scRNA-tools database assigned to each of
#         its 33 analysis categories, grouped by phase of a standard analysis
#         workflow and ordered left to right. A tool can belong to several
#         categories, so the counts sum to more than the number of tools.
#         Only tools added to the database by the end of May 2024 are counted,
#         the same cut-off as fig05a (decision: Chang, Nov 16, 2026; see
#         NOTES.md). Categories are the ones recorded in the current snapshot.
#         Same content as Fig. 1D of Zappia & Theis (2021), updated to the
#         current database and laid out horizontally to fit the slide. The
#         phase names (the database only numbers them) are taken from that
#         figure.
# Data:   data/processed/scrna_tools.csv and scrna_tools_categories.csv, built
#         from the scRNA-tools snapshot logged in data/SOURCES.md.
# Cite:   Zappia L, Theis FJ (2021). Over 1000 tools reveal trends in the
#         single-cell RNA-seq analysis landscape. Genome Biology 22:301.
#         Database: scrna-tools.org.
# Seed:   none (no randomness).
# Output: output/fig05b.png, output/fig05b.svg,
#         data/processed/fig05b_tools_per_category.csv
# Run from the repository root: Rscript figures/fig05b_tools_per_category.R

source(file.path("figures", "deck_style.R"))

size <- c(7.8, 2.85)  # wide panel: sits beside the half-slide fig05a

phase_names <- c(
  "Phase 1" = "Data\nacquisition",
  "Phase 2" = "Data\ncleaning",
  "Phase 3" = "Cell\nassignment",
  "Phase 4" = "Gene\nidentification",
  "Multiple" = "Multiple\nphases",
  "Other" = "Other"
)

tools <- read_csv(file.path(processed, "scrna_tools.csv"), show_col_types = FALSE) |>
  filter(added <= scrna_tools_cutoff)
n_tools <- nrow(tools)
categories <- read_csv(file.path(processed, "scrna_tools_categories.csv"), show_col_types = FALSE) |>
  semi_join(tools, by = "tool") |>
  count(phase, category, name = "n_tools") |>
  mutate(
    pct_of_tools = 100 * n_tools / .env$n_tools,
    # "DimensionalityReduction" -> "Dimensionality reduction", US spelling
    label = category |>
      stringr::str_replace_all("(?<=[a-z])(?=[A-Z])", " ") |>
      stringr::str_to_sentence() |>
      stringr::str_replace("isation", "ization") |>
      stringr::str_replace("^Umis$", "UMIs") |>
      # abbreviations as in the paper's figure, to keep the rotated labels short
      stringr::str_replace("^Dimensionality", "Dim.") |>
      stringr::str_replace("^Differential", "Diff.") |>
      stringr::str_replace("^Alternative", "Alt."),
    phase = factor(phase, levels = names(phase_names), labels = phase_names)
  ) |>
  arrange(phase, desc(pct_of_tools))
stopifnot(!anyNA(categories$phase))
message(n_tools, " tools added by ", scrna_tools_cutoff, "; ", sum(categories$n_tools),
        " category assignments in ", nrow(categories), " categories")
write_csv(mutate(categories, phase = stringr::str_replace(phase, "\n", " ")),
          file.path(processed, "fig05b_tools_per_category.csv"))

categories <- mutate(categories, label = factor(label, levels = label))

# Category names (9 pt) and value labels (7 pt) are below the 12 pt in the
# README: 33 categories do not fit otherwise.
p <- ggplot(categories, aes(label, n_tools)) +
  geom_col(fill = deck$blue, width = 0.75) +
  geom_text(aes(label = n_tools), vjust = -0.4, family = deck$font, size = 7 / .pt) +
  facet_grid(cols = vars(phase), scales = "free_x", space = "free_x") +
  scale_y_continuous(breaks = c(0, 400, 800), limits = c(0, 900), expand = c(0, 0)) +
  labs(x = NULL, y = "Tools") +
  theme_deck() +
  theme(
    axis.text.x = element_text(size = 9, angle = 45, hjust = 1, vjust = 1),
    axis.ticks.x = element_blank(),
    strip.background = element_blank(),
    strip.text = element_text(size = 10, colour = deck$text2, lineheight = 0.9, vjust = 0),
    strip.clip = "off",
    panel.spacing = unit(7, "pt"),
    plot.margin = margin(4, 8, 4, 24)  # left room for the first rotated label
  )

save_fig(p, "fig05b", size)
