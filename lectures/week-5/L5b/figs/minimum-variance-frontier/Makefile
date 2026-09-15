# Both vector exports come from the same TikZ source. No raster export.
XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

.DEFAULT_GOAL := all
.PHONY: all clean

all: frontier.pdf frontier.svg

frontier.pdf: frontier.tex ../../../../templates/vnflow.sty
	mkdir -p .build
	$(XELATEX) $(LATEX_FLAGS) -output-directory=.build frontier.tex
	cp .build/frontier.pdf $@

frontier.svg: frontier.pdf svg-metadata.py
	$(PDF2SVG) $< $@
	$(PYTHON) svg-metadata.py $@

clean:
	$(RM) -r .build
