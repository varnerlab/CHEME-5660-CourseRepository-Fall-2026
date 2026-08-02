#!/bin/sh

# Clear out junk
rm -f *aux

# Tex this mofo -
pdflatex Notes.tex
bibtex Notes
pdflatex Notes.tex
makeindex Notes
pdflatex Notes.tex
bibtex Notes
pdflatex Notes.tex