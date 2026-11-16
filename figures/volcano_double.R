# Shared by fig07d_5 and fig07d_6 (not a figure script itself): the cell-level
# volcano plot of the shown donor split, extended to rarely detected genes.
# The two figures use identical axes so that fig07d_6 can be laid exactly over
# fig07d_5 on the slide.
#
# x: log2 ratio of mean normalized expression between the two groups, without
#    the offset of 1 that Seurat adds to each mean (which shrinks the fold
#    changes of rarely detected genes).
# y: -log10 p-value of the Wilcoxon test, stopped at the same limit as
#    fig07d_1; genes above it are triangles on the top edge with their value.

double_volcano <- function(show_rare) {
  genes <- read_csv(file.path(processed, "kang_null_rare_genes.csv"), show_col_types = FALSE) |>
    mutate(rare = detected_in == "1 to 10% of cells", neglog10p = -log10(p_cell))
  main <- read_csv(file.path(processed, "kang_null_genes.csv"), show_col_types = FALSE)
  y_max <- 10 * ceiling(sort(-log10(c(main$p_cell, main$p_pseudobulk)), decreasing = TRUE)[2] / 10)
  x_max <- ceiling(max(abs(genes$log2_ratio_of_means)))
  genes <- mutate(genes, off_scale = neglog10p > y_max, y = pmin(neglog10p, y_max))
  message(sum(!genes$rare), " genes detected in at least 10% of cells, ", sum(genes$rare),
          " in 1 to 10%; called at FDR 5%: ", sum(genes$fdr_cell[!genes$rare] < 0.05), " and ",
          sum(genes$fdr_cell[genes$rare] < 0.05))
  common <- filter(genes, !rare)
  p <- ggplot(mapping = aes(log2_ratio_of_means, y))
  if (show_rare) {
    p <- p +
      geom_point(data = filter(genes, rare), colour = deck$orange, size = 0.8, stroke = 0, alpha = 0.55) +
      annotate("text", x = x_max, y = y_max * 0.36, hjust = 1, family = deck$font, size = deck$label_size,
               colour = deck$orange, label = "Detected in\n1\u201310% of cells", lineheight = 0.9)
  }
  p +
    geom_point(data = filter(common, !off_scale), colour = deck$blue, size = 0.8, stroke = 0, alpha = 0.8) +
    geom_point(data = filter(common, off_scale), colour = deck$blue, shape = 17, size = 2) +
    geom_text(aes(label = paste0(gene, " (", round(neglog10p), ")")), filter(common, off_scale),
              hjust = 1, nudge_x = -0.12, fontface = "italic", family = deck$font,
              size = deck$label_size, colour = deck$blue) +
    annotate("text", x = -x_max, y = y_max * 0.9, hjust = 0, family = deck$font, size = deck$label_size,
             colour = deck$blue, label = "Detected in\n\u2265 10% of cells", lineheight = 0.9) +
    scale_x_continuous(limits = c(-x_max, x_max), breaks = seq(-x_max, x_max, by = 1)) +
    scale_y_continuous(limits = c(0, y_max), expand = expansion(mult = c(0, 0.03))) +
    coord_cartesian(clip = "off") +
    labs(x = "Log2 fold change", y = expression(-log[10] ~ italic(P))) +
    theme_deck(grid = TRUE)
}
