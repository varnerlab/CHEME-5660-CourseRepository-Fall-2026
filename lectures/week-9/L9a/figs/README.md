# L9a figures

`Fig-L9a-Contract-Right-Obligation` is the call and put schematic at the top of
the lecture's "Call and Put Options Contracts" section. It is a minimal TikZ
remake of the instructor's 2024 raster figure, which is archived in
`lectures/archive/week-8-L8b-options-2026-10-09/week-8/L8b/figs/`. It shows
only the actors and the cash flows: the premium is always paid, and the shares
move only if the buyer exercises.
`Fig-L9a-Option-CashFlows` is the option cash-flow timeline that opens "Options
as Abstract Assets". It is modeled on L2a's T-bill timeline.

`make` builds each figure's PDF with XeLaTeX and converts it to SVG with
`pdf2svg`. The SVG build also runs `theme_svg.py`, which adds a dark screen
palette in a `<style>` block keyed on the light colors. The notebook's image
block passes VS Code's selected theme to the SVG, so changing the editor theme
repaints the figure. Outside VS Code the image follows the viewer's color
scheme, and print uses the light palette. If the TikZ palette changes, update
the color map in `theme_svg.py`. An unmapped color fails the build on purpose.
The white fill of the time-point units maps to VS Code's default dark editor
background.

The slides include the PDFs, which keep the light palette (XeLaTeX cannot
include SVG directly).
