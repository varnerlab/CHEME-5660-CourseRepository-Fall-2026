# Build standalone L2a figures to PDF (for the notes) and SVG (for the notebooks).
#
#   make          build every figure in both formats
#   make pdf      PDF only
#   make svg      SVG only
#   make clean    remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG

FIGURES := Fig-L2a-TBill-CashFlows Fig-L2a-NoteBond-CashFlows

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := vnfigure.sty

.PHONY: all pdf svg clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

%.pdf: %.tex $(STYLE)
	$(XELATEX) $(LATEX_FLAGS) $<

# Convert from the PDF rather than XeLaTeX's .xdv: dvisvgm cannot interpret the
# xdvipdfmx graphics specials that PGF emits under XeLaTeX, and silently drops
# every TikZ path. pdf2svg traces glyphs to paths, so the SVG needs no fonts.
%.svg: %.pdf
	$(PDF2SVG) $< $@

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

distclean: clean
	$(RM) $(PDFS) $(SVGS)

.PRECIOUS: %.pdf
