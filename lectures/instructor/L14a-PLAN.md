# L14a plan: brainstorm notes (2026-11-19)

These are brainstorm notes, not an approved design. Jeff will build L14a on his other machine, which has
v2 of the INFORMS methods. **Do not build on the v1 INFORMS engine in this repo's `code/src/mpc`.**

## Built on 2026-11-19 (the machine with v2), on disk, not committed

Jeff chose option A: port v2 into the course package, run every strategy once, and cache the results. The
examples load the cache and do cheap analysis only.

- **The v2 port.** `code/src/mpc` now holds the v2 engine from INFORMS `feat/method-v2` (commit 5d31b74): the factor
  forecast, the market-turn and β triggers, the SPY short, and the v2 settings. `data/mpc/study.toml` is the v2
  config, and `data/mpc/study_v1.toml` is the v1 config. The factor forecast reads the JumpHMM 0.6.0 models of the
  sector factor example, so the package has no JumpHMM dependency.
- **Checks.** All 2,191 engine tests pass, including the v2 tests and the v1 regression gate. On identical inputs
  (the GBM forecast, every other v2 switch on), the course port and INFORMS v2 give the same ending equity to every
  digit for CD, MinVar, 130/30 and SG.
- **Course additions.**
  - A `covariance_model` setting. `"sector_factor"` gives the Markowitz rules the sector factor covariance: the
    market part, the residual variance, and σ_res,i·σ_res,j·√(ρᵢρⱼ) within a sector. This is the factor
    forecast's own covariance.
  - Betting against beta (`run_bab`), as Frazzini and Pedersen built it. It uses their β estimate (one-year
    volatilities, a five-year correlation of 3-day returns), shrinks β 0.6/0.4 toward 1, builds rank-weighted
    low and high portfolios scaled to β = 1, and rebalances monthly. It holds every stock of the universe.
  - The buy-and-hold references, a market built from growth rates, and a loader option for prices through
    2026-11-13.
- **The run.** `lectures/week-14/L14a/scripts/run_strategies.jl` runs 21 strategies on the real market and on 1,000
  synthetic markets. The strategies are CD, CES, CESw, SG, MinVar, Tangent, MinVar and Tangent with the sector
  factor covariance (`-SF`), and 130/30, each with the hedge on and off. Then come betting against beta, SPY
  buy-and-hold and equal-weight buy-and-hold. All strategies use the γ screen and seed 5660.
- **The universe** is 371 stocks: the generator's 375 minus AVB, BK, EA and EQR, which have gaps in the 2025–26
  prices. The run calibrates on 2014–2024 and trades 2025-01-02 to 2026-11-13.
- **The synthetic markets** are full 2014–2026 histories drawn from the saved sector factor model (seeds 1 to
  1,000). They use two settings from the INFORMS v2 generator: α pulled toward the average (φ = 0.62), and β
  drifting with a 126-day half-life and the study's drift scale for each stock
  (`data/L14a-Synthetic-Drift-Settings.csv`). Each market is recalibrated on its own 2014–2024 part.
- **The output** is in `lectures/week-14/L14a/data/L14a-Strategies-*`, and the run's settings are in
  `L14a-Strategies-Settings.toml`.
- **CodecZlib** is now a direct dependency of the course environment. The sector factor example saves its
  generator compressed, and loading that file without CodecZlib fails.

First real-market numbers (growth rate, 1/yr): SPY buy-and-hold 0.137, equal weight 0.136, the best managed book
Tangent-SF with the hedge off 0.097, CD with the hedge on 0.055. Betting against beta lost 0.084/yr: the high-β
half rose about 25%/yr against SPY's 15%, and the low-β half's realized β was 0.21 against an estimate of 0.50.

The paper's window stops on 2026-09-04. On that window the course run gives CD with the hedge on 0.106/yr and 36
decisions, the paper's numbers. September to November 2026 cut CD to 0.055/yr and SPY from 0.166 to 0.137/yr.
The factor forecast and the GBM forecast give nearly the same CD growth on both windows (0.106 against 0.099, and
0.055 against 0.057).

## What Jeff asked for

- **Review first:** start L14a with a JumpHMM review, maybe the same as L13b's. It points to the sector factor
  example, now `lectures/week-14/L14a/CHEME-5660-L14a-Example-JumpHMM-SectorFactor-Fall-2026.ipynb`.
- **Objective:** use JumpHMM to evaluate different equity trading strategies. Then compare the strategies with
  what actually happened.
  - In sample: 2014–2024, for training only.
  - Out of sample: 2025–2026. This is the historical backtest.
  - Compare with the multiple-asset JumpHMM, following the INFORMS idea: maybe 2025 and 2026 were just good or bad
    years.
- **Rebalancing:** the model predictive control (MPC) rebalance system, with JumpHMM used to simulate the
  portfolio wealth.
- **Strategies to compare:**
  - the AQR betting against beta strategy
  - a single index Markowitz portfolio that updates (covariance and mean growth computed with single index
    models)
  - maybe the sector factor model as well
  - all of our utility methods
  - maybe a long-short strategy
  - the INFORMS methods use **v2** of the methods. v2 is on the other machine and may not be checked in yet.
- **Universe:** the 375 stocks of the sector factor example.
- **Scoring:** evaluate the strategies on a variety of performance indicators.
- **Ending:** close L14a with an introduction to the Alpaca Markets SDK. Students use it in the practicum, which is
  released on November 29.

## Dates

- L14a is Tuesday, November 24. Under the 48-hour freeze rule, the freeze is Sunday, November 22.
- November 26 is Thanksgiving, so there is no lecture (L14c).
- The practicum is released Sunday, November 29.

## What exists on the Fall 2026 machine (checked 2026-11-19)

- **INFORMS v1 engine:** `code/src/mpc` has the v1 port. It contains the CD, CES, CESw, SG, MinVar, Tangent and
  130/30 rules, the γ picker, the hedge and the triggers. Its forecast of wealth inside the controller is a GBM
  band (`project_gbm` in `Projection.jl`), not JumpHMM.
- **No synthetic runner:** the code that ran strategies on synthetic markets (`Synthetic.jl`) was removed when the
  course moved to JumpHMM 0.5. It is parked in `lectures/archive/week-13-L13b-trading-2026-11-18/` and does not
  run on JumpHMM 0.6.0.
- **Archived MPC lecture and examples:** the same archive folder has the MPC lecture sections (re-plan triggers,
  forecast band, daily controller algorithm) and the real-data and synthetic-data examples. On the one real path,
  random baskets grew anywhere from −0.013 to 0.212 per year. That spread is the case for the synthetic test.
- **v2 is not on this machine.** The newest INFORMS work here is Bob's feedback and draft test plan of
  November 4 (`docs/2026-11-04-talk-feedback-bob.md` on branch `docs/hedge-wording-review-fixes` of the INFORMS
  repo).
- **No betting against beta code** exists anywhere in the repo or the course package.
- **Out-of-sample prices:** `code/src/data` has daily OHLC files for 2025 and for 2026 through November 13. The
  INFORMS study stopped on September 4, 2026.
- **Universe size:** the INFORMS study used 373 names with a full history through September 2026. The sector
  factor example's 375 names need a full history only through 2024.
- **Alpaca SDK:** `varnerlab/alpaca-markets-sdk` (`Alpaca.jl`, not registered). It reads credentials from a TOML
  file (`conf/apidata.toml`) and targets paper trading.
- **Carryover:** `lectures/instructor/L14a-DRIFTING-BETA-FROM-L13b.md` holds the drifting β section cut from L13b
  on November 19 for L14a.
- **Old L14a files:** `lectures/week-14/L14a/` still has the 2025-based lecture (TradeBot and Wolfram markets),
  the MyTradeBot synthetic example, `src/` (bandits) and `docs/` (Notes, which are retired).
- **Uncommitted on this machine:** the move of the sector factor example and its data from L13b to L14a is staged
  but not committed. The L13b lecture, deck and README still link the old L13b path.

## Open questions

1. **Where does JumpHMM go?** "JumpHMM used to simulate the portfolio wealth" could mean either of these.
   - (A) **Test markets only.** The controller keeps the GBM forecast. JumpHMM draws synthetic 2025–2026
     universes, and every strategy trades each one. We see where the real result falls among each strategy's
     synthetic results.
   - (B) **Test markets and forecaster.** Everything in A, plus JumpHMM draws of the held names replace the GBM
     forecast inside the controller. Fat tails widen the bands, which changes when re-plans happen.
   - Claude's pick was A, to keep the strategies comparable with the INFORMS results. Not decided.
2. **How many examples?** The course limit is two examples worked in class per lecture. The sector factor review,
   the historical backtest and the synthetic test would make three. One option is one strategy example whose
   tasks are the backtest and the synthetic test, since every example has exactly three tasks.
3. **Which universe?** Which of the 375 names have prices for all of 2025–2026? What happens to names that left
   the index?
4. **Which out-of-sample end date?** September 4, 2026 (the study's), or November 13, 2026 (the newest data)?
5. **How does betting against beta trade?** It ranks on β, holds low-β names levered up to β = 1 and shorts
   high-β names scaled down to β = 1. Does it follow the MPC triggers, or its own monthly schedule? How does its
   leverage fit the course limits?
6. **What is the sector factor Markowitz portfolio?** A candidate is a covariance built from the fitted β, δ and ψ
   of each stock and the variances of the market and sector models.
7. **Which performance indicators?** Claude's proposal, not decided: the growth rate g (1/yr, never returns), the
   ending wealth ratio, the maximum drawdown, the volatility, the realized β, the trading cost and the number of
   re-plans. For the synthetic test, add P(g < 0) and the percentile of the real result.
8. **Does the drifting β carryover go into L14a?**
9. **What happens to the old L14a files?** Archive them as in earlier rebuilds?
10. **What does the Alpaca introduction cover?** For example: a paper account, the credentials file, pulling bars,
    and submitting a paper order. Credentials must never go in this repo, which is public.
