# fig07d_6: the outer burst: rarely detected genes added.
#
# Slide:  not in the final deck (backup for Example 3, differential
#         expression: the two bursts of Gibson's drawing).
# Shows:  fig07d_5 plus, in orange, the genes detected in 1 to 10% of cells.
#         They form the wide, low outer burst of Gibson's "double volcano":
#         larger fold changes, weaker significance. Identical axes to
#         fig07d_5, so the two can be superimposed on the slide.
# Data:   data/processed/kang_null_rare_genes.csv, built by data/make_null_de.R
#         from the control sample of Kang et al. (GEO GSE96583, logged in
#         data/SOURCES.md).
# Cite:   Kang HM, et al. (2018). Nature Biotechnology 36:89-94. The "double
#         volcano": Gibson G (2022). PLoS Genetics 18:e1010210, Fig. 1A.
# Seed:   none (no randomness).
# Output: output/fig07d_6.png, output/fig07d_6.svg
# Run from the repository root: Rscript figures/fig07d_6_double_volcano_all.R

source(file.path("figures", "deck_style.R"))
source(file.path("figures", "volcano_double.R"))

save_fig(double_volcano(show_rare = TRUE), "fig07d_6")
