# L11b figures

Two one-panel profit diagrams, added November 4, 2026 at the instructor's
request ("like we did for L11a"), using the L11a TikZ pipeline copied from
`../../L11a/figs/` (`profit-diagram.tex`, `theme_svg.py`, `Makefile`).

| Figure | Shown in |
|---|---|
| `Fig-L11b-Covered-Call` | Covered Calls, after the comparison with the shares alone |
| `Fig-L11b-Collar` | Protective Collars, after the zero-cost collar sentence (three panels, width 1000) |
| `Fig-L11b-TJUL` | Protective Collars, TJUL box, after the EDGAR paragraph (one panel, to scale, width 500) |

Each panel draws the position's profit at expiration (ink) and, for comparison,
the profit of the shares alone (gray, dashed, the new `shares` style). As in
L11a's buying-shares panel there is no payoff curve, because the shares' payoff
leaves the panel. Lines are named in a legend in the upper-left corner
(`\shareslegend`, the one corner these profits never draw into); direct labels
collided with the max-profit arrow. Strikes, the breakeven, `S(0)`, and the
max-profit and max-loss arrows follow the L11a conventions. The panels are
schematics with no axis numbers; each `.tex` header records the values used.

From this folder, run `make` to build each PDF (deck) and themed SVG (notebook,
width 450), and `make clean` to remove the LaTeX temporaries.

## Opportunity point

Added November 4, 2026 at the instructor's request. Each figure marks the
opportunity point $O^{+}$ (open ink circle, labeled above left), where the
shares alone reach the position's maximum profit, and shades in gray the region
where the shares alone earn more (the opportunity loss). For the covered call,
$O^{+}=K+\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$, as defined in the
covered call example. For the collar, $O^{+}=K_{2}+\mathcal{D}_{T,0}(g_{y})
\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$, so the collar figure has three panels:
a net credit ($O^{+}>K_{2}$), a zero-cost collar ($O^{+}=K_{2}$), and a net
debit ($O^{+}<K_{2}$, and the shares earn more everywhere above the point where
they cross the floor). On November 5, 2026, the instructor had the $O^{+}$ circle
removed from the net debit panel: there it is not where the opportunity loss
starts, so it marked nothing useful; the blue circle (below) marks where it starts. The max-profit and max-loss arrows are drawn only in the
covered call figure, to keep the three collar panels readable.

## Short call alone (covered call figure)

Added November 4, 2026, at the instructor's request. The covered call figure also
draws the profit of the short call alone (blue, `payoff` style, third legend entry),
flat at the premium grown to expiration for $S(T)\le K$ and falling one for one above $K$. It crosses
zero at $K+\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}=O^{+}$: an open blue circle
labeled "short call breakeven", joined by a gray drop to the $O^{+}$ circle directly
above it. The covered call is the shares plus the short call, so the two are equal
where the short call breaks even, and the opportunity loss above $O^{+}$ is the short
call's loss. The blue line is drawn before the covered call, so the ink line stays
on top where they cross. With the schematic values, the shares line passes through
the short call's kink at $(K, 1.0)$; that is a coincidence of the values, not a
general result. The label starts at $S=6.75$, about 3.8 pt clear of the falling line
(measured with `pdftotext -bbox`).

## Options together (collar figure)

Added November 5, 2026, at the instructor's request, as the collar's counterpart of
the short call alone. Each collar panel draws the profit of the long put and the short
call held together (blue, `payoff` style), $(K_{1}-S(T))^{+}-(S(T)-K_{2})^{+}+n$ with
$n=\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$. The collar is the
shares plus this position, so the shading begins where the blue line drops below zero (the
shading stops where the shares line ends, the blue line runs on). Net credit: it crosses
zero directly below $O^{+}$ (blue circle, gray drop to $O^{+}$). Zero
cost: it lies along the zero line between the strikes (no circle). Net debit: it crosses
zero at $K_{1}+n$, where the shares cross the floor and the shading starts (blue circle,
gray drop to that point), not at $O^{+}$. The schematic values are unchanged. Because
the blue line now starts in the first panel's upper-left corner, the legend is one row
centered below the panels. With $|n|=0.6$ the S-double-dagger label does not fit between
the zero line and the blue line, so in the credit and debit panels it sits left or right
of its circle, nudged 3 pt, on a white knockout (mapped to the dark background in the
SVG); a larger $|n|$ was tried and put the debit label on the $K_{2}$ drop.

## TJUL today

Added November 5, 2026, at the instructor's request (option B of two mockups: drawn to
scale with numeric axes). One panel shows where the TJUL collar sits on the net debit
diagram, using the premiums in TJUL's SEC Form N-PORT for July 31, 2025 (series
S000080903; cost = value minus unrealized appreciation): put 45.459, call 34.232
USD/share, strikes K1 = S(0) = 617.85 and K2 = 701.94. They are grown to expiration at the
two-year Treasury yield on June 30, 2025 (FRED DGS2, 3.72%, g_y = 2 ln(1 + y/2)). The SPY
close on November 4, 2026 (766.81) is marked in orange, the course's color for before
expiration, with the gap to SPY alone (about 77 USD/share). The `.tex` header records every
number. The figure draws the collar on shares bought at $S(0)$, as the lecture does. TJUL
holds a call at 11.12 instead (cost 596.27), which is cheaper than the shares by about
11.25 USD/share, the value of the dividends it gives up. Grown to expiration (about 12.1), that
raises TJUL's own lines by the same amount as a SPY holder's who collects the dividends,
so the gap (about 77) is unchanged; only the levels differ (TJUL's cap profit is about
36.8, not 24.7). The lecture's Dividends bullet says this. The legend is one row below the axis label, because today's label needs the
upper-left space. The S-double-dagger label sits above the SPY-alone line: below the
circle, the blue line at -12.1 leaves no room for it.

## Fit and finish (November 4, 2026)

- The "opportunity loss" label sits 0.95 profit units above the cap, to the right
  of the wedge, so it clears both the cap line and the wedge edge.
- `\yzero` is 3.2 in both figures (4.0 x `\yscale`), so the shares-alone line
  starts exactly at the corner of the axes: its profit at $S(T)=0$ is the whole
  purchase price grown (instructor's catch; it had started 0.2 above the corner).
- The collar figure uses `\panelgap` 11.4 (L11a: 10.6) so each y-axis label clears
  the panel to its left, and its panel titles read "Collar, net credit/zero
  cost/net debit".
- Checked by measurement: no two word boxes (`pdftotext -bbox`) are within 1.5 pt,
  other than the pieces of one label (a symbol and its subscript or superscript).
- Dark mode checked by applying the SVG's dark rules directly to a scratch copy
  (`rsvg-convert` ignores the `prefers-color-scheme` block, so a plain render
  shows ink on dark and looks broken; it is not).
