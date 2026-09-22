# L5b figures

`Fig-L5b-Covariance-Schematic` is the lecture-notebook covariance schematic:
seeded bivariate normal samples with negative, zero, and positive covariance,
their 1σ and 2σ covariance ellipses, and a second row overlaying a cloud with
four times the covariance. `generate_samples.py` writes the `Data-*.csv`
sample files (`make data`), and `make` builds the PDF and SVG with XeLaTeX
and `pdf2svg`.

The SVG build also runs `theme_svg.py`, which adds a dark screen palette in a
`<style>` block keyed on the light colors. The notebook's image block passes
VS Code's selected theme to the SVG, so changing the editor theme repaints the
figure. Outside VS Code the image follows the viewer's color scheme (JupyterLab
strips the `<style>` block, so its own theme setting is not forwarded), and
print uses the light palette. If the TikZ palette changes, update the color
mapping in `theme_svg.py`; an unmapped color fails the build on purpose. The
white halo under the blue cloud's contour maps to VS Code's default dark
editor background, so it shows as a faint border on other dark themes.

`Fig-Cov-Schematic.png` is the earlier raster version, still used by the slides.
