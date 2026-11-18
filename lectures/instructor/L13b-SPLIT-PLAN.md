# L13b Split and Week-13 JumpHMM 0.5.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Release week-13.2 on 2026-11-19 with L13b as the multi-asset lecture, a new out-of-sample `SPY` example, and week 13 running on JumpHMM 0.5.0 with unchanged numbers.

**Architecture:** Park the trading material in one archive folder, move the course environment to JumpHMM `6b18ead`, port the two released week-13 examples, add one new example, rewrite the L13b lecture and deck around the sector factor model, then build and test the release bundle.

**Tech Stack:** Julia 1.12 notebooks (nbconvert, kernel `julia-1.12`), JumpHMM.jl 0.5.0, the course package `VLQuantitativeFinancePackage` (`code/`), LaTeX Beamer deck.

**Spec:** `lectures/instructor/L13b-SPLIT-SPEC.md`

## Global Constraints
- Ported notebooks show the same numbers as before; 0.5.0's only number changes are the Hellinger distance, `tune` keeping a model's own `p_neg`/`N_tail`, and a Frank copula at θ = 0.
- Calls are qualified (`JumpHMM.build`, `JumpHMM.tune`, …); no commented-out 0.4.1 code.
- Examples have exactly three `## Task N:` sections, each opening with one sentence on what it does; every returned variable is named as `name::Type`; new library calls get a function link at first use; no lecture numbers in student text; never start a sentence with a symbol.
- Commit through a temporary `GIT_INDEX_FILE` (other sessions edit this repo); never push or tag without the instructor's go-ahead.
- Follow `WEEKLY-RELEASE-CHECKLIST.md` for the bundle; run the include test from outside the bundle.

## Review Focus
- A data file still holding a 0.4.1 object (`.jld2` in `lectures/week-13/*/data`) fails to load in the 0.5.0 bundle: grep every reader and regenerate every file week 13 reads.
- A released notebook shows output its code no longer produces: re-execute every edited notebook and compare text outputs with the pre-port copy.
- The L13b lecture, deck, README, or FAQ notation still links to a parked example, section, or figure: grep for every moved file name and removed heading.
- The instructor's 2026 data pull lands under a new file name: update `MyTestingMarketDataSet`, `MARKET-DATA.md`, and the out-of-sample example together.
- The bundle loads files from outside the week-13 folder (for example `../L13a/data`): the out-of-sample example reads its own `L13b/data` copy of the `SPY` model.

---

### Task 1: Park the trading material (dispatched 2026-11-18)

**Files:** `lectures/archive/week-13-L13b-trading-2026-11-18/` (new); moves from `lectures/week-13/L13b/` and `code/src/mpc/Synthetic.jl`.

- [ ] Agent moves the two MPC examples, scripts, data, and `Synthetic.jl`; copies the lecture; snapshots the 0.4.1 environment; removes the `Synthetic.jl` include.
- [ ] Verify: `julia --project=. -e 'using VLQuantitativeFinancePackage'` loads; course package tests pass; the agent's list of remaining references goes to Task 6.
- [ ] Commit (agent).

### Task 2: Switch the course environment to JumpHMM 0.5.0

**Files:** `Project.toml`, `code/Project.toml`, `Manifest.toml`.

- [ ] Set `[sources] JumpHMM` `rev = "6b18ead…"` (full hash) and `[compat] JumpHMM = "0.5"` in both Project files.
- [ ] Run `julia --project=. -e 'using Pkg; Pkg.update("JumpHMM")'`; check `git diff Manifest.toml` touches only the JumpHMM entry (and new dependencies of JumpHMM, if any).
- [ ] Verify: the course package loads; course package tests pass.
- [ ] Commit.

### Task 3: Port the L13a `SPY` example

**Brief:** `scratchpad/week13-port/l13a-port-brief.md` (session scratchpad).
**Produces:** `lectures/week-13/L13a/data/JumpHMM-SPY-2014-2024.jld2` and its `L13b/data` copy, each holding a 0.5.0 `MyJumpHiddenMarkovModel` under key `model`.

- [ ] Port, re-execute, compare outputs with the pre-port copy (all equal except run times), commit (agent).

### Task 4: Port the sector factor example

**Brief:** `scratchpad/week13-port/l13b-sectorfactor-port-brief.md`.

- [ ] Port, re-execute, compare outputs (all equal except run times and any Hellinger values), regenerate its saved files, commit (agent).

### Task 5: Build the out-of-sample `SPY` example

**Files:** Create `lectures/week-13/L13b/CHEME-5660-L13b-Example-JumpHMM-SPY-OutOfSample-Fall-2026.ipynb`.
**Consumes:** `lectures/week-13/L13b/data/JumpHMM-SPY-2014-2024.jld2` (Task 3); `MyTestingMarketDataSet(year = 2025)` and `(year = 2026)`.

- [ ] Setup: load the model and settings; the 2025 and 2026 `SPY` closes; growth rates with the model's `Δt` and the same risk-free convention as L13a.
- [ ] Task 1: simulate paths the length of the test window and compare the out-of-sample growth rates with them (histogram of observed against simulated, `JumpHMM.validate` pass rates).
- [ ] Task 2: a `deepcopy` of the model with `ϵ = 0.0`; score both models on the same test data and compare.
- [ ] Task 3: ACF of |g| over 252 lags for the test data and the simulated paths (simulations as lines, 95% band).
- [ ] Verify: executes without error; three tasks; style checks in Global Constraints.
- [ ] Commit.

### Task 6: Rewrite the L13b lecture, deck, and README

**Files:** Rename `CHEME-5660-L13b-Lecture-MPC-Allocation-Fall-2026.ipynb` to `CHEME-5660-L13b-Lecture-JumpHMM-ManyStocks-Fall-2026.ipynb`; `lectures/week-13/L13b/slides/`; `lectures/week-13/L13b/README.md`; FAQ notation entries.

- [ ] Title "L13b: Synthetic Markets of Many Stocks"; opening and learning objectives for the new scope; Examples list (out-of-sample `SPY` first, then the sector factor example); remove the four trading sections; Summary for the new scope. Reuse the instructor's text; word-level edits only elsewhere.
- [ ] Move figures used only by the removed sections to the archive; fix every reference from Task 1's list.
- [ ] Deck mirrors the lecture; compile it.
- [ ] Commit.

### Task 7: QA

- [ ] Fresh reviewers score each new or changed notebook and the deck 0–10 against the style guide; fix every item until each scores at least 9.

### Task 8: Release week-13.2

- [ ] Follow `WEEKLY-RELEASE-CHECKLIST.md`: build the ZIP, test it from outside the bundle (every week-13 notebook's include runs), annotated tag `week-13.2`, draft release. Push and tag only after the instructor's go-ahead; the instructor publishes.
