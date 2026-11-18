# fig07d_3: false discoveries across all 35 donor splits.
#
# Slide:  26, "False positives across datasets and methods" (Example 3, cells
#         against individuals as the unit of a differential expression test)
# Shows:  number of genes called differentially expressed (false discovery rate
#         below 5%) in each of the 35 ways to split eight untreated donors into
#         two groups of four, for the cell-level Wilcoxon test and for
#         pseudobulk DESeq2. One point per split; the bar is the median. Every
#         called gene is a false discovery, since no treatment separates the
#         groups.
# Data:   data/processed/kang_null_splits.csv, built by data/make_null_de.R from
#         the control sample of Kang et al. (GEO GSE96583, logged in
#         data/SOURCES.md).
# Cite:   Kang HM, et al. (2018). Multiplexed droplet single-cell RNA-sequencing
#         using natural genetic variation. Nature Biotechnology 36:89-94.
#         Experiment after Squair JW, et al. (2021). Confronting false
#         discoveries in single-cell differential expression. Nature
#         Communications 12:5692.
# Seed:   none (all 35 donor splits are enumerated; nothing is random).
# Output: output/fig07d_3.png, output/fig07d_3.svg
# Run from the repository root: Rscript figures/fig07d_3_null_discoveries.R

source(file.path("figures", "deck_style.R"))

splits <- read_csv(file.path(processed, "kang_null_splits.csv"), show_col_types = FALSE) |>
  select(split, `Cell level\n(Wilcoxon)` = n_de_cell, `Individual level\n(pseudobulk)` = n_de_pseudobulk) |>
  tidyr::pivot_longer(-split, names_to = "test", values_to = "n_de")
medians <- splits |> group_by(test) |> summarise(n_de = median(n_de)) |> arrange(test)

# Points are spread sideways by a fixed rule (split number), not at random.
p <- ggplot(splits, aes(test, n_de)) +
  geom_point(aes(x = as.numeric(factor(test)) + ((split * 7) %% 35 - 17) / 110, colour = test),
             size = 1.3, stroke = 0, alpha = 0.7) +
  geom_errorbar(aes(ymin = n_de, ymax = n_de), medians, width = 0.45, linewidth = 0.9,
                colour = deck$text) +
  annotate("text", x = c(1.3, 2), y = c(medians$n_de[1], 90), hjust = c(0, 0.5),
           label = paste("median", medians$n_de), family = deck$font, size = deck$label_size) +
  scale_colour_manual(values = c(deck$blue, deck$gray)) +
  scale_x_discrete(limits = sort(unique(splits$test)), expand = expansion(add = c(0.6, 0.75))) +
  scale_y_continuous(limits = c(0, 500), expand = c(0, 0)) +
  labs(x = NULL, y = "Genes called (FDR < 5%)") +
  theme_deck(grid = TRUE)

save_fig(p, "fig07d_3")
