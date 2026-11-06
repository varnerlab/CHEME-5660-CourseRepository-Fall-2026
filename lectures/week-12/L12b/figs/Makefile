# Build the L12b figures (rule switch, crash timeline) with pdflatex to PDF (deck) and SVG (notebook).
# The deck PNG is rendered from the light PDF.

FIGURES := Fig-L12b-RuleSwitch Fig-L12b-CrashTimeline

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))
PNGS := $(addsuffix .png,$(FIGURES))

LATEX ?= pdflatex
PDF2SVG ?= pdf2svg
PDFTOPPM ?= pdftoppm
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := vnfigure.sty ../../../templates/vnfigure.sty ../../../templates/vnflow.sty

.PHONY: all pdf svg png clean distclean
.DEFAULT_GOAL := all

all: pdf svg png

pdf: $(PDFS)
svg: $(SVGS)
png: $(PNGS)

%.pdf: %.tex
	$(LATEX) $(LATEX_FLAGS) $<

# PDF conversion traces glyphs to paths, so the notebook SVG needs no fonts.
# theme_svg.py then adds the dark screen palette; the PDF keeps the light one.
%.svg: %.pdf theme_svg.py
	$(PDF2SVG) $< $@
	$(PYTHON) theme_svg.py $@

%.png: %.pdf
	$(PDFTOPPM) -png -r 300 -singlefile $< $*

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

distclean: clean
	$(RM) $(PDFS) $(SVGS) $(PNGS)

.PRECIOUS: %.pdf
.DELETE_ON_ERROR:
