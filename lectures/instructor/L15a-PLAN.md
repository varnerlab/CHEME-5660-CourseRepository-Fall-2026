# L15a implementation plan (outline, 2026-11-25; not yet expanded into full TDD steps)

Spec: `lectures/instructor/L15a-DESIGN.md` (approved by Jeff 11-25). Not committed.

## Done
- **T0 data pull (11-25; replaced 11-26).** The first pull wrote a separate L15a OHLCV file. On 11-26 the practicum's
  `data/prices.jld2` gained the same open, high, low, and volume arrays (commit `9a72d73`; every array identical to
  the L15a pull), so L15a copies that one file and the separate file, its check table, and `pull_ohlcv.jl` are gone.
- The practicum's drift-enabled `src/Generator.jl` landed locally at
  `80ea80bb5545f3cdd3b2290cd73b87a72d23aaa4`. Task 7 uses that source with the pinned
  `data/beta-drift.csv`. See the [Codex handoff](L15a-CODEX-HANDOFF.md) for the interface and checks.
- **T1 data loader.** The snapshot has 2,740 trading days. `MPC.load_l15a_market` reads the practicum's
  `prices.jld2` and returns the same 505 pickable tickers (14 ETFs; SGOV out) for the full snapshot and the 476-day
  backtest window, with the practicum's T-bill rule (4.18% on 2026-11-24). `L15a/data/SOURCE.md` records every copied
  file at practicum commit `9a72d73`, including the re-pinned `Generator.jl` and `beta-drift.csv` (style-only
  changes since `80ea80bb`; markets 1 and 2 still match the practicum's draws).
- **T2 strategy interface.** `MyStudyRun` accepts strategy objects and built-in names. `utility_objective!`
  adds each utility's objective while the engine supplies the trading limits. Both Cobb–Douglas hedge settings
  matched the L14a cache bit for bit before the trigger change. Object and named runs also matched on trades,
  decisions, and picks.
- **T3 estimates.** The fixed context repeats the training fit. The updated context can process market days
  before the first trading decision. Tests verify that starting decisions later gives the same estimates as
  slicing a run with the same first update date.
- **T4 one trigger list.** The live loop picks and decides on the same date and records the same reason for
  both. The removed fields no longer appear in the two package settings files. Tests compare the first decision
  with the v1 fixture and check the new schedule after that.
- **T5 picking files.** The eight rules match the built-in baskets on all 476 real-market days, including
  both hand-picked lists (4,284 comparisons). A Cobb–Douglas smoke backtest ran in each estimate mode
  with the GBM forecast. The factor forecast adapter is Task 7.

- **T6 weighting files (Claude, 11-25 evening).** Nine files in `strategies/weighting/`. Each holds a plain
  function `weigh_…` (vectors in, weights out, no trading limits, copyable into the practicum) and a `MyL15a…Rule`
  type the engine calls. The seven INFORMS rules hand their problem to the built-in rule, so the file runs are
  bit-identical to the built-in runs (check 2: equity and trades equal on the real market, Jan–Mar 2025).
  Equal weight uses the new `MPC.scaled_book` (the largest multiple of equal weights that meets every limit; the rest
  is cash, and the hedge pool can carry part of the book for the β limit). A first try as Cobb–Douglas with equal
  scores was dropped: the volatility cap tilted it to 0.015–0.052 per stock. BAB uses the new `MPC.closest_book`
  (the book closest to the Frazzini–Pedersen weights, scaled to a side β of 1 with a floor of `beta_floor = 0.1`,
  under the 130/30 caps and every limit). The engine gained `rule_preferences` (a rule can mark the picked stocks)
  and the public `uses_short_candidates`. Checks: `scripts/check_weighting_files.jl` (35 pass); engine suite 2,194
  pass, 1 old skip.
- **T7 synthetic year (Claude).** `scripts/synthetic.jl`: the practicum's `Generator.jl` and `beta-drift.csv` copied
  at `80ea80bb` into `scripts/practicum/` (SOURCE.md); 252 NYSE days after 2026-11-24; opens = closes; median
  2016–2024 volume; last real T-bill rate. Forecast adapter `l15a_forecast_models`: stocks use their GICS sector,
  ETFs their largest loading; ρ = the sector part's variance given the market over that plus the own variance
  (own includes the β drift variance). The same forecast models serve the real run.
- **T8 run script (Claude).** `scripts/run_strategies.jl`. The stress test's first decision is made after the
  2026-11-24 close, so its orders fill at the first synthetic open (the settings start on 2026-11-24). Summary
  columns are stored with concrete types (JLD2 stores an `Any` column one element at a time). The forecast models
  are saved to `data/L15a-Forecast-Models.jld2`, so an example can run one strategy live and match its saved row
  without the generator code. Smoke test: 36 strategies on the real market and on 2 synthetic markets, no
  failures, about 12 s per synthetic market for 36 runs on 28 threads.
- **T9 examples (Claude's split).**
  - *Backtesting a Strategy from the Menu.* The student sets the picking rule, the weighting rule, the hedge,
    and the estimates as constants. Task 1 runs that strategy live on 2025–2026 and plots its equity with SPY
    and the trigger days. Task 2 places it among the 3,456 saved runs (Sharpe ratio against the largest
    drawdown). Task 3 runs it again with updated estimates (the default is practicum fund A: gamma by sector,
    Cobb-Douglas, hedge off, fixed estimates). Status (11-26, after the full-universe rerun): executed with no errors
    in about 4 min; the live run matches its saved row. Fund A ends at USD 101,746 with fixed estimates and
    USD 123,761 with updated estimates; SPY ends at USD 125,365. The "What do we see?" boxes and the Summary quote
    menu-wide counts from the saved file (762 of 3,456 runs beat SPY's Sharpe ratio, 651 also with a smaller
    drawdown; in 792 of 1,728 updated/fixed pairs the updated run ends with more wealth), so they hold for any
    strategy a student sets. The trigger legend uses the practicum's names (first, scheduled, market turn). These
    numbers change once more with Monday's data (see the Monday runbook). The include cell's output is cleared.
    Every doc anchor resolves except `load_l15a_market`, which appears once the docs rebuild with `CourseL15a.jl`.
  - *Stress-Testing a Strategy with the Five Gates.* Task 1 plots the strategy's equity band over the 200
    synthetic markets with SPY's band. Task 2 computes the five gates. The default is practicum fund A (hedge off,
    fixed estimates), so Task 3 turns the hedge on and computes the gates again. Status (11-26, from the draft
    200-market run): executed with no errors; the include cell's output is cleared. Its generator is
    `lectures/instructor/L15a-tools/make_stress_example.py` with `stress_facts.json` (the "What do we see?" and Key
    Takeaway text), and `stress_facts.jl` recounts the numbers. Because the strategy is student-set, the boxes and the Summary quote
    only menu-wide counts: 23 of the 756 stress tests pass all five gates, every other stress test fails the failure
    rate, SPY ends below W0 on 49 of the 200 markets and the 60/40 on 56, and in 75,600 hedge-off/on pairs the
    hedged run has the smaller drawdown in 41,852 and more wealth in 30,864. Fund A (not quoted): passes four gates
    and fails the failure rate by one market (21 of 200 below W0, limit 20); median Sharpe 1.10, drawdown 11.3%,
    median terminal USD 125,723 against the 60/40's USD 106,414, NPV USD 20,576. With the hedge on it fails the same
    gate (24 markets) and ends with more wealth on 47 of 200 markets. Monday: rerun `stress_facts.jl`, update the
    facts file, regenerate, and re-execute.
- **Picking files restyled (Claude).** `findall(==(x))`, `findfirst(==(x))`, and `sortperm(collect(zip(...)))`
  became explicit loops. `scripts/check_picking_files.jl` compares every picking file with the built-in screen on
  all 476 backtest days (random rules with seeds 1 and 7, both hand-picked lists): 5,712 baskets equal before and
  after the rewrite.
- **Practicum sync check (11-26, before the 200-market run).** Compared with the practicum's `src/Stress.jl`,
  `Backtest.jl`, and `config/defaults.toml` at `1515a62`.
  - *Fixed:* the runner drew market p with seed p. It now uses 5660 + p, the practicum's seed for path p. In both
    projects, paths 1 and 2 are bit-identical (same JumpHMM commit; the Distributions and StatsBase versions differ
    but draw the same numbers). The runner also saves each market's TLT closes, so the stress example can compute
    the practicum's 60/40 benchmark (60% SPY, 40% TLT, rebalanced on the first trading day of each month).
  - *Same in both:* 200 paths × 252 days from the 2026-11-24 closes; the five gates and their limits (median Sharpe
    ≥ 0.3, median drawdown ≤ 25%, failure rate ≤ 10%, median terminal wealth ≥ the comparison, median NPV ≥ 0); the
    Sharpe ratio (mean daily excess growth over its volatility, annualized); the drawdown; NPV = W_T exp(−Σ r Δt) − W_0
    over the 252 days; updated estimates carried from the fit through 2025–2026 into the synthetic year; EWLS
    half-life 63 days and prior weight 63 days; 5/25/50/75/95 percentile bands.
  - *Gate 4 (Claude's call, to match the practicum):* a strategy with updated estimates faces its copy with fixed
    estimates; a strategy with fixed estimates faces the 60/40 benchmark. Computed after the run from the saved rows
    and the SPY and TLT closes.
  - *Fill price:* L15a decides after the 2026-11-24 close and fills at the first synthetic price; the practicum buys
    at the first synthetic close, so both fill at the same price.
- **Practicum alignment (Jeff, 11-26: "yes go ahead, use fixed").** Everything outside the engine is the same as the
  practicum's; the engines differ by design, and the lecture says how in one table.
  - *Naming:* the estimates setting is `"fixed"` or `"updated"` ("frozen" is gone from the engine, tests, and scripts).
  - *Universe:* the practicum's full universe, 505 pickable tickers besides SPY; SGOV stays out (the generator does not
    model it). The 38 tickers that list after 2016-01-04 (latest GEHC, 2022-12-15) hold `NaN` before their first close.
    `fit_base_sim` fits each ticker on its own days, `shrinkage_loss` draws each anchor's baskets from the tickers
    listed over that anchor's windows, and `training_volume` takes the median over finite days. Every window a strategy
    reads during the backtest starts on 2023-11-29 or later, so no screen or limit sees a `NaN`.
  - *One dataset (done):* L15a copies the practicum's `data/prices.jld2` (commit `9a72d73`) byte for byte.
  - *Coming Monday 11-30 (practicum session):* the practicum's pull restarts DOW on 2019-04-02 and SMCI on 2020-01-14
    (`NaN` before; the flat zero-volume bars of the DowDuPont gap and the Nasdaq delisting go away), and the refit
    changes those two tickers' estimates and generator models. A new `prices.jld2` and `generator.jld2` come after
    Monday's close. The practicum session's answers (11-26):
    - The pull ends on 2026-11-30, and the practicum's stress test starts from the 2026-11-30 closes. The fit window
      stays 2016-01-04 to 2024-12-31.
    - The refit moves every synthetic market. Besides DOW and SMCI, it changes the IT and Materials factors and,
      through the Cholesky order, the Real Estate and Utilities series (4 of 11 sector models), `chol_L`, `μ`, every
      ticker's sector loadings, and every own-part model. The market model and the other 7 sector models stay.
  - *Monday runbook (after the practicum session sends the two SHA-1s):*
    1. Copy `data/prices.jld2` and `data/generator.jld2` from the practicum byte for byte, check both SHA-1s, and
       update `data/SOURCE.md` (commit, checksums).
    2. Set `_BACKTEST_STOP = Date(2026, 11, 30)` in `scripts/setup.jl`. The synthetic year follows the last loaded
       day, so it then starts after 2026-11-30. Update the "2026-11-24" comments in `setup.jl`, `synthetic.jl`,
       `run_strategies.jl`, and `check_picking_files.jl`.
    3. Smoke test: `run_strategies.jl --synthetic-only --paths 2 --strategies 4 --tag synccheck`; SPY and TLT on
       markets 1 and 2 must match the practicum's paths 1 and 2 (seeds 5661 and 5662). Delete the synccheck files.
    4. Run the picking and weighting checks, then `run_strategies.jl --real-only` (about 15 min with the three
       estimate settings, 5,184 runs; it also rewrites `L15a-Forecast-Models.jld2` from the new generator).
    5. Backtest example: set `run_stop = Date(2026, 11, 30)` and the "November 24" text, recount the "What do we
       see?" numbers and the Summary with `menu_facts.jl`, and re-execute.
       With the sector factor estimates (added 11-27), the menu has 486 strategies and 5,184 backtests: update
       "3,456" (cells 0, 20, 24, 33), "324" (cell 20), and the check `@assert nrow(df) == 3456` (cell 21). The 1,728
       updated-versus-fixed pairs stay 1,728. `menu_facts.jl` counts only those pairs, so add the sector factor
       pairs if the text should mention them. In the stress example, "756" (cells 4 and 32) becomes 1,134.
    6. Start the 200-market run (about 7 h: 1,134 runs per market with the sector factor estimates, added 11-27) and
       delete the timing10 files when it finishes. The saved summary no longer has the `combination` column, which
       keeps the file near 75 MB.
    7. Stress example: do NOT regenerate it with `make_stress_example.py`. That script still writes the old 30-cell
       example (checked 11-27), and the committed example (34 cells, utility basket and BAB) was edited after it.
       Edit the notebook by hand: the "November 24" text and the `Date(2026, 11, 24)` check. Recount the menu-wide
       numbers with `julia lectures/instructor/L15a-tools/stress_facts.jl <repo>` (it compares the updated and the
       sector factor runs with their fixed copies), update the "What do we see?" boxes, execute with nbconvert in
       place, and run `clear_include_output.py` on the result.
    8. Lecture: in `make_lecture.py`, update the two "November 24, 2026" mentions and the Summary's menu-wide
       statements (fewer than half, most strategies, few pass, about a quarter) if Monday's counts change them.
       Regenerate from the HEAD lecture, or apply the same edits by hand if Jeff has edited the notebook.
    9. Updating section and its example:
       - Run `julia lectures/instructor/L15a-tools/updating_facts.jl 2026-11-30 <scratch folder>`. It prints the
         new day number of the last day and JPM's last estimate. It also checks that most stocks still moved less
         with the market. The 2,263 count and the 1.12 stay, because the fit window is the same.
       - Update `data_edits` in `make_lecture.py` (day 476 and November 24, and the alt text if JPM's path
         changes).
       - Redraw the figure with `redraw_ewls_jpm.py <scratch folder> lectures/week-15/L15a/figs/Fig-L15a-EWLS-JPM.tex`
         and run `make` in `figs`, then update the figs README row.
       - Update the derivation, the L15a notation rows, and the deck frames for any changed number.
       - In the updating example, set `run_stop`, the load's `stop` and its check, and the "November 24" text.
         Then re-execute, check its three "What do we see?" boxes and the shared-ticker counts, and clear the
         include output.
  - *Draft 200-market run (Jeff, 11-26: "yes start the draft run now"):* started 11-26 on today's data and generator
    (about 85 s per market, about 4.7 h), so the stress example and the lecture can be built over the weekend.
    Monday night's run replaces its numbers.
  - *T-bill rate:* `load_l15a_market` uses the practicum's rule, the latest DTB3 rate on or before each day divided by
    100 (`_l15a_tbill_rates`), with no conversion and no lag.
  - *Lecture:* a short subsection compares the two engines in one table: triggers (2 of the 6, "scheduled" every 21
    trading days and "market turn"), weights ("your formula" vs "the same formula, adjusted by optimization to meet
    the trading limits"), fills (close vs next open), limits, and hedge.
  - *Examples start from practicum fund A:* "gamma by sector", "Cobb-Douglas", hedge off, fixed estimates. The
    backtest example's Task 3 now switches to updated estimates.
  - *Two-trigger version (optional):* no engine change needed. Settings `z = Inf` (band off), `D_max = 1.0`
    (drawdown off), and `beta_over_cap = Inf` (β trigger off) leave the 21-day and market-turn triggers; the cash
    revisit fires only after an all-cash decision, and with the hedge off the market turn is the sign change of ξ,
    as in the practicum.
- **Engine note (not changed).** The min-variance solve works in shares. At USD 100,000 its weights are accurate to
  about 0.007 (variance within 0.01% of the least); at USD 1,000 they are exact. Built-in and file runs are equal.
- **Lecture draft (Claude, 11-26 evening, on disk, not committed).**
  - Renamed with a plain `mv` to `CHEME-5660-L15a-Lecture-Testing-Trading-Strategies-Fall-2026.ipynb`. The text
    comes from `lectures/instructor/L15a-tools/make_lecture.py <HEAD lecture> <out> <alt1.txt> <alt2.txt>`. The
    alt texts are the two "Alt text" sections of `figs/README.md`.
  - Jeff's updating section and the advanced cell are word for word, except the "Picks at market turns" bullet,
    now "Picks when a trigger fires" with the six triggers. The old cell ids are kept.
  - New sections: Backtesting (strategy table, Backtest-Day figure, definition, algorithm, six-trigger table),
    Stress-Testing (Stress-Test figure, definition, algorithm, five-gate table, the fourth gate's comparison),
    Testing Your Fund in the Practicum (five-row engine table), and a new Summary.
  - Figures `Fig-L15a-Backtest-Day` and `Fig-L15a-Stress-Test` (TikZ, in `figs/` and the Makefile).
  - The strategy menu notebook, the README, and the Validation-Gates archive are done. The derivation notebook,
    `content.json` (title, link, rows for W_0, W(t), P, p), and `notation.html` (pinned Pandoc) point to the new name.
  - Both examples: wording fixes applied by `tighten_examples.py` to the generators and the executed notebooks
    (text only, outputs unchanged).
  - QA round 1 (brief `L15a-tools/qa-brief.md`): lecture 7.5, backtest 7.5, stress 7.0, menu 8.5. Fixes went
    into `make_lecture.py`, `make_backtest_example.py`, `make_stress_example.py`, and `stress_facts.json`.
    - The examples were re-executed. Every text output matched the earlier run, and the include output was cleared.
    - The backtest example computes `W_spy` and `spy_scores` once, in its settings cell.
    - The stress example has no `my_hedge` constant: Tasks 1 and 2 run hedge off. Its "What do we see?" boxes now
      say what depends on the constants.
    - The stress figure no longer draws a price history.
    - `tighten_examples.py` was a one-time edit, and its fixes are now in the generators. Do not rerun it.
  - QA rounds 2 and 3 (fresh reviewers each time):
    - Lecture: 8.4, then 8.5, with about 9.2 expected after round 3's fixes.
    - Backtest: 8.2, then 8.6. Stress: 8.5, then 8.6. Menu: 8.8, then 8.9.
    - What changed:
      - The generator is now defined at step 4c.
      - The stress-test first decision now comes after the start day's close.
      - "Weigh" is now "Weight", in the lecture and in the figure.
      - "About half" replaces "fewer than half". The 1,728 pairs count the random rules 30 times, and per strategy
        the share is 84 of 162.
      - The stress example uses `find_runs` in `src/Helper.jl` instead of four row filters. It was checked with
        `my_estimates = "updated"`.
      - Its `my_picking` example is now "liquid gamma". "random liquid" has no saved runs at seed 5660.
    - The gate tables keep three decimals: at two, the 0.105 failure rate prints as 0.10 against a 0.10 limit.
  - QA round 4 (one fresh reviewer, all four): lecture 8.5, backtest 8.5, stress 8.5, menu 9.0. Its fixes were
    applied, and there was no fifth round, because the scores had levelled off and the reviewers had started to
    reverse each other.
    - The menu link moved into the strategy table's header.
    - Step 4b lists the trading-cost limit.
    - "Back from cash" is described as the scheduled trigger after an all-cash decision. Both use τ ≥ 21.
    - "Fewer than half" is back: 792 of 1,728 backtests.
    - The stress example's Task 3 box sits after the gates table again, and it covers both wealth and drawdown.
    - The itinerary paragraphs in the example openers were kept, as in the L14a example.
    - Every text output was unchanged after each re-execution.
  - Converted to the practicum's data (11-26, Jeff: "I specifically asked you to make sure all was the same"):
    - The updating example now loads `prices.jld2` with `MPC.load_l15a_market`: 505 tickers, the 2016 to 2024
      fit, and data to November 24, 2026. It says "ticker" where a count covers the 14 ETFs.
    - The frozen section's numbers changed:
      - 2,263 daily growth rates and the sum from −2262;
      - day 476, November 24, 2026;
      - JPM 1.12 (it ends at 0.73);
      - 412 of 491 stocks moved less with the market.
    - The opening sentence says "on the training data", because the earlier lectures fit on 2014 to 2024.
    - The edits are in `make_lecture.py` (`data_edits`).
    - The other files changed:
      - the JPM figure (redrawn from 476 values);
      - the derivation;
      - the L15a notation rows (notation.html rebuilt);
      - the advanced and figs READMEs;
      - the staged deck frames.
    - `Include.jl` no longer defines `_PATH_TO_MARKET_DATA` or imports `Logging`.
    - Its two step plots got taller y-axes (2.8 and 1.75), so that the legends clear the baskets' average β.
    - All three "What do we see?" boxes still hold. The baskets share 12.0 and 4.2 of 36 tickers.

## Tasks (in order; engine tasks touch `code/src/mpc/StudyBacktest.jl`, so run them one at a time)
1. **Data in the engine.** Copy the practicum `generator.jld2`, `universe.csv`, `tbill.csv`, `nyse-holidays.csv`
   into L15a/data with a SOURCE.md (practicum commit and sha1). Add
   `load_l15a_market(data_dir; start, stop)::MyMarketData` (new `code/src/mpc/CourseL15a.jl`): the 468
   full-history tickers other than SPY, with ETF sector "ETF", g_f from tbill.
2. **Strategy hook (no number change).** `MyStudyRun` takes a screen object and a rule object. Replace the
   closure in `_solve_utility` with dispatch `utility_objective!(rule, m, x, γp)`. Proof: the L14a real run of
   CD hedge on/off is bit-identical to the L14a cache (scratch harness: session scratchpad `repick_test.jl`).
3. **Fixed or updated estimates.** Settings `estimates::String` ("updated" | "fixed") and `estimates_start::Date`.
   Fixed: `ctx.sim` α, β, σ_ε, σ_m are held at the calibration values on every row. Default updated with
   estimates_start = start reproduces the cache.
4. **One trigger list.** In `run_study`, every trigger (reason != :in_spec) re-plans and re-picks. Remove
   `repick_interval`, `repick_on_band_exit`, `repick_on_market_turn` (settings, study.toml, loader, 10 test refs).
5. **Picking files (8)** `lectures/week-15/L15a/strategies/picking/*.jl`: a plain function (vectors in, tickers
   out) + a type + an `MPC.pick` method. Test: identical baskets to the built-in screens on real-market days.
6. **Weighting files (9)** `strategies/weighting/*.jl`: the 7 INFORMS rules (objective in the file, the shared
   limits and solver in the engine; weights equal to the built-in within 1e-6), equal weight (= CD with equal γ),
   BAB (closest book to the Frazzini–Pedersen rank weights under the limits, signed, 130/30).
7. **Synthetic year.** Real history to 2026-11-24, then 252 NYSE days from the practicum draw with the drift;
   opens = closes; median 2016–2024 volume; g_f held at the 2026-11-24 rate. Forecast adapter from the practicum
   generator to the fields `build_forecast_models` reads (ETFs: the sector with the largest loading).
8. **Run script** `lectures/week-15/L15a/scripts/run_strategies.jl`: real 3,456 runs; synthetic 756 per path ×
   200 paths. Time 10 paths first and report to Jeff before the full run. Outputs: summary rows for every run,
   real daily equity, synthetic percentile bands per combination (under 100 MB per file).
9. **Examples (2) + strategy index notebook:** backtest from the menu, stress test with the five gates (Task 3
   changes one choice).
10. **Lecture:** backtest-loop and stress-loop p-code, six triggers + one list, the five gates replacing
    Validation and Compliance, 3 LOs / 3 KTs, notation, deck sync. The kept updating section is on the new data
    (done 11-26).
11. **17 strategy decks** (cut line: may follow during the practicum window).

Execution: subagent-driven (build-and-QA pipeline) once Jeff confirms.
