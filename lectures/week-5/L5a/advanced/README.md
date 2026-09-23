# L5a optional advanced material

These standalone notebooks extend the L5a discussion of geometric Brownian
motion, parameter estimates, and target probabilities. They are optional and
are not prerequisites for L5b.

- [`ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb`](ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb)
  develops the exponential weights, centered variance update, and conversion
  from growth-rate moments to GBM parameters behind the lecture proposition.
- [`drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb`](drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb)
  shows that the drift estimate depends on the calendar span of the data and
  not on the sampling frequency, and propagates that uncertainty into the
  target probability.
- [`monte-carlo/CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb`](monte-carlo/CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb)
  estimates the target probability by simulation with standard errors, compares
  the exact one-step transition with the Euler scheme, and reduces variance
  with antithetic variates.

The EMA derivation develops the parameter updates, the drift-uncertainty
notebook examines estimation precision, and the Monte Carlo notebook examines
simulation accuracy. They can be completed independently. The latter two
retain their L4b identifiers because they also accompany that lecture.
