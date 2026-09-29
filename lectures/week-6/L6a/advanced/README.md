# L6a optional advanced material

These optional notebooks develop the portfolio-weight derivations and frontier
geometry. None is a prerequisite for L6a.

- [`gmv-derivation/CHEME-5660-L6a-Derivation-GMV-Fall-2026.ipynb`](gmv-derivation/CHEME-5660-L6a-Derivation-GMV-Fall-2026.ipynb)
  gives the full Lagrange-multiplier derivation of the short-allowed GMV weights
  and minimum variance, extending the lecture's brief calculation.
- [Minimum-variance weights at an exact growth target](target-growth-derivation/CHEME-5660-L6a-Derivation-TargetGrowth-Fall-2026.ipynb).
  How does a required growth rate change the GMV calculation? We introduce a
  second Lagrange multiplier, solve the budget and growth constraints together,
  and derive the weights and minimum variance. Recovering GMV as a special case
  explains why any different exact target requires additional variance.
- [`frontier-geometry/CHEME-5660-L6a-Advanced-FrontierGeometry-Fall-2026.ipynb`](frontier-geometry/CHEME-5660-L6a-Advanced-FrontierGeometry-Fall-2026.ipynb)
  derives the closed-form frontier for every target growth rate and checks it
  against a numerical solver. It shows that every unconstrained frontier
  portfolio combines two fixed frontier portfolios (the two-fund theorem). It
  measures what a position cap and a long-only constraint cost in risk for this
  dataset.

Begin with the GMV derivation, then the exact-growth derivation, followed by the
frontier-geometry example.
