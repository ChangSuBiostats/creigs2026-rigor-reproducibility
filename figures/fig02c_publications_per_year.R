# fig02c: single-cell RNA-seq publications per year.
#
# Slide:  2, "Rapid Growth in Single Cell Studies"
# Shows:  number of PubMed records per publication year, 2009 to 2025, whose
#         title or abstract mentions single-cell or single-nucleus RNA-seq,
#         reviews excluded. The exact query is in data/get_data.R and
#         data/SOURCES.md. The count depends on the query, so it shows the
#         trend, not an exact census of studies. 2026 is left out because the
#         year is not complete.
# Data:   data/processed/pubmed_counts.csv, from NCBI E-utilities (esearch).
# Cite:   PubMed, National Library of Medicine; search run on the access date
#         in data/SOURCES.md.
# Seed:   none (no randomness).
# Output: output/fig02c.png, output/fig02c.svg
# Run from the repository root: Rscript figures/fig02c_publications_per_year.R

source(file.path("figures", "deck_style.R"))

pubmed <- read_csv(file.path(processed, "pubmed_counts.csv"), show_col_types = FALSE)

p <- ggplot(pubmed, aes(year, count)) +
  geom_col(fill = deck$blue, width = 0.75) +
  scale_x_continuous(breaks = c(2010, 2015, 2020, 2025)) +
  scale_y_continuous(breaks = c(0, 4000, 8000, 12000), labels = label_si,
                     limits = c(0, 12500), expand = c(0, 0)) +
  labs(x = "Publication year", y = "Publications") +
  theme_deck()

save_fig(p, "fig02c")
