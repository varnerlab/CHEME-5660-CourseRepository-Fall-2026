# Build standalone L1b figures to PDF (for the notes) and SVG (for the notebooks).
#
#   make          build every figure in both formats
#   make pdf      PDF only
#   make svg      SVG only
#   make clean    remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG
#
# Note: the notes do NOT include the generated PDF. ../docs/Style-Specimen.tex
# \inputs abstract-asset-timeline.tex directly, so the notes and the notebook
# SVG are produced from one source and cannot drift apart.

FIGURES := Fig-L1b-AbstractAsset-Timeline

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := vnfigure.sty
SHARED := abstract-asset-timeline.tex

.PHONY: all pdf svg clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

%.pdf: %.tex $(STYLE) $(SHARED)
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
