# Build the L14a figures to PDF (for slides), themed SVG (for the notebook), and PNG (preview).
# Each figure shares schematic-style.tex, a copy of the L13a style (week-12 schematics).

FIGURES := Fig-L14a-EWLS-JPM Fig-L14a-Gamma-Picks Fig-L14a-PaperTrading-Schematic

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PDFTOPPM ?= pdftoppm
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := schematic-style.tex

.PHONY: all clean
.DEFAULT_GOAL := all

all: $(addsuffix .pdf,$(FIGURES)) $(addsuffix .svg,$(FIGURES)) $(addsuffix .png,$(FIGURES))

%.pdf: %.tex $(STYLE)
	$(XELATEX) $(LATEX_FLAGS) $<

# PDF conversion traces glyphs to paths, so the notebook SVG needs no fonts.
# theme_svg.py then adds the dark screen palette; the PDF keeps the light palette.
%.svg: %.pdf theme_svg.py
	$(PDF2SVG) $< $@
	$(PYTHON) theme_svg.py $@

%.png: %.pdf
	$(PDFTOPPM) -png -scale-to 2200 -singlefile $< $(@:.png=)

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

.PRECIOUS: %.pdf
.DELETE_ON_ERROR:
