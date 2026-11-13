# Build standalone L13a figures to PDF (for slides) and SVG (for notebooks).
# Both figures share the style file jumphmm-diagram.tex (the week-12 schematic style).

FIGURES := Fig-L13a-JumpHMM-Schematic Fig-L13a-JumpHMM-Fit-Schematic

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := jumphmm-diagram.tex

.PHONY: all pdf svg clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

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
