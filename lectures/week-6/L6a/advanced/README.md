# L6a optional advanced material

These optional notebooks develop the GMV derivation, frontier geometry, and estimation risk. The
frontier-geometry example extends this lecture. The estimation-risk example
follows the risk-free portfolio material in L6b. None is a prerequisite for L6a.

- [`gmv-derivation/CHEME-5660-L6a-Derivation-GMV-Fall-2026.ipynb`](gmv-derivation/CHEME-5660-L6a-Derivation-GMV-Fall-2026.ipynb)
  gives the full Lagrange-multiplier derivation of the short-allowed GMV weights
  and minimum variance, extending the lecture's brief calculation.
- [`frontier-geometry/CHEME-5660-L6a-Advanced-FrontierGeometry-Fall-2026.ipynb`](frontier-geometry/CHEME-5660-L6a-Advanced-FrontierGeometry-Fall-2026.ipynb)
  derives the closed-form frontier for every target growth rate, checks it
  against a numerical solver, shows that every unconstrained frontier portfolio
  is a combination of two fixed frontier portfolios (the two-fund theorem), and
  measures what a short-sale limit and a long-only constraint cost in variance
  for this dataset.
- [`../../L6b/advanced/estimation-risk/CHEME-5660-L6b-Advanced-EstimationRisk-Fall-2026.ipynb`](../../L6b/advanced/estimation-risk/CHEME-5660-L6b-Advanced-EstimationRisk-Fall-2026.ipynb)
  resamples the 2014 to 2024 growth rates to measure how far the frontier, the
  minimum-variance weights, and the tangent weights move under sampling error,
  attributes the tangent portfolio's instability to the mean growth rates, and
  pushes every resampled portfolio through 2025.

The geometry notebook is about what the optimizer can reach, and the estimation
notebook is about how much of that reach survives re-estimation. Begin with the
GMV derivation, then frontier geometry. Return to estimation risk after the
risk-free portfolio material in L6b.
