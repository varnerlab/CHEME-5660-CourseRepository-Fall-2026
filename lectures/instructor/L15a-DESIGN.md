# L15a design: testing a trading strategy (backtest, stress test, the INFORMS v2 method)

Status: draft for Jeff's approval, 2026-11-25 (builder check done, Jeff's answers in). Not committed.

## Intent and the why

L15a (Tuesday, December 1, 2026, in person) teaches how to test a trading strategy, in the order every strategy
goes through it: a backtest on the real market, then a stress test on synthetic markets. The same day, the
practicum (`CHEME-4660-5660-Practicum-Fall-2026`) is released. Students design a fund there and take it through
a backtest, a stress test with the five L15a gates, and a paper test on Alpaca. L15a is the rehearsal for that
work.

Jeff's plan (11-25): students choose strategies from a menu, see the real 2025–2026 backtest, and then see a
stress test on markets from the new JumpHMM generator. The lecture carries the general backtest loop and the
general stress-test loop as pseudocode, and then the INFORMS v2 implementation of that loop.

## Goals

- The lecture gains three parts: the general backtest loop (pseudocode), the general stress-test loop
  (pseudocode), and the INFORMS v2 method, with all six triggers.
- A strategy is **one picking rule + one weighting rule + the hedge on or off + frozen or updated estimates**.
- Each rule has one plain-code Julia file and one short PDF deck. An index notebook groups the rules and links
  to both. Jeff: the code files show how a strategy works to people without a strong command of code.
- The engine's daily loop calls the strategy files. A picking file returns the basket, and a weighting file
  returns the weights. The function shapes match the practicum's student parts (vectors in, a basket or
  weights out, course-style docstrings), so the lecture teaches the same pattern students use in the practicum.
- Every combination runs once on the real market and once on synthetic markets. The examples load the saved
  results, so nothing heavy runs in class.
- SPY is the only benchmark.

## Non-goals and anti-goals

- No bandit picking rule ("we didn't do bandits this year").
- No news-based picking rule. Alpaca has a news feed; this is a future idea.
- The practicum engine is not changed. L15a does not merge the two engines (Jeff picked "1 and 3", see
  Approaches).
- The in-class "add your own strategy" part is a fun extra. What students write is **parked** by Jeff. It is
  not designed here.
- L15b gets its own design. Agreed outline only: the paper test (take a stress-tested strategy to the Alpaca
  paper account) and a short course wrap-up. It replaces the old captured-operations L15b.
- Anti-goal: an engine setting that keeps an old rule "to match the paper". When Jeff simplifies a rule, the old
  rule goes away.
- Anti-goal: running anything heavy in class, or starting the big run before this list is final ("we need to be
  crystal clear on what we are going to run before we run them, otherwise we will be out of time").

## Constraints

- **Dates.** Today is Wednesday 11-25. Thanksgiving is 11-26. L15a is Tuesday 12-01. The practicum takes the
  L15a gate thresholds as they stand on Monday 11-30.
- **Data: the practicum's, not the course's.** `CHEME-4660-5660-Practicum-Fall-2026/data/prices.jld2` (branch
  `practicum-build`): total-return closes (Alpaca `adjustment = all`, SIP feed), 2016-01-04 to 2026-11-24, 507
  tickers (491 stocks, 16 ETFs), `NaN` before a ticker's first day. 469 tickers have a full history, and the
  course engine uses only those (its universe rule). The fits use 2016–2024. The real backtest runs from
  2025-01-02 to 2026-11-24. T-bills: the practicum's `data/tbill.csv`.
- **Volume and opens are missing.** The practicum price file stores closes only. The engine needs daily volume
  for its trading-cost model (impact against the 63-day mean volume) and for the two "liquid" picking rules (the
  100 most traded stocks). It also fills every order at the next day's open (`open[t]`, `spy_open[t]` in
  `StudyBacktest.jl`). One **SIP** pull (Jeff: the IEX volume is not correct), with `adjustment = all`, over the
  same dates and tickers, fetches open, high, low, close, and volume (Jeff added high and low: "might be fun"). It writes a separate course-side file,
  `lectures/week-15/L15a/data/`, and leaves the practicum's `prices.jld2`, `generator.jld2`, and `estimates.csv`
  untouched. The course run takes its closes from the practicum file. A check compares the new pull's closes with
  them: if a distribution after 11-24 rescaled the history, each ticker's opens are rescaled by the ratio of the
  two closes. (Claude's call.) The pull uses the L14a keys (Jeff, 11-25): `ALPACA_CREDENTIALS` is set to the path of
  `lectures/week-14/L14a/alpaca-mcp/conf/apidata.toml`. Never read, print, or copy that file. **The big
  run waits on this.**
- **Universe: every ticker with a full history, ETFs included (Jeff, 11-25: "Yes, ETFs can be pickable").** The
  469 full-history tickers are 455 stocks and 14 ETFs (SPY, QQQ, IWM, TLT, and ten sector funds). SPY stays the
  market and the hedge instrument, and it is not pickable, so a basket never holds SPY long while the hedge
  shorts it (Claude's call). The other 13 ETFs are pickable. Each ETF gets a single index model fit like a stock
  (the practicum generator already fits the ETFs to the market and all 11 sector factors). In the two per-sector
  rules, the ETFs form a twelfth group, "ETF", with the same number of picks as a sector (Claude's call). The
  universe-wide rules rank ETFs and stocks together. The hedge pool may take an ETF whose β is at or below 0,
  for example TLT. This is a change from INFORMS, where the universe was stocks and SPY.
- **Generator: the practicum's new one.** `data/generator.jld2`, read by `load_generator` and
  `synthetic_growth(generator, days, seed)` in the practicum `src/Generator.jl`. It is the general factor model
  with the Cholesky step, so the sectors move together. `GENERATOR-CHECK.md` passes (Real Estate–Utilities
  correlation 0.447 real, 0.423 synthetic mean). It covers 506 tickers, SGOV left out.
- **Engine.** The course engine (`code/src/mpc`, `VLQuantitativeFinancePackage.MPCPortfolio`) is the INFORMS v2
  engine ported on 11-19 and bit-identical to INFORMS v2 on the same inputs. Its tests must run with
  `--project=code`. Today it picks built-in rules by name (`allocator = "CD"`, `screen = :gamma`).
- **Course code style** (CLAUDE.md, memory `src-code-beginner-syntax`): documented top-level functions,
  explicit loops and if-blocks, a comment on each step, no inner functions, closures, `do` blocks, ternary
  chains, or `x || throw` one-liners. After any rewrite, prove that the outputs are unchanged.
- **Notebooks** follow AGENTS.md and the shared notebook style guide. Examples have exactly three
  `## Task N:` sections. No lecture-number references in student text. No hardcoded tickers. Every symbol is
  defined at first use. Each new symbol goes in the FAQ notation page (content.json) in the same pass.
- **Git.** Other sessions edit this repo at the same time (memory `shared-worktree-commit-hygiene`). Commit only
  when Jeff asks.
- **GitHub file limit.** 100 MB per file. The L14a cache was 49 MB.

## Approaches considered

1. **Which engine runs the L15a menu.**
   - *Course engine (picked).* It already runs the whole INFORMS v2 method: 6 triggers, the forecast band,
     conic weighting under trading limits, and the market hedge. It needs the new data, the new generator, the
     strategy-file hook, a frozen-estimates setting, and two new weighting rules.
   - *Practicum engine (rejected).* It runs a whole fund (options, fixed income, margin, paper, report,
     grading), but on stocks it has only γ per sector, closed-form Cobb–Douglas, min-var, and BAB weights with
     no trading limits, and only 2 of the 6 triggers. Its backtest and stress test (practicum tasks 8–9) are
     not built yet. Running the INFORMS menu there would mean building INFORMS v2 a second time inside a build
     that ships 12-01.
2. **Practicum link (Jeff: "go with 1 and 3").**
   - *1, picked:* keep both engines as designed.
   - *2, rejected for this week:* an "INFORMS v2" stock sleeve in the practicum that calls the course engine.
   - *3, picked:* a cheap bridge. The L15a strategy files are plain functions, so an Expert student can copy
     one into their practicum `decide`. The practicum environment may need the conic solver (Clarabel) and JuMP
     added.
3. **What a strategy file holds.** Jeff: "doesn't the engine call the strategy file during its run loop?" Yes.
   Each file holds the function that the loop calls, in plain course code. Thin wrappers around the built-in
   rules were rejected because they hide the work.
4. **Stress-test shape.**
   - *A, picked:* the practicum's stress test. 200 paths of 252 trading days start after 2026-11-24. Each
     strategy starts from its estimates on 2026-11-24, with no refit for each market.
   - *B, rejected:* the INFORMS/L14a shape, a full synthetic 2016–2026 history refit for each market. It
     matches the backtest window but costs a refit per market, and the practicum generator draws forward only.
5. **Frozen vs. updated estimates (Jeff: "I guess ... 1").** A fourth choice for every strategy, which keeps
   gate 4 (median ending wealth vs. the frozen copy of the same strategy) in the lecture and the practicum. The
   alternative (updated only, gate 4 vs. SPY) was rejected.
6. **Re-pick rule (Jeff, 11-25, "it's dumb to have two lists").** One trigger list: every trigger re-plans and
   picks a new basket. A scratch test on 200 synthetic markets (L14a generator, Cobb–Douglas γ per sector)
   found no difference from the paper's rule: −0.10 ± 0.09 %/yr with the hedge on (better on 96 markets, worse
   on 103) and −0.02 ± 0.07 %/yr with the hedge off. No setting keeps the old rule.

## What Jeff decided

### The strategy menu

**Picking rules (8):**

| Rule | What it picks | Seeds |
|:--|:--|:--|
| γ per sector | the 3 highest γ in each of the 11 sectors and the ETF group (36 names) | 1 |
| random per sector | 3 at random in each sector and the ETF group (the luck control) | 30 real, 5 per synthetic market |
| global γ | the 13 highest γ in the universe, no sector quota | 1 |
| correlation-aware γ | down the γ ranking, accepting a stock only if its 252-day growth correlation with every accepted stock is at most 0.7 | 1 |
| liquid then γ | the 13 highest γ among the 100 most traded stocks | 1 |
| random liquid | 13 at random among the 100 most traded stocks | 30 / 5 |
| random global | 13 at random from the whole universe | 30 / 5 |
| hand-picked | Jeff's two lists in `study.toml` (`l8b_13`, `l8b_15`), never re-picked; one deck, two runs | 1 each |

**Weighting rules (9):** Cobb–Douglas; CES on shares (η = 0.5); CES on weights (η = 0.5); Stone–Geary (1%
baseline); minimum variance; maximum Sharpe; 130/30 long-short Cobb–Douglas; **equal weight** (the same weight
on every picked stock); **BAB** (long the low-β half of the basket, short the high-β half, each side scaled to
β = 1 as in Frazzini and Pedersen, so the book's β sits near zero). Equal weight and BAB moved in from the old
benchmark list. The seven INFORMS rules keep their INFORMS trading limits.

Equal weight and BAB follow the same limits as every other rule. (Claude's call: one set of limits for all nine
rules, so the comparison is between weighting rules and not between limit sets.)
- **Equal weight:** the same weight on each picked stock, cut back to meet the single-name cap. With the hedge
  on, the engine meets the β limit the same way it does for the other rules: it moves wealth into cash and the
  hedge pool, and shorts SPY below a zero limit.
- **BAB:** ranks the basket by the strategy's own SIM β, so that frozen and updated estimates differ. The low-β
  half goes long and the high-β half goes short, with Frazzini–Pedersen rank weights scaled toward a book β of 0.
  Then the single-name cap, the 130/30 gross limits (long ≤ 1.30, short ≤ 0.30), and cash ≥ 0 apply. Where a cap
  binds, the book's β moves away from 0. The deck says so in one sentence. The old `run_bab` (whole universe,
  monthly, no caps, borrowing at the bill rate) is retired.

**The ones we considered.** Linear utility (perfect substitutes) and Leontief (perfect complements) appear in
the CES deck as the two ends of the INFORMS η sweep (0.1 to 10). They are not separate rules. (Proposed; Jeff did
not object.)

**Hedge:** the market hedge on or off (β limit = max(1 − ξ_t, −0.5), with a SPY short below zero).

**Estimates:** frozen (the 2016–2024 fit, never updated) or updated (daily EWLS, half-life 63, prior weight 63,
started from the 2016–2024 fit).

**Benchmark:** SPY buy-and-hold only.

### The engine loop (one trigger list)

```text
each trading day:
    update the estimates (updated runs only)
    check the six triggers: cash revisit, drawdown, market turn, β over the limit, horizon, band exit
    if a trigger fired:
        basket  = pick(today's data)               ← picking-rule file
        weights = weigh(basket, today's estimates) ← weighting-rule file
        apply the market hedge (if on), then trade at the next open
```

Settings: the INFORMS v2 `study.toml` (T = 21, D_max = 8%, β margin 0.1, quantile band, cash revisit 21,
market turn on with the ξ = 1 turn, 5 bps half spread, κ = 0.001), plus the one-list rule. The separate re-pick
timer goes away: the horizon trigger covers it.

### The runs

- **Real market:** every combination, 2025-01-02 to 2026-11-24. That is (6 single-seed picks + 3 random picks ×
  30 seeds) × 9 weighting × 2 hedge × 2 estimates = **3,456 runs**.
- **Stress test (shape A):** 200 synthetic paths of 252 trading days after 2026-11-24 from the practicum
  generator (seeds as the practicum numbers its paths). Per path: (6 + 3 × 5) × 9 × 2 × 2 = **756 runs**, so
  **151,200 runs** in total. Real history up to 2026-11-24, then the synthetic year. Frozen runs use the
  2016–2024 fit. Updated runs carry the EWLS state through the real 2025–2026 days into the synthetic year.
- **Timing:** time 10 paths first and report before the full run. The estimate is 6 to 12 hours on 28 threads,
  so it runs overnight.
- **Gates (the five L15a gates, thresholds unchanged unless Jeff says otherwise):** median Sharpe ≥ 0.3; median
  maximum drawdown ≤ 25%; failure rate (paths ending below USD 100,000) ≤ 10%; median ending wealth ≥ that of the
  frozen copy of the same strategy; median NPV ≥ 0.

### Lecture

- Keep the opening and the updating section (moved from L14a on 11-23: the daily EWLS update, the general
  factor extension, the preference weights with updated estimates, the market hedge, the BAB comparison). This
  section is the INFORMS v2 implementation. It moves to the new data and the one-list rule (Claude's call, so the
  lecture teaches one re-pick rule and one fit window):
  - Only the sentences about when a basket is picked change ("every 21 trading days and whenever the market
    turns" becomes "whenever one of the six triggers fires"). Each number in Jeff's text is replaced with the
    value from the new data and 2016–2024 fit. No other words change.
  - `pick_days` in `src/Helper.jl` and the kept example follow the one-list rule and the new data. The figures
    `Fig-L15a-EWLS-JPM` and `Fig-L15a-Gamma-Picks` are redrawn from the new numbers with the same layout and
    colors.
  - Cut line: this conversion comes after the runs and the new examples. If time runs out, it waits, and the
    kept example says which data it uses.
- Add the general backtest loop and the general stress-test loop (pseudocode), and the six triggers with their
  settings and the one-list rule.
- Replace "Validation and Compliance" (concentration caps, a production lecture) with the five gates.
- Rewrite the LOs, the Key Takeaways, and the Examples list to match (exactly 3 LOs and 3 Key Takeaways).
- Sync the deck. `slides/frames-from-L14a.tex` holds the frames staged from L14a.

### Strategy folder

`lectures/week-15/L15a/strategies/`: one index notebook that groups the rules (picking rules, weighting rules,
hedge, estimates). Each entry gets one sentence and links to the rule's deck and code file. For each rule there
is one Julia file and one PDF deck with the same name. Each deck has about four frames: the idea, the math, the
pseudocode, and the settings, with the function in the Julia file that does each step. The math frames reuse
Jeff's existing frames and notation (min-var: L5b, L6a, L6b, L7a decks; preference weights, market hedge, BAB,
EWLS: L13b, L14a, and `frames-from-L14a.tex`). That makes 8 picking decks + 9 weighting decks = 17.

### Examples

The existing example "Updating the Single Index Model and the Preference Weights" stays. The old
"Validation-Gates" example is archived. New examples load the saved results. The builder proposes their task
split (see below).

### The synthetic markets (Jeff, 11-25: option 1)

The practicum generator draws each stock with its 2016–2024 least-squares α and β (`fit_generator.jl`, step 1).
Those are the numbers that the frozen strategies use, so on the practicum's draw a frozen strategy would know the
true parameters of every synthetic market, and gate 4 would favor it by design. The course-side draw adds the two
INFORMS v2 changes that the L14a stress test used:
- each stock's α is pulled toward the average α: α_i = ā + φ(α_i − ā), with φ = 0.62;
- each stock's β drifts around its estimate with a 126-day half-life and the stock's drift scale from
  `lectures/week-14/L14a/data/L14a-Synthetic-Drift-Settings.csv` (the median scale for a stock missing from
  that file).

The practicum's own stress test has the same issue. The practicum session should make the same change (Claude
offers to send it a note).

## Left to the builder

- **The strategy-file interface.** Proposed: course-style types with dispatch (a `My…` type per rule and a
  method `pick(rule, data)` or `weigh(rule, basket, data)`), with plain vectors in and a basket (tickers) or
  weights out, mirroring the practicum's student parts (for example `minimum_variance_weights(β, σ_ε, σ_m)`).
  Before the big run, every file that replaces a built-in rule must reproduce the built-in output on the real
  market: identical baskets, and weights within solver tolerance.
- The engine changes: the hook that calls the files, the one-list rule (with the engine tests updated for it),
  the frozen-estimates setting, the equal-weight and BAB weighting rules, loading the practicum data, and
  building the synthetic year from `synthetic_growth`. The forecast models behind the band (`ForecastFactor.jl`)
  read the L14a sector factor generator today. They must read the practicum generator, or the plan must say what
  the forecast uses instead.
- Synthetic volumes (proposed: each stock's median 2016–2024 volume, as in L14a) and the T-bill rate on the
  synthetic year (proposed: match the practicum's stress test).
- The cache layout under the 100 MB limit. Proposed: one summary row per run (all 154,656 runs), and daily
  equity only as per-combination percentile bands on the synthetic paths and full paths on the real market.
- Example names, their three tasks each, and the index notebook's name.
- The order of work, with a cut line for 12-01 (proposed: engine and data, files and the equivalence check, runs,
  examples, lecture text; then the decks, which can follow during the practicum window if time runs out).
