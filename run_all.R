# Rebuild every figure from the committed raw data snapshot.
#
# Usage (from the repository root): Rscript run_all.R
#
# Steps: fetch any missing raw data, build derived tables (including the null
# differential expression tests for fig07d and the PBMC 3k layouts for
# Example 1), run each figure
# script, then run the check against the existing deck image. Each step runs
# in a fresh R session so that scripts cannot depend on each other's state.

steps <- c(
  file.path("data", "get_data.R"),
  file.path("data", "make_processed.R"),
  file.path("data", "make_null_de.R"),
  file.path("data", "make_pbmc3k.R"),
  sort(list.files("figures", pattern = "^fig[0-9]{2}.*\\.R$", full.names = TRUE)),
  file.path("reference", "check_slide02_a.R")
)

rscript <- file.path(R.home("bin"), "Rscript")
for (step in steps) {
  message("== ", step)
  if (system2(rscript, shQuote(step)) != 0) stop("failed: ", step)
}
message("all figures rebuilt")
