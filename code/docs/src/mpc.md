# Model-predictive portfolios

`VLQuantitativeFinancePackage.MPCPortfolio` is the portfolio method of the INFORMS Annual Meeting 2026 study,
J. D. Varner, ["Interpretable Allocation and Model-Predictive Rebalancing of Equity Portfolios, Tested on Real
and Synthetic Markets"](https://arxiv.org/abs/2611.03022) (arXiv:2611.03022). The code is ported from the
study's repository, [varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab](https://github.com/varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab)
(commit 2fc998c), and reproduces its real-data results on the course's S&P 500 files.

The method has three parts:

- **What to hold.** Each stock gets a score γ from a single-index fit, with β counting more or less as the
  market state ξ (a 21-day against a 63-day moving average of SPY) changes. A picker chooses a basket: by γ,
  at random, or from a fixed list.
- **How to weight it.** Maximum-utility allocation (Cobb–Douglas, CES, Stone–Geary, minimum variance, the
  tangency portfolio, or a 130/30 book) under a per-name cap, a volatility cap, sector caps and a spread-cost
  turnover budget, solved with Clarabel (SCS as the fallback).
- **When to trade.** The book re-plans after 21 trading days, when its value leaves a GBM forecast band, or after
  an 8% drawdown from its peak. An optional hedge caps the book's β, more tightly as the market turns bearish.

Synthetic markets for testing the method come from [JumpHMM.jl](https://github.com/varnerlab/JumpHMM.jl)'s
`SectorFactorModel`; `fit_generator` fits its drift to the method's own β estimate, and `path_sets` chooses
typical, burst and bear markets, as the study does.

The submodule has its own namespace, because the course package's adaptive-portfolio routines use some of the
same names. Use it qualified:

```julia
using Dates
import VLQuantitativeFinancePackage
import VLQuantitativeFinancePackage: build
import VLQuantitativeFinancePackage.MPCPortfolio as MPC

dir = joinpath(dirname(pathof(VLQuantitativeFinancePackage)), "data")
md = MPC.load_market_data(dir; start = Date(2014, 1, 3), stop = Date(2026, 9, 4))   # 373 names
calib = MPC.calibrate(md; train_start = Date(2014, 1, 3), train_stop = Date(2024, 12, 31))
s = MPC.with_settings(MPC.load_study(MPC.default_study_path()).settings; hedge = false)
ctx = MPC.build_context(md, calib, s)
run = build(MPC.MyStudyRun, (settings = s, allocator = "CD", screen = :gamma, seed = 5660))
result = MPC.run_study(ctx, run)     # equity, trades, decisions, re-picks, day by day
```

Threaded runs: SCS needs `OMP_NUM_THREADS=1` and `KMP_GTID_MODE=2` set before Julia starts.

## Reference

The reference is split by part of the method: [data, the single-index model, and settings](mpc-data.md),
[allocation](mpc-allocation.md), [trading and the study loop](mpc-trading.md), and
[synthetic markets](mpc-synthetic.md).

```@docs
VLQuantitativeFinancePackage.MPCPortfolio
```
