# Nomenclature and worked explanations

The [notebook](CHEME-5660-Nomenclature-Fall-2026.ipynb) and
[PDF](CHEME-5660-Nomenclature-Fall-2026.pdf) cover the main lectures through L6b.
The notebook contains only Markdown cells and can be read without a Julia kernel.

The September 29 revision connects the notation to the engagement-survey questions
and follows lecture order from L1b to L6b. Start with the question guide. The five
worked explanations address volatility clustering (L3a), forecasting versus pricing
(L3b), mean growth versus drift and model purpose and limits (L4b), and correlated
shocks (L5b). The GBM target-probability application follows the GBM explanation
and precedes the regression-uncertainty discussion.
Each includes a changed-example check and its answer. The lecture tables retain
their lookup role, and the remaining displayed equations now have a purpose,
explanatory steps, and an interpretation.

The [independent Claude review and revision record](../instructor/NOMENCLATURE-CLARITY-REVIEW-2026-09-29.md)
preserves both assessments, the changes they prompted, and the separate source
and rendering checks.

## Updating the reference

Edit the notebook as the course introduces symbols. Add the meaning, units,
and lecture context; retain separate entries when a symbol is reused. For each
displayed equation, explain the question it answers, the inputs, the key operation,
and what its output means. Numerical examples should identify their assumptions.
Update
the coverage and date in the notebook metadata and opening cell, and the matching
PDF footer in `build_pdf.py`. Regenerate the PDF with Python 3, Pandoc, and pdfLaTeX:

```sh
python3 lectures/reference/build_pdf.py
```

PDF page breaks before notation-table cells are stored in the cells' metadata;
they do not add visible TeX commands to the notebook. Explicit HTML anchors keep
the question guide's links usable in notebook renderers, while the PDF uses
Pandoc's matching heading destinations.

## Reusing course figures

Use only figures and schematics already present in the course lectures or examples.
The volatility-clustering figure is an unmodified copy of
`lectures/week-3/L3a/figs/Fig-L3a-AMD-Volatility-Clustering`:
the notebook uses the lecture SVG and the PDF builder uses the matching lecture
PDF. Both show SPY and AMD growth rates, the March-2020 cluster, and the isolated
April-2016 AMD jump. Source paths and hashes are recorded in
`figs/figure-provenance.json`. If the lecture figure changes, refresh both copies
and the hashes; do not redraw it for this reference.

Inspect the rendered PDF after regenerating it. The notebook is the maintained
source; the PDF is its posting copy. `nomenclature-sources.json` records the lecture
files and hashes used for the initial reference. Refresh it when reviewing new
lecture content. The September 29 explanatory revision checked those hashes
against the current lectures and corrected the SIM residual-variance bound from
`K` to the lecture's `bar(sigma)^2` notation.

This reference is distributed separately from the versioned weekly bundles.
Existing release assets remain unchanged. The course README uses repository URLs
so its reference links also work from an extracted weekly bundle once published.
