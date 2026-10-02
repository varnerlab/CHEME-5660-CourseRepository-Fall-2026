# Both vector exports come from the same TikZ source.
XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

.DEFAULT_GOAL := all
.PHONY: all clean

all: cal.pdf cal.svg

cal.pdf: cal.tex ../../../../templates/vnflow.sty
	mkdir -p .build
	$(XELATEX) $(LATEX_FLAGS) -output-directory=.build cal.tex
	cp .build/cal.pdf $@

cal.svg: cal.pdf svg-metadata.py
	$(PDF2SVG) $< $@
	$(PYTHON) svg-metadata.py $@

clean:
	$(RM) -r .build
