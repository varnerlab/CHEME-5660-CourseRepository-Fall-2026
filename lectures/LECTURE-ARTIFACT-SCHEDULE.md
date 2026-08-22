# CHEME 5660 lecture artifact schedule (Fall 2026)

This manifest is the authoritative scope, sequence, and artifact status for the
Fall 2026 lectures. It supersedes both the earlier workbook ordering and lecture
ordering inferred from the Fall 2025 folders.

The maintained model is one detailed notebook plus one concise slide deck per
substantive lecture. LaTeX notes retired on 2026-08-22 where both replacements
were complete. A temporary legacy note remains only where a notebook or slide
deck is still missing. L1a is a compact course and institutional orientation;
Fall Break (8a) and Thanksgiving Break (14b) do not require lecture artifacts.
The 7a slot, formerly held for a Goldman Sachs guest Q/A, is a production
lecture from Fall 2026 (decision of 2026-08-17: the guest was unconfirmed); if a
guest Q/A is confirmed it is delivered asynchronously and does not displace 7a.

| Lecture | Date | Unit | 2026 topic | Primary notebook substrate | Artifact status |
|---|---:|---:|---|---|---|
| 1a | Aug 25 | 1 | Course orientation, money flows, and the Federal Reserve | Introductory lecture material; no computational notebook required | Slides complete; no notebook or legacy notes required |
| 1b | Aug 27 | 1 | Time value of money, abstract assets, and net present value | `week-1/L1b` | Notebook and slides complete; legacy notes retired |
| 2a | Sep 1 | 1 | Pricing Treasury bills, notes, and bonds by NPV | `week-2/L2a` | Notebook and slides complete; legacy notes retired |
| 2b | Sep 3 | 1 | Yield, price sensitivity, duration, convexity, and the yield curve | `week-2/L2b`; deeper term-structure work in `advanced/` | Notebook and slides complete; root legacy notes retired; advanced notes retained |
| 3a | Sep 8 | 2 | Equity markets and stylized facts of growth rates | `week-3/L3a` | Notebook and slides complete; legacy notes retired |
| 3b | Sep 10 | 2 | Equity-price lattices under real-world and risk-neutral measures | `week-3/L3b` | Notebook and slides complete; legacy notes retired |
| 4a | Sep 15 | 2 | Lattice trade rules and probability of profit | `week-4/L4a` | Notebook and slides complete; legacy notes retired |
| 4b | Sep 17 | 2 | Single-asset geometric Brownian motion | `week-4/L4b` | Notebook and slides complete; legacy notes retired |
| 5a | Sep 22 | 2 | Multivariate GBM and Dirichlet portfolio weights | `week-5/L5a` | Notebook and slides complete; legacy notes retired |
| 5b | Sep 24 | 2 | Minimum-variance allocation, efficient frontier, CAL, and market portfolio | `week-5/L5b` | Notebook and slides complete; legacy notes retired |
| 6a | Sep 29 | 2 | Introduction to single-index models | `week-6/L6a` | Notebook and slides complete; legacy notes retired |
| 6b | Oct 1 | 2 | SIM-based risky/risk-free minimum-variance allocation | `week-6/L6b` | Notebook and slides complete; legacy notes retired |
| 7a | Oct 6 | 2 | Utility-based allocation and the adaptive rebalancing engine | `week-7/L7a`; utility allocator, engine, and drift examples on course data | Notebook, examples, and slides complete; legacy notes retired |
| 7b | Oct 8 | 2 | Online SIM estimation: updating the engine as data arrive | `week-7/L7b`; EWLS replay and scenario-ensemble examples on course data | Notebook, examples, and slides complete; legacy notes retired |
| 8b | Oct 15 | 3 | Option contracts: call/put payoff and profit | `week-8/L8b`; static-replication derivation in `advanced/` | Notebook, examples, and slides complete; legacy notes retired |
| 9a | Oct 20 | 3 | European option pricing with Black–Scholes–Merton | `week-9/L9a`; BSM and risk-neutral Monte Carlo example; SPXW skew notebook in `advanced/` | Notebook, examples, and slides complete; legacy notes retired |
| 9b | Oct 22 | 3 | American CRR pricing versus the European benchmark; intrinsic, extrinsic, and early-exercise value | `week-9/L9b`; CRR factor derivation in `advanced/` | Notebook, examples, and slides complete; legacy notes retired |
| 10a | Oct 27 | 3 | Option sensitivities: delta, gamma, theta, vega, and rho | `week-10/L10a` | Notebook complete; slides pending; legacy notes retained temporarily |
| 10b | Oct 29 | 3 | Probability of profit, composite contracts, and delta hedging | `week-10/L10b` | Notebook complete; slides pending; legacy notes retained temporarily |
| 11a | Nov 3 | 3 | Covered calls and cash-secured puts | `week-11/L11a` | Notebook complete; slides pending; legacy notes retained temporarily |
| 11b | Nov 5 | 3 | Standard-listed protective collars and defined-outcome ETFs: TJUL comparison | `week-11/L11b`; Wheel material in `advanced/` | Notebook complete; slides pending; legacy notes retained temporarily |
| 12a | Nov 10 | 4 | Stochastic multi-armed bandits and exploration versus exploitation | `week-12/L12a`; Markov/HMM material in `advanced/` | Replacement notebook and slides pending; legacy notes retained |
| 12b | Nov 12 | 4 | Binary Bernoulli bandit ticker picker | `week-12/L12b` | Notebook complete; slides pending; legacy notes retained temporarily |
| 13a | Nov 17 | 4 | Maximum-utility allocation and adaptive portfolio rebalancing | `week-13/L13a`; former Bandit/MWA lecture in `advanced/` | Notebook complete; slides and re-scope pending; legacy notes retained temporarily |
| 13b | Nov 19 | 4 | Market crashes and agent-based Wolfram Markets | `week-13/L13b` | Notebook complete; slides pending; legacy notes retained temporarily |
| 14a | Nov 24 | 4 | Building and testing the course Autotrader | `week-14/L14a` | Notebook complete; slides pending; legacy notes retained temporarily |
| 15a | Dec 1 | 4 | Autotrader laboratory: diagnostics, risk controls, and strategy iteration | `week-15/L15a`; EWLS-replay and validation-gate examples plus the policy-gradient derivation | Notebook complete; slides and re-scope pending; no legacy notes |
| 15b | Dec 3 | 4 | Final trading challenge, model review, and course synthesis | `week-15/L15b`; captured decision-queue example | Notebook complete; slides pending; no legacy notes |

## Calendar-sensitive content rules

- Every production title block includes the exact 2026 lecture date above.
- Notebook and slide titles and learning objectives follow the 2026 topic, even
  when a 2025 notebook folder uses a different emphasis.
- A notebook is linked only when its computations materially support the 2026
  topic. A historical notebook is not relabeled to conceal a content mismatch.
- Optional extensions live in an `advanced/` subfolder of the applicable
  lecture directory. L2b contains the former Week 3 yield-curve, stochastic-rate,
  and STRIPS material; L11b contains the Wheel lecture and supporting examples;
  L12a contains the Markov/HMM enrichment module; L7a contains the CES
  derivation; L7b contains the EWLS recursion derivation; L8b contains the
  static-replication theorem; L9a contains the SPXW parity and volatility-skew
  notebook; L9b contains the CRR factor derivation; L13a
  contains the former Bandit/MWA lecture; L15a contains the policy-gradient
  derivation.
- Fall Break remains L8a and Thanksgiving Break remains L14b; production topics
  do not move into those calendar slots. L7a is a production lecture from Fall
  2026; a Goldman Sachs guest Q/A, if confirmed, is delivered asynchronously.
- L15a and L15b are deliberately reserved for applied AI/trading work so the
  final course unit no longer depends on finishing new material in one meeting.
