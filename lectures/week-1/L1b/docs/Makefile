EXTRA_DEPS := Style-Specimen.tex
include ../../../templates/lecture.mk

.PHONY: specimen

specimen: Style-Specimen.pdf

Style-Specimen.pdf: Style-Specimen.tex varnernotes.sty \
	../../../templates/varnernotes.sty
	$(LATEXMK) -xelatex $(LATEX_FLAGS) Style-Specimen.tex
