# fig07d_4: why the cell-level test is over-confident (one gene, by donor).
#
# Slide:  Example 3, pseudo-replication in differential expression (README: fig07d)
# Shows:  expression of one gene in every cell, grouped by donor, for the donor
#         split of fig07d_1. The gene is the most significant cell-level
#         discovery that the donor-level test does not call. Gray points:
#         cells. Bars: donor means, blue for group A and orange for group B.
#         Donors differ from each other, and cells of one donor share that
#         donor's level, so thousands of cells carry the information of only
#         eight donors.
# Data:   data/processed/kang_null_example.csv, built by data/make_null_de.R from
#         the control sample of Kang et al. (GEO GSE96583, logged in
#         data/SOURCES.md).
# Cite:   Kang HM, et al. (2018). Multiplexed droplet single-cell RNA-sequencing
#         using natural genetic variation. Nature Biotechnology 36:89-94.
#         Experiment after Squair JW, et al. (2021). Confronting false
#         discoveries in single-cell differential expression. Nature
#         Communications 12:5692.
# Seed:   none (all 35 donor splits are enumerated; nothing is random; set.seed(20261118)
#         fixes only the sideways spread of the points).
# Output: output/fig07d_4.png, output/fig07d_4.svg
# Run from the repository root: Rscript figures/fig07d_4_null_example_gene.R

source(file.path("figures", "deck_style.R"))

cells <- read_csv(file.path(processed, "kang_null_example.csv"), show_col_types = FALSE) |>
  arrange(group, donor) |>
  mutate(donor = factor(donor, levels = unique(donor)))
donor_means <- cells |> group_by(group, donor) |> summarise(n_cells = n(), mean = mean(lognorm), .groups = "drop")
gene <- unique(cells$gene)
message(gene, ": donor means ", paste(sprintf("%.2f", donor_means$mean), collapse = " "))

set.seed(20261118)  # sideways spread of the points only
p <- ggplot(cells, aes(donor, lognorm)) +
  geom_jitter(width = 0.3, height = 0, size = 0.35, stroke = 0, alpha = 0.35, colour = deck$gray) +
  geom_errorbar(aes(y = mean, ymin = mean, ymax = mean, colour = group), donor_means,
                width = 0.8, linewidth = 1.1) +
  geom_vline(xintercept = 4.5, colour = deck$grid, linewidth = 0.4) +
  annotate("text", x = c(2.5, 6.5), y = max(cells$lognorm) * 1.06, label = c("Group A", "Group B"),
           colour = c(deck$blue, deck$orange), family = deck$font, size = deck$label_size) +
  scale_colour_manual(values = c(A = deck$blue, B = deck$orange)) +
  scale_x_discrete(labels = 1:8) +
  # the axis starts a little below zero so that cells with no reads stay visible
  scale_y_continuous(limits = c(-0.25, max(cells$lognorm) * 1.12), breaks = c(0, 2, 4, 6), expand = c(0, 0)) +
  labs(x = "Individual", y = bquote(italic(.(gene)) ~ "expression (log)")) +
  theme_deck()

save_fig(p, "fig07d_4")
