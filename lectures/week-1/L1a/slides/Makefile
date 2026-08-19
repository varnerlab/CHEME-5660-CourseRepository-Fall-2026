TEXFILE := CHEME-5660-L1a-Slides-Fall-2026.tex
PDF := $(TEXFILE:.tex=.pdf)
STEM := $(basename $(TEXFILE))

LATEXMK ?= latexmk
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

STYLE := ../../../templates/vnslides.sty
FIGURES := ../figs/course-map.tex ../figs/validation-ladder.tex

.DEFAULT_GOAL := slides

# WHY THE BUILD TARGETS ARE PHONY
#
# latexmk keeps its own content-aware dependency database (.fdb_latexmk) that
# records every file the build actually read -- \input figure bodies, the
# canonical styles three directories up, the Cornell seal asset. Make sees only
# the prerequisites listed here, and only their mtimes.
#
# Those two views disagree in a way that ships stale output. The generated PDF
# is tracked in git, so a checkout, a branch switch, a restored artifact, or a
# timestamp-preserving copy can leave the PDF NEWER than its sources. Make then
# declares it current and never invokes latexmk at all, so latexmk's better
# information is never consulted. That is not hypothetical: on 2026-08-19 the
# deck was shown with superseded figures because of exactly this.
#
# So: always invoke latexmk and let IT decide whether work is needed. The cost
# is one fast no-op call per `make`; the alternative is silently shipping a deck
# that does not match its source.
.PHONY: slides clean distclean $(PDF)

slides: $(PDF)

$(PDF): $(TEXFILE) vnslides.sty $(STYLE) $(FIGURES)
	$(LATEXMK) -xelatex $(LATEX_FLAGS) $(TEXFILE)

clean:
	$(LATEXMK) -c $(TEXFILE)
	$(RM) $(STEM).nav $(STEM).snm $(STEM).vrb

distclean: clean
	$(RM) $(PDF)
