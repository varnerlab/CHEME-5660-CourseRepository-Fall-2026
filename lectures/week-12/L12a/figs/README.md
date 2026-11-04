# L12a figures

`Fig-L12a-JumpHMM-Schematic` is the lecture-notebook schematic of the jump hidden
Markov model: the $N$ states ordered from the most negative to the most positive
daily growth rate, each with its Student-t emission, the ordinary step with the
counted transition matrix, and the jump episodes that start with probability
$\epsilon$, last a Poisson number of days with mean $\lambda$, and draw each day's
state from the most negative or the most positive states. It is ported from the
INFORMS 2026 talk (`talk/figs/jumphmm_architecture.tex` in
varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab, also the paper's JumpHMM figure),
with the lecture's notation and the course palette. `make` builds the PDF and SVG
with XeLaTeX and `pdf2svg`.

The SVG build also runs `theme_svg.py` (a copy of the L5b script), which adds a dark
screen palette in a `<style>` block keyed on the light colors. The notebook's image
block passes VS Code's selected theme to the SVG, so changing the editor theme
repaints the figure. If the TikZ palette changes, update the color mapping in
`theme_svg.py`; an unmapped color fails the build on purpose.

`Fig-TransitionMatrix-Schematic.svg` is the 2025 transition-matrix schematic and has
no source here.
