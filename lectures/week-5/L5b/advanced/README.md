# L5b optional advanced material

These standalone notebooks extend the L5b discussion of multiple asset GBM and
the covariance matrix. They are optional and are not prerequisites for L6a.

- [`ito-derivation/CHEME-5660-L5b-Derivation-MAGBM-Solution-Fall-2026.ipynb`](ito-derivation/CHEME-5660-L5b-Derivation-MAGBM-Solution-Fall-2026.ipynb)
  extends the L4b Itô argument to several independent Wiener processes, derives
  the half-variance correction $C_{ii}/2$ and the exact one-step transition for
  each asset, and shows that the one-step growth rates have covariance
  $\mathbf{C}/\Delta t$. Prose only, no code.
- [`covariance-estimation/CHEME-5660-L5b-Advanced-CovarianceEstimation-Fall-2026.ipynb`](covariance-estimation/CHEME-5660-L5b-Advanced-CovarianceEstimation-Fall-2026.ipynb)
  measures how noisy a large sample covariance is (its eigenvalues against the
  Marchenko-Pastur law and a simulated error study), then shrinks the estimate
  toward structured targets and tests the effect on a minimum-variance
  portfolio out of sample.
- [`rolling-correlation/CHEME-5660-L5b-Advanced-RollingCorrelation-Fall-2026.ipynb`](rolling-correlation/CHEME-5660-L5b-Advanced-RollingCorrelation-Fall-2026.ipynb)
  estimates correlations on rolling windows and with exponential weighting
  through 2014 to 2024, for a few firm pairs and for the whole universe, and
  examines whether correlations rise during high-volatility windows in this
  sample.

The derivation notebook is about where the model's transition comes from; the
estimation notebook is about how much to trust one covariance matrix; the
correlation notebook is about how it moves in time. They can be completed
independently; the suggested order is the order listed.
