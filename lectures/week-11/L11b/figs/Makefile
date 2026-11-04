# Build the L11b profit diagrams: a PDF from each TikZ source (for the deck),
# then the themed notebook SVG. Requires XeLaTeX, pdf2svg, and Python 3
# (standard library). Same pipeline as L11a/figs.
#
#   make            build every figure in both formats
#   make pdf        PDF only
#   make svg        SVG only
#   make clean      remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG

FIGURES := Fig-L11b-Covered-Call Fig-L11b-Collar

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

.PHONY: all pdf svg clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

%.pdf: %.tex profit-diagram.tex Makefile
	$(XELATEX) $(LATEX_FLAGS) $<

# PDF conversion traces glyphs to paths, so the notebook SVG needs no fonts.
# theme_svg.py then adds the dark screen palette the lecture notebook relies on;
# the PDF keeps the light palette for the slides.
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
