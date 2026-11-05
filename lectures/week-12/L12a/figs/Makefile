# Build the L12a schematics: a PDF from each TikZ source (for the deck), then the
# themed notebook SVG. Requires XeLaTeX, pdf2svg, and Python 3 (standard library).
# Same pipeline as L11b/figs.
#
#   make            build every figure in both formats
#   make clean      remove LaTeX intermediates

FIGURES := Fig-L12a-MinorityGame Fig-L12a-FarmerJoshi

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

%.pdf: %.tex abm-diagram.tex Makefile
	$(XELATEX) $(LATEX_FLAGS) $<

%.svg: %.pdf theme_svg.py
	$(PDF2SVG) $< $@
	$(PYTHON) theme_svg.py $@

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

distclean: clean
	$(RM) $(PDFS) $(SVGS)

.PRECIOUS: %.pdf
.DELETE_ON_ERROR:
