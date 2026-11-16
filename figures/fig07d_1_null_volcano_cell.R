# fig07d_1: false discoveries from a cell-level test (volcano plot).
#
# Slide:  Example 3, pseudo-replication in differential expression (README: fig07d)
# Shows:  volcano plot for a comparison in which no true difference exists: CD4 T
#         cells of eight untreated donors, split into two groups of four
#         donors. Test: Wilcoxon rank-sum on log-normalized counts with every
#         cell as an observation (Seurat's default). Blue: genes called at a
#         false discovery rate below 5%. The split shown is the one with the
#         median number of such genes among all 35 possible splits. Same axes
#         as fig07d_2. A gene above the y-axis limit is drawn as a triangle on
#         the top edge and labelled with its value. The gene circled in orange
#         is the one shown by donor in fig07d_4.
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

# Both volcano plots (fig07d_1, fig07d_2) use the same axes so that their
# heights can be compared directly. The y-axis stops at Y_MAX: a gene above it
# is drawn as a triangle on the top edge and labelled with its true value, so
# nothing is hidden. Y_MAX is the lowest multiple of 10 that leaves at most
# one gene off the scale in either plot.
neglog10p_all <- -log10(c(genes$p_cell, genes$p_pseudobulk))
Y_MAX <- 10 * ceiling(sort(neglog10p_all, decreasing = TRUE)[2] / 10)
x_max <- ceiling(max(abs(c(genes$log2fc_cell, genes$log2fc_pseudobulk)), na.rm = TRUE))
# The gene shown by donor in fig07d_4 is marked in both volcano plots.
example <- unique(read_csv(file.path(processed, "kang_null_example.csv"), show_col_types = FALSE)$gene)

untested <- sum(is.na(genes$p_cell))
if (untested > 0) message(untested, " gene(s) without a p-value from this test are not drawn")
genes <- genes |>
  filter(!is.na(p_cell)) |>
  mutate(neglog10p = -log10(p_cell), off_scale = neglog10p > Y_MAX, y = pmin(neglog10p, Y_MAX))
message(sum(genes$called), " of ", nrow(genes), " genes called at FDR ", fdr,
        "; smallest p-value ", signif(min(genes$p_cell), 3), "; y-axis to ", Y_MAX, "; above it: ",
        paste0(genes$gene[genes$off_scale], " (", round(genes$neglog10p[genes$off_scale]), ")", collapse = ", "))
marked <- filter(genes, gene == example)
stopifnot(nrow(marked) == 1, !marked$off_scale)

p <- ggplot(filter(genes, !off_scale), aes(log2fc_cell, y)) +
  geom_point(aes(colour = called), size = 0.9, stroke = 0, alpha = 0.8) +
  # off the scale: triangle on the top edge, labelled with the true value
  geom_point(aes(colour = called), filter(genes, off_scale), shape = 17, size = 2) +
  geom_text(aes(label = paste0(gene, " (", round(neglog10p), ")"), colour = called), filter(genes, off_scale),
            hjust = 1, nudge_x = -0.1, fontface = "italic", family = deck$font, size = deck$label_size) +
  geom_point(data = marked, shape = 21, size = 2.2, stroke = 0.6, colour = deck$orange, fill = NA) +
  geom_text(aes(label = gene), marked, hjust = 0, nudge_x = 0.12,
            fontface = "italic", family = deck$font, size = deck$label_size, colour = deck$orange) +
  annotate("text", x = -x_max, y = Y_MAX * 0.9, hjust = 0, family = deck$font,
           size = deck$label_size, colour = deck$blue,
           label = paste0(sum(genes$called), " genes\nFDR < 5%"), lineheight = 0.9) +
  scale_colour_manual(values = c(`TRUE` = deck$blue, `FALSE` = deck$gray)) +
  scale_x_continuous(limits = c(-x_max, x_max), breaks = seq(-x_max, x_max, by = 1)) +
  scale_y_continuous(limits = c(0, Y_MAX), expand = expansion(mult = c(0, 0.03))) +
  coord_cartesian(clip = "off") +
  labs(x = "Log2 fold change", y = expression(-log[10] ~ italic(P))) +
  theme_deck(grid = TRUE)

save_fig(p, "fig07d_1")
