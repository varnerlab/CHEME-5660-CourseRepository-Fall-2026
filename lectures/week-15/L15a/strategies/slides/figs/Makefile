# Builds the strategy-deck figures to PDF for the decks.
# make_deck_figures.py writes every Fig-L15a-Deck-*.tex; each figure \inputs ../../../figs/schematic-style.tex.

PYTHON ?= python3
XELATEX ?= xelatex
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := ../../../figs/schematic-style.tex

.DEFAULT_GOAL := all
.PHONY: all tex pdfs clean

# the script rewrites a .tex file only when its text changes
tex: make_deck_figures.py
	$(PYTHON) make_deck_figures.py

all: tex
	$(MAKE) pdfs

FIGURES = $(basename $(wildcard Fig-L15a-Deck-*.tex))
pdfs: $(addsuffix .pdf,$(FIGURES))

%.pdf: %.tex $(STYLE)
	$(XELATEX) $(LATEX_FLAGS) $<

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

.PRECIOUS: %.pdf
.DELETE_ON_ERROR:
