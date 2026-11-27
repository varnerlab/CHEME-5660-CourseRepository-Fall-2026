# Builds one short deck per strategy rule: every CHEME-5660-L15a-Strategy-*.tex in this folder.
TEXFILES := $(wildcard CHEME-5660-L15a-Strategy-*.tex)
PDFS := $(TEXFILES:.tex=.pdf)

LATEXMK ?= latexmk
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

STYLE := ../../../../templates/vnslides.sty

.DEFAULT_GOAL := slides

.PHONY: slides decks clean distclean

# The figures come first: make in figs/ rebuilds only the figures whose source changed.
slides:
	$(MAKE) -C figs
	$(MAKE) decks

decks: $(PDFS)

# The shared style inputs ../../../templates/ from the working directory, so LaTeX runs from strategies/ (three
# folders below lectures/) and writes the PDFs and build files here. Paths in the decks are relative to strategies/.
$(PDFS): %.pdf: %.tex vnslides.sty $(STYLE) $(wildcard figs/Fig-L15a-Deck-*.pdf)
	cd .. && TEXINPUTS=slides: $(LATEXMK) -xelatex $(LATEX_FLAGS) -outdir=slides slides/$<

clean:
	$(MAKE) -C figs clean
	cd .. && for f in $(TEXFILES); do $(LATEXMK) -c -outdir=slides slides/$$f; done
	$(RM) *.nav *.snm *.vrb *.xdv

distclean: clean
	$(RM) $(PDFS)
