# L11a figures

## Profit diagrams

Four two-panel schematics for the lecture's composite-contract section, one per
subsection, each shown before the subsection's mathematics:

| Figure | Left panel | Right panel |
|---|---|---|
| `Fig-L11a-Short-Put-Call` | short put | short call |
| `Fig-L11a-Credit-Spreads` | put credit spread | call credit spread |
| `Fig-L11a-Straddle-Strangle` | short straddle | short strangle |
| `Fig-L11a-Protected-Condor` | protected strangle | iron condor |

These are the eight structures sold in PS4. Each panel draws the payoff at
expiration (blue) and the profit (ink) per share. For these credit structures
the profit is the payoff moved up by the credit, so the arrow labeled "max
profit = credit" spans the gap between the two curves. Each strike has a dashed
drop to the axis, labeled with its symbol and the leg written there (for
example $K_1$ over "long put"). Strikes are numbered from low to high. The
breakevens are open red circles, labeled $S^{\ddagger}$ for one breakeven and
$S^{\ddagger}_{-}$, $S^{\ddagger}_{+}$ for two. A capped loss has a "max loss"
arrow, and an uncapped call side ends in an arrowhead labeled "unlimited
loss". The y-axis sits at $S(T)=0$, where the short put reaches its largest
loss. A short tick labeled $S(0)$ just above the axis (`\entryprice`, added
October 27, 2026) marks the share price when the trade opens, so students can see
that the short legs start out of the money; the straddle's strike is labeled
$K=S(0)$. A note in each panel's upper-right corner (`\outlook`, added October 28, 2026) gives the structure's outlook, as in the lecture's composite-contract table. The panels are schematics with no axis numbers. Each `.tex` header
records the strikes, credit, and breakevens used to draw it.

They were drawn in TikZ on October 23, 2026 in the style of the CHEME 5800 L9c
convexity and gradient-descent figures (same palette, arrowed axes, open markers,
and dashed drops), at the instructor's request. The shared macros and palette
are in `profit-diagram.tex`, which each figure `\input`s.

| File | Role |
|---|---|
| `profit-diagram.tex` | Shared palette, panel frame, and macros (`\strike`, `\entryprice`, `\breakeven`, `\maxprofit`, `\maxloss`, `\unlimited`, `\outlook`) |
| `Fig-L11a-*.tex` | Standalone TikZ sources (XeLaTeX) |
| `Makefile` | Builds each PDF, then its themed SVG |
| `theme_svg.py` | Adds the dark screen palette to each SVG |
| `Fig-L11a-*.pdf` | Light figures for the slides |
| `Fig-L11a-*.svg` | Notebook figures |

From this folder, run `make` to rebuild everything and `make clean` to remove the
LaTeX temporaries. The build needs XeLaTeX, `pdf2svg`, and Python 3 (standard
library only). `pdf2svg` traces the glyphs to paths, so the SVG needs no fonts.
`theme_svg.py` maps each light color to a dark screen color under
`prefers-color-scheme: dark`. An unmapped color stops the build, so a palette
change in `profit-diagram.tex` must be added to the script's mapping.

Label placement was checked by measurement as well as by eye. Every word box
(from `pdftotext -bbox-layout`) is at least 2 pt from every drawn line and from
every other label. The exceptions are the deliberate 1.9 pt gap between each
breakeven label and its circle, and the lines inside one stacked label.

## Short strangle before expiration

`Fig-L11a-Strangle-Time-Decay` shows why the diagrams above are drawn at
expiration. A short strangle is opened 30 days before expiration: sell a put at
$K_1=90$ and a call at $K_2=110$ USD/share, with $S(0)=100$, $\sigma=0.40$, and
$g_y=0.04$. If we buy both legs back early, the profit is the credit, grown to
that day, minus what the legs cost then. The left panel shows that profit against
the share price with 30 (entry), 20, and 10 days left, in orange tints that darken
toward expiration, and at expiration in ink. Each leg's buy-back price still holds
extrinsic value, so every earlier curve lies below the profit at expiration and
rises onto it as the time value decays. The right panel holds the share price at
$S(0)$ and splits that profit into two parts. One is the credit collected at
entry (dashed, grown with interest). The other is the cost to buy both legs back
(orange), which is all extrinsic value at $S(0)$. The gap between them is the
profit if we close. It is zero at entry, where the cost equals the credit, and
the whole credit at expiration, where both legs expire worthless. Its circles are
the same four days in the left panel's colors. An earlier version plotted only the
profit at $S(0)$, and the instructor read its zero at entry as a contradiction ("I
make max profit when I enter the position"). The split shows that the credit is
collected at entry but is offset by what it costs to buy the legs back. The orange is the L9c simulated-annealing
orange. It is used only here, so the earlier curves are not read as payoffs (blue).

Unlike the schematics, these curves are computed.
`generate-strangle-time-decay.jl` prices the American legs on CRR trees
($h=501$), with the same self-contained pricer as the L10a premium-versus-moneyness
figure, and writes `Fig-L11a-Strangle-Time-Decay-coords.tex`, which the figure
`\input`s. Run `julia generate-strangle-time-decay.jl` (about 3 s) after changing
a parameter, then `make`. The generated file is committed, so `make` alone needs
no Julia. On October 23, 2026 the pricer was checked against the course package's
`binomial_premium(...; method = :crr)`: the entry premiums (put 1.0016, call
1.4359, credit 2.4375 USD/share) and the profit at $S=92$ with 20 days left
(−0.0833 USD/share) match to four decimals.
