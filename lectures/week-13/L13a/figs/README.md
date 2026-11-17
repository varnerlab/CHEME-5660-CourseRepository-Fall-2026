# L13a figures

Three TikZ figures of the jump hidden Markov model, drawn in the style of the week-12
schematics. All three `\input` the shared style file `jumphmm-diagram.tex`: Arial text with
standard TeX math, the ink, blue, red, and orange palette, filled rounded boxes, and
Latex arrowheads (from `week-12/L12a/figs/abm-diagram.tex`), plus the plot styles of the
L10b profit diagrams (arrowed axes, a thick ink curve, open circle markers, dashed drops).

| Figure | Shown in |
|---|---|
| `Fig-L13a-JumpHMM-Fit-Schematic` | The Jump Hidden Markov Model, before "Fitting algorithm" (width 1000), and the deck. How the model is fit, with headers that match the steps of the fitting algorithm (1. Laplace, 2. States, 3. Count, 4. Transitions): the daily growth rates of a ticker, with each marker showing the state of its day and the moves 3 → 4 drawn in orange; the fitted Laplace density, drawn sideways from its 5% to its 95% quantile and cut into five bins of equal area; and the table of counted moves with the estimate of $\hat{p}_{ij}$. Drawn with $N = 5$ states and sixteen made-up days, so every count can be checked against the states in the markers. |
| `Fig-L13a-JumpHMM-Schematic` | Why add jumps?, before "Sampling algorithm" (width 880), and the deck. One simulated day: the $N$ states with their Student-t emissions, the ordinary step with $\hat{\mathbf{P}}$, and the jump episode that starts with probability $\epsilon$, lasts a Poisson number of days with mean $\lambda$, and draws each day's state from the most negative states (probability $p_{\text{neg}}$) or the most positive states. The layout is ported from the INFORMS 2026 talk (`talk/figs/jumphmm_architecture.tex` in varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab, also the paper's JumpHMM figure). |
| `Fig-L13a-Episode-Shape` | What the episodes add and what they miss (width 1000). Two panels. Left, a schematic: the volatility of a simulated jump episode is a flat box for about $\lambda$ days, and a real crash spikes and then fades. Right, the data: the standard deviation of $g$ over the past 21 trading days for real `SPY` from 2020-02-20, six episodes of the tuned SPY model (`data/JumpHMM-SPY-2014-2024.jld2`) one by one, and the mean over all of its episodes, each aligned at its first day. `Fig-L13a-Episode-Shape-Data.jl` writes the panel's data, `Fig-L13a-Episode-Shape-Data.csv`; rerun it if the saved model changes. |

Each `.tex` header records the consistency checks. From this folder, `make` builds each
PDF (deck) and themed SVG (notebook) with XeLaTeX and `pdf2svg`.

The SVG build runs `theme_svg.py`, which adds a dark screen palette in a `<style>` block
keyed on the light colors. The notebook's image block passes VS Code's selected theme to
the SVG, so changing the editor theme repaints the figure. If the palette in
`jumphmm-diagram.tex` changes, update the color mapping in `theme_svg.py`; an unmapped
color fails the build on purpose.

`vnfigure.sty` is no longer used by these figures.

## Wolfram-market review

`Fig-L13a-Wolfram-Markets` shows three rows of actual simulation snapshots at
the same six steps: 1000, 1250, 1500, 1600, 2000, and 4000. The rows are R19280
alone, the closed-market switch from R19280 to R19286, and the switch in an open
market with continuous refresh and R0 buyers after step 1500. Each panel also
gives the Sell percentage and share price in USD/share. Blue is Buy, gray is
Hold, and orange is Sell, matching L12b.

The figure uses the L12b RuleSwitch example's constants: a 64 by 64 grid, seed 1,
active edge traders, dealer depth 100, 25% switching after step 1000, and price
noise with annual volatility 0.40 at one-minute steps. The third row uses the
Viewport example's `refresh_rate = 0.001`, beginning after step 1500: each
interior trader then leaves with that probability at every step, and a new
player takes its place with fresh cash and shares. A quarter of new arrivals,
on average, follow R0; the other players follow the baseline or switch rule of
their seats. There are no R0 players before refresh starts. The two switched
markets have identical grids and prices through step 1500, when 65.2% of their
traders intend to sell. At step 1600, the open market has 3.1% R0 players and
63.6% Sell intentions; by step 2000 those percentages are 9.9% and 24.3%.

All figure-specific source and saved data are in this folder. The Julia data
script calls the existing L12b helpers and the course package, preserving one
implementation of the market. A small observer adapter delays refresh while
leaving price noise active; the L12b observer still handles all replacement and
rule logic. The script checks the shared history through step 1500, the Sell
majority, the empty initial R0 population, and later R0 entry before exporting.
The Python script draws the PDF, PNG, and SVG;
the SVG adapts text and outlines to dark screens while keeping intention colors.

From this folder, `make wolfram-data` reruns the simulations. Then run
`make Fig-L13a-Wolfram-Markets.pdf PYTHON=/path/to/python-with-matplotlib` to draw
all three formats. The lecture's "Review: Wolfram Markets" section shows this
figure after the three-rule figure, both at width 1000 with the notebook's
existing theme wrapper.

## Three Wolfram rules

`Fig-L13a-Wolfram-Rules` copies the L12b rule-switch drawing, with one additional
Rule 0 row. The single trader-and-neighbors cross, neighbor-sum arrow, two original
lookup rows, fonts, colors, and highlighted sum-1 column retain the L12b layout.
All lookup cells contain numeric intention codes only. The added Rule 0 row is
all zeros (Buy), and the original legend moves down to leave room for that row.

The TikZ source decodes each output directly from the rule number with exact
integer division. The tables read `222110002`, `222110022`, and `000000000` in
base 3. This figure uses pdfLaTeX to match the reference's Computer Modern font.
Build the PDF, themed SVG, and PNG with
`make Fig-L13a-Wolfram-Rules.pdf Fig-L13a-Wolfram-Rules.svg Fig-L13a-Wolfram-Rules.png`.
