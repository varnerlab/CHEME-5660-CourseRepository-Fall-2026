# L13b: Interpretable allocation and model-predictive rebalancing

This lecture teaches the portfolio method of the INFORMS Annual Meeting 2026 study (J. D. Varner,
arXiv:2611.03022): what to hold (the γ score and its pickers), how to weight it (maximum-utility allocation
under trading limits), when to trade (a 21-day horizon, a forecast band, a drawdown stop), the β hedge, and how
to judge the method on one real path and on many synthetic markets. It builds on the utility allocation of L8b
and the synthetic markets of L13a.

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
- `figs/`: figures.

The 2025 bandit material that L13b replaced is in `lectures/archive/week-12-L12b-bandits-2026-11-04/`.
