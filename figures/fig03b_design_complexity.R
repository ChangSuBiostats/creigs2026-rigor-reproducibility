# fig03b: share of studies with a more complex design, by period.
#
# Slide:  3, "Increasing Complexity of Single Cell Studies"
# Shows:  among CELLxGENE collections with human data, the percentage in each
#         three-year publication period that (1) include both donors with a
#         disease and unaffected ("normal") donors, and (2) use more than one
#         assay (sequencing platform or chemistry version). Years are pooled
#         into periods because single years have as few as 6 collections.
#         Collections published before 2018 (3) are left out.
# Data:   data/processed/cellxgene_collections.csv, built from the CELLxGENE
#         Discover snapshot logged in data/SOURCES.md.
# Cite:   CZI Cell Science Program et al. (2025). CZ CELLxGENE Discover: a
#         single-cell data platform for scalable exploration, analysis and
#         modeling of aggregated data. Nucleic Acids Research 53, D886-D900.
# Seed:   none (no randomness).
# Output: output/fig03b.png, output/fig03b.svg,
#         data/processed/fig03b_design_by_period.csv
# Run from the repository root: Rscript figures/fig03b_design_complexity.R

source(file.path("figures", "deck_style.R"))

collections <- read_csv(file.path(processed, "cellxgene_collections.csv"), show_col_types = FALSE) |>
  filter(human, !is.na(pub_date), year >= 2018) |>
  mutate(period = cut(year, breaks = c(2017, 2020, 2023, 2026),
                      labels = c("2018–20", "2021–23", "2024–26")))

by_period <- collections |>
  group_by(period) |>
  summarise(
    n_collections = n(),
    pct_disease_and_normal = 100 * mean(disease_and_normal),
    pct_multi_assay = 100 * mean(n_assays > 1)
  )
write_csv(by_period, file.path(processed, "fig03b_design_by_period.csv"))

long <- by_period |>
  tidyr::pivot_longer(starts_with("pct_"), names_to = "design", values_to = "pct") |>
  mutate(design = factor(design, levels = c("pct_disease_and_normal", "pct_multi_assay"),
                         labels = c("Disease and\ncontrol donors", "More than\none assay")))

p <- ggplot(long, aes(period, pct)) +
  geom_col(aes(fill = period == "2018–20"), width = 0.7) +
  geom_text(aes(label = sprintf("%.0f%%", pct)), vjust = -0.5, family = deck$font,
            size = deck$label_size) +
  facet_wrap(vars(design)) +
  scale_fill_manual(values = c(`TRUE` = deck$gray, `FALSE` = deck$blue)) +
  scale_y_continuous(breaks = c(0, 20, 40), limits = c(0, 58), expand = c(0, 0)) +
  labs(x = "Publication year", y = "Studies (%)") +
  theme_deck() +
  theme(strip.background = element_blank(),
        strip.text = element_text(size = 10, colour = deck$text2, lineheight = 0.9),
        strip.clip = "off",
        axis.text.x = element_text(size = 8),  # six period labels do not fit at 12 pt
        panel.spacing = unit(10, "pt"))

save_fig(p, "fig03b")
