# L15a build handoff from Codex

November 25, 2026. Tasks 0–5 are complete in the shared course worktree on `main`, based on `511a5c3`.
Resume at Task 6, the nine weighting files. The practicum has supplied the drift-enabled generator pin for Task 7. [Implementation plan](L15a-PLAN.md) · [Design](L15a-DESIGN.md)

## Completed work

- **Market data.** `MPC.load_l15a_market(data_dir; start, stop)` in `code/src/mpc/CourseL15a.jl` reads the aligned Alpaca opens and volumes with the practicum's closes. It fixes the universe at 468 pickable tickers, including 13 ETFs, across all date slices. SPY supplies benchmark and hedge prices. The loader uses the course engine's DTB3 conversion and publication lag with the practicum's `tbill.csv`. [Data provenance](../week-15/L15a/data/SOURCE.md)
- **Strategy interface.** `build(MyStudyRun, (settings=s, allocator=rule, screen=screen, seed=seed))` accepts strategy objects or the existing named selectors. The shared utility solve calls `utility_objective!(rule, m, x, γp)` for the rule's cone constraints and objective. The solver and trading limits stay in the engine.
- **Estimate modes.** `estimates="frozen"` holds the training SIM parameters and market volatility fixed. `estimates="updated"` runs EWLS. `estimates_start=nothing` resolves to the run's `start`. For the synthetic year, set `estimates_start=Date(2025, 1, 2)` and set `start` to the first synthetic date to carry the estimate history into the trial.
- **One trigger list.** The study loop picks and decides on the same trigger, with identical dates and reasons in `repicks` and `decisions`. The three separate re-pick settings are gone from `study.toml` and `study_v1.toml`. Live reruns with v1 forecast and hedge settings also use the new trigger list.
- **Picking files.** `lectures/week-15/L15a/strategies/picking/` contains eight standalone rules with plain ticker-returning functions and `MPC.pick` methods. The correlation screen retains the built-in fallback that fills a short basket in score order. The two hand-picked lists come from `study.toml`.

## Verification

- The market snapshot passed 22 checks. It contains 2,740 trading days, including 476 from January 2, 2025 through November 24, 2026. Its closes match the practicum array exactly.
- Before the trigger change, named and object-based Cobb–Douglas runs reproduced the two L14a cached equity paths bit for bit with the hedge on and off. The new trigger list intentionally changes the live schedule. The v1 fixture now verifies the initial decision and first fill from the original run.
- All eight picking files matched the built-in baskets across the 476 real-market days. That is 4,284 comparisons including both hand-picked lists. Two Cobb–Douglas smoke runs used the GBM forecast and passed in both estimate modes.
- The final MPC suite passed 2,161 checks with one existing skip. Run it from the course repository root. The compiled-module option lets Julia use the installed dependencies in a sandbox that restricts writes to the home depot.

```sh
OMP_NUM_THREADS=1 KMP_GTID_MODE=2 julia --compiled-modules=existing --project=code --startup-file=no code/test/mpc/runtests_mpc.jl
```

## Practicum generator for Task 7

The sibling worktree `../CHEME-4660-5660-Practicum-Fall-2026` has the reviewed generator on local `practicum-build` at `80ea80bb5545f3cdd3b2290cd73b87a72d23aaa4`. Include `src/Generator.jl` from that pin with `data/beta-drift.csv` in its checkout-relative location. The source resolves the CSV relative to `@__DIR__`.

`load_generator(path::String)` returns the fitted models and ticker order. `synthetic_growth(generator, days::Int, seed::Int)` returns annualized growth rates with one row per day and columns in `generator.tickers` order. Map SPY and the 468 pickable columns by ticker before appending the 252 synthetic sessions.

The L15a `data/generator.jld2` matches the pinned file byte for byte. The practicum reports 39 generator checks and a standalone run passing. The pinned loader applies intercept shrinkage and β drift to 491 stocks and preserves the same-seed ETF paths, including SPY.

## Resume here

1. **Task 6.** Add nine files in `strategies/weighting/`. Match the seven built-in rules within `1e-6`. Equal weight and BAB need the actual basket membership because a picked ticker can also be in the hedge pool. The `hedge` flag alone cannot identify pool-only columns.
2. **Task 7.** Wire the pinned generator into the synthetic-year builder and adapt the factor forecast. Use 252 NYSE sessions after November 24, 2026, the last real close as each price base, open equal to close, the median 2016–2024 volume, and the last real T-bill rate.
3. **Task 8.** Build the runner for 3,456 real runs and 756 combinations per synthetic market. Time 10 paths and report the timing to Jeff before launching the 200-path run. Follow the plan for cache contents and file sizes.
4. **Tasks 9–11.** Build the examples and strategy index, update the lecture and deck, and prepare the per-rule decks in the order recorded in the plan.
