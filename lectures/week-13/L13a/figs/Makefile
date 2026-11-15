# Build standalone L13a figures to PDF (for slides) and SVG (for notebooks).
# TikZ figures share jumphmm-diagram.tex (the week-12 schematic style).

FIGURES := Fig-L13a-JumpHMM-Schematic Fig-L13a-JumpHMM-Fit-Schematic Fig-L13a-Episode-Shape Fig-L13a-Wolfram-Markets Fig-L13a-Wolfram-Rules

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDFLATEX ?= pdflatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
JULIA ?= julia
PDFTOPPM ?= pdftoppm
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := jumphmm-diagram.tex

.PHONY: all pdf svg clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

# The review figure uses actual L12b simulations. Recompute its data explicitly
# with `make wolfram-data`; ordinary figure builds only redraw the saved frames.
.PHONY: wolfram-data
wolfram-data:
	cd ../../../.. && $(JULIA) --project=. lectures/week-13/L13a/figs/Fig-L13a-Wolfram-Markets-Data.jl

Fig-L13a-Wolfram-Markets.pdf: generate-wolfram-markets.py Fig-L13a-Wolfram-Markets-Data.json
	$(PYTHON) generate-wolfram-markets.py

Fig-L13a-Wolfram-Markets.svg Fig-L13a-Wolfram-Markets.png: Fig-L13a-Wolfram-Markets.pdf
	@test -f "$@" || $(PYTHON) generate-wolfram-markets.py

Fig-L13a-Wolfram-Rules.png: Fig-L13a-Wolfram-Rules.pdf
	$(PDFTOPPM) -png -scale-to 2200 -singlefile $< $(@:.png=)

# Match the L12b rule-switch drawing's original font and TeX engine.
Fig-L13a-Wolfram-Rules.pdf: Fig-L13a-Wolfram-Rules.tex
	$(PDFLATEX) $(LATEX_FLAGS) $<

%.pdf: %.tex $(STYLE)
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
