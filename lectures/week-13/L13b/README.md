# L13b: Interpretable allocation and model-predictive rebalancing

This lecture is an extended version of the INFORMS Annual Meeting 2026 talk (J. D. Varner, session TD47,
November 3, 2026; paper arXiv:2611.03022; public repository `varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab`).
It follows the talk's three parts. Allocation covers the maximum-utility problem with its trading limits and
the γ score. Rebalancing covers the 21-day horizon, the forecast band, the drawdown stop, and the real-data
backtest. The market generator part covers the JumpHMM synthetic markets and the simulated sell-offs. The
lecture builds on the utility allocation of L8b and the synthetic markets of L13a.

The method's code is the `MPCPortfolio` submodule of the course package (`code/src/mpc/`), ported from the
study's repository; synthetic markets come from `JumpHMM.jl`.

## Files

- `Include.jl`: the setup file every notebook includes.
- `data/pretrained-jumphmm-market-surrogate.jld2`: the JumpHMM model of SPY that the INFORMS study uses as the
  market of its synthetic markets, copied from `varnerlab/eCornell-AI-finance-lectures`
  (`code/src/data/`, commit fa50240).
- `data/MPC-SyntheticGenerator-2014-2024.jld2` and its `-summary.toml`: the synthetic-market generator fitted to
  the 373-name universe on 2014–2024, written by `scripts/fit_generator.jl`.
- `scripts/fit_generator.jl`: refits the generator (run once, with threads; see the file).
- `figs/`: the four figures of the talk (market state, forecast band, real-data results, synthetic-market
  results), built from the talk's own drawing code and data. `figs/README.md` describes each figure and the build.

The 2025 bandit material that L13b replaced is in `lectures/archive/week-12-L12b-bandits-2026-11-04/`.
