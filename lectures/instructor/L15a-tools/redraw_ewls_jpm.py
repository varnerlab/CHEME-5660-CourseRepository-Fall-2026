"""Redraw figs/Fig-L15a-EWLS-JPM.tex from the output of updating_facts.jl.

Usage (from the repo root): python3 lectures/instructor/L15a-tools/redraw_ewls_jpm.py <folder with jpm_beta.csv> <tex file>
Then run `make` in lectures/week-15/L15a/figs. The layout stays: x = 12 (s - 1) / (n - 1) over the run days and
y = 6 (beta - 0.5), so the frame shows beta from 0.5 to 1.3. The two curve labels move to clear the curve by 0.15.
"""
import sys, re, csv, datetime as dt
folder, tex = sys.argv[1], sys.argv[2]
rows = list(csv.reader(open(f"{folder}/jpm_beta.csv")))
dates = [dt.date.fromisoformat(r[0]) for r in rows]
beta = [float(r[1]) for r in rows]
fixed = float(open(f"{folder}/jpm_fixed.txt").read())
n = len(beta)
def X(s): return 12.0 * s / (n - 1)
def Y(b): return 6.0 * (b - 0.5)
pts = [(X(s), Y(b)) for s, b in enumerate(beta)]
assert dates[0] == dt.date(2025, 1, 2), "the run starts on January 2, 2025"
assert min(beta) > 0.5 and max(beta) < 1.3 and 0.5 < fixed < 1.3, "the curve must stay inside the 0.5 to 1.3 frame"
s = open(tex).read()

# header: the run date, the number of days, and the two estimates -
s, c = re.subn(r"run [0-9-]+; [0-9]+ trading days from 2025-01-02 to [0-9-]+\.\n% Fixed estimate [0-9.]+; last updated estimate [0-9.]+\.",
               f"run {dt.date.today()}; {n} trading days from 2025-01-02 to {dates[-1]}.\n% Fixed estimate {fixed:.4f}; last updated estimate {beta[-1]:.4f}.", s)
assert c == 1, "header"

# ticks: the first trading day of each labeled month -
ticks = []
for (y, m, label) in [(2025, 1, "Jan 2025"), (2025, 7, "Jul 2025"), (2026, 1, "Jan 2026"), (2026, 7, "Jul 2026")]:
    k = next(i for i, d in enumerate(dates) if d.year == y and d.month == m)
    ticks.append(f"{X(k):.3f}/{label}")
s, c = re.subn(r"\\foreach \\xx/\\lab in \{[^}]*\}", lambda m: "\\foreach \\xx/\\lab in {" + ", ".join(ticks) + "}", s)
assert c == 1, "ticks"

# the fixed line, the curve, and its two end points -
yf = Y(fixed)
s, c = re.subn(r"\\draw\[drop, line width=1\.3pt\] \(0, [0-9.]+\) -- \(12\.0, [0-9.]+\);",
               lambda m: f"\\draw[drop, line width=1.3pt] (0, {yf:.3f}) -- (12.0, {yf:.3f});", s)
assert c == 1, "fixed line"
coords = " ".join(f"({x:.3f},{y:.3f})" for x, y in pts)
s, c = re.subn(r"plot coordinates \{[^}]*\};", lambda m: "plot coordinates {" + coords + "};", s)
assert c == 1, "curve"
s, c = re.subn(r"\\node\[pt\] at \(0, [0-9.]+\) \{\};\n  \\node\[pt\] at \(12\.0, [0-9.]+\) \{\};",
               lambda m: f"\\node[pt] at (0, {pts[0][1]:.3f}) {{}};\n  \\node[pt] at (12.0, {pts[-1][1]:.3f}) {{}};", s)
assert c == 1, "end points"

# labels: the fixed-line label sits just above its line, and the curve labels clear the curve -
s, c = re.subn(r"(\\node\[note, anchor=south west, align=left\] at \(3\.9, )[0-9.]+\)", lambda m: m.group(1) + f"{yf + 0.08:.3f})", s)
assert c == 1, "fixed label"
low_left = min(y for x, y in pts if 0.3 <= x <= 4.3)
s, c = re.subn(r"(anchor=north west, align=left\] at \(0\.35, )[0-9.]+\)", lambda m: m.group(1) + f"{min(2.73, low_left - 0.15):.3f})", s)
assert c == 1, "left label"
high_right = max(y for x, y in pts if x >= 9.2)
s, c = re.subn(r"(anchor=south east, align=right\] at \(11\.95, )[0-9.]+\)", lambda m: m.group(1) + f"{max(1.74, high_right + 0.15):.3f})", s)
assert c == 1, "right label"
open(tex, "w").write(s)
print(f"wrote {tex}: {n} days to {dates[-1]}, fixed {fixed:.4f}, last {beta[-1]:.4f}")
