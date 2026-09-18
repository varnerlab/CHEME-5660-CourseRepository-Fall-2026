TEXFILE := CHEME-5660-L5b-Slides-Fall-2026.tex
PDF := $(TEXFILE:.tex=.pdf)
STEM := $(basename $(TEXFILE))

LATEXMK ?= latexmk
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

STYLE := ../../../templates/vnslides.sty
FRONTIER_DIR := ../figs/minimum-variance-frontier
FRONTIER_PDF := $(FRONTIER_DIR)/frontier.pdf
CAL_DIR := ../figs/capital-allocation-line
CAL_PDF := $(CAL_DIR)/cal.pdf
FIGURES := $(FRONTIER_PDF) $(CAL_PDF)

.DEFAULT_GOAL := slides

.PHONY: slides clean distclean

slides: $(PDF)

$(PDF): $(TEXFILE) vnslides.sty $(STYLE) $(FIGURES)
	$(LATEXMK) -xelatex $(LATEX_FLAGS) $(TEXFILE)

$(FRONTIER_PDF): $(FRONTIER_DIR)/frontier.tex $(FRONTIER_DIR)/Makefile ../../../templates/vnflow.sty
	$(MAKE) -C $(FRONTIER_DIR) all

$(CAL_PDF): $(CAL_DIR)/cal.tex $(CAL_DIR)/Makefile ../../../templates/vnflow.sty
	$(MAKE) -C $(CAL_DIR) all

clean:
	$(LATEXMK) -c $(TEXFILE)
	$(RM) $(STEM).nav $(STEM).snm $(STEM).vrb

distclean: clean
	$(RM) $(PDF)
