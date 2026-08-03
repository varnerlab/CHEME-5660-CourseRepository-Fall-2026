# Shared build rules for CHEME 5660 lecture notes.

TEXFILE ?= Notes.tex
PDF := $(TEXFILE:.tex=.pdf)
LATEXMK ?= latexmk
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE ?= ../../../templates/varnernotes.sty
EXTRA_DEPS ?=

.DEFAULT_GOAL := notes

.PHONY: notes clean

notes: $(PDF)

$(PDF): $(TEXFILE) varnernotes.sty $(STYLE) $(EXTRA_DEPS)
	$(LATEXMK) -xelatex $(LATEX_FLAGS) $(TEXFILE)

clean:
	$(LATEXMK) -c $(TEXFILE)
