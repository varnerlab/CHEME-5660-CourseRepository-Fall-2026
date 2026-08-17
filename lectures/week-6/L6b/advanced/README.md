# L6b optional advanced material

This standalone notebook extends the L6b treatment of single index model
portfolio allocation. It is optional and is not a prerequisite for L7b.

- [`uncertainty/CHEME-5660-L6b-Advanced-SIM-Portfolio-Uncertainty-Fall-2026.ipynb`](uncertainty/CHEME-5660-L6b-Advanced-SIM-Portfolio-Uncertainty-Fall-2026.ipynb)
  bootstraps the SIM parameters of a six-firm universe two ways (empirical
  residuals and Gaussian innovations), keeps each asset's joint draw of
  intercept, beta, and residual scale, rebuilds the SIM covariance for every
  draw, and reads the resulting distributions of a fixed unconstrained
  minimum-variance portfolio's growth-rate standard deviation, its allocation
  distance from the scenario-optimal weights, and its variance regret.

It is the executable counterpart of the propagation section of the L6a advanced
theory notebook (`../../L6a/advanced/sim/`); the L6b examples supply the
constrained allocation problems it deliberately leaves aside.
