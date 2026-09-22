# Build standalone L5b figures to PDF (for notes) and SVG (for notebooks).

FIGURES := Fig-L5b-Covariance-Schematic

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := vnfigure.sty ../../../templates/vnfigure.sty ../../../templates/vnflow.sty
DATA := $(foreach c,Negative Zero Positive,$(foreach s,Base Scaled,Data-L5b-Cov-$(c)-$(s).csv))
DATA_FIRST := $(firstword $(DATA))

.PHONY: all pdf svg data clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

# Seeded samples plotted by the covariance schematic; regenerated when the
# generator changes. One run writes every CSV, so the first file carries the
# recipe and the rest depend on it.
data: $(DATA)
$(DATA_FIRST): generate_samples.py
	$(PYTHON) generate_samples.py
$(filter-out $(DATA_FIRST),$(DATA)): $(DATA_FIRST)

%.pdf: %.tex $(STYLE) $(DATA)
	$(XELATEX) $(LATEX_FLAGS) $<

# PDF conversion traces glyphs to paths, so the notebook SVG needs no fonts.
# theme_svg.py then adds the dark screen palette the lecture notebook relies on;
# the PDF keeps the light palette for the notes and slides.
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
