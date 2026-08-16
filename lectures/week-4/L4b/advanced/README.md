# L4b optional advanced material

These standalone notebooks extend the L4b discussion of geometric Brownian
motion. They are optional and are not prerequisites for L5a.

- [`lattice-limit/CHEME-5660-L4b-Advanced-LatticeToGBM-Fall-2026.ipynb`](lattice-limit/CHEME-5660-L4b-Advanced-LatticeToGBM-Fall-2026.ipynb)
  calibrates the binomial lattice of L3b and L4a to the GBM drift and volatility
  and shows the terminal distribution, and the L4a binomial-tail target
  probability, converging to the lognormal and to the L4b closed form.
- [`first-passage/CHEME-5660-L4b-Advanced-FirstPassage-GBM-Fall-2026.ipynb`](first-passage/CHEME-5660-L4b-Advanced-FirstPassage-GBM-Fall-2026.ipynb)
  computes take-profit and stop-loss first-passage probabilities under GBM
  (closed form for one barrier, the L4a absorbing recursion and Monte Carlo for
  two) and quantifies the effect of the monitoring frequency.
- [`drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb`](drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb)
  shows that the drift estimate depends on the calendar span of the data and
  not on the sampling frequency, and propagates that uncertainty into the
  target probability.
- [`monte-carlo/CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb`](monte-carlo/CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb)
  estimates the target probability by simulation with standard errors, compares
  the exact one-step transition with the Euler scheme, and reduces variance
  with antithetic variates.

The lattice-limit notebook extends the model, the first-passage notebook
extends the trade rule, the drift-uncertainty notebook extends the estimation,
and the Monte Carlo notebook extends the computation. They can be completed
independently; the suggested order is the order listed.
