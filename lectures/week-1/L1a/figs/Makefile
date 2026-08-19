# Build standalone L1a figures to PDF and SVG.
#
#   make          build every figure in both formats
#   make pdf      PDF only
#   make svg      SVG only
#   make clean    remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG
#
# Note: the deck does NOT include the generated PDF. It \inputs the body files
# (course-map.tex, validation-ladder.tex) directly, so the deck and the SVG are
# produced from one source and cannot drift apart.

FIGURES := Fig-L1a-CourseMap Fig-L1a-ValidationLadder

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
# vnfigure.sty here is the three-line wrapper; the canonical styles it pulls in
# live in lectures/templates and are real inputs, so they are prerequisites too.
# Omitting them let a template edit leave every figure PDF and SVG stale.
STYLE := vnfigure.sty ../../../templates/vnfigure.sty ../../../templates/vnflow.sty
SHARED := course-map.tex validation-ladder.tex

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
