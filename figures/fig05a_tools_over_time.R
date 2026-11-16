# fig05a: number of single-cell RNA-seq analysis tools over time.
#
# Slide:  5, "Rapid Growth in Single Cell Analysis Tools"
# Shows:  cumulative number of tools in the scRNA-tools database by the date
#         each tool was added to the database (not its release date), from the
#         start of the database (September 2016) to the end of May 2024. An
#         updated version of Fig. 1A in Zappia & Theis (2021), which ends at
#         about 1,000 tools.
#         The x-axis stops at May 2024 because the database has been in
#         low-maintenance mode since then (stated on scrna-tools.org): only 70
#         tools were added afterwards, which reflects curation, not tool
#         development. Decision: Chang, Nov 16, 2026; see NOTES.md.
# Data:   data/processed/scrna_tools.csv, built from the scRNA-tools snapshot
#         logged in data/SOURCES.md.
# Cite:   Zappia L, Theis FJ (2021). Over 1000 tools reveal trends in the
#         single-cell RNA-seq analysis landscape. Genome Biology 22:301.
#         Database: scrna-tools.org.
# Seed:   none (no randomness).
# Output: output/fig05a.png, output/fig05a.svg
# Run from the repository root: Rscript figures/fig05a_tools_over_time.R

source(file.path("figures", "deck_style.R"))

cutoff <- scrna_tools_cutoff  # end of May 2024, set in deck_style.R

all_tools <- read_csv(file.path(processed, "scrna_tools.csv"), show_col_types = FALSE)
tools <- all_tools |>
  filter(added <= cutoff) |>
  count(added, name = "n_added") |>
  mutate(n_tools = cumsum(n_added))
message(max(tools$n_tools), " tools by ", cutoff, "; ", nrow(all_tools) - max(tools$n_tools),
        " added later are not shown")

p <- ggplot(tools, aes(added, n_tools)) +
  geom_step(colour = deck$blue, linewidth = 0.9) +
  scale_x_date(breaks = as.Date(paste0(seq(2018, 2024, 2), "-01-01")), date_labels = "%Y",
               limits = as.Date(c("2016-06-01", "2024-09-01")), expand = c(0, 0)) +
  scale_y_continuous(breaks = c(0, 500, 1000, 1500, 2000), limits = c(0, 2000), expand = c(0, 0)) +
  labs(x = "Date added to database", y = "Tools") +
  theme_deck(grid = TRUE)

save_fig(p, "fig05a")
