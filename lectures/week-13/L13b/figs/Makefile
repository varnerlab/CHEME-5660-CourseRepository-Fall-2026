# Build the L13b figures (market state, forecast band, real-data dot plot, synthetic-market dot plots) with XeLaTeX
# to PDF (deck), SVG (notebook), and PNG. The PNG is rendered from the light PDF.

FIGURES := Fig-L13b-MarketState Fig-L13b-ForecastBand Fig-L13b-RealData-Selection Fig-L13b-Synthetic-Sets

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))
PNGS := $(addsuffix .png,$(FIGURES))

LATEX ?= xelatex
PDF2SVG ?= pdf2svg
PDFTOPPM ?= pdftoppm
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

# Every figure is redrawn when the style, a drawing file from the talk, or a data file changes.
SOURCES := vntalkfigure.sty vnsf.tex market_state.tex mpc.tex dotplot.tex $(wildcard data/*.csv)

.PHONY: all pdf svg png clean distclean
.DEFAULT_GOAL := all

all: pdf svg png

pdf: $(PDFS)
svg: $(SVGS)
png: $(PNGS)

%.pdf: %.tex $(SOURCES)
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
