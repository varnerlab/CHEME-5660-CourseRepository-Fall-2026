# L9a before the October 2026 redesign

L9a was rebuilt as "Introduction to Derivatives and European Option Pricing"
after options moved out of L8b. The design and its steps are in
`lectures/instructor/L9a-REDESIGN-SPEC.md` and `L9a-REDESIGN-PLAN.md`. This
snapshot holds the files the rebuild replaced. `SHA256SUMS` records them.

| File | Status |
| --- | --- |
| `CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb` | Retired. The new lecture is assembled from the instructor's Fall-2025 text. This lecture linked the SPXW volatility-skew advanced notebook. The new lecture does not. |
| `slides/` | The pre-redesign deck. Its BSM, risk-neutral, and parity frames are a source for the rebuilt deck. |
| `figs/` | Three figures that nothing in week 9 referenced. L9b keeps its own Hull PNG, and L3b and L4a keep their own lattice SVG. |

The instructor asked that cut material not move into a later week. To reuse a
file, move it out with `git mv` rather than editing it here.
