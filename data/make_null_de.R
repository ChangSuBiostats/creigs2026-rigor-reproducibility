# Differential expression between random groups of untreated donors (fig07d).
#
# Usage (from the repository root): Rscript data/make_null_de.R
#
# The experiment follows Squair et al. (2021, Nature Communications 12:5692),
# who split the control donors of this dataset at random into two groups. No
# treatment separates the groups, so any gene called differentially expressed
# is a false discovery.
#
# Data:   control sample of Kang et al. (2018), eight donors (data/raw/kang_*).
#         Cells: singlets of one cell type (CELL_TYPE below, the most abundant).
#         Genes: detected in at least 10% of these cells (Seurat's default
#         min.pct), so both tests see the same genes.
# Splits: all 35 ways to divide eight donors into two groups of four. Nothing
#         is drawn at random, so there is no seed.
# Tests:  (1) cell level: Wilcoxon rank-sum test on log-normalized counts,
#             every cell an observation. This is the default of Seurat's
#             FindMarkers. The normal approximation with tie and continuity
#             correction is computed here directly (checked against
#             stats::wilcox.test below) because 35 splits are tested.
#         (2) pseudobulk: counts summed per donor, then DESeq2 with four
#             donors per group, as for a bulk RNA-seq experiment.
#         Both: Benjamini-Hochberg false discovery rate below 5%.
# Output: data/processed/kang_null_splits.csv   one row per split
#         data/processed/kang_null_genes.csv    one row per gene, for the
#                                               split shown in the volcano plots
#         data/processed/kang_null_example.csv  one row per cell, for the
#                                               example gene of fig07d_4
#         data/processed/kang_null_rare_genes.csv  cell-level test of the shown
#                                               split, extended to rarely
#                                               detected genes (fig07d_5, fig07d_6)
#
# The split shown is the one with the median number of cell-level discoveries
# among the 35 (a typical split, not the most extreme).

suppressPackageStartupMessages({
  library(Matrix)
  library(DESeq2)
  library(readr)
})

CELL_TYPE <- "CD4 T cells"
FDR <- 0.05
MIN_PCT <- 0.10
MIN_PCT_RARE <- 0.01  # fig07d_5 and fig07d_6 also show genes detected in 1 to 10% of cells

raw <- file.path("data", "raw")
processed <- file.path("data", "processed")

# --- load the control sample -------------------------------------------------
counts <- as(readMM(gzfile(file.path(raw, "kang_ctrl_counts.mtx.gz"))), "CsparseMatrix")
barcodes <- readLines(gzfile(file.path(raw, "kang_ctrl_barcodes.tsv.gz")))
genes <- read.delim(gzfile(file.path(raw, "kang_genes.tsv.gz")), header = FALSE,
                    col.names = c("ensembl", "symbol"))
meta <- read.delim(gzfile(file.path(raw, "kang_cell_metadata.tsv.gz")))
meta <- meta[meta$stim == "ctrl", ]
# The metadata lists the control cells first, in the order of the matrix columns.
stopifnot(identical(rownames(meta), barcodes), ncol(counts) == nrow(meta),
          nrow(counts) == nrow(genes))
rownames(counts) <- make.unique(genes$symbol)

singlets <- meta$multiplets == "singlet" & !is.na(meta$cell)
stopifnot(names(which.max(table(meta$cell[singlets]))) == CELL_TYPE)
use <- singlets & meta$cell == CELL_TYPE
counts <- counts[, use]
donor <- factor(meta$ind[use])
donors <- levels(donor)
stopifnot(length(donors) == 8)

# --- normalize as the standard pipeline does ---------------------------------
# log(1 + counts per 10,000), where a cell's total is taken over all genes,
# before any gene is filtered out (Seurat's NormalizeData).
counts_all_genes <- counts
cell_total <- colSums(counts_all_genes)
detected <- rowMeans(counts > 0) >= MIN_PCT
counts <- counts[detected, ]
lognorm <- as.matrix(log1p(t(t(counts) / cell_total) * 1e4))
message(CELL_TYPE, ": ", ncol(counts), " cells from ", length(donors), " donors, ",
        nrow(counts), " genes tested")

# --- cell-level Wilcoxon test ------------------------------------------------
n <- ncol(lognorm)
ranks <- t(apply(lognorm, 1, rank))
tie_term <- apply(lognorm, 1, function(v) { t <- table(v); sum(t^3 - t) })
wilcoxon <- function(in_a) {
  n_a <- sum(in_a)
  n_b <- n - n_a
  z <- rowSums(ranks[, in_a, drop = FALSE]) - n_a * (n_a + 1) / 2 - n_a * n_b / 2
  sigma <- sqrt(n_a * n_b / 12 * ((n + 1) - tie_term / (n * (n - 1))))
  2 * pnorm(-abs((z - sign(z) * 0.5) / sigma))
}

# --- pseudobulk --------------------------------------------------------------
pseudobulk <- sapply(donors, function(d) rowSums(counts[, donor == d, drop = FALSE]))
storage.mode(pseudobulk) <- "integer"
deseq <- function(group_a) {
  design <- data.frame(group = factor(ifelse(donors %in% group_a, "A", "B")))
  dds <- DESeqDataSetFromMatrix(pseudobulk, design, ~group)
  as.data.frame(results(suppressMessages(DESeq(dds, quiet = TRUE)), contrast = c("group", "A", "B")))
}

# --- all 35 splits -----------------------------------------------------------
# Fixing the first donor in group A lists each 4 vs 4 split once.
splits <- combn(donors, 4)
splits <- splits[, splits[1, ] == donors[1], drop = FALSE]
stopifnot(ncol(splits) == 35)

test_split <- function(k) {
  in_a <- donor %in% splits[, k]
  p_cell <- wilcoxon(in_a)
  pb <- deseq(splits[, k])
  data.frame(
    split = k,
    gene = rownames(lognorm),
    # fold change of mean normalized expression, as Seurat reports it
    log2fc_cell = log2((rowMeans(expm1(lognorm[, in_a])) + 1) / (rowMeans(expm1(lognorm[, !in_a])) + 1)),
    p_cell = p_cell,
    fdr_cell = p.adjust(p_cell, "BH"),
    bonferroni_cell = p.adjust(p_cell, "bonferroni"),
    log2fc_pseudobulk = pb$log2FoldChange,
    p_pseudobulk = pb$pvalue,
    fdr_pseudobulk = pb$padj
  )
}
results <- lapply(seq_len(ncol(splits)), test_split)

# The shortcut must agree with R's own test.
in_a <- donor %in% splits[, 1]
check <- sapply(1:20, function(i) wilcox.test(lognorm[i, in_a], lognorm[i, !in_a])$p.value)
stopifnot(max(abs(log10(check) - log10(results[[1]]$p_cell[1:20]))) < 1e-6)

summary_table <- do.call(rbind, lapply(results, function(r) {
  k <- r$split[1]
  in_a <- donor %in% splits[, k]
  data.frame(
    split = k,
    donors_a = paste(splits[, k], collapse = " "),
    donors_b = paste(setdiff(donors, splits[, k]), collapse = " "),
    cells_a = sum(in_a),
    cells_b = sum(!in_a),
    genes_tested = nrow(r),
    n_de_cell = sum(r$fdr_cell < FDR),
    n_de_cell_bonferroni = sum(r$bonferroni_cell < FDR),
    max_neglog10p_cell = max(-log10(r$p_cell)),
    n_de_pseudobulk = sum(r$fdr_pseudobulk < FDR, na.rm = TRUE),
    max_neglog10p_pseudobulk = max(-log10(r$p_pseudobulk), na.rm = TRUE)
  )
}))

# The split shown: median number of cell-level discoveries (35 is odd, so the
# median is one of the splits; ties go to the lowest split number).
shown <- summary_table$split[which(summary_table$n_de_cell == median(summary_table$n_de_cell))[1]]
summary_table$shown <- summary_table$split == shown
write_csv(summary_table, file.path(processed, "kang_null_splits.csv"))

genes_shown <- results[[shown]]
genes_shown <- genes_shown[order(genes_shown$p_cell), ]
write_csv(genes_shown, file.path(processed, "kang_null_genes.csv"))

# Example gene: the most significant cell-level discovery in the shown split
# that the pseudobulk test does not call (FDR above 5%).
candidates <- genes_shown[is.na(genes_shown$fdr_pseudobulk) | genes_shown$fdr_pseudobulk >= FDR, ]
example <- candidates$gene[1]
in_a <- donor %in% splits[, shown]
write_csv(
  data.frame(gene = example, donor = donor, group = ifelse(in_a, "A", "B"),
             count = counts[example, ], lognorm = lognorm[example, ]),
  file.path(processed, "kang_null_example.csv")
)

# --- the shown split again, with rarely detected genes -----------------------
# Gibson (2022) draws a "double volcano": an inner burst of small fold changes
# with extreme significance and an outer burst of larger fold changes with
# lower significance. The outer burst consists of rarely detected genes, which
# the analysis above leaves out (Seurat's min.pct) and whose fold changes
# Seurat shrinks by adding 1 to each mean. Here the same cell-level test is
# run on every gene detected in at least MIN_PCT_RARE of the cells, and the
# fold change is the plain ratio of mean normalized expression, without offset.
pct_detected <- rowMeans(counts_all_genes > 0)
rare_counts <- counts_all_genes[pct_detected >= MIN_PCT_RARE, ]
rare_lognorm <- as.matrix(log1p(t(t(rare_counts) / cell_total) * 1e4))
stopifnot(isTRUE(all.equal(rare_lognorm[rownames(lognorm), ], lognorm)))
in_a <- donor %in% splits[, shown]
rare_ranks <- t(apply(rare_lognorm, 1, rank))
rare_tie <- apply(rare_lognorm, 1, function(v) { t <- table(v); sum(t^3 - t) })
n_a <- sum(in_a)
n_b <- n - n_a
z <- rowSums(rare_ranks[, in_a, drop = FALSE]) - n_a * (n_a + 1) / 2 - n_a * n_b / 2
sigma <- sqrt(n_a * n_b / 12 * ((n + 1) - rare_tie / (n * (n - 1))))
p_rare <- 2 * pnorm(-abs((z - sign(z) * 0.5) / sigma))
mean_a <- rowMeans(expm1(rare_lognorm[, in_a]))
mean_b <- rowMeans(expm1(rare_lognorm[, !in_a]))
stopifnot(all(mean_a > 0), all(mean_b > 0))  # the ratio is defined for every gene
rare <- data.frame(
  split = shown,
  gene = rownames(rare_lognorm),
  pct_detected = 100 * pct_detected[pct_detected >= MIN_PCT_RARE],
  detected_in = ifelse(pct_detected[pct_detected >= MIN_PCT_RARE] >= MIN_PCT, "at least 10% of cells", "1 to 10% of cells"),
  log2_ratio_of_means = log2(mean_a / mean_b),
  p_cell = p_rare,
  fdr_cell = p.adjust(p_rare, "BH")
)
# The well-detected genes must get the p-values of the main analysis.
stopifnot(isTRUE(all.equal(rare$p_cell[match(results[[shown]]$gene, rare$gene)], results[[shown]]$p_cell)))
write_csv(rare[order(rare$p_cell), ], file.path(processed, "kang_null_rare_genes.csv"))
message("rare genes: ", nrow(rare), " genes detected in at least ", 100 * MIN_PCT_RARE, "% of cells; ",
        paste(names(table(rare$detected_in)), table(rare$detected_in), collapse = ", "))

message("splits: cell-level discoveries median ", median(summary_table$n_de_cell),
        " (range ", min(summary_table$n_de_cell), " to ", max(summary_table$n_de_cell),
        "); pseudobulk median ", median(summary_table$n_de_pseudobulk),
        " (range ", min(summary_table$n_de_pseudobulk), " to ", max(summary_table$n_de_pseudobulk), ")")
message("shown: split ", shown, " (", summary_table$donors_a[shown], " vs ",
        summary_table$donors_b[shown], "); example gene ", example)
