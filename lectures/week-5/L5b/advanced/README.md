# L5b optional advanced material

These standalone notebooks extend the L5b discussion of minimum-variance
portfolios, the efficient frontier, and the tangent portfolio. They are optional
and are not prerequisites for L6a.

- [`frontier-geometry/CHEME-5660-L5b-Advanced-FrontierGeometry-Fall-2026.ipynb`](frontier-geometry/CHEME-5660-L5b-Advanced-FrontierGeometry-Fall-2026.ipynb)
  derives the closed-form frontier for every target growth rate, checks it
  against a numerical solver, shows that every unconstrained frontier portfolio
  is a combination of two fixed frontier portfolios (the two-fund theorem), and
  measures what a short-sale limit and a long-only constraint cost in variance.
- [`estimation-risk/CHEME-5660-L5b-Advanced-EstimationRisk-Fall-2026.ipynb`](estimation-risk/CHEME-5660-L5b-Advanced-EstimationRisk-Fall-2026.ipynb)
  resamples the 2014 to 2024 growth rates to measure how far the frontier, the
  minimum-variance weights, and the tangent weights move under sampling error,
  attributes the tangent portfolio's instability to the mean growth rates, and
  pushes every resampled portfolio through 2025.

The geometry notebook is about what the optimizer can reach; the estimation
notebook is about how much of that reach is real. They can be completed
independently; the suggested order is the order listed.
