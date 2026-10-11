# L9b figures

`Fig-L9b-American-Decision-Rule` is the decision-rule schematic in the lecture's
"Decision-Rule for American Options" section. It is a minimal TikZ redraw of the
instructor's 2025 raster `Fig-American-Contract-Decision-Schematic.png` (Fall-2025
`lectures/week-10/L10a/figs/`). A three-step lattice has one decision cell zoomed
out, and the decision rule sits below it in the 2026 notation: `q` is the
risk-neutral up probability, `V̂_{t,k}` is the value at node `(t,k)`, and `V(K,S)`
is the payoff, as in L9a. The two boxed terms are "exercise now" (gray) and "hold
for the future" (salmon), the instructor's two colors.

`Fig-HullExample-American-v-European-Schematic.png` is the instructor's 2025 Hull
Examples 13.4 and 13.5 raster. It is kept as is.

`make` builds each TikZ figure's PDF with XeLaTeX and converts it to SVG with
`pdf2svg`. The SVG build also runs `theme_svg.py`, which adds a dark screen
palette in a `<style>` block keyed on the light colors. The notebook's image
block passes VS Code's selected theme to the SVG, so changing the editor theme
repaints the figure. Outside VS Code the image follows the viewer's color
scheme, and print uses the light palette. If the TikZ palette changes, update
the color map in `theme_svg.py`. An unmapped color fails the build on purpose.
The white node fill maps to VS Code's default dark editor background.

The slides include the PDFs, which keep the light palette (XeLaTeX cannot
include SVG directly).
