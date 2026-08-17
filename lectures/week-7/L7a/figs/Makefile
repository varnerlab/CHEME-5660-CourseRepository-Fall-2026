# Build standalone L7a figures to PDF (for notes), SVG (for notebooks), and PNG (for the deck).

FIGURES := Fig-L7a-Rebalancing-Engine-Loop

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))
PNGS := $(addsuffix .png,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PDFTOPPM ?= pdftoppm
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := vnfigure.sty

.PHONY: all pdf svg png clean distclean
.DEFAULT_GOAL := all

all: pdf svg png

pdf: $(PDFS)
svg: $(SVGS)
png: $(PNGS)

%.pdf: %.tex $(STYLE)
	$(XELATEX) $(LATEX_FLAGS) $<

# PDF conversion traces glyphs to paths, so the notebook SVG needs no fonts.
%.svg: %.pdf
	$(PDF2SVG) $< $@

%.png: %.pdf
	$(PDFTOPPM) -png -r 220 -singlefile $< $(basename $@)

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

distclean: clean
	$(RM) $(PDFS) $(SVGS) $(PNGS)

.PRECIOUS: %.pdf
