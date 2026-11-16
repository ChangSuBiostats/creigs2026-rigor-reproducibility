# fig05b: analysis tasks covered by single-cell RNA-seq tools.
#
# Slide:  5, "Rapid Growth in Single Cell Analysis Tools"
# Shows:  percentage of tools in the scRNA-tools database assigned to each
#         analysis category, for the TOP_N most common of the database's
#         categories. A tool can belong to several categories, so the
#         percentages do not sum to 100. An updated version of Fig. 1D in
#         Zappia & Theis (2021).
# Data:   data/processed/scrna_tools.csv and scrna_tools_categories.csv, built
#         from the scRNA-tools snapshot logged in data/SOURCES.md.
# Cite:   Zappia L, Theis FJ (2021). Over 1000 tools reveal trends in the
#         single-cell RNA-seq analysis landscape. Genome Biology 22:301.
#         Database: scrna-tools.org.
# Seed:   none (no randomness).
# Output: output/fig05b.png, output/fig05b.svg,
#         data/processed/fig05b_tools_per_category.csv (all categories)
# Run from the repository root: Rscript figures/fig05b_tools_per_category.R

source(file.path("figures", "deck_style.R"))

top_n <- 14

n_tools <- nrow(read_csv(file.path(processed, "scrna_tools.csv"), show_col_types = FALSE))
categories <- read_csv(file.path(processed, "scrna_tools_categories.csv"), show_col_types = FALSE) |>
  count(category, name = "n_tools", sort = TRUE) |>
  mutate(
    pct_of_tools = 100 * n_tools / .env$n_tools,
    # "DimensionalityReduction" -> "Dimensionality reduction", US spelling
    label = category |>
      stringr::str_replace_all("(?<=[a-z])(?=[A-Z])", " ") |>
      stringr::str_to_sentence() |>
      stringr::str_replace("isation", "ization")
  )
write_csv(categories, file.path(processed, "fig05b_tools_per_category.csv"))

top <- slice_head(categories, n = top_n) |>
  mutate(label = factor(label, levels = rev(label)))

# Category names and value labels are 9 pt: 14 rows do not fit at 12 pt.
p <- ggplot(top, aes(pct_of_tools, label)) +
  geom_col(fill = deck$blue, width = 0.72) +
  geom_text(aes(label = sprintf("%.0f%%", pct_of_tools)), hjust = 0, nudge_x = 0.6,
            family = deck$font, size = 9 / .pt) +
  scale_x_continuous(breaks = c(0, 20, 40), limits = c(0, 48), expand = c(0, 0)) +
  labs(x = "Tools (%)", y = NULL) +
  theme_deck() +
  theme(axis.text.y = element_text(size = 9), axis.ticks.y = element_blank())

save_fig(p, "fig05b")
