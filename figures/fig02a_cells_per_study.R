# fig02a: cells reported per study over time.
#
# Slide:  2, "Rapid Growth in Single Cell Studies"
# Shows:  one point per study (publication date vs. reported total cells, log
#         scale) and the median per calendar year, drawn at mid-year.
#         Reconstruction of the existing panel reference/slide02_1.png, which
#         uses all measurement types and studies dated 2009 or later.
# Data:   data/processed/svensson_studies.csv, built from the single-cell
#         studies database snapshot logged in data/SOURCES.md.
# Cite:   Svensson V, da Veiga Beltrame E, Pachter L (2020). A curated database
#         reveals trends in single-cell transcriptomics. Database, baaa073.
# Seed:   none (no randomness).
# Output: output/fig02a.png, output/fig02a.svg,
#         data/processed/fig02a_yearly_median.csv
# Run from the repository root: Rscript figures/fig02a_cells_per_study.R

source(file.path("figures", "deck_style.R"))

start <- as.Date("2009-01-01")  # same cut as the existing panel

studies <- read_csv(file.path(processed, "svensson_studies.csv"), show_col_types = FALSE) |>
  filter(!is.na(cells), date >= start)

yearly <- studies |>
  group_by(year) |>
  summarise(n_studies = n(), median_cells = median(cells))
write_csv(yearly, file.path(processed, "fig02a_yearly_median.csv"))

p <- ggplot(studies, aes(date, cells)) +
  geom_point(colour = deck$gray, alpha = 0.5, size = 0.9, stroke = 0) +
  geom_line(aes(mid_year(year), median_cells), yearly, colour = deck$blue, linewidth = 0.9) +
  geom_point(aes(mid_year(year), median_cells), yearly, colour = deck$blue, size = 1.1) +
  annotate("text", x = as.Date("2021-03-01"), y = 300, label = "Median per year",
           colour = deck$blue, family = deck$font, size = deck$label_size, hjust = 0.5) +
  scale_y_log10(breaks = 10^c(0, 2, 4, 6, 8), labels = label_si, limits = c(1, 4e8),
                expand = c(0, 0)) +
  scale_x_date(breaks = as.Date(paste0(c(2010, 2015, 2020, 2025), "-01-01")),
               date_labels = "%Y", limits = as.Date(c("2008-10-01", "2027-03-01")),
               expand = c(0, 0)) +
  labs(x = "Publication date", y = "Cells per study") +
  theme_deck(grid = TRUE)

save_fig(p, "fig02a")
