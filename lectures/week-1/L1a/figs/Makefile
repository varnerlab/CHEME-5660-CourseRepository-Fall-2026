# Build standalone L1a figures.
#
#   make          build every figure in both formats
#   make pdf      PDF only
#   make svg      SVG only
#   make clean    remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG
#
# The TikZ figures are built to PDF and SVG for reuse, while the two numerical
# previews are generated directly as vector PDFs from packaged course data.

FIGURES := Fig-L1a-CourseMap Fig-L1a-ValidationLadder Fig-L1a-DecisionLoop
NUMERICAL_PDFS := Fig-L1a-PortfolioPreview.pdf Fig-L1a-PayoffPreview.pdf

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
JULIA ?= julia
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
# vnfigure.sty here is the three-line wrapper; the canonical styles it pulls in
# live in lectures/templates and are real inputs, so they are prerequisites too.
# Omitting them let a template edit leave every figure PDF and SVG stale.
STYLE := vnfigure.sty ../../../templates/vnfigure.sty ../../../templates/vnflow.sty
SHARED := course-map.tex validation-ladder.tex decision-loop.tex

.PHONY: all pdf svg numerical clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)
numerical:
	$(JULIA) --project=../../../.. generate-numerical-previews.jl
	test -s Fig-L1a-PortfolioPreview.pdf
	test -s Fig-L1a-PayoffPreview.pdf

# Numerical previews are intentionally opt-in. Normal figure and slide builds
# consume the checked-in PDFs without starting Julia.

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
	$(RM) $(PDFS) $(SVGS) $(NUMERICAL_PDFS)

.PRECIOUS: %.pdf
