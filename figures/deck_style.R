# Shared figure style for the CREiGS 2026 deck (see README, "Figure style").
# Sourced by every figNN script so that all figures match the slides.

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(readr)
})

deck <- list(
  blue = "#4472C4",    # highlight: the series that carries the message
  orange = "#ED7D31",  # secondary
  gray = "#A5A5A5",    # neutral / context
  text = "#000000",
  text2 = "#44546A",   # secondary text
  grid = "#E7E6E6",
  font = "Georgia",
  half = c(3.9, 2.85), # half-slide panel, inches
  full = c(10.2, 4.8), # full content area, inches
  label_size = 10 / .pt  # 10 pt direct labels
)

processed <- file.path("data", "processed")

# Slide 5 (fig05a, fig05b): last month of regular curation of the scRNA-tools
# database. Both figures use only tools added by this date; see NOTES.md.
scrna_tools_cutoff <- as.Date("2024-05-31")

# grid = TRUE adds light horizontal gridlines (line and scatter charts only).
theme_deck <- function(grid = FALSE) {
  theme_classic(base_size = 12, base_family = deck$font) +
    theme(
      text = element_text(colour = deck$text),
      axis.title = element_text(size = 14),
      axis.text = element_text(size = 12, colour = deck$text),
      axis.line = element_line(colour = deck$text, linewidth = 0.4),
      axis.ticks = element_line(colour = deck$text, linewidth = 0.4),
      panel.grid.major.y = if (grid) element_line(colour = deck$grid, linewidth = 0.4) else element_blank(),
      legend.position = "none",
      plot.background = element_rect(fill = "white", colour = NA),
      panel.background = element_rect(fill = "white", colour = NA),
      plot.margin = margin(4, 8, 4, 4)
    )
}

# Write output/<name>.png (300 dpi) and output/<name>.svg at the exact size.
# Each file is drawn in the session's temporary folder and then copied into
# output/, and the copy is checked. The repository sits in a cloud-synced
# folder, where drawing directly into output/ occasionally left an empty file.
save_fig <- function(plot, name, size = deck$half) {
  dir.create("output", showWarnings = FALSE)
  put <- function(ext, ...) {
    tmp <- tempfile(fileext = ext)
    ggsave(tmp, plot, width = size[1], height = size[2], bg = "white", ...)
    dest <- file.path("output", paste0(name, ext))
    for (attempt in 1:3) {
      ok <- file.copy(tmp, dest, overwrite = TRUE) && identical(file.size(dest), file.size(tmp)) &&
        identical(unname(tools::md5sum(dest)), unname(tools::md5sum(tmp)))
      if (ok) break
      Sys.sleep(1)
    }
    if (!ok) stop("could not write ", dest)
  }
  put(".png", dpi = 300, device = ragg::agg_png)
  put(".svg", device = svglite::svglite)
  message("wrote output/", name, ".png and output/", name, ".svg")
}

# 1000 -> "1k", 1e6 -> "1M"
label_si <- function(x) {
  ifelse(x >= 1e6, paste0(x / 1e6, "M"), ifelse(x >= 1e3, paste0(x / 1e3, "k"), as.character(x)))
}

mid_year <- function(year) as.Date(paste0(year, "-07-01"))
