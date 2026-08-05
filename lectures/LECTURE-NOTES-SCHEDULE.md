# CHEME 5660 production lecture-notes schedule (Fall 2026)

This manifest is the authoritative scope and sequence for production lecture
notes. It records the revised Fall 2026 sequence and supersedes both the earlier
workbook ordering and lecture ordering inferred from the Fall 2025 folders.

The notes target contains 27 course lectures. L1a provides a compact course and
institutional orientation; the Goldman Sachs guest Q/A (7a), Fall Break (8a),
and Thanksgiving Break (14b) do not require production theory notes.

| Lecture | Date | Unit | 2026 topic | Primary notebook substrate | Notes status |
|---|---:|---:|---|---|---|
| 1a | Aug 25 | 1 | Course orientation, money flows, and the Federal Reserve | Introductory lecture material; no computational notebook required | Built; visual QA passed |
| 1b | Aug 27 | 1 | Time value of money, abstract assets, and net present value | `week-1/L1b` | Built; visual QA passed after L1a split |
| 2a | Sep 1 | 1 | Pricing Treasury bills, notes, and bonds by NPV | `week-2/L2a` | Built; visual QA passed |
| 2b | Sep 3 | 1 | Yield, price sensitivity, duration, convexity, and the yield curve | `week-2/L2b`; deeper term-structure work in `advanced/` | Built; visual QA passed after reorg |
| 3a | Sep 8 | 2 | Equity markets and stylized facts of growth rates | `week-3/L3a` | Built; visual QA passed after reorg |
| 3b | Sep 10 | 2 | Equity-price lattices under real-world and risk-neutral measures | `week-3/L3b` | Built; visual QA passed after reorg |
| 4a | Sep 15 | 2 | Lattice trade rules and probability of profit | `week-4/L4a` | Built; visual QA passed after reorg |
| 4b | Sep 17 | 2 | Single-asset geometric Brownian motion | `week-4/L4b` | Built; visual QA passed after reorg |
| 5a | Sep 22 | 2 | Multivariate GBM and Dirichlet portfolio weights | `week-5/L5a` | Built; visual QA passed after reorg |
| 5b | Sep 24 | 2 | Minimum-variance allocation, efficient frontier, CAL, and market portfolio | `week-5/L5b` | Built; visual QA passed after reorg |
| 6a | Sep 29 | 2 | Introduction to single-index models | `week-6/L6a` | Built; visual QA passed after reorg |
| 6b | Oct 1 | 2 | SIM-based risky/risk-free minimum-variance allocation | `week-6/L6b` | Built; visual QA passed after reorg |
| 7b | Oct 8 | 2 | Dynamic rebalancing of minimum-variance portfolios | `week-7/L7b`; course-native stress-testing example added | Built; eCornell stress-testing concepts integrated |
| 8b | Oct 15 | 3 | Option contracts: call/put payoff and profit | `week-8/L8b` | Built; visual QA passed after reorg |
| 9a | Oct 20 | 3 | European BSM and American CRR option pricing | `week-9/L9a` | Built; visual QA passed after reorg |
| 9b | Oct 22 | 3 | Intrinsic and extrinsic value of American options | `week-9/L9b` | Built; visual QA passed after reorg |
| 10a | Oct 27 | 3 | Option sensitivities: delta, gamma, theta, vega, and rho | `week-10/L10a` | Built; visual QA passed after reorg |
| 10b | Oct 29 | 3 | Probability of profit, composite contracts, and delta hedging | `week-10/L10b` | Built; visual QA passed after reorg |
| 11a | Nov 3 | 3 | Covered calls and cash-secured puts | `week-11/L11a` | Built; visual QA passed after reorg |
| 11b | Nov 5 | 3 | Standard-listed protective collars and defined-outcome ETFs: TJUL comparison | `week-11/L11b`; Wheel material in `advanced/` | Built; visual QA passed after reorg |
| 12a | Nov 10 | 4 | Stochastic multi-armed bandits and exploration versus exploitation | `week-12/L12a`; Markov/HMM material in `advanced/` | Built; visual QA passed after reorg |
| 12b | Nov 12 | 4 | Binary Bernoulli bandit ticker picker | `week-12/L12b` | Built; visual QA passed after reorg |
| 13a | Nov 17 | 4 | Maximum-utility allocation and adaptive portfolio rebalancing | `week-13/L13a`; former Bandit/MWA lecture in `advanced/` | Built; adaptive-utility lecture and examples integrated |
| 13b | Nov 19 | 4 | Market crashes and agent-based Wolfram Markets | `week-13/L13b` | Built; visual QA passed after reorg |
| 14a | Nov 24 | 4 | Building and testing the course Autotrader | `week-14/L14a` | Built; visual QA passed after reorg |
| 15a | Dec 1 | 4 | Autotrader laboratory: diagnostics, risk controls, and strategy iteration | `week-15/L15a`; EWLS and validation-gate examples plus derivations | Built; production lecture and course-native examples added |
| 15b | Dec 3 | 4 | Final trading challenge, model review, and course synthesis | `week-15/L15b`; captured decision-queue example | Built; credential-free production workflow added |

## Calendar-sensitive content rules

- Every production title block includes the exact 2026 lecture date above.
- Notes titles and learning objectives follow the 2026 topic, even when a 2025
  notebook folder uses a different emphasis.
- A notebook is linked only when its computations materially support the 2026
  topic. A historical notebook is not relabeled to conceal a content mismatch.
- Optional extensions live in an `advanced/` subfolder of the applicable
  lecture directory. L2b contains the former Week 3 yield-curve, stochastic-rate,
  and STRIPS material; L11b contains the Wheel lecture and supporting examples;
  L12a contains the Markov/HMM enrichment module; L13a contains the former
  Bandit/MWA lecture and the CES derivation; L15a contains online-learning
  derivations.
- The Goldman Sachs guest Q/A remains L7a, Fall Break remains L8a, and
  Thanksgiving Break remains L14b. Production topics do not move into those
  calendar slots.
- L15a and L15b are deliberately reserved for applied AI/trading work so the
  final course unit no longer depends on finishing new material in one meeting.
