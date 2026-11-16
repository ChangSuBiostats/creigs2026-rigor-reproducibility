# fig02b: which tissues single-cell studies profile.
#
# Slide:  2, "Rapid Growth in Single Cell Studies"
# Shows:  share of tissue mentions for the 13 most common tissues, with all
#         remaining tissues pooled as "Other". A study that lists several
#         tissues counts once per tissue, so the denominator is tissue
#         mentions, not studies. Reconstruction of the existing panel
#         reference/slide02_2.png, which uses studies dated 2009 or later.
# Data:   data/processed/svensson_tissues.csv, built from the single-cell
#         studies database snapshot logged in data/SOURCES.md.
# Cite:   Svensson V, da Veiga Beltrame E, Pachter L (2020). A curated database
#         reveals trends in single-cell transcriptomics. Database, baaa073.
# Seed:   none (no randomness).
# Output: output/fig02b.png, output/fig02b.svg,
#         data/processed/fig02b_tissue_share.csv
# Run from the repository root: Rscript figures/fig02b_tissues.R

source(file.path("figures", "deck_style.R"))

start <- as.Date("2009-01-01")  # same cut as the existing panel
top_n <- 13
in_vitro <- "Culture"           # the database's label for in vitro samples

tissues <- read_csv(file.path(processed, "svensson_tissues.csv"), show_col_types = FALSE) |>
  filter(date >= start)

counts <- count(tissues, tissue, name = "mentions", sort = TRUE)
other_label <- paste0("Other (", nrow(counts) - top_n, " tissues)")
shares <- bind_rows(
  slice_head(counts, n = top_n),
  tibble(tissue = other_label, mentions = sum(counts$mentions[-seq_len(top_n)]))
) |>
  mutate(share_pct = 100 * mentions / nrow(tissues))
write_csv(shares, file.path(processed, "fig02b_tissue_share.csv"))

shares <- shares |>
  mutate(
    tissue = factor(tissue, levels = rev(tissue)),
    kind = case_when(tissue == other_label ~ "other", tissue == in_vitro ~ "in_vitro",
                     .default = "tissue"),
    label = paste0(sprintf("%.1f%%", share_pct), if_else(kind == "in_vitro", "  in vitro", ""))
  )

# Tissue names and value labels are 9 pt: 14 rows do not fit at 12 pt.
p <- ggplot(shares, aes(share_pct, tissue, fill = kind)) +
  geom_col(width = 0.72) +
  geom_text(aes(label = label, colour = kind), hjust = 0, nudge_x = 0.5,
            family = deck$font, size = 9 / .pt) +
  scale_fill_manual(values = c(tissue = deck$blue, in_vitro = deck$orange, other = deck$gray)) +
  scale_colour_manual(values = c(tissue = deck$text, in_vitro = deck$orange, other = deck$text)) +
  scale_x_continuous(breaks = c(0, 10, 20, 30), limits = c(0, 39), expand = c(0, 0)) +
  labs(x = "Share of tissue mentions (%)", y = NULL) +
  theme_deck() +
  theme(axis.text.y = element_text(size = 9), axis.ticks.y = element_blank())

save_fig(p, "fig02b")
