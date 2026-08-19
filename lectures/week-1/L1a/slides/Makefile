TEXFILE := CHEME-5660-L1a-Slides-Fall-2026.tex
PDF := $(TEXFILE:.tex=.pdf)
STEM := $(basename $(TEXFILE))

LATEXMK ?= latexmk
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

STYLE := ../../../templates/vnslides.sty
FIGURES := ../figs/course-map.tex ../figs/validation-ladder.tex

.DEFAULT_GOAL := slides

.PHONY: slides clean distclean

slides: $(PDF)

$(PDF): $(TEXFILE) vnslides.sty $(STYLE) $(FIGURES)
	$(LATEXMK) -xelatex $(LATEX_FLAGS) $(TEXFILE)

clean:
	$(LATEXMK) -c $(TEXFILE)
	$(RM) $(STEM).nav $(STEM).snm $(STEM).vrb

distclean: clean
	$(RM) $(PDF)
