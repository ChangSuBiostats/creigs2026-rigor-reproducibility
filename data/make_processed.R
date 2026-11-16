# Build derived tables in data/processed/ from the raw snapshots.
#
# Usage (from the repository root): Rscript data/make_processed.R
#
# Input:  data/raw/svensson_single_cell_studies.tsv
#         data/raw/cellxgene_collections.json, data/raw/cellxgene_datasets.json
#         data/raw/pubmed_counts.tsv
# Output: data/processed/svensson_studies.csv      one row per study
#         data/processed/svensson_tissues.csv      one row per (study, tissue) mention
#         data/processed/cellxgene_collections.csv one row per collection (about one paper)
#         data/processed/pubmed_counts.csv         one row per publication year
#
# Nothing is imputed: fields missing in the source stay missing.
# No randomness, so no seed.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(purrr)
  library(lubridate)
  library(jsonlite)
})

raw <- file.path("data", "raw")
processed <- file.path("data", "processed")
dir.create(processed, showWarnings = FALSE)

# '1,234' -> 1234; stop on anything that is not a number.
to_number <- function(x) {
  cleaned <- str_trim(str_remove_all(x, ","))
  value <- suppressWarnings(as.numeric(cleaned))
  stopifnot(all(is.na(value) == is.na(cleaned)))
  value
}

# --- Svensson single-cell studies database ----------------------------------
svensson_raw <- read_tsv(file.path(raw, "svensson_single_cell_studies.tsv"),
                         col_types = cols(.default = col_character()))
stopifnot(!anyDuplicated(svensson_raw$DOI))

studies <- svensson_raw |>
  transmute(
    doi = DOI,
    shorthand = Shorthand,
    title = Title,
    journal = Journal,
    date = ymd(Date),
    year = year(date),
    cells = to_number(`Reported cells total`),
    n_individuals = to_number(`Number individuals`),
    organism = Organism,
    tissue = Tissue,
    technique = Technique,
    measurement = Measurement
  ) |>
  arrange(date, doi)
stopifnot(!anyNA(studies$date))

# A study can list several tissues separated by commas; one row per mention.
tissues <- studies |>
  filter(!is.na(tissue)) |>
  select(doi, date, year, tissue) |>
  separate_longer_delim(tissue, delim = ",") |>
  mutate(tissue = str_trim(tissue)) |>
  filter(tissue != "")

write_csv(studies, file.path(processed, "svensson_studies.csv"))
write_csv(tissues, file.path(processed, "svensson_tissues.csv"))
message("svensson_studies.csv: ", nrow(studies), " studies, ", min(studies$date), " to ",
        max(studies$date), "; ", sum(!is.na(studies$cells)), " with cell counts")
message("svensson_tissues.csv: ", nrow(tissues), " tissue mentions, ",
        n_distinct(tissues$tissue), " distinct")

# --- CELLxGENE Discover ------------------------------------------------------
# Unit of analysis: the collection, which corresponds to one publication. A
# collection holds one or more datasets, and the same donors often appear in
# several of them, so donors, diseases and assays are pooled per collection.
collections_raw <- fromJSON(file.path(raw, "cellxgene_collections.json"), simplifyVector = FALSE)
datasets_raw <- fromJSON(file.path(raw, "cellxgene_datasets.json"), simplifyVector = FALSE)

labels <- function(items) map_chr(items, "label")
not_a_donor <- c("pooled", "unknown", "none", "na", "nan", "")  # placeholders, not individuals

per_dataset <- tibble(
  collection_id = map_chr(datasets_raw, "collection_id"),
  organism = map(datasets_raw, \(d) labels(d$organism)),
  donor = map(datasets_raw, \(d) unlist(d$donor_id)),
  disease = map(datasets_raw, \(d) labels(d$disease)),
  assay = map(datasets_raw, \(d) labels(d$assay))
)

pooled <- per_dataset |>
  group_by(collection_id) |>
  summarise(
    n_datasets = n(),
    organisms = list(sort(unique(unlist(organism)))),
    donors = list(setdiff(unique(unlist(donor)), NA)),
    diseases = list(sort(unique(unlist(disease)))),
    assays = list(sort(unique(unlist(assay)))),
    .groups = "drop"
  ) |>
  mutate(
    human = map_lgl(organisms, \(x) "Homo sapiens" %in% x),
    n_donors = map_int(donors, \(x) sum(!str_to_lower(x) %in% not_a_donor)),
    n_assays = lengths(assays),
    n_diseases = map_int(diseases, \(x) sum(x != "normal")),
    # Both affected and unaffected ("normal") donors in the same collection.
    disease_and_normal = map_lgl(diseases, \(x) "normal" %in% x && length(x) > 1),
    organisms = map_chr(organisms, str_flatten, collapse = "; "),
    assays = map_chr(assays, str_flatten, collapse = "; "),
    diseases = map_chr(diseases, str_flatten, collapse = "; ")
  ) |>
  select(-donors)

publication <- tibble(
  collection_id = map_chr(collections_raw, "collection_id"),
  name = map_chr(collections_raw, "name"),
  doi = map_chr(collections_raw, \(c) c$doi %||% NA_character_),
  journal = map_chr(collections_raw, \(c) c$publisher_metadata$journal %||% NA_character_),
  is_preprint = map_lgl(collections_raw, \(c) c$publisher_metadata$is_preprint %||% NA),
  # Publication date of the paper (from the publisher), not the date the data
  # were added to CELLxGENE.
  pub_date = make_date(
    map_int(collections_raw, \(c) c$publisher_metadata$published_year %||% NA_integer_),
    map_int(collections_raw, \(c) c$publisher_metadata$published_month %||% NA_integer_),
    map_int(collections_raw, \(c) c$publisher_metadata$published_day %||% NA_integer_)
  )
)

collections <- publication |>
  inner_join(pooled, by = "collection_id") |>
  mutate(year = year(pub_date), .after = pub_date) |>
  arrange(pub_date, collection_id)
stopifnot(nrow(collections) == length(collections_raw))

write_csv(collections, file.path(processed, "cellxgene_collections.csv"))
message("cellxgene_collections.csv: ", nrow(collections), " collections (",
        sum(collections$human), " with human data, ", sum(is.na(collections$pub_date)),
        " without a publication date) from ", length(datasets_raw), " datasets")

# --- PubMed counts -----------------------------------------------------------
pubmed <- read_tsv(file.path(raw, "pubmed_counts.tsv"), col_types = "iic") |>
  select(year, count)
write_csv(pubmed, file.path(processed, "pubmed_counts.csv"))
message("pubmed_counts.csv: ", min(pubmed$year), " to ", max(pubmed$year))
