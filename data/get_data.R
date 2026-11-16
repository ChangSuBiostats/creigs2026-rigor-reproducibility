# Download raw data for the CREiGS 2026 lecture figures.
#
# Usage (from the repository root):
#   Rscript data/get_data.R            # download only what is missing
#   Rscript data/get_data.R --refresh  # re-download everything (new snapshot)
#
# Each download is written to data/raw/ and logged in data/SOURCES.md with its
# source URL, access date (UTC) and SHA-256 checksum. Files in data/raw/ are
# never edited by hand.
#
# All three sources are live, so a re-download can differ from the committed
# snapshot. Figures are built from the committed snapshot; use --refresh only
# when you intend to update the figures to a newer version.
# No randomness, so no seed.

raw_dir <- file.path("data", "raw")
sources_md <- file.path("data", "SOURCES.md")
refresh <- "--refresh" %in% commandArgs(trailingOnly = TRUE)

# nxn.se answers R's and Python's default download clients with HTTP 403 but
# serves curl, so every download goes through the system curl.
curl_get <- function(url, dest) {
  status <- system2("curl", c("--silent", "--show-error", "--fail", "--location",
                              "--max-time", "300", "--output", shQuote(dest), shQuote(url)))
  if (status != 0 || !file.exists(dest) || file.size(dest) == 0) {
    stop("download failed: ", url)
  }
}

log_source <- function(name, description, url) {
  path <- file.path(raw_dir, name)
  entry <- c(
    "",
    paste0("## ", name),
    paste0("- Description: ", description),
    paste0("- URL: ", url),
    paste0("- Accessed: ", format(Sys.time(), "%Y-%m-%d %H:%M UTC", tz = "UTC")),
    paste0("- SHA-256: ", unname(tools::sha256sum(path))),
    paste0("- Size: ", file.size(path), " bytes")
  )
  cat(entry, file = sources_md, sep = "\n", append = TRUE)
  message("downloaded ", name, " (", file.size(path), " bytes)")
}

needed <- function(name) {
  have <- file.exists(file.path(raw_dir, name))
  if (have && !refresh) message("have ", name, ", skipping (use --refresh to update)")
  !have || refresh
}

dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# --- 1. Single-cell studies database (Svensson et al. 2020) ------------------
if (needed("svensson_single_cell_studies.tsv")) {
  url <- "https://nxn.se/single-cell-studies/data.tsv"
  curl_get(url, file.path(raw_dir, "svensson_single_cell_studies.tsv"))
  log_source(
    "svensson_single_cell_studies.tsv",
    paste("Single-cell studies database (Svensson, da Veiga Beltrame & Pachter 2020,",
          "Database, doi:10.1093/database/baaa073). Live table; the URL redirects to a",
          "published Google Sheet."),
    url
  )
}

# --- 2. CELLxGENE Discover: public collections and datasets ------------------
cellxgene <- c(
  cellxgene_collections.json = "https://api.cellxgene.cziscience.com/curation/v1/collections",
  cellxgene_datasets.json = "https://api.cellxgene.cziscience.com/curation/v1/datasets"
)
for (name in names(cellxgene)) {
  if (needed(name)) {
    curl_get(cellxgene[[name]], file.path(raw_dir, name))
    log_source(
      name,
      paste("CZ CELLxGENE Discover curation API, all public",
            sub("cellxgene_(.*)\\.json", "\\1", name),
            "with their metadata (CZI Cell Science Program et al. 2025, Nucleic Acids",
            "Research, doi:10.1093/nar/gkae1142)."),
      cellxgene[[name]]
    )
  }
}

# --- 3. PubMed: single-cell RNA-seq publications per year --------------------
# One count per publication year from NCBI E-utilities. The count depends on
# the query, so it shows the trend, not an exact census of studies.
pubmed_term <- paste(
  '("single cell RNA"[tiab] OR "scRNA-seq"[tiab] OR "single cell transcriptomics"[tiab]',
  'OR "single cell transcriptomic"[tiab] OR "single cell transcriptome"[tiab]',
  'OR "single nucleus RNA"[tiab] OR "snRNA-seq"[tiab]) NOT review[pt]'
)
pubmed_years <- 2009:2025  # 2025 is the last complete year

if (needed("pubmed_counts.tsv")) {
  esearch <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
  tmp <- tempfile(fileext = ".json")
  counts <- vapply(pubmed_years, function(year) {
    term <- paste0("(", pubmed_term, ") AND ", year, "[dp]")
    url <- paste0(esearch, "?db=pubmed&rettype=count&retmode=json&tool=figure_script&term=",
                  utils::URLencode(term, reserved = TRUE))
    curl_get(url, tmp)
    result <- jsonlite::fromJSON(tmp)$esearchresult
    # PubMed silently rewrites a query it cannot match as written; stop if it did.
    if (!is.null(result$errorlist) || !is.null(result$warninglist)) {
      stop("PubMed reported a problem with the query for ", year)
    }
    Sys.sleep(0.4)  # stay under the 3 requests/second limit
    as.integer(result$count)
  }, integer(1))
  write.table(
    data.frame(year = pubmed_years, count = counts, term = pubmed_term),
    file.path(raw_dir, "pubmed_counts.tsv"),
    sep = "\t", quote = FALSE, row.names = FALSE
  )
  log_source(
    "pubmed_counts.tsv",
    paste0("Number of PubMed records per publication year (", min(pubmed_years), " to ",
           max(pubmed_years), ") for the query: ", pubmed_term,
           " -- each year adds `AND <year>[dp]`."),
    esearch
  )
}

# --- 4. scRNA-tools database (Zappia & Theis 2021) ---------------------------
scrna_tools <- c(
  scrna_tools.tsv = "https://raw.githubusercontent.com/scRNA-tools/scRNA-tools/main/database/tools.tsv",
  scrna_tools_categories.tsv = "https://raw.githubusercontent.com/scRNA-tools/scRNA-tools/main/database/categories-idx.tsv"
)
for (name in names(scrna_tools)) {
  if (needed(name)) {
    curl_get(scrna_tools[[name]], file.path(raw_dir, name))
    log_source(
      name,
      paste("scRNA-tools database, github.com/scRNA-tools/scRNA-tools, MIT licence (Zappia &",
            "Theis 2021, Genome Biology 22:301, doi:10.1186/s13059-021-02519-4). The site",
            "states the database has been in low-maintenance mode since May 2024."),
      scrna_tools[[name]]
    )
  }
}
