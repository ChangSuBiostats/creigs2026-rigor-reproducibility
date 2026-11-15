"""Check the existing slide 2 panel (cells per study) against the database.

The existing panel is an image, so its yearly medians cannot be read directly.
Instead this script finds the red median markers in reference/slide02_a.png
(the full-resolution image embedded in the deck) and tests whether their pixel
positions are an exact linear map of the medians computed from the database
(log10 cells vs. pixel row, mid-year vs. pixel column). 18 points and 2 free
parameters per axis, so a near-zero residual means the same medians.

Run after data/make_processed.py and figures/fig02a_cells_per_study.py.
No randomness, so no seed.
"""

from pathlib import Path

import matplotlib.image as mpimg
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RED = np.array([196, 78, 82]) / 255   # median line colour in the existing panel
RADIUS = 8                            # erosion radius (px): removes the line, keeps markers
LEGEND_BOX = (900, 880)               # ignore the legend marker (x > 900 and y > 880)

img = mpimg.imread(ROOT / "reference" / "slide02_a.png")[..., :3]
red = np.abs(img - RED).sum(axis=2) < 0.25
ys, xs = np.indices(red.shape)
red &= ~((xs > LEGEND_BOX[0]) & (ys > LEGEND_BOX[1]))

core = red.copy()
for dy in range(-RADIUS, RADIUS + 1):
    for dx in range(-RADIUS, RADIUS + 1):
        if dx * dx + dy * dy <= RADIUS * RADIUS:
            core &= np.roll(np.roll(red, dy, axis=0), dx, axis=1)

cols = np.flatnonzero(core.any(axis=0))
groups = np.split(cols, np.flatnonzero(np.diff(cols) > 5) + 1)
markers = []
for g in groups:
    sub = core[:, g[0]:g[-1] + 1]
    yy, xx = np.nonzero(sub)
    markers.append((xx.mean() + g[0], yy.mean()))
markers = pd.DataFrame(markers, columns=["px_x", "px_y"]).sort_values("px_x").reset_index(drop=True)

yearly = pd.read_csv(ROOT / "data" / "processed" / "fig02a_yearly_median.csv")
print(f"markers found in existing panel: {len(markers)}; years in reconstruction: {len(yearly)}")
assert len(markers) == len(yearly), "marker count differs from number of years"

out = yearly.join(markers)
for label, value, px in (("y (log10 median cells)", np.log10(out["median_cells"]), out["px_y"]),
                         ("x (mid-year)", out["year"] + 0.5, out["px_x"])):
    slope, intercept = np.polyfit(value, px, 1)
    resid = px - (slope * value + intercept)
    out[f"resid_px_{label[0]}"] = resid.round(2)
    print(f"{label}: {abs(slope):.1f} px per unit, max |residual| {resid.abs().max():.2f} px "
          f"(image is {img.shape[1]} x {img.shape[0]} px)")
print(out.to_string(index=False))
