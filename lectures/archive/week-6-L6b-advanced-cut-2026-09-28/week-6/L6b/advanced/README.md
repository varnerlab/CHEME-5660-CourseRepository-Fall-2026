# L6b optional advanced material

These notebooks extend the L6b lecture. They are optional and are not
prerequisites for Week 7. A suggested order:

1. [SIM estimation theory](sim/CHEME-5660-L6b-Advanced-SIM-Theory-Fall-2026.ipynb):
   ridge estimation and its covariance, the two bootstraps, unit conventions,
   propagating parameter uncertainty into portfolios, and the maximum-Sharpe
   problem as a second-order cone program. Start here for the theory.
2. [Residual diagnostics and two bootstrap methods](diagnostics/CHEME-5660-L6b-Advanced-SIM-Diagnostics-Fall-2026.ipynb):
   empirical-residual and Gaussian bootstraps against the classical standard
   errors, residual tail and autocorrelation diagnostics, and
   autocorrelation-consistent standard errors.
3. [SIM parameter uncertainty in portfolios](uncertainty/CHEME-5660-L6b-Advanced-SIM-Portfolio-Uncertainty-Fall-2026.ipynb):
   joint bootstrap draws of each asset's SIM parameters, the SIM covariance
   rebuilt for every draw, and the resulting spread in a fixed minimum-variance
   portfolio's risk, allocation distance, and variance regret. It is the
   executable counterpart of the propagation section of the theory notebook.
4. [Estimation risk in portfolio weights](estimation-risk/CHEME-5660-L6b-Advanced-EstimationRisk-Fall-2026.ipynb):
   resampled growth observations, re-estimated inputs, and the resulting GMV
   and tangent allocations, evaluated on 2025 prices.
5. [Data-driven portfolios with a risk-free asset](data-risk-free/CHEME-5660-L6b-Advanced-Data-MinVar-RiskFree-Fall-2026.ipynb):
   the long-only frontier, approximate tangent portfolio, and capital
   allocation line from sample estimates, for comparison with the SIM examples.
