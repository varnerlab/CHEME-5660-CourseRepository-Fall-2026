# Build the L15a figures to PDF (for slides), themed SVG (for the notebook), and PNG (preview).
# Each figure shares schematic-style.tex, a copy of the L13a style (week-12 schematics).

FIGURES := Fig-L15a-EWLS-JPM Fig-L15a-Gamma-Picks Fig-L15a-Market-Hedge Fig-L15a-BAB-Tilt Fig-L15a-Backtest-Day Fig-L15a-Stress-Test

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

# The made-up paths of the stress-test schematic come from stress_paths.py (a fixed-seed draw).
Fig-L15a-Stress-Test-paths.tex: stress_paths.py
	$(PYTHON) stress_paths.py

Fig-L15a-Stress-Test.pdf: Fig-L15a-Stress-Test-paths.tex

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
