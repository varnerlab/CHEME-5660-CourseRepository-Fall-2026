# L13b: Synthetic markets of many stocks

The lecture extends the jump hidden Markov model from one asset to a universe of stocks. It opens with a review
of the single-asset model, a stop at the out-of-sample example, and an AQR Capital Management company profile.
The Many Assets section then teaches the sector factor model: each stock's daily growth rate is a baseline plus
market, sector, and stock-specific parts computed from the data. A single-asset jump hidden Markov model fitted to
each part supplies the market, sector, and stock-specific draws. The section covers the residual scale, the
sampling algorithm, and the option of a drifting β. The deck mirrors the lecture.

## Examples

- `CHEME-5660-L13b-Example-JumpHMM-SPY-OutOfSample-Fall-2026.ipynb` (the refresher of the single-asset model):
  loads the `SPY` model fitted to 2014–2024, compares its simulated paths with the 2025 and 2026 daily growth
  rates, turns the jump episodes off and compares both models, and compares volatility clustering.
- `CHEME-5660-L13b-Example-JumpHMM-SectorFactor-Fall-2026.ipynb`: builds a universe of two stocks from each
  sector plus `SPY` with the sector factor model, compares a synthetic path with the real data, lets β drift,
  and saves the generator.

## History

On November 17, 2026, the many-asset material moved here from L13a. On November 18, 2026, L13b became the
multi-asset lecture only. The trading material (the model-predictive controller of the INFORMS 2026 study,
its two examples, their data, the generator script, and the figures that only those sections used) moved to
`lectures/archive/week-13-L13b-trading-2026-11-18/`. The same day, week 13 moved to JumpHMM.jl 0.5.0.

## Files

- `Include.jl`: the setup file every notebook includes.
- `data/JumpHMM-SPY-2014-2024.jld2`: a copy of the tuned `SPY` model that the L13a single-asset example
  saves. Both examples read it.
- `data/JumpHMM-SectorFactor-Universe-2014-2024.jld2`: the universe that the sector factor example saves.
- `figs/`: the JumpHMM schematic of the lecture's review, a copy of L13a's. `figs/README.md` explains the copy.
- `slides/`: the deck and its Makefile.

The 2025 bandit material that L13b replaced is in `lectures/archive/week-12-L12b-bandits-2026-11-04/`.
