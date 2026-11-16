# fig03a: number of individuals (donors) per study over time.
#
# Slide:  3, "Increasing Complexity of Single Cell Studies"
# Shows:  one point per CELLxGENE collection with human data (publication date
#         of the paper vs. number of distinct donors, log scale) and the median
#         per publication year, drawn at mid-year for years with at least
#         MIN_PER_YEAR collections. A collection corresponds to one
#         publication; donors are pooled across its datasets.
# Data:   data/processed/cellxgene_collections.csv, built from the CELLxGENE
#         Discover snapshot logged in data/SOURCES.md.
# Cite:   CZI Cell Science Program et al. (2025). CZ CELLxGENE Discover: a
#         single-cell data platform for scalable exploration, analysis and
#         modeling of aggregated data. Nucleic Acids Research 53, D886-D900.
# Seed:   none (no randomness).
# Output: output/fig03a.png, output/fig03a.svg,
#         data/processed/fig03a_yearly_median.csv
# Run from the repository root: Rscript figures/fig03a_donors_per_study.R

source(file.path("figures", "deck_style.R"))

min_per_year <- 5  # do not draw a median from fewer collections than this

collections <- read_csv(file.path(processed, "cellxgene_collections.csv"), show_col_types = FALSE) |>
  filter(human, !is.na(pub_date), n_donors > 0)

yearly <- collections |>
  group_by(year) |>
  summarise(n_collections = n(), median_donors = median(n_donors), max_donors = max(n_donors)) |>
  mutate(median_drawn = n_collections >= min_per_year)
write_csv(yearly, file.path(processed, "fig03a_yearly_median.csv"))
drawn <- filter(yearly, median_drawn)

p <- ggplot(collections, aes(pub_date, n_donors)) +
  geom_point(colour = deck$gray, alpha = 0.6, size = 1.1, stroke = 0) +
  geom_line(aes(mid_year(year), median_donors), drawn, colour = deck$blue, linewidth = 0.9) +
  geom_point(aes(mid_year(year), median_donors), drawn, colour = deck$blue, size = 1.1) +
  annotate("text", x = as.Date("2018-01-01"), y = 300, label = "Median per year",
           colour = deck$blue, family = deck$font, size = deck$label_size, hjust = 0.5) +
  scale_y_log10(breaks = c(1, 10, 100, 1000), limits = c(0.8, 3000), expand = c(0, 0)) +
  scale_x_date(breaks = as.Date(paste0(seq(2016, 2026, 2), "-01-01")), date_labels = "%Y",
               limits = as.Date(c("2015-10-01", "2027-03-01")), expand = c(0, 0)) +
  labs(x = "Publication date", y = "Donors per study") +
  theme_deck(grid = TRUE)

save_fig(p, "fig03a")
