#!/usr/bin/env python3
"""Write the made-up paths of Fig-L15a-Stress-Test.tex into Fig-L15a-Stress-Test-paths.tex.

The figure is a schematic, so the paths are made up: a fixed-seed draw, not the stress test.
- the synthetic markets: 200 paths of 63 steps from W0 (one step per 4 trading days),
  with growth rate 0.15/yr and volatility 0.18/yr, so that about one market in five ends below W0
- the fan draws 30 of the paths, at evenly spaced ranks of their last value, so it spans the same range as
  the sideways histogram, which counts the last value of all 200
- a path that ends below W0 is drawn in the failure style (fanfail), the others in fanok, to match the bars

Coordinates (cm): the start day is at x = 1.7, the synthetic year runs to x = 13, and W0 is at
y = 2.2, with 5 cm per unit of W/W0.

Run from this folder: python3 stress_paths.py
"""

import math
import random

random.seed(5660)

X_START = 1.7          # the start day (cm)
X_END = 13.0           # the last synthetic day (cm)
Y_W0 = 2.2             # the starting wealth W0 (cm)
Y_SCALE = 5.0          # cm per unit of W/W0
N_PATHS = 200          # synthetic markets
N_DRAWN = 30           # paths drawn in the fan
N_STEPS = 63           # steps of a synthetic year (one step per 4 trading days)
MU, SIGMA = 0.15, 0.18  # growth rate (1/yr) and volatility (1/sqrt(yr)) of the made-up wealth
DT = 1.0 / N_STEPS     # one step (yr)

# the synthetic markets: W/W0 at each step -
paths = []
for p in range(N_PATHS):
    w = [1.0]
    for k in range(N_STEPS):
        w.append(w[-1] * math.exp((MU - 0.5 * SIGMA ** 2) * DT + SIGMA * math.sqrt(DT) * random.gauss(0.0, 1.0)))
    paths.append(w)

# the sideways histogram of the last value: bins of width 0.1 in W/W0, one edge at W0 -
last = sorted(w[-1] for w in paths)
median = 0.5 * (last[N_PATHS // 2 - 1] + last[N_PATHS // 2])
width = 0.1
low = math.floor(min(last) / width) * width
high = math.ceil(max(last) / width) * width
n_bins = round((high - low) / width)
counts = [0] * n_bins
for v in last:
    i = min(int((v - low) / width), n_bins - 1)
    counts[i] += 1
failures = sum(1 for v in last if v < 1.0)


def y_of(w):
    return Y_W0 + Y_SCALE * (w - 1.0)


lines = ["% Written by stress_paths.py: the made-up paths of Fig-L15a-Stress-Test.tex. Do not edit by hand."]
lines.append(f"% {failures} of {N_PATHS} made-up markets end below W0, and the median last value is {median:.3f} W0.")

# the fan: N_DRAWN paths at evenly spaced ranks of the last value -
ranked = sorted(paths, key=lambda w: w[-1])
drawn = [ranked[round(j * (N_PATHS - 1) / (N_DRAWN - 1))] for j in range(N_DRAWN)]
# paths that end below W0 use the failure style, drawn last so they sit on top -
lines.append("\\newcommand{\\fanpaths}{%")
for w in reversed(drawn):
    style = "fanfail" if w[-1] < 1.0 else "fanok"
    coords = []
    for k, v in enumerate(w):
        x = X_START + (X_END - X_START) * k / N_STEPS
        coords.append(f"({x:.3f},{y_of(v):.3f})")
    lines.append(f"  \\draw[{style}] " + " -- ".join(coords) + ";%")
lines.append("}")

# the histogram bars: lower edge, upper edge, count -
bars = []
for i, c in enumerate(counts):
    if c > 0:
        a = low + i * width
        bars.append(f"{y_of(a):.3f}/{y_of(a + width):.3f}/{c}/{1 if a + width <= 1.0 + 1e-9 else 0}")
lines.append("\\newcommand{\\histbars}{" + ", ".join(bars) + "}")
lines.append(f"\\newcommand{{\\ymedian}}{{{y_of(median):.3f}}}")
lines.append(f"\\newcommand{{\\ylow}}{{{y_of(low):.3f}}}")
lines.append(f"\\newcommand{{\\yhigh}}{{{y_of(high):.3f}}}")

with open("Fig-L15a-Stress-Test-paths.tex", "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"fan y from {min(y_of(v) for w in drawn for v in w):.3f} to {max(y_of(v) for w in drawn for v in w):.3f}")
print(f"wrote Fig-L15a-Stress-Test-paths.tex: {failures} of {N_PATHS} below W0, median {median:.3f}, "
      f"range {min(last):.3f} to {max(last):.3f}, {n_bins} bins, largest count {max(counts)}")
