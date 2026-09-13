TEXFILE := CHEME-5660-L4a-Slides-Fall-2026.tex
PDF := $(TEXFILE:.tex=.pdf)
STEM := $(basename $(TEXFILE))

LATEXMK ?= latexmk
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
RSVG_CONVERT ?= rsvg-convert

STYLE := ../../../templates/vnslides.sty
FIGURES := ../figs/Fig-Lattice-Schematic.pdf \
	../figs/Fig-TradeRule-Schematic.pdf

.DEFAULT_GOAL := slides

.PHONY: slides clean distclean

slides: $(PDF)

$(PDF): $(TEXFILE) vnslides.sty $(STYLE) $(FIGURES)
	$(LATEXMK) -xelatex $(LATEX_FLAGS) $(TEXFILE)

# Use the same NPV illustration as the lecture notebook.
../figs/Fig-TradeRule-Schematic.pdf: ../figs/Fig-TradeRule-Schematic.svg
	$(RSVG_CONVERT) --format=pdf --output=$@ $<

clean:
	$(LATEXMK) -c $(TEXFILE)
	$(RM) $(STEM).nav $(STEM).snm $(STEM).vrb

distclean: clean
	$(RM) $(PDF)
