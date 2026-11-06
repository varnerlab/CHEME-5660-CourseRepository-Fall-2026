# L12b figures

`Fig-L12b-RuleSwitch` shows the one-entry policy change at the center of the
rule-switch example: a trader with three Buy neighbors and one Hold neighbor
(neighbor sum c = 1) returns Buy under Rule 19280 and Sell under Rule 19286,
and the two nine-entry lookup tables differ only in the c = 1 column. Colors
are the paper's Buy blue, Hold gray, Sell orange, and highlight yellow.

`make` builds the PDF and PNG (light palette, for the deck) and the SVG (for
the notebook) with XeLaTeX, `pdf2svg`, and `pdftoppm`. The SVG build runs
`theme_svg.py`, which adds a dark screen palette in a `<style>` block keyed on
the light colors, so the notebook figure follows the viewer's color scheme.
If the TikZ palette changes, update the mapping in `theme_svg.py`; an unmapped
color fails the build on purpose. The other files in this folder are older
figures and are not built by the Makefile.
