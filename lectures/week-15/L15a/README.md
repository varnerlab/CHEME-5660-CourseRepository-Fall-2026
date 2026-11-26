# L15a: Testing a Trading Strategy

The lecture updates the estimates of the trading method every trading day. Then it tests strategies from the menu
with a backtest on the real market and a stress test on synthetic markets with the five gates. The updating section
moved here from L14a on 2026-11-23.

- [`CHEME-5660-L15a-Lecture-Testing-Trading-Strategies-Fall-2026.ipynb`](CHEME-5660-L15a-Lecture-Testing-Trading-Strategies-Fall-2026.ipynb)
  is the lecture.
- [`CHEME-5660-L15a-Example-Strategy-Backtest-Fall-2026.ipynb`](CHEME-5660-L15a-Example-Strategy-Backtest-Fall-2026.ipynb)
  backtests one strategy from the menu on the real market, places it among the saved backtests of the menu, and
  runs it again with updated estimates.
- [`CHEME-5660-L15a-Example-Strategy-Stress-Test-Fall-2026.ipynb`](CHEME-5660-L15a-Example-Strategy-Stress-Test-Fall-2026.ipynb)
  runs one strategy on 200 synthetic markets, tests it with the five gates, and tests it again with the market
  hedge on.
- [`CHEME-5660-L15a-Example-Updating-SIM-Gamma-Fall-2026.ipynb`](CHEME-5660-L15a-Example-Updating-SIM-Gamma-Fall-2026.ipynb)
  updates the single index model of every stock with each trading day of 2025 and 2026, and picks the
  preference basket. It uses `src/Helper.jl` (`pick_days`, `gamma_basket`).
- [`strategies/`](strategies/) holds the strategy menu.
  [`CHEME-5660-L15a-Strategy-Menu-Fall-2026.ipynb`](strategies/CHEME-5660-L15a-Strategy-Menu-Fall-2026.ipynb)
  lists each rule with its code file. The rule files are in `picking/` and `weighting/`, and `menu.jl` lists the
  rules by name.
- [`src/Helper.jl`](src/Helper.jl) holds the helpers of the examples: the pick days, the preference basket, the
  60/40 benchmark, the five gates, and the lookup of saved stress-test runs.
- [`advanced/`](advanced/) holds the EWLS derivation and the policy-gradient derivation.
- [`data/`](data/) holds the saved results of the menu, the backtests and the stress test, and the practicum's
  data. [`data/SOURCE.md`](data/SOURCE.md) gives the source and the checksum of each copied file.
- [`scripts/`](scripts/) is for the instructor. `run_strategies.jl` runs every strategy on the real market and on
  the synthetic markets and writes the saved results, and the two check scripts compare the rule files with the
  engine's built-in rules.
- [`figs/`](figs/) holds the figures of the lecture, with their sources.
- `slides/frames-from-L14a.tex` holds the deck frames removed from L14a, staged for the L15a deck. It is not
  built.

The old EWLS replay example and EWLS recursion notebook are in
`lectures/archive/week-15-L15a-before-move-2026-11-23/`. The old validation-gates example is in
`lectures/archive/week-15-L15a-validation-gates-2026-11-26/`.
