# Check the existing slide 2 panel (cells per study) against the database.
#
# The existing panel is an image, so its yearly medians cannot be read
# directly. This script finds the red median markers in reference/slide02_a.png
# (the full-resolution image embedded in the deck) and tests whether their
# pixel positions are an exact linear map of the medians computed from the
# database (log10 cells vs. pixel row, mid-year vs. pixel column). There are 18
# points and 2 free parameters per axis, so a near-zero residual means the
# medians are the same.
#
# Run from the repository root, after figures/fig02a_cells_per_study.R:
#   Rscript reference/check_slide02_a.R
# No randomness, so no seed.

red <- c(196, 78, 82) / 255  # median line colour in the existing panel
radius <- 8                  # erosion radius (px): removes the line, keeps the markers
legend_box <- c(x = 900, y = 880)  # ignore the legend marker (right of x, below y)

img <- png::readPNG(file.path("reference", "slide02_a.png"))[, , 1:3]
is_red <- abs(img[, , 1] - red[1]) + abs(img[, , 2] - red[2]) + abs(img[, , 3] - red[3]) < 0.25
is_red[row(is_red) > legend_box["y"] & col(is_red) > legend_box["x"]] <- FALSE

# Erode with a disc: a pixel survives only if every pixel within `radius` is red.
shift <- function(m, dy, dx) {
  out <- matrix(FALSE, nrow(m), ncol(m))
  rows <- max(1, 1 + dy):min(nrow(m), nrow(m) + dy)
  cols <- max(1, 1 + dx):min(ncol(m), ncol(m) + dx)
  out[rows, cols] <- m[rows - dy, cols - dx]
  out
}
core <- is_red
for (dy in -radius:radius) for (dx in -radius:radius) {
  if (dx^2 + dy^2 <= radius^2) core <- core & shift(is_red, dy, dx)
}

# Group the surviving pixels into markers by gaps along x.
px <- which(core, arr.ind = TRUE)
px <- px[order(px[, "col"]), ]
marker <- cumsum(c(1, diff(px[, "col"]) > 5))
markers <- data.frame(px_x = tapply(px[, "col"], marker, mean),
                      px_y = tapply(px[, "row"], marker, mean))

yearly <- read.csv(file.path("data", "processed", "fig02a_yearly_median.csv"))
cat("markers found in existing panel:", nrow(markers), "; years in reconstruction:", nrow(yearly), "\n")
stopifnot(nrow(markers) == nrow(yearly))

out <- cbind(yearly, markers)
fit_y <- lm(px_y ~ log10(median_cells), out)
fit_x <- lm(px_x ~ year, out)
out$resid_px_y <- round(resid(fit_y), 2)
out$resid_px_x <- round(resid(fit_x), 2)
cat(sprintf("y (log10 median cells): %.1f px per unit, max |residual| %.2f px\n",
            abs(coef(fit_y)[2]), max(abs(resid(fit_y)))))
cat(sprintf("x (year): %.1f px per unit, max |residual| %.2f px (image is %d x %d px)\n",
            abs(coef(fit_x)[2]), max(abs(resid(fit_x))), ncol(img), nrow(img)))
print(out, row.names = FALSE)
# Fail the build if the existing panel and the database disagree by more than a pixel.
stopifnot(max(abs(resid(fit_y))) < 1, max(abs(resid(fit_x))) < 1)
