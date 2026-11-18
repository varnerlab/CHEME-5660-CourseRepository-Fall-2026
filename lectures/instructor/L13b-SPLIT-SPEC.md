# L13b split and the week-13 move to JumpHMM 0.5.0 (design, approved 2026-11-18)

## Intent
L13b becomes only the multi-asset extension of the jump hidden Markov model. All trading material leaves
L13b. It is parked for now; L14a will later tie the multi-asset model to a Markowitz problem with growth
rates and covariance that change over time, the utility allocation, and a short Alpaca demo. Students
asked about timescale, which the optional one-minute notebook answers. L13b is released on
2026-11-19 as week-13.2.

## Goals
- The L13b lecture covers the single-asset review and the sector factor model of many stocks.
- A new out-of-sample example serves as the refresher for the single-asset model.
- Week 13 (L13a and L13b) runs on JumpHMM 0.5.0 with the same numbers as 0.4.1.

## Non-goals
- L14a content (planned after this release).
- The one-minute notebook (a follow-up release, after the Alpaca SDK can pull 2025 one-minute bars).
- Porting the parked controller code to 0.5.0.

## Constraints
- The week-13.2 ZIP copies the whole week-13 folder, so L13a ships ported to 0.5.0 in the same release.
  The ZIPs students already downloaded keep their 0.4.1 environment and keep working.
- Ported notebooks show the same numbers as before (0.5.0's only number changes are the Hellinger
  distance, `tune` keeping a model's own `p_neg`/`N_tail`, and a Frank copula at θ = 0).
- Follow the weekly release checklist, the notebook style guide, and the example rules (exactly three
  tasks, each returned variable named as `name::Type`, function links at first use, no lecture numbers in
  student text).

## Approaches considered
- Stay on JumpHMM 0.4.1 this semester and migrate between semesters: nothing to push, but the new examples
  would be written in the old interface and ported later.
- Move week 13 to 0.5.0 now (chosen by the instructor): the new examples are written once in the new
  style; JumpHMM 0.5.0 is pushed (done 2026-11-18, `6b18ead`), and the projects that follow JumpHMM
  `main` are pinned first (eCornell, cobb-douglas, heston; done locally).

## Decisions
- Lecture title: "L13b: Synthetic Markets of Many Stocks". Kept: the opening and learning objectives
  (rewritten for the new scope), the review of the single-asset model, the sector factor model with its
  sampling algorithm and the drifting β option, the AQR company profile, the summary, and the disclaimer.
  Removed and parked: Building an Adaptive Trading System, Portfolio Allocation with Trading Limits,
  Keeping the Estimates Current, and Model-Predictive Rebalancing. The deck follows the lecture.
- Parked in `lectures/archive/week-13-L13b-trading-2026-11-18/`: the two MPC examples, their scripts and
  data, `code/src/mpc/Synthetic.jl`, a copy of the lecture, and a 0.4.1 environment. The rest of the course
  package (allocators, covariance, mean-variance code) stays.
- Example 1, out-of-sample `SPY` (the refresher), first in the Examples list. It loads the L13a `SPY` model
  (fit on 2014–2024) and the 2025 and 2026 daily data (2026 through the instructor's November 13 pull).
  - Task 1: compare the out-of-sample growth rates with the model's simulated paths.
  - Task 2: turn the jump episodes off and compare both models on the same test data.
  - Task 3: compare volatility clustering (ACF of |g| with the 95% band).
- Example 2: the sector factor example, ported to 0.5.0.

## Left to the builder
Figure details within the course figure style; exact wording, in the instructor's voice and reusing his
text; the validation settings (number of paths) within the notebook's run-time budget.
