#!/usr/bin/env python3
"""Draw matched Wolfram-market snapshots exported by the Julia data script.

Run this file after Fig-L13a-Wolfram-Markets-Data.jl. The open-market row uses
the L12b Viewport logic, delaying refresh and R0 entry until after step 1500.
"""
import json
import os
from pathlib import Path

os.environ.setdefault("MPLCONFIGDIR", "/private/tmp/cheme5660-wolfram-mpl")
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, BoundaryNorm
from matplotlib.font_manager import fontManager
from matplotlib.patches import Patch
import numpy as np

ROOT = Path(__file__).resolve().parent
STEM = ROOT / "Fig-L13a-Wolfram-Markets"
INK = "#202124"
GRAY = "#6d7278"
COLORS = ["#0072b2", "#aaaaaa", "#d55e00"]

# Match the Arial text used in the surrounding lecture figures.
for font in ("Arial.ttf", "Arial Bold.ttf"):
    path = Path("/System/Library/Fonts/Supplemental") / font
    if path.exists():
        fontManager.addfont(path)
plt.rcParams.update({"font.family": "Arial", "font.size": 12,
                     "text.color": INK, "pdf.fonttype": 42,
                     "svg.fonttype": "path", "savefig.pad_inches": 0.03})

data = json.loads((ROOT / "Fig-L13a-Wolfram-Markets-Data.json").read_text())
steps = data["steps"]
cmap = ListedColormap(COLORS)
norm = BoundaryNorm([-0.5, 0.5, 1.5, 2.5], 3)
fig = plt.figure(figsize=(14.3, 7.9), facecolor="white")

# Fixed square panels keep every grid the same size and all time columns aligned.
left, right = 0.171, 0.988
gap = 0.012
width = (right - left - 5 * gap) / 6
height = width * 14.3 / 7.9
row_tops = [0.885, 0.607, 0.329]
labels = [("R19280 alone", "No rule switch"),
          ("Closed market", "R19280 → R19286"),
          ("Open market", "R0 entry after 1,500")]

for col, step in enumerate(steps):
    x = left + col * (width + gap) + width / 2
    fig.text(x, 0.940, f"t = {step:,}", ha="center", va="center",
             fontsize=14, weight="bold")

for row_index, (row, top, (title, subtitle)) in enumerate(zip(data["rows"], row_tops, labels)):
    center = top - height / 2
    fig.text(0.017, center + 0.014, title, ha="left", va="center",
             fontsize=14, weight="bold")
    fig.text(0.017, center - 0.020, subtitle, ha="left", va="center",
             fontsize=11.5, color=GRAY)
    for col, panel in enumerate(row["panels"]):
        x = left + col * (width + gap)
        ax = fig.add_axes([x, top - height, width, height])
        grid = np.asarray(panel["grid"], dtype=int)
        assert grid.shape == (62, 62) and np.isin(grid, [0, 1, 2]).all()
        ax.imshow(grid, cmap=cmap, norm=norm, interpolation="nearest", origin="upper")
        ax.set_xticks([])
        ax.set_yticks([])
        for spine in ax.spines.values():
            spine.set_linewidth(0.55)
            spine.set_color(GRAY)
        fig.text(x + width / 2, top - height - 0.020,
                 f"{100*panel['sell_fraction']:.0f}% Sell  |  S = {panel['price']:.1f}",
                 ha="center", va="center", fontsize=10.5)

legend = [Patch(facecolor=color, edgecolor="none", label=label)
          for color, label in zip(COLORS, ["Buy", "Hold", "Sell"])]
fig.legend(handles=legend, loc="lower left", bbox_to_anchor=(0.008, 0.018),
           frameon=False, ncol=3, fontsize=12, handlelength=1,
           handletextpad=0.4, columnspacing=1.1)
fig.text(0.365, 0.042, "25% switch after t = 1,000.  Refresh begins after t = 1,500.",
         fontsize=11.5, ha="left", va="center")
fig.text(0.365, 0.016, "Refresh: 0.1% per step; 25% of new players follow R0.  S: USD/share.",
         fontsize=11.5, color=GRAY, ha="left", va="center")

fig.savefig(STEM.with_suffix(".pdf"))
fig.savefig(STEM.with_suffix(".png"), dpi=180)
fig.savefig(STEM.with_suffix(".svg"), transparent=True)

# Keep the categorical intentions fixed; adapt only text and panel outlines to dark screens.
svg_path = STEM.with_suffix(".svg")
svg = svg_path.read_text()
svg = svg.replace("fill: #202124", "fill: var(--wolfram-ink, #202124)")
svg = svg.replace("fill: #6d7278", "fill: var(--wolfram-gray, #6d7278)")
svg = svg.replace("stroke: #6d7278", "stroke: var(--wolfram-gray, #6d7278)")
style = '''<style id="course-theme">
  @media screen and (prefers-color-scheme: dark) {
    svg { --wolfram-ink: #e3e6ea; --wolfram-gray: #aeb4ba; }
  }
</style>'''
end = svg.index(">", svg.index("<svg")) + 1
themed_svg = svg[:end] + "\n" + style + svg[end:]
svg_path.write_text("\n".join(line.rstrip() for line in themed_svg.splitlines()) + "\n")
print(f"Wrote {STEM.name}.pdf, .png, and themed .svg")
