# L5a optional advanced material

These standalone notebooks extend the L5a discussion of multiple asset GBM and
the covariance matrix. They are optional and are not prerequisites for L5b.

- [`covariance-estimation/CHEME-5660-L5a-Advanced-CovarianceEstimation-Fall-2026.ipynb`](covariance-estimation/CHEME-5660-L5a-Advanced-CovarianceEstimation-Fall-2026.ipynb)
  measures how noisy a large sample covariance is (its eigenvalues against the
  Marchenko-Pastur law and a simulated error study), then shrinks the estimate
  toward structured targets and tests the effect on a minimum-variance
  portfolio out of sample.
- [`rolling-correlation/CHEME-5660-L5a-Advanced-RollingCorrelation-Fall-2026.ipynb`](rolling-correlation/CHEME-5660-L5a-Advanced-RollingCorrelation-Fall-2026.ipynb)
  estimates correlations on rolling windows and with exponential weighting
  through 2014 to 2024, for a few firm pairs and for the whole universe, and
  shows that correlations cluster with market volatility.

The estimation notebook is about how much to trust one covariance matrix; the
correlation notebook is about how it moves in time. They can be completed
independently; the suggested order is the order listed.
