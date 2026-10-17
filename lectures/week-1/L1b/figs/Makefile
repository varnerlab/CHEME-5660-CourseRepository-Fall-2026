# Build standalone L1b figures to PDF (for the notes) and SVG (for the notebooks).
#
#   make          build every figure in both formats
#   make pdf      PDF only
#   make svg      SVG only
#   make clean    remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG
#
# The standalone wrapper produces the PDF/SVG used by the notebook and slides.

FIGURES := Fig-L1b-AbstractAsset-Timeline

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := vnfigure.sty
SHARED := abstract-asset-timeline.tex

.PHONY: all pdf svg clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

%.pdf: %.tex $(STYLE) $(SHARED)
	$(XELATEX) $(LATEX_FLAGS) $<

# Convert from the PDF rather than XeLaTeX's .xdv: dvisvgm cannot interpret the
# xdvipdfmx graphics specials that PGF emits under XeLaTeX, and silently drops
# every TikZ path. pdf2svg traces glyphs to paths, so the SVG needs no fonts.
# theme_svg.py then adds the dark screen palette the lecture notebook relies on.
# The PDF keeps the light palette for the notes and slides.
%.svg: %.pdf theme_svg.py
	$(PDF2SVG) $< $@
	$(PYTHON) theme_svg.py $@

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

distclean: clean
	$(RM) $(PDFS) $(SVGS)

.PRECIOUS: %.pdf
# A failed theme step must not leave an unthemed SVG that later looks current.
.DELETE_ON_ERROR:
