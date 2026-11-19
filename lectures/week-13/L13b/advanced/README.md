# L13b optional advanced material

This folder holds two notebooks.

- [`sector_factor/CHEME-5660-L13b-Derivation-SectorFactor-Parts-Fall-2026.ipynb`](sector_factor/CHEME-5660-L13b-Derivation-SectorFactor-Parts-Fall-2026.ipynb)
  is the derivation companion to the lecture's section on computing the parts of the sector factor model. It
  shows that the average single index residual of a sector has no market part, sets up the least-squares fit of
  the sector loading on the sector factor computed without the stock, and derives the one scale per sector that
  matches the average covariance of two residuals in the sector. It then shows that the stock-specific residual
  averages zero in the data, and derives the residual scale that keeps the variance of each single index
  residual. It is a derivation notebook with no code.

- [`one_minute/CHEME-5660-L13b-Advanced-JumpHMM-SPY-OneMinute-Fall-2026.ipynb`](one_minute/CHEME-5660-L13b-Advanced-JumpHMM-SPY-OneMinute-Fall-2026.ipynb)
  asks whether the hidden Markov model of `SPY` works when the time step is one minute instead of one day.
  It fits the model to the one-minute growth rates of 2025, with and without jump episodes tuned to the
  volatility clustering of the minutes. It then scores the model one trading day at a time on 2025 and 2026, and
  refits it before each day of 2026 on the trading days just before it. The score of a day follows its
  volatility, and refitting helps when the volatility of the market stays at a new level for weeks.

## Files of the notebook

- `one_minute/Include.jl`: the setup file of the notebook.
- `one_minute/src/Helper.jl`: the `pass_rate(...)` function, which scores one trading day against the model, and
  the `growth_rate_density(...)` function, which estimates the density of the growth rate from a histogram.
  `one_minute/docs/pass-rate.md` and `one_minute/docs/growth-rate-density.md` document them.
- `one_minute/data/SPY-OHLCV-1-min-2025-2026.jld2`: the one-minute bars of `SPY`. `one_minute/data/README.md`
  says where they come from.
