# Week 5: GBM predictions and trade outcomes

**L5a — Single-asset GBM and NPV.** We review the price model, develop the
probability that a long position exceeds an NPV target, and connect the prediction
to observed trade outcomes.

- [Lecture](L5a/CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb) and [slides](L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.pdf).
- [Out-of-sample example](L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb): How well do historical estimates describe later prices? We simulate 2025 prices, construct pointwise prediction bands, and compare their observed coverage for one asset and across the shared dataset.
- [NPV trade-rule example](L5a/CHEME-5660-L5a-Example-GBM-NPV-TradeRule-Fall-2026.ipynb): How likely is a trade to exceed a target discounted return? We calculate its probability, verify the result at the median, and examine how the probability changes as we vary the target.
- [EMA parameter-updating example](L5a/CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb): Can giving recent observations more weight improve the forecasts? We update mean growth and volatility, compare forecasts using frozen and updated estimates, and measure their accuracy on the same observed outcomes.
- [EMA derivation](L5a/advanced/ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb): Develop the exponential weights, centered variance update, and conversion to GBM parameters behind the lecture proposition.

**L5b — Multiple-asset GBM and portfolio weights.** We extend the price model
to correlated assets, estimate their covariance, and construct portfolio weights.

- [Lecture](L5b/CHEME-5660-L5b-Lecture-MultipleAsset-GBM-Fall-2026.ipynb) and [slides](L5b/slides/CHEME-5660-L5b-Slides-Fall-2026.pdf).
- [Covariance example](L5b/CHEME-5660-L5b-Example-CovarianceMatrix-Fall-2026.ipynb): How do historical growth rates describe the assets' joint fluctuations? We estimate and interpret their covariance matrix.
- [Dirichlet weights example](L5b/CHEME-5660-L5b-Example-Dirichlet-PortfolioWeights-Fall-2026.ipynb): How can we sample feasible long-only portfolio weights? We explore the Dirichlet distribution and connect the weights to portfolio wealth.
- [Optional advanced examples](L5b/advanced/README.md) examine covariance estimation and rolling correlation.
