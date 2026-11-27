"""Write the TikZ source of the strategy-deck figures (one .tex file per figure).

Run from this folder (make does it). Every figure \\inputs the L15a schematic style, ../../../figs/schematic-style.tex.
Each figure is drawn at about the size it has on a slide (at most 13.5 cm by 4.5 cm), so its labels keep their size.
The markets, tickers, and portfolios are made up. The weights of the three-ticker examples are computed here the
same way as the weigh_* functions in strategies/weighting, so the figures match the numbers in the decks.
Edit this script, not the .tex files it writes.
"""
import math
import random

HEAD = r"""%% Written by make_deck_figures.py: edit the script, not this file.
%% %s
\documentclass[tikz,border=2pt]{standalone}
\input{../../../figs/schematic-style.tex}

\begin{document}
\begin{tikzpicture}
"""
TAIL = r"""\end{tikzpicture}
\end{document}
"""


def write(name, comment, body):
    """Write one figure's .tex file, and leave the file alone when its text is unchanged (so make skips it)."""
    path = f"Fig-L15a-Deck-{name}.tex"
    text = HEAD % comment + body + TAIL
    try:
        with open(path) as f:
            if f.read() == text:
                return
    except FileNotFoundError:
        pass
    with open(path, "w") as f:
        f.write(text)


def fmt(x):
    return f"{x:.4f}".rstrip("0").rstrip(".")


def num(v, digits=2):
    """A bar label: 0 for a zero weight, and a math minus sign for a negative one."""
    if v == 0:
        return "0"
    return f"{v:.{digits}f}".replace("-", "$-$")


# ================================================================== a made-up market: 12 sectors of 7 tickers
SECTORS = ["Tech", "Financials", "Health", "Industrials", "Discretionary", "Staples", "Energy", "Utilities",
           "Real estate", "Materials", "Comm.", "ETF"]
CENTER = [0.42, 0.05, -0.05, 0.12, 0.0, -0.15, 0.30, -0.25, -0.2, -0.05, 0.15, 0.0]
PER_SECTOR = 7
rng = random.Random(5660)
gamma = []  # gamma[s] = the sorted preference weights of sector s, highest first
for s in range(len(SECTORS)):
    while True:
        values = sorted((max(-0.9, min(0.92, rng.gauss(CENTER[s], 0.22))) for _ in range(PER_SECTOR)), reverse=True)
        gaps = [values[k] - values[k + 1] for k in range(PER_SECTOR - 1)]
        if min(gaps) >= 0.085:  # the dots of one column do not overlap
            break
    gamma.append(values)

flat = sorted(((gamma[s][k], s, k) for s in range(len(SECTORS)) for k in range(PER_SECTOR)), reverse=True)
top13 = set((s, k) for (_, s, k) in flat[:13])
cutoff = 0.5 * (flat[12][0] + flat[13][0])
by_sector_top = set((s, k) for s in range(len(SECTORS)) for k in range(3))
by_sector_random = set()
for s in range(len(SECTORS)):
    for k in rng.sample(range(PER_SECTOR), 3):
        by_sector_random.add((s, k))
cells = [(s, k) for s in range(len(SECTORS)) for k in range(PER_SECTOR)]
global_random = set(rng.sample(cells, 13))
crowd = {}
for (s, k) in top13:
    crowd[SECTORS[s]] = crowd.get(SECTORS[s], 0) + 1
EMPTY_SECTORS = [SECTORS[s] for s in range(len(SECTORS)) if not any((s, k) in top13 for k in range(PER_SECTOR))]
NEGATIVE_PICKS = [(SECTORS[s], round(gamma[s][k], 3)) for (s, k) in sorted(by_sector_top) if gamma[s][k] < 0]
assert crowd["Tech"] == 4 and len(EMPTY_SECTORS) == 4 and len(NEGATIVE_PICKS) == 4  # the facts the decks quote

DX = 0.43  # cm between sector columns
GY = 1.15  # cm per unit of gamma
PANEL = DX * (len(SECTORS) + 0.4)  # cm, the width of one panel


def grid_panel(x0, title, picked, cutoff_line, y_label, values=None, cut=None, GY=GY):
    """One dot panel: the preference weights `values` of each sector (default: the made-up market), and the cutoff
    `cut` of the top 13 (default: its cutoff), at `GY` cm per unit of preference weight."""
    if values is None:
        values = gamma
    if cut is None:
        cut = cutoff
    out = [r"  \begin{scope}[shift={(%s, 0)}]" % fmt(x0)]
    out.append(r"    \node[font=\sffamily\small\bfseries, anchor=south] at (%s, %s) {%s};" % (fmt(PANEL / 2), fmt(0.97 * GY), title))
    out.append(r"    \draw[axis] (0, %s) -- (0, %s);" % (fmt(-0.95 * GY), fmt(0.98 * GY)))
    out.append(r"    \draw[drop] (0, 0) -- (%s, 0);" % fmt(PANEL))
    for v in (-0.5, 0.0, 0.5):
        out.append(r"    \draw[spine] (0, %s) -- (-0.07, %s);" % (fmt(v * GY), fmt(v * GY)))
        out.append(r"    \node[anchor=east, font=\sffamily\footnotesize] at (-0.08, %s) {%s};" % (fmt(v * GY), num(v, 1)))
    if y_label:
        out.append(r"    \node[font=\sffamily\small, rotate=90, anchor=south] at (-0.62, 0) {preference weight};")
    if cutoff_line:
        out.append(r"    \draw[draw=saorange, line width=1.0pt, dash pattern=on 4pt off 2pt] (0, %s) -- (%s, %s);"
                   % (fmt(cut * GY), fmt(PANEL), fmt(cut * GY)))
    for s in range(len(SECTORS)):
        x = DX * (s + 0.7)
        out.append(r"    \node[font=\sffamily\footnotesize, rotate=45, anchor=east] at (%s, %s) {%s};" % (fmt(x + 0.06), fmt(-0.95 * GY - 0.04), SECTORS[s]))
        for k in range(PER_SECTOR):
            y = values[s][k] * GY
            if (s, k) in picked:
                out.append(r"    \filldraw[fill=saorange, draw=vnink, line width=0.5pt] (%s, %s) circle (0.054);" % (fmt(x), fmt(y)))
            else:
                out.append(r"    \filldraw[fill=white, draw=gdgray, line width=0.5pt] (%s, %s) circle (0.047);" % (fmt(x), fmt(y)))
    out.append(r"  \end{scope}")
    return "\n".join(out) + "\n"


def dot_legend(cutoff_entry, GY=GY):
    """One row above both panels: the two kinds of dots, and the cutoff line of global gamma."""
    x, y = SHIFT - 3.2 - (1.6 if cutoff_entry else 0.0), 0.97 * GY + 0.78
    out = [r"  \filldraw[fill=saorange, draw=vnink, line width=0.5pt] (%s, %s) circle (0.054);" % (fmt(x), fmt(y)),
           r"  \node[anchor=west, font=\sffamily\footnotesize] at (%s, %s) {in the basket};" % (fmt(x + 0.1), fmt(y)),
           r"  \filldraw[fill=white, draw=gdgray, line width=0.5pt] (%s, %s) circle (0.047);" % (fmt(x + 2.6), fmt(y)),
           r"  \node[anchor=west, font=\sffamily\footnotesize] at (%s, %s) {not picked};" % (fmt(x + 2.7), fmt(y))]
    if cutoff_entry:
        out += [r"  \draw[draw=saorange, line width=1.0pt, dash pattern=on 4pt off 2pt] (%s, %s) -- +(0.5, 0);" % (fmt(x + 4.9), fmt(y)),
                r"  \node[anchor=west, font=\sffamily\footnotesize] at (%s, %s) {cutoff for the top 13};" % (fmt(x + 5.45), fmt(y))]
    return "\n".join(out) + "\n"


SHIFT = PANEL + 1.35
write("Picks-Sector",
      "Gamma by sector and random by sector on a made-up market of 12 sectors with 7 tickers each (seed 5660).",
      grid_panel(0, "gamma by sector", by_sector_top, False, True)
      + grid_panel(SHIFT, "random by sector", by_sector_random, False, False)
      + dot_legend(False))
write("Picks-Global",
      "Global gamma and random global on the same made-up market as Fig-L15a-Deck-Picks-Sector (seed 5660).",
      grid_panel(0, "global gamma", top13, True, True)
      + grid_panel(SHIFT, "random global", global_random, False, False)
      + dot_legend(True))

# ================================================================== the sector factor estimates on the same market
# A made-up smoothed sector factor for each sector (1/yr) and a made-up loading for each stock. The sector term
# moves the argument of tanh, so each preference weight becomes tanh(atanh(gamma) + delta * f). The ETFs have no
# sector, so they keep their preference weights. A second random stream draws the loadings, so the figures above
# keep their draws; the loop redraws until the dots of each column stay apart at the taller scale GY_SF.
SECTOR_TERM = dict(zip(SECTORS, [-0.55, 0.0, 0.7, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0, 0.0, -0.2, 0.0]))
GY_SF = 1.42  # cm per unit of gamma: two picked dots need a gap of 0.108 cm
rng_sf = random.Random(5662)
while True:
    loading = [[0.0 if SECTORS[s] == "ETF" else max(0.4, min(1.4, rng_sf.gauss(0.9, 0.12))) for k in range(PER_SECTOR)]
               for s in range(len(SECTORS))]
    gamma_sf = [[math.tanh(math.atanh(gamma[s][k]) + loading[s][k] * SECTOR_TERM[SECTORS[s]]) for k in range(PER_SECTOR)]
                for s in range(len(SECTORS))]
    gap = min(abs(a - b) for column in gamma_sf for i, a in enumerate(column) for j, b in enumerate(column) if i < j)
    if gap * GY_SF >= 0.108 and max(max(c) for c in gamma_sf) <= 0.93:
        break
flat_sf = sorted(((gamma_sf[s][k], s, k) for s in range(len(SECTORS)) for k in range(PER_SECTOR)), reverse=True)
top13_sf = set((s, k) for (_, s, k) in flat_sf[:13])
cutoff_sf = 0.5 * (flat_sf[12][0] + flat_sf[13][0])
crowd_sf = {}
for (s, k) in top13_sf:
    crowd_sf[SECTORS[s]] = crowd_sf.get(SECTORS[s], 0) + 1
KEPT_SF = len(top13 & top13_sf)
# the facts the deck quotes: Tech 4 to 1, Health and Staples 1 to 3 each, Comm. 1 to 0, and 9 of the 13 tickers kept
assert (crowd["Tech"], crowd_sf.get("Tech", 0)) == (4, 1)
assert (crowd["Health"], crowd_sf.get("Health", 0), crowd["Staples"], crowd_sf.get("Staples", 0)) == (1, 3, 1, 3)
assert (crowd["Comm."], crowd_sf.get("Comm.", 0)) == (1, 0) and KEPT_SF == 9
write("Sector-Factor",
      "Global gamma with the fixed estimates and with the sector factor estimates, on the made-up market of "
      "Fig-L15a-Deck-Picks-Global (seed 5660), with made-up sector terms and loadings (seed 5662).",
      grid_panel(0, "fixed estimates", top13, True, True, GY=GY_SF)
      + grid_panel(SHIFT, "sector factor estimates", top13_sf, True, False, values=gamma_sf, cut=cutoff_sf, GY=GY_SF)
      + dot_legend(True, GY=GY_SF))

# ================================================================== correlation gamma: the walk down the ranking
VISITED = 17
SHOWN = 19
SKIPS = {3: (1, 0.82), 7: (5, 0.76), 10: (8, 0.91), 14: (11, 0.74)}  # skipped rank: (the taken rank, rho)
assert VISITED - len(SKIPS) == 13
for r, (p, rho) in SKIPS.items():
    assert p < r and p not in SKIPS and rho > 0.7
RX = 0.56  # cm per rank
RY = 2.3   # cm per unit of gamma
corr = [r"  \draw[axis] (0, 0) -- (%s, 0);" % fmt(RX * (SHOWN + 0.9)),
        r"  \draw[axis] (0, 0) -- (0, %s);" % fmt(0.98 * RY),
        r"  \draw[spine] (0, %s) -- (-0.07, %s);" % (fmt(0.5 * RY), fmt(0.5 * RY)),
        r"  \node[anchor=east, font=\sffamily\footnotesize] at (-0.08, %s) {0.5};" % fmt(0.5 * RY),
        r"  \node[font=\sffamily\small, rotate=90, anchor=south] at (-0.5, %s) {preference weight};" % fmt(0.45 * RY),
        r"  \node[font=\sffamily\small, anchor=west] at (%s, 0) {rank};" % fmt(RX * (SHOWN + 1.0))]
taken = 0
for r in range(1, SHOWN + 1):
    g = 0.88 - 0.031 * (r - 1)
    x = RX * r
    corr.append(r"  \node[font=\sffamily\footnotesize, anchor=north] at (%s, -0.03) {%d};" % (fmt(x), r))
    box = (fmt(x - 0.18), fmt(x + 0.18), fmt(g * RY))
    if r > VISITED:
        corr.append(r"  \draw[draw=gdgray, line width=0.6pt, dash pattern=on 2pt off 1.5pt] (%s, 0) rectangle (%s, %s);" % box)
    elif r in SKIPS:
        corr.append(r"  \filldraw[fill=white, draw=gdgray, line width=0.7pt] (%s, 0) rectangle (%s, %s);" % box)
        corr.append(r"  \draw[draw=gdred, line width=1.1pt] (%s, %s) -- (%s, %s) (%s, %s) -- (%s, %s);"
                    % (fmt(x - 0.1), fmt(g * RY + 0.07), fmt(x + 0.1), fmt(g * RY + 0.27),
                       fmt(x - 0.1), fmt(g * RY + 0.27), fmt(x + 0.1), fmt(g * RY + 0.07)))
    else:
        taken += 1
        corr.append(r"  \filldraw[fill=orangefill, draw=vnink, line width=0.7pt] (%s, 0) rectangle (%s, %s);" % box)
assert taken == 13
# each arc below the ranks joins a skipped ticker to the taken ticker it moves with
for r, (p, rho) in SKIPS.items():
    depth = 0.25 + 0.06 * (r - p)
    xs, xp = RX * r, RX * p
    corr.append(r"  \draw[draw=gdred, line width=0.8pt] (%s, -0.36) .. controls (%s, %s) and (%s, %s) .. (%s, -0.36);"
                % (fmt(xs), fmt(xs), fmt(-0.36 - depth), fmt(xp), fmt(-0.36 - depth), fmt(xp)))
    corr.append(r"  \node[font=\sffamily\footnotesize, text=gdred, anchor=north, inner sep=1pt] at (%s, %s) {$\rho=%s$};"
                % (fmt((xs + xp) / 2), fmt(-0.38 - 0.75 * depth), f"{rho:.2f}"))
xstop = RX * (VISITED + 0.5)
corr.append(r"  \draw[drop] (%s, 0) -- (%s, %s);" % (fmt(xstop), fmt(xstop), fmt(0.5 * RY)))
corr.append(r"  \node[note, anchor=south] at (%s, %s) {13th ticker taken:\\the basket is full};" % (fmt(xstop), fmt(0.5 * RY)))
corr.append(r"  \filldraw[fill=orangefill, draw=vnink, line width=0.7pt] (%s, %s) rectangle +(0.3, 0.22);" % (fmt(RX * 7.0), fmt(0.9 * RY)))
corr.append(r"  \node[anchor=west, font=\sffamily\small] at (%s, %s) {taken};" % (fmt(RX * 7.0 + 0.36), fmt(0.9 * RY + 0.11)))
corr.append(r"  \filldraw[fill=white, draw=gdgray, line width=0.7pt] (%s, %s) rectangle +(0.3, 0.22);" % (fmt(RX * 9.6), fmt(0.9 * RY)))
corr.append(r"  \node[anchor=west, font=\sffamily\small] at (%s, %s) {skipped: $\rho>0.7$ with a ticker already taken};" % (fmt(RX * 9.6 + 0.36), fmt(0.9 * RY + 0.11)))
write("Picks-Correlation", "Correlation gamma on a made-up ranking: four skips, so the 13th ticker taken is at rank 17.",
      "\n".join(corr) + "\n")


# ================================================================== liquid gamma and random liquid: the shortlist
def funnel(highlight):
    g_fill = "orangefill" if highlight == "gamma" else "boxfill"
    r_fill = "orangefill" if highlight == "random" else "boxfill"
    return r"""  \node[sumbox, text width=2.4cm] (U) at (0, 0) {universe\\491 stocks and 14 ETFs};
  \node[sumbox, text width=2.9cm] (L) at (5.3, 0) {shortlist\\the 100 tickers with the largest $D_{i}(t)$};
  \node[sumbox, fill=%s, text width=3.4cm] (G) at (10.4, 0.95) {liquid gamma\\the 13 with the highest\\preference weights};
  \node[sumbox, fill=%s, text width=3.4cm] (R) at (10.4, -0.95) {random liquid\\13 drawn at random};
  \draw[flow] (U) -- node[note, above=2pt] {rank by $D_{i}(t)$} node[note, below=2pt] {the median value\\traded per day,\\last 63 days} (L);
  \draw[flow] (L.east) -- (G.west);
  \draw[flow] (L.east) -- (R.west);
""" % (g_fill, r_fill)


write("Picks-Liquid-Gamma", "The two steps of liquid gamma, with the liquid-gamma box shaded.", funnel("gamma"))
write("Picks-Liquid-Random", "The two steps of random liquid, with the random-liquid box shaded.", funnel("random"))

# ================================================================== the weights of three made-up tickers
GAMMA3 = [0.6, 0.3, -0.1]
PRICES3 = [100.0, 300.0, 50.0]
pos = [max(g, 0.0) for g in GAMMA3]
W_CD = [p / sum(pos) for p in pos]
amt = [p ** 0.5 for p in pos]
W_CESW = [a / sum(amt) for a in amt]
amt = [PRICES3[i] * (GAMMA3[i] / PRICES3[i]) ** 0.5 if GAMMA3[i] > 0 else 0.0 for i in range(3)]
W_CESS = [a / sum(amt) for a in amt]
W_SG = [0.01 + (1 - 3 * 0.01) * p / sum(pos) for p in pos]
neg = sum(-g for g in GAMMA3 if g < 0)
W_LS = [1.30 * g / sum(pos) if g > 0 else 0.30 * g / neg for g in GAMMA3]
GX = 2.4      # cm between the groups of bars
BAR = 0.58    # cm, the width of one bar


def bars(series, group_labels, digits=2, y_unit=2.6, ymin=-0.22, ymax=1.0, gap=0.22, legend=True):
    """series: list of (legend, values, fill, draw). The legend sits to the right of the bars."""
    out = []
    nseries = len(series)
    xmax = GX * (len(group_labels) - 0.15)
    out.append(r"  \draw[axis] (0, %s) -- (0, %s);" % (fmt(ymin * y_unit), fmt(ymax * y_unit)))
    out.append(r"  \draw[spine] (0, 0) -- (%s, 0);" % fmt(xmax))
    out.append(r"  \node[anchor=east, font=\sffamily\footnotesize] at (-0.08, 0) {0};")
    for g, lab in enumerate(group_labels):
        xc = GX * (g + 0.45)
        out.append(r"  \node[font=\sffamily\small, align=center, anchor=north] at (%s, %s) {%s};" % (fmt(xc), fmt(ymin * y_unit - 0.03), lab))
        for k, (_, values, fill, draw) in enumerate(series):
            x = xc + (k - (nseries - 1) / 2) * (BAR + gap)
            v = values[g]
            out.append(r"  \filldraw[fill=%s, draw=%s, line width=0.8pt] (%s, 0) rectangle (%s, %s);"
                       % (fill, draw, fmt(x - BAR / 2), fmt(x + BAR / 2), fmt(v * y_unit)))
            anchor = "south" if v >= 0 else "north"
            out.append(r"  \node[font=\sffamily\small, anchor=%s, inner sep=2pt] at (%s, %s) {%s};" % (anchor, fmt(x), fmt(v * y_unit), num(v, digits)))
    if legend:
        for k, (name, _, fill, draw) in enumerate(series):
            y = (ymax - 0.06) * y_unit - 0.5 * k
            out.append(r"  \filldraw[fill=%s, draw=%s, line width=0.8pt] (%s, %s) rectangle +(0.34, 0.26);" % (fill, draw, fmt(xmax + 0.2), fmt(y - 0.13)))
            out.append(r"  \node[anchor=west, font=\sffamily\small] at (%s, %s) {%s};" % (fmt(xmax + 0.6), fmt(y), name))
    return "\n".join(out) + "\n"


G_LABELS = [r"ticker 1\\$\gamma=0.6$", r"ticker 2\\$\gamma=0.3$", r"ticker 3\\$\gamma=-0.1$"]
G_LABELS_S = [r"ticker 1\\$\gamma=0.6$\\$S=100$", r"ticker 2\\$\gamma=0.3$\\$S=300$", r"ticker 3\\$\gamma=-0.1$\\$S=50$"]
CD_SERIES = ("Cobb-Douglas", W_CD, "boxfill", "gdgray")
write("Weights-Cobb-Douglas", "Cobb-Douglas weights of three made-up tickers, next to their preference weights.",
      bars([("preference weight $\\gamma_{i}$", GAMMA3, "white", "gdgray"), ("Cobb-Douglas weight $w_{i}$", W_CD, "orangefill", "vnink")], G_LABELS))
write("Weights-CES-Shares", "CES-on-shares weights of three made-up tickers, next to Cobb-Douglas.",
      bars([CD_SERIES, ("CES on shares", W_CESS, "orangefill", "vnink")], G_LABELS_S))
write("Weights-CES-Weights", "CES-on-weights weights of three made-up tickers, next to Cobb-Douglas.",
      bars([CD_SERIES, ("CES on weights", W_CESW, "orangefill", "vnink")], G_LABELS))
write("Weights-Stone-Geary", "Stone-Geary weights of three made-up tickers, next to Cobb-Douglas.",
      bars([CD_SERIES, ("Stone-Geary", W_SG, "orangefill", "vnink")], G_LABELS, digits=3, gap=0.42)
      + r"  \node[note, anchor=south] at (%s, %s) {the 1\%% baseline};" % (fmt(GX * 2.45 + 0.5 * (BAR + 0.42)), fmt(0.2 * 2.6)) + "\n")

# the 130/30 weights, with the long side, the short side, and the net position
LY = 1.7  # cm per unit of weight
ls = bars([("130/30 weight", W_LS, "orangefill", "vnink")],
          [r"ticker 1\\$\gamma=0.6$", r"ticker 2\\$\gamma=0.3$", r"short candidate\\$\gamma=-0.1$"],
          y_unit=LY, ymin=-0.5, ymax=1.4, legend=False)
xs = GX * 3.2
long1, long2 = W_LS[0], W_LS[1]
ls += r"""  \filldraw[fill=orangefill, draw=vnink, line width=0.8pt] (%s, 0) rectangle (%s, %s);
  \filldraw[fill=orangefill, draw=vnink, line width=0.8pt] (%s, %s) rectangle (%s, %s);
  \filldraw[fill=bluefill, draw=vnink, line width=0.8pt] (%s, 0) rectangle (%s, %s);
  \draw[draw=gdgray, line width=1.0pt, dash pattern=on 4pt off 2pt] (%s, %s) -- (%s, %s);
  \node[font=\sffamily\small, anchor=west, align=left] at (%s, %s) {long side: $0.87+0.43=1.30$};
  \node[font=\sffamily\small, text=gdgray, anchor=west, align=left] at (%s, %s) {net: $1.30-0.30=1.00$};
  \node[font=\sffamily\small, anchor=west, align=left] at (%s, %s) {short side: $-0.30$};
""" % (fmt(xs - 0.29), fmt(xs + 0.29), fmt(long1 * LY),
       fmt(xs - 0.29), fmt(long1 * LY), fmt(xs + 0.29), fmt((long1 + long2) * LY),
       fmt(xs - 0.29), fmt(xs + 0.29), fmt(W_LS[2] * LY),
       fmt(xs - 0.5), fmt(1.0 * LY), fmt(xs + 0.5), fmt(1.0 * LY),
       fmt(xs + 0.45), fmt(1.22 * LY),
       fmt(xs + 0.55), fmt(0.93 * LY),
       fmt(xs + 0.45), fmt(-0.15 * LY))
write("Weights-Long-Short", "130/30 weights of two made-up basket tickers and one short candidate.", ls)

# the equal weights, scaled down by c to meet a limit
K, C = 13, 0.85
EY = 20.0  # cm per unit of weight
EX = 0.55  # cm between bars
eq = [r"  \draw[axis] (0, 0) -- (0, %s);" % fmt(0.17 * EY), r"  \draw[spine] (0, 0) -- (%s, 0);" % fmt(EX * (K + 2.8))]
for i in range(K):
    x = EX * (i + 1)
    eq.append(r"  \draw[draw=gdgray, line width=0.7pt, dash pattern=on 2pt off 1.5pt] (%s, 0) rectangle (%s, %s);" % (fmt(x - 0.19), fmt(x + 0.19), fmt(EY / K)))
    eq.append(r"  \filldraw[fill=orangefill, draw=vnink, line width=0.7pt] (%s, 0) rectangle (%s, %s);" % (fmt(x - 0.19), fmt(x + 0.19), fmt(C * EY / K)))
xc = EX * (K + 2)
eq.append(r"  \filldraw[fill=boxfill, draw=gdgray, line width=0.7pt] (%s, 0) rectangle (%s, %s);" % (fmt(xc - 0.19), fmt(xc + 0.19), fmt((1 - C) * EY)))
eq.append(r"  \node[font=\sffamily\small, anchor=west, align=left] at (%s, %s) {cash:\\$1-c=%s$};" % (fmt(xc + 0.3), fmt((1 - C) * EY * 0.6), f"{1 - C:.2f}"))
eq.append(r"  \node[font=\sffamily\small, anchor=north] at (%s, -0.03) {the $K=13$ tickers of the basket};" % fmt(EX * 7))
eq.append(r"  \draw[spine] (0, %s) -- (-0.07, %s);" % (fmt(EY / K), fmt(EY / K)))
eq.append(r"  \node[anchor=east, font=\sffamily\small, text=gdgray] at (-0.08, %s) {target $1/K\approx %s$};" % (fmt(EY / K + 0.16), f"{1 / K:.3f}"))
eq.append(r"  \draw[spine] (0, %s) -- (-0.07, %s);" % (fmt(C * EY / K), fmt(C * EY / K)))
eq.append(r"  \node[anchor=east, font=\sffamily\small] at (-0.08, %s) {scaled $c/K\approx %s$};" % (fmt(C * EY / K - 0.2), f"{C / K:.3f}"))
write("Weights-Equal", "Equal weights of a 13-ticker basket, scaled by a made-up c = 0.85, with the rest in cash.", "\n".join(eq) + "\n")

# ================================================================== the two steps of minimum variance and maximum Sharpe
S0, M0, KK = 0.12, 0.03, 0.5  # the made-up edge of the long-only portfolios: sigma(m)^2 = S0^2 + ((m - M0)/KK)^2
SMAX = 0.135
M_T = M0 + S0 ** 2 * KK ** 2 / M0
S_T = math.sqrt(S0 ** 2 + ((M_T - M0) / KK) ** 2)
C_T = SMAX / S_T
assert S0 < SMAX < S_T
XS, YS = 24.0, 16.5  # cm per unit of volatility and of excess growth
LEN = math.hypot(S_T * XS, M_T * YS)
UX, UY = S_T * XS / LEN, M_T * YS / LEN  # along the line from cash, in cm
NX, NY = -UY, UX  # across the line, up and to the left
M_TOP = 0.19


def sigma(m):
    return math.sqrt(S0 ** 2 + ((m - M0) / KK) ** 2)


def two_step(which):
    pts = " ".join(f"({fmt(sigma(m) * XS)}, {fmt(m * YS)})" for m in [M_TOP * k / 50 for k in range(51)])
    out = [r"  \draw[axis] (0, 0) -- (%s, 0);" % fmt(0.37 * XS),
           r"  \draw[axis] (0, 0) -- (0, %s);" % fmt(0.2 * YS),
           r"  \node[font=\sffamily\small, anchor=north] at (%s, -0.05) {volatility $\sqrt{w^{\top}\Sigma_{g}w}$};" % fmt(0.24 * XS),
           r"  \node[font=\sffamily\small, rotate=90, anchor=south, align=center] at (-0.1, %s) {excess growth\\$(\mu_{g}-g_{f})^{\top}w$};" % fmt(0.1 * YS),
           r"  \draw[curve, draw=gdgray] plot[smooth] coordinates {%s};" % pts,
           r"  \node[font=\sffamily\small, text=gdgray, anchor=west, align=left] at (%s, %s) {long-only portfolios\\of the basket};" % (fmt(sigma(M_TOP) * XS + 0.1), fmt(M_TOP * YS - 0.2)),
           r"  \draw[draw=gdred, line width=1.0pt, dash pattern=on 4pt off 2pt] (%s, 0) -- (%s, %s);" % (fmt(SMAX * XS), fmt(SMAX * XS), fmt(M_TOP * YS)),
           r"  \node[font=\sffamily\small, text=gdred, anchor=south] at (%s, %s) {volatility limit $\sigma_{\max}$};" % (fmt(SMAX * XS), fmt(M_TOP * YS)),
           r"  \node[pt, fill=vnink] at (0, 0) {};",
           r"  \node[font=\sffamily\small, anchor=north west] at (0.02, -0.02) {cash};"]
    if which == "minvar":
        out += [r"  \node[pt, fill=saorange, minimum size=2.4mm] at (%s, %s) {};" % (fmt(S0 * XS), fmt(M0 * YS)),
                r"  \node[font=\sffamily\small, anchor=east, align=right] at (%s, %s) {minimum-\\variance mix,\\$c=1$};" % (fmt(S0 * XS - 0.18), fmt(M0 * YS + 0.15))]
    else:
        out += [r"  \draw[draw=vnink, line width=0.8pt] (0, 0) -- (%s, %s);" % (fmt(1.1 * S_T * XS), fmt(1.1 * M_T * YS)),
                r"  \node[pt, fill=white] at (%s, %s) {};" % (fmt(S_T * XS), fmt(M_T * YS)),
                r"  \node[font=\sffamily\small, anchor=west] at (%s, %s) {maximum-Sharpe mix};" % (fmt(S_T * XS + 0.2), fmt(M_T * YS - 0.2)),
                r"  \draw[feedback] (%s, %s) -- (%s, %s);" % (fmt(S_T * XS + 0.25 * NX - 0.2 * UX), fmt(M_T * YS + 0.25 * NY - 0.2 * UY),
                                                             fmt(C_T * S_T * XS + 0.25 * NX + 0.2 * UX), fmt(C_T * M_T * YS + 0.25 * NY + 0.2 * UY)),
                r"  \node[pt, fill=saorange, minimum size=2.4mm] at (%s, %s) {};" % (fmt(C_T * S_T * XS), fmt(C_T * M_T * YS)),
                r"  \node[font=\sffamily\small, anchor=east, align=right] at (%s, %s) {scaled: $c\,w_{\text{mix}}$,\\the rest in cash};" % (fmt(C_T * S_T * XS - 0.2), fmt(C_T * M_T * YS + 0.25))]
    return "\n".join(out) + "\n"


write("Two-Step-Minimum-Variance", "The two steps of the minimum-variance rule on a made-up basket: the mix is within the limit.", two_step("minvar"))
write("Two-Step-Maximum-Sharpe", "The two steps of the maximum-Sharpe rule on a made-up basket: the mix is scaled back to the limit.", two_step("sharpe"))

# ================================================================== the tilt of the preference weight
# The left panel of figs/Fig-L15a-BAB-Tilt, without its title and with the deck's time index on beta.
write("Tilt", "The factor 1/max(|beta_i|, beta_floor)^xi_t on the expected growth rate, as in the left panel of Fig-L15a-BAB-Tilt.",
      r"""  \begin{scope}[x=2.45cm, y=0.72cm]
    \draw[axis] (0, 0) -- (3.2, 0);
    \draw[axis] (0, 0) -- (0, 4.35);
    \foreach \x in {0, 1, 2, 3} {
      \draw[spine] (\x, 0) -- (\x, -0.1);
      \node[anchor=north, font=\sffamily\footnotesize] at (\x, -0.12) {\x};
    }
    \draw[spine] (0, 1) -- (-0.03, 1);
    \node[anchor=east, font=\sffamily\footnotesize] at (-0.04, 1) {1};
    \node[font=\sffamily\small, anchor=north] at (1.6, -0.5) {market sensitivity $\beta_{i}(t)$};
    \node[font=\sffamily\small, rotate=90, anchor=south, align=center] at (-0.12, 2.1) {factor on the expected\\growth rate};
    \draw[drop] (0, 1) -- (3.05, 1);
    \draw[curve, draw=gdred] plot[domain=0.25:3.05, samples=140] (\x, {1/\x});
    \draw[curve, draw=gdblue] (0.1, 0.1) -- (3.05, 3.05);
    \node[pt] at (1, 1) {};
    \node[font=\sffamily\small, text=gdred, anchor=west, align=left] at (0.33, 3.75) {market falling, $\xi_{t}>0$:\\favors low $\beta_{i}(t)$};
    \node[font=\sffamily\small, text=gdblue, anchor=south east, align=right] at (3.05, 3.15) {market rising, $\xi_{t}<0$:\\favors high $\beta_{i}(t)$};
    \node[font=\sffamily\small, text=gdgray, anchor=south east] at (3.05, 1.02) {$\xi_{t}=0$: no tilt};
    \node[font=\sffamily\small, anchor=west] at (3.25, 2.0) {factor $=\dfrac{1}{\max\big(|\beta_{i}(t)|,\,\beta_{\text{floor}}\big)^{\xi_{t}}}$};
  \end{scope}
""")

# ================================================================== the facts the decks quote
print("top13 by sector:", dict(sorted(crowd.items(), key=lambda kv: -kv[1])))
print("sectors with no ticker in the global-gamma basket:", EMPTY_SECTORS)
print("gamma-by-sector picks with a negative preference weight:", NEGATIVE_PICKS)
print("sector factor estimates: top13 by sector", dict(sorted(crowd_sf.items(), key=lambda kv: -kv[1])), "kept", KEPT_SF,
      "of 13; smallest gap", round(gap, 3))
print("weights: CD", [round(w, 3) for w in W_CD], "CES-S", [round(w, 3) for w in W_CESS], "CES-W", [round(w, 3) for w in W_CESW],
      "SG", [round(w, 3) for w in W_SG], "LS", [round(w, 3) for w in W_LS])
print("two-step: tangent sigma", round(S_T, 4), "excess", round(M_T, 4), "c", round(C_T, 3))
