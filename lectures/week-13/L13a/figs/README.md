# L13a figures

Three TikZ figures of the jump hidden Markov model, drawn in the style of the week-12
schematics. All three `\input` the shared style file `jumphmm-diagram.tex`: Arial text with
standard TeX math, the ink, blue, red, and orange palette, filled rounded boxes, and
Latex arrowheads (from `week-12/L12a/figs/abm-diagram.tex`), plus the plot styles of the
L10b profit diagrams (arrowed axes, a thick ink curve, open circle markers, dashed drops).

| Figure | Shown in |
|---|---|
| `Fig-L13a-JumpHMM-Fit-Schematic` | The Jump Hidden Markov Model, before "Fitting algorithm" (width 1000), and the deck. How the model is fit, with headers that match the steps of the fitting algorithm (1. Laplace, 2. States, 3. Count, 4. Transitions): the daily growth rates of a ticker, with each marker showing the state of its day and the moves 3 → 4 drawn in orange; the fitted Laplace density, drawn sideways from its 5% to its 95% quantile and cut into five slices of equal area; and the table of counted moves with the estimate of $\hat{p}_{ij}$. Drawn with $N = 5$ states and sixteen made-up days, so every count can be checked against the states in the markers. |
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
