# Fall 2026 Course Schedule Workbook Update Instructions

## Purpose

Update `CHEME-5660-CourseSchedule-Fall-2026.xlsx` so that its lecture topics and unit boundaries match the current Fall 2026 production sequence in [`lectures/LECTURE-ARTIFACT-SCHEDULE.md`](lectures/LECTURE-ARTIFACT-SCHEDULE.md).

The lecture artifact manifest is the source of truth. It explicitly supersedes the earlier workbook ordering and any ordering inferred from Fall 2025 materials.

## Source workbook

`/Users/jeffreyvarner/Library/Mobile Documents/com~apple~CloudDocs/CHEME-5660-Instances/CHEME-5660-LectureSlides-Fall-2026/CHEME-5660-CourseSchedule-Fall-2026.xlsx`

All changes below apply to `Sheet1`.

## Editing rules

1. Preserve the existing dates in column `E`; they already match the Fall 2026 calendar.
2. Preserve the event identifiers in column `C`, including Fall Break and Thanksgiving Break.
3. Preserve the workbook's existing formatting, row heights, column widths, date formats, and borders.
4. Update the lecture-topic cells in column `F` using the table below.
5. Update the unit assignments and section-header locations described below.
6. Do not automatically rewrite problem-set, practicum, or office-hour rows. Attendance and asynchronous-delivery rows follow the confirmed policies below.
7. After editing, verify that no formulas or links contain errors and visually inspect the complete schedule.

## Unit headers and assignments

### Unit 1

- Change `A3` to `Unit 1: Quantitative Finance Foundations and Marketable Treasury Securities`.
- Keep lectures `1a` through `2b` in Unit 1.

### Unit 2

- Keep the existing Unit 2 header in `A16`.
- Change `B12` and `B13` from Unit 1 to Unit 2.
- Unit 2 lecture content begins with `3a` and continues through `7b`.

### Unit 3

- Place `Unit 3: Modeling and Analysis of Equity Derivatives` in `A34`, the blank separator row immediately before Fall Break and the first Unit 3 lecture.
- Clear the obsolete Unit 3 header from `A39:G39` while retaining the row as a blank separator.
- Change `B36` and `B40` to Unit 3. The remaining Unit 3 lecture rows already use Unit 3.
- Unit 3 lecture content begins with `8b` and continues through `11b`.

### Unit 4

- Place `Unit 4: Modeling and Analysis of Financial Decision-Making` in `A53`, the blank separator row immediately before `12a`.
- Clear the obsolete Unit 4 header from `A58:G58` while retaining the row as a blank separator.
- Change `B54`, `B55`, and `B56` to Unit 4.
- Unit 4 lecture content begins with `12a` and continues through `15b`.

## Confirmed lecture-topic replacements

| Cell | Event | Date | Replacement topic |
|---|---|---|---|
| `F4` | 1a | Aug 25 | Course orientation, money flows, and the Federal Reserve |
| `F5` | 1b | Aug 27 | Time value of money, abstract assets, and net present value |
| `F7` | 2a | Sep 1 | Pricing Treasury bills, notes, and bonds by net present value |
| `F8` | 2b | Sep 3 | Yield, price sensitivity, duration, convexity, and the yield curve |
| `F12` | 3a | Sep 8 | Equity markets and stylized facts of growth rates |
| `F13` | 3b | Sep 10 | Equity-price lattices under real-world and risk-neutral measures |
| `F17` | 4a | Sep 15 | Lattice trade rules and probability of profit |
| `F18` | 4b | Sep 17 | Single-asset geometric Brownian motion |
| `F22` | 5a | Sep 22 | Multivariate GBM and Dirichlet portfolio weights |
| `F23` | 5b | Sep 24 | Minimum-variance allocation, efficient frontier, capital allocation line, and market portfolio |
| `F26` | 6a | Sep 29 | Introduction to single-index models |
| `F27` | 6b | Oct 1 | SIM-based risky/risk-free minimum-variance allocation |
| 7a row (Oct 6) | 7a | Oct 6 | Utility-based allocation and the adaptive rebalancing engine (was: Goldman Sachs recorded Q/A; changed 2026-08-17, guest unconfirmed) |
| `F32` | 7b | Oct 8 | Online SIM estimation: updating the engine as data arrive |
| `F36` | 8b | Oct 15 | Option contracts: call and put payoff and profit |
| `F40` | 9a | Oct 20 | European option pricing with Black–Scholes–Merton |
| `F41` | 9b | Oct 22 | American CRR pricing versus the European benchmark; intrinsic, extrinsic, and early-exercise value |
| `F45` | 10a | Oct 27 | Option sensitivities: delta, gamma, theta, vega, and rho |
| `F46` | 10b | Oct 29 | Probability of profit, composite contracts, and delta hedging |
| `F49` | 11a | Nov 3 | Covered calls and cash-secured puts |
| `F50` | 11b | Nov 5 | Standard-listed protective collars and defined-outcome ETFs: TJUL comparison |
| `F54` | 12a | Nov 10 | Stochastic multi-armed bandits and exploration versus exploitation |
| `F55` | 12b | Nov 12 | Binary Bernoulli bandit ticker picker |
| `F59` | 13a | Nov 17 | Maximum-utility allocation and adaptive portfolio rebalancing |
| `F60` | 13b | Nov 19 | Market crashes and agent-based Wolfram Markets |
| `F64` | 14a | Nov 24 | Building and testing the course Autotrader |
| `F68` | 15a | Dec 1 | Autotrader laboratory: diagnostics, risk controls, and strategy iteration |
| `F69` | 15b | Dec 3 | Final trading challenge, model review, and course synthesis |

## Rows to retain as scheduled events

Keep these events and dates unchanged:

- `8a`, Oct 13: Fall Break; no lecture.
- `14b`, Nov 26: Thanksgiving Break.
- All Sunday problem-set, practicum, and office-hour rows unless separately revised.

The `7a`, Oct 6 row is no longer a guest event (2026-08-17): its topic cell takes the
lecture topic above and its unit is Unit 2; if the Goldman Sachs Asset Management Q/A is
confirmed it is delivered asynchronously and noted in the notes column, not in the topic.

## Confirmed attendance schedule

Attendance begins in week 3, after the early-semester enrollment churn. Use one
in-person attendance check per instructional week, balanced across Tuesdays and
Thursdays. Do not mark asynchronous or break meetings for attendance.

- Tuesday: `3a`, `5a`, `7a`, `9a`, `12a`, and `15a`.
- Thursday: `4b`, `6b`, `8b`, `10b`, `11b`, and `13b`.
- No attendance check in weeks 1–2 or week 14. Asynchronous rows `3b`, `11a`,
  and `14a` use the short Canvas quiz instead.

## Confirmed asynchronous-delivery notes

Every asynchronous lecture includes a short Canvas quiz associated with the
assigned video and supporting work.

- `3b`, Sep 10: asynchronous video and short Canvas quiz because JV travels on
  Sep 10 for the Cornell Financial Engineering Manhattan AI & Future of Finance
  Conference on Sep 11.
- `11a`, Nov 3: asynchronous video and short Canvas quiz while JV attends the
  2026 INFORMS Annual Meeting in San Francisco.
- `14a`, Nov 24: asynchronous video and short Canvas quiz before Thanksgiving
  Break, which begins on Nov 25; describe this as pre-Thanksgiving rather than
  as occurring during the break.

## Problem-set rows requiring a separate review

The authoritative lecture manifest does not define the problem-set sequence, so the following cells should not be changed solely from the lecture schedule:

- `F9`: Problem Set 1
- `F19`: Problem Set 2
- `F28`: Problem Set 3
- `F42`: Problem Set 4
- `F51`: Problem Set 5
- `F61`: Problem Set 6
- `F66`: Practicum problem

In particular, confirm whether PS1 should still reference lattice interest-rate models and whether PS4 should remain a minimum-variance portfolio problem after the revised Unit 3 transition.

## Verification checklist

- [ ] Dates in `E4:E70` remain unchanged and retain their date formatting.
- [ ] Lecture identifiers in column `C` remain unchanged.
- [ ] Unit 1 contains `1a` through `2b`.
- [ ] Unit 2 contains `3a` through `7b`, with `7a` a production lecture (no guest-event distinction).
- [ ] Unit 3 begins with `8b` and ends with `11b`.
- [ ] Unit 4 begins with `12a` and ends with `15b`.
- [ ] Fall Break and Thanksgiving Break remain in their original calendar slots.
- [ ] The revised topics agree exactly with `lectures/LECTURE-ARTIFACT-SCHEDULE.md`.
- [ ] Problem-set descriptions were either intentionally approved or left unchanged.
- [ ] No `#REF!`, `#VALUE!`, `#NAME?`, `#N/A`, or other formula errors are present.
- [ ] Text is readable without clipping, and the existing visual style is preserved.
