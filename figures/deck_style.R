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
save_fig <- function(plot, name, size = deck$half) {
  dir.create("output", showWarnings = FALSE)
  ggsave(file.path("output", paste0(name, ".png")), plot, width = size[1], height = size[2],
         dpi = 300, device = ragg::agg_png, bg = "white")
  ggsave(file.path("output", paste0(name, ".svg")), plot, width = size[1], height = size[2],
         device = svglite::svglite, bg = "white")
  message("wrote output/", name, ".png and output/", name, ".svg")
}

# 1000 -> "1k", 1e6 -> "1M"
label_si <- function(x) {
  ifelse(x >= 1e6, paste0(x / 1e6, "M"), ifelse(x >= 1e3, paste0(x / 1e3, "k"), as.character(x)))
}

mid_year <- function(year) as.Date(paste0(year, "-07-01"))
