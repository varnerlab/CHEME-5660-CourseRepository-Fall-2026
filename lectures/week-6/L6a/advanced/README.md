# L6a optional advanced material

This standalone notebook extends the L6a treatment of single index models beyond
the least-squares estimation and classical uncertainty of the lecture. It is
optional and is not a prerequisite for L6b.

- [`sim/CHEME-5660-L6a-Advanced-SIM-Theory-Fall-2026.ipynb`](sim/CHEME-5660-L6a-Advanced-SIM-Theory-Fall-2026.ipynb)
  derives the ridge (regularized) estimator and its model-based covariance with
  the caveats regularization brings, distinguishes the empirical-residual and
  Gaussian parametric bootstraps, keeps the growth-rate, log-return, and
  volatility conventions of a SIM covariance straight, propagates parameter
  uncertainty into portfolio risk and weights, and writes the long-only
  maximum-Sharpe allocation as a second-order cone program.

The notebook is theory only (no code); the executable counterparts are the two
L6a examples and the L6b optional advanced propagation notebook
(`../../L6b/advanced/uncertainty/`).
