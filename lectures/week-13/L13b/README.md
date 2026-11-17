# L13b: Interpretable allocation and model-predictive rebalancing

The lecture constructs one adaptive trading system from account measurements to executed orders.
It builds the stock score, the constrained allocation, the online single index updates, the wealth
forecast, and the three triggers, then assembles them in the controller algorithm. The two-stock toy
book was removed on November 16, 2026. The talk's forecast-band figure was redrawn the same day: one 95%
band per plan, with the re-plan reasons under the date axis. A JumpHMM review (with a copy of
L13a's schematic) and an AQR Capital Management company profile were added after the examples.

The allocation section explains the score in plain words, gives each trading limit one sentence,
and shows the four utilities in a table after the problem box. The controller pseudocode uses numbered
prose with one nested group for its three triggers.

The INFORMS Annual Meeting 2026 study supplies the application and the two computational examples
(J. D. Varner, session TD47, November 3, 2026; paper arXiv:2611.03022; public repository
`varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab`). The closing section reports the study's findings
on the historical path (weighting rule, stock selection) and on typical and sell-off synthetic markets
(including the hedge).
The lecture builds on the utility allocation
of L8b and the synthetic markets of L13a. The slide deck still follows the original talk structure.

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
- `figs/`: the lecture's portfolio feedback schematic and the four figures of the talk. The notebook uses
  the new schematic and the forecast-band episode; the talk's results figures remain available for the
  deck. `figs/README.md` describes the sources and the build.

The 2025 bandit material that L13b replaced is in `lectures/archive/week-12-L12b-bandits-2026-11-04/`.
