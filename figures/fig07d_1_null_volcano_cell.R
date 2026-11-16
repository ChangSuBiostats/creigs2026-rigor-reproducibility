# fig07d_1: false discoveries from a cell-level test (volcano plot).
#
# Slide:  Example 3, pseudo-replication in differential expression (README: fig07d)
# Shows:  volcano plot for a comparison in which no true difference exists: CD4 T
#         cells of eight untreated donors, split into two groups of four
#         donors. Test: Wilcoxon rank-sum on log-normalized counts with every
#         cell as an observation (Seurat's default). Blue: genes called at a
#         false discovery rate below 5%. The split shown is the one with the
#         median number of such genes among all 35 possible splits. Same axes
#         as fig07d_2. The gene circled in orange is the one shown by
#         donor in fig07d_4.
# Data:   data/processed/kang_null_genes.csv, built by data/make_null_de.R from
#         the control sample of Kang et al. (GEO GSE96583, logged in
#         data/SOURCES.md).
# Cite:   Kang HM, et al. (2018). Multiplexed droplet single-cell RNA-sequencing
#         using natural genetic variation. Nature Biotechnology 36:89-94.
#         Experiment after Squair JW, et al. (2021). Confronting false
#         discoveries in single-cell differential expression. Nature
#         Communications 12:5692.
# Seed:   none (all 35 donor splits are enumerated; nothing is random).
# Output: output/fig07d_1.png, output/fig07d_1.svg
# Run from the repository root: Rscript figures/fig07d_1_null_volcano_cell.R

source(file.path("figures", "deck_style.R"))

fdr <- 0.05
genes <- read_csv(file.path(processed, "kang_null_genes.csv"), show_col_types = FALSE) |>
  mutate(called = !is.na(fdr_cell) & fdr_cell < fdr)

# Both volcano plots (fig07d_1, fig07d_2) use the same axes, set by the data
# of both tests, so that their heights can be compared directly.
y_max <- 10 * ceiling(max(-log10(c(genes$p_cell, genes$p_pseudobulk)), na.rm = TRUE) / 10)
x_max <- ceiling(max(abs(c(genes$log2fc_cell, genes$log2fc_pseudobulk)), na.rm = TRUE))
message(sum(genes$called), " of ", nrow(genes), " genes called at FDR ", fdr,
        "; smallest p-value ", signif(min(genes$p_cell, na.rm = TRUE), 3))

# The gene shown by donor in fig07d_4 is marked in both volcano plots.
example <- unique(read_csv(file.path(processed, "kang_null_example.csv"), show_col_types = FALSE)$gene)
untested <- sum(is.na(genes$p_cell))
if (untested > 0) message(untested, " gene(s) without a p-value from this test are not drawn")

p <- ggplot(filter(genes, !is.na(p_cell)), aes(log2fc_cell, -log10(p_cell))) +
  geom_point(aes(colour = called), size = 0.9, stroke = 0, alpha = 0.8) +
  geom_point(data = filter(genes, gene == example), shape = 21, size = 2.2, stroke = 0.6,
             colour = deck$orange, fill = NA) +
  geom_text(aes(label = gene), filter(genes, gene == example), hjust = 0, nudge_x = 0.12,
            fontface = "italic", family = deck$font, size = deck$label_size, colour = deck$orange) +
  annotate("text", x = -x_max, y = y_max * 0.93, hjust = 0, family = deck$font,
           size = deck$label_size, colour = deck$blue,
           label = paste0(sum(genes$called), " genes\nFDR < 5%"), lineheight = 0.9) +
  scale_colour_manual(values = c(`TRUE` = deck$blue, `FALSE` = deck$gray)) +
  scale_x_continuous(limits = c(-x_max, x_max), breaks = seq(-x_max, x_max, by = 1)) +
  scale_y_continuous(limits = c(0, y_max), expand = expansion(mult = c(0, 0.02))) +
  labs(x = "Log2 fold change", y = expression(-log[10] ~ italic(P))) +
  theme_deck(grid = TRUE)

save_fig(p, "fig07d_1")
