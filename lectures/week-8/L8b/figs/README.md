# L8b figures

`Fig-L8b-Bet-CashFlows` is the cash-flow timeline at the top of the lecture's
"Derivatives: A Bet on the Future" section. It follows L1b's abstract-asset
timeline: the price $p$ is paid at $t=0$, the payoff (1 USD if $S_T \geq K$,
0 if $S_T < K$) is received $T$ years from now and may be zero, and an arrow
below the timeline discounts the payoff to today with
$\mathcal{D}^{-1}_{T,0}(g_y)$.

`make` builds the figure's PDF with XeLaTeX and converts it to SVG with
`pdf2svg`. The SVG build also runs `theme_svg.py` (copied from L9a), which adds
a dark screen palette in a `<style>` block keyed on the light colors. The
notebook's image block passes VS Code's selected theme to the SVG, so changing
the editor theme repaints the figure. Outside VS Code the image follows the
viewer's color scheme, and print uses the light palette. If the TikZ palette
changes, update the color map in `theme_svg.py`. An unmapped color fails the
build on purpose.

The slides include the PDF, which keeps the light palette (XeLaTeX cannot
include SVG directly).
