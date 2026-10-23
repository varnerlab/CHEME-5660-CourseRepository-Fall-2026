# Build the L10b profit diagrams: a PDF from each TikZ source (for the deck),
# then the themed notebook SVG. Requires XeLaTeX, pdf2svg, and Python 3
# (standard library).
#
#   make            build every figure in both formats
#   make pdf        PDF only
#   make svg        SVG only
#   make clean      remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG

FIGURES := Fig-L10b-Short-Put-Call Fig-L10b-Credit-Spreads \
           Fig-L10b-Straddle-Strangle Fig-L10b-Protected-Condor \
           Fig-L10b-Strangle-Time-Decay

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

# The time-decay figure draws computed curves. Rebuild the coordinates with
#   julia generate-strangle-time-decay.jl
# (about 3 s); the generated file is kept in the repository so make needs no Julia.
Fig-L10b-Strangle-Time-Decay.pdf: Fig-L10b-Strangle-Time-Decay-coords.tex

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
