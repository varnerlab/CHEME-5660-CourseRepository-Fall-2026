# L14a plan: brainstorm notes (2026-11-19)

These are brainstorm notes, not an approved design. Jeff will build L14a on his other machine, which has
v2 of the INFORMS methods. **Do not build on the v1 INFORMS engine in this repo's `code/src/mpc`.**

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
