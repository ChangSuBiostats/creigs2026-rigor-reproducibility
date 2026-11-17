# PBMC 3k through the Seurat tutorial pipeline, then PCA, t-SNE and UMAP
# layouts for Example 1 (fig09a to fig09c, fig11, fig12).
#
# Usage (from the repository root): Rscript data/make_pbmc3k.R
#
# Data:     data/raw/pbmc3k_filtered_gene_bc_matrices.tar.gz (10x Genomics).
# Pipeline: the Seurat "Guided Clustering Tutorial"
#           (satijalab.org/seurat/articles/pbmc3k_tutorial), with its settings:
#           genes in at least 3 cells; cells with 200 to 2,500 genes and under
#           5% mitochondrial reads; log-normalization; 2,000 variable genes;
#           scaling; PCA; neighbors and clusters on 10 principal components
#           (resolution 0.5); t-SNE and UMAP on the same 10 components.
# Cell types: the tutorial's nine names, assigned to clusters by its marker
#           genes (not by cluster number, which can change between versions).
# UMAP layouts (fig11): uwot, the package Seurat calls, with Seurat's metric
#           (cosine). The first layout is Seurat's default and is checked to be
#           identical to RunUMAP's result.
# Seeds:    Seurat's defaults: PCA 42, clustering 0, t-SNE 1, UMAP 42. The
#           other UMAP layouts use the seeds in `layouts` below. Seeds 1 and 2
#           were fixed before looking at any layout: no seed was chosen for its
#           picture.
# Output:   data/processed/pbmc3k_cells.csv           one row per cell
#           data/processed/pbmc3k_layouts.csv         one row per cell and layout
#           data/processed/pbmc3k_type_distances.csv  one row per pair of cell
#                                                     types and layout (fig12)
#           data/processed/pbmc3k_resolutions.csv     one row per cell: clusters
#                                                     at resolutions 0.1, 0.5
#                                                     and 2.5 (fig15)
#           data/processed/pbmc3k_gene_pairs.csv      one row per cell and gene
#                                                     pair (fig08): three pairs
#                                                     of genes drawn at random
#                                                     from all 13,714 genes,
#                                                     seed 20261118 (the lecture
#                                                     date), in the order drawn

suppressPackageStartupMessages({
  library(Seurat)
  library(readr)
})

raw <- file.path("data", "raw")
processed <- file.path("data", "processed")

# --- the tutorial pipeline ---------------------------------------------------
unpacked <- tempfile("pbmc3k")
untar(file.path(raw, "pbmc3k_filtered_gene_bc_matrices.tar.gz"), exdir = unpacked)
pbmc <- CreateSeuratObject(Read10X(file.path(unpacked, "filtered_gene_bc_matrices", "hg19")),
                           min.cells = 3, min.features = 200)
pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")
pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)
pbmc <- NormalizeData(pbmc, verbose = FALSE)
pbmc <- FindVariableFeatures(pbmc, selection.method = "vst", nfeatures = 2000, verbose = FALSE)
pbmc <- ScaleData(pbmc, features = rownames(pbmc), verbose = FALSE)
pbmc <- RunPCA(pbmc, verbose = FALSE)
pbmc <- FindNeighbors(pbmc, dims = 1:10, verbose = FALSE)
pbmc <- FindClusters(pbmc, resolution = 0.5, verbose = FALSE)
pbmc <- suppressWarnings(RunUMAP(pbmc, dims = 1:10, verbose = FALSE))
pbmc <- RunTSNE(pbmc, dims = 1:10)
stopifnot(ncol(pbmc) == 2638)  # the tutorial's number of cells

# --- cell types from the tutorial's marker genes -----------------------------
markers <- c("IL7R", "CCR7", "S100A4", "CD14", "LYZ", "MS4A1", "CD8A", "FCGR3A", "MS4A7",
             "GNLY", "NKG7", "FCER1A", "CST3", "PPBP", "CD3D")
cluster <- Idents(pbmc)
expr <- GetAssayData(pbmc, layer = "data")[markers, ]
name_cluster <- function(m) {
  if (m["PPBP"] > 2) return("Platelet")
  if (m["FCER1A"] > 1) return("DC")
  if (m["MS4A1"] > 1) return("B")
  if (m["LYZ"] > 2.5 && m["CST3"] > 2) {
    return(if (m["FCGR3A"] > 1 && m["MS4A7"] > 0.8) "FCGR3A+ Mono" else "CD14+ Mono")
  }
  if (m["GNLY"] > 2 && m["CD3D"] < 1) return("NK")
  if (m["CD3D"] > 1 && m["CD8A"] > 0.8) return("CD8 T")
  if (m["CCR7"] > 0.6) "Naive CD4 T" else "Memory CD4 T"
}
type_of_cluster <- sapply(levels(cluster), function(cl) {
  name_cluster(rowMeans(expr[, cluster == cl, drop = FALSE]))
})
cell_types <- c("Naive CD4 T", "Memory CD4 T", "CD8 T", "NK", "B", "CD14+ Mono",
                "FCGR3A+ Mono", "DC", "Platelet")
stopifnot(setequal(type_of_cluster, cell_types), !anyDuplicated(type_of_cluster))
cell_type <- unname(type_of_cluster[as.character(cluster)])

cells <- data.frame(
  cell = colnames(pbmc),
  cluster = as.character(cluster),
  cell_type = cell_type,
  pc1 = Embeddings(pbmc, "pca")[, 1], pc2 = Embeddings(pbmc, "pca")[, 2],
  tsne1 = Embeddings(pbmc, "tsne")[, 1], tsne2 = Embeddings(pbmc, "tsne")[, 2],
  umap1 = Embeddings(pbmc, "umap")[, 1], umap2 = Embeddings(pbmc, "umap")[, 2]
)
write_csv(cells, file.path(processed, "pbmc3k_cells.csv"))
message(nrow(cells), " cells; ", paste(names(table(cell_type)), table(cell_type), collapse = ", "))

# --- clusters at three resolutions (fig15a to fig15c) ------------------------
# Same neighbor graph, Louvain at a low, the tutorial's and a high resolution.
resolutions <- c(0.1, 0.5, 2.5)
by_resolution <- data.frame(cell = cells$cell, umap1 = cells$umap1, umap2 = cells$umap2)
for (r in resolutions) {
  pbmc <- FindClusters(pbmc, resolution = r, verbose = FALSE)
  by_resolution[[paste0("resolution_", r)]] <- as.character(Idents(pbmc))
}
stopifnot(identical(by_resolution$resolution_0.5, cells$cluster))
write_csv(by_resolution, file.path(processed, "pbmc3k_resolutions.csv"))
message("clusters at resolutions ", paste(resolutions, collapse = ", "), ": ",
        paste(sapply(by_resolution[, -(1:3)], function(v) length(unique(v))), collapse = ", "))

# --- three random pairs of genes (fig08) -------------------------------------
set.seed(20261118)
drawn <- matrix(sample(rownames(pbmc), 6), ncol = 2, byrow = TRUE)
lognorm <- GetAssayData(pbmc, layer = "data")
write_csv(
  do.call(rbind, lapply(1:3, function(i) {
    data.frame(pair = i, gene_x = drawn[i, 1], gene_y = drawn[i, 2], cell = cells$cell,
               cell_type = cell_type, x = lognorm[drawn[i, 1], ], y = lognorm[drawn[i, 2], ],
               row.names = NULL)
  })),
  file.path(processed, "pbmc3k_gene_pairs.csv")
)
message("random gene pairs: ", paste(drawn[, 1], drawn[, 2], sep = " and ", collapse = "; "),
        "; cells with both genes at zero: ",
        paste(sapply(1:3, function(i) sum(lognorm[drawn[i, 1], ] == 0 & lognorm[drawn[i, 2], ] == 0)), collapse = ", "))

# --- UMAP under other settings and starting positions ------------------------
pcs <- Embeddings(pbmc, "pca")[, 1:10]  # what UMAP is given
layouts <- data.frame(
  layout = c("default", "another_seed", "few_neighbors", "many_neighbors", "random_start_1", "random_start_2"),
  n_neighbors = c(30, 30, 5, 100, 30, 30),
  min_dist = c(0.3, 0.3, 0.1, 0.8, 0.3, 0.3),
  start = c("spectral", "spectral", "spectral", "spectral", "random", "random"),
  seed = c(42, 1, 42, 42, 1, 2)
)
run_umap <- function(i) {
  set.seed(layouts$seed[i])
  uwot::umap(pcs, n_neighbors = layouts$n_neighbors[i], min_dist = layouts$min_dist[i],
             metric = "cosine", init = layouts$start[i], n_threads = 1, n_sgd_threads = 1)
}
coords <- lapply(seq_len(nrow(layouts)), run_umap)
names(coords) <- layouts$layout
# The first layout must be the one Seurat's RunUMAP produced above.
stopifnot(max(abs(coords$default - Embeddings(pbmc, "umap"))) == 0)
write_csv(
  do.call(rbind, lapply(seq_len(nrow(layouts)), function(i) {
    data.frame(layouts[i, ], cell = cells$cell, cell_type = cell_type,
               umap1 = coords[[i]][, 1], umap2 = coords[[i]][, 2], row.names = NULL)
  })),
  file.path(processed, "pbmc3k_layouts.csv")
)

# --- distances between cell types: in the data and on each UMAP --------------
# Distance between two cell types = distance between their average cells.
# "data": the 10 principal components UMAP is given. As a check, the same
# distances in two larger spaces (2,000 scaled variable genes; all genes,
# log-normalized) are also written.
between_types <- function(m) {
  centers <- t(sapply(cell_types, function(t) colMeans(m[cell_type == t, , drop = FALSE])))
  as.matrix(dist(centers))
}
pairs <- t(combn(cell_types, 2))
pick <- function(d) d[pairs]
distances <- data.frame(
  type_a = pairs[, 1], type_b = pairs[, 2],
  data_10_pcs = pick(between_types(pcs)),
  data_variable_genes = pick(between_types(t(as.matrix(
    GetAssayData(pbmc, layer = "scale.data")[VariableFeatures(pbmc), ])))),
  data_all_genes = pick(between_types(t(as.matrix(GetAssayData(pbmc, layer = "data")))))
)
for (l in layouts$layout) distances[[paste0("umap_", l)]] <- pick(between_types(coords[[l]]))
write_csv(distances, file.path(processed, "pbmc3k_type_distances.csv"))
rho <- function(a, b) round(cor(a, b, method = "spearman"), 2)
message("rank correlation of the 36 distances, data (10 PCs) vs default UMAP: ",
        rho(distances$data_10_pcs, distances$umap_default),
        "; 10 PCs vs variable genes: ", rho(distances$data_10_pcs, distances$data_variable_genes),
        "; 10 PCs vs all genes: ", rho(distances$data_10_pcs, distances$data_all_genes))
