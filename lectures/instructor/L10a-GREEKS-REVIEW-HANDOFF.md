# L10a Greeks update and review — October 11, 2026

> **Superseded on October 12, 2026.** The instructor found this update poorly organized, and L10a was rebuilt from his Fall-2025 L11a text. See [the L10a rebuild spec](L10a-REBUILD-SPEC.md). The files described below are archived in `lectures/archive/week-10-L10a-before-rebuild-2026-10-12/`. The package code (`BinomialSensitivities.jl`) is kept.

**Status: the authorized updates are implemented and checked; awaiting instructor review.**
The instructor approved the two proposed improvements and chose a reusable
Leisen–Reimer implementation in the shared Julia package, with CRR remaining the
default. The approved scope is the lecture, both examples, and this handoff.
L10a has no slide deck; creating one remains a separate task. This record does
not close the instructor's review.

## Assessment

These are Codex editorial and technical assessments of the corresponding
snapshots, not independent reviewer scores.

| Material | Before | After | Main reason for the change |
| --- | ---: | ---: | --- |
| Lecture | 7.5 | 9.1 | Explicit Greek units and time convention, numerical methods, analytic benchmarks, and position hedge signs |
| NVDA Greeks example | 8.0 | 9.1 | Fresh outputs, CRR/LR convergence checks, American-put refinement, and price-change estimates checked against repricing |
| TSLA probability example | 7.5 | 9.0 | Reproducible simulation, an independently specified analytic distribution, and a clear distinction between terminal moneyness and exercise |
| Legacy notes | 9.0 | 9.0 | Unchanged; retained temporarily as before |

The initial overall assessment was 7.5/10. The updated teaching materials now
meet the requested 9/10 threshold in this assessment.

## Update 1: conventions and a worked price-change calculation

The lecture defines Delta, Gamma, calendar-time Theta, Vega, and Rho as raw
derivatives of a per-share option premium. A table converts annual Theta to a
daily quote and Vega/Rho to quotes per percentage point. Signed contract counts
and the usual 100-share multiplier convert these into position exposures. A
long position's Delta exposure and its offsetting stock hedge have opposite
signs: the hedge is −100 n Delta shares for signed contract count n.

The local price-change formula retains the Gamma term and uses positive elapsed
calendar time. The lecture introduces central differences and all five
non-dividend-paying European BSM Greek formulas before the example uses them.
It also distinguishes the package's existing finite-change functions from raw
central derivatives. Their numerical implementations are unchanged; their
docstrings now describe the actual conventions and rounding limits.

The NVDA example keeps the historical contracts, the individual call and put
Greek calculations, and the long/short comparison. Historical broker quotes are
reported as comparisons rather than enforced as mathematical correctness
tests. All saved outputs were regenerated. The previously saved Gamma values
were stale: the existing node-slope CRR calculation now returns approximately
0.0152709 for the call and 0.0150508 for the put, close to the historical quotes.
The new central-difference study is a separate numerical comparison.

Task 3 adds Delta-only and Delta–Gamma estimates against full repricing for six
stock-price changes. For a +5 USD/share move, the full one-contract call change
is approximately 264.862 USD. The Delta-only error is −18.822 USD and the
Delta–Gamma error is +0.250 USD. A joint stock, volatility, rate, and one-day
time change then shows all five contributions and the remaining approximation
error (about −0.774 USD per contract).

## Update 2: Leisen–Reimer and numerical validation

The correct name is **Leisen–Reimer**. The lecture explains why CRR's changing
strike alignment can produce oscillating finite-difference Greeks, then gives
the odd-step Peizer–Pratt method-2 construction and the resulting up/down
factors. The factors depend on the strike and perturbed inputs, so each bumped
price rebuilds its tree. American early-exercise boundaries can still affect
smoothness; Leisen–Reimer is not presented as a universal guarantee.

The shared package adds `binomial_premium` and `binomial_greeks` in
`code/src/BinomialSensitivities.jl`, exports them, and documents them in
`code/docs/src/derivatives.md`. Both support European and American vanilla calls
and puts, with optional continuous dividend yield. `method=:crr` is the default;
`method=:leisen_reimer` selects LR. An even LR step count is increased by one.
Prices retain full precision, use O(h) storage, and ignore the contract's sense,
copy count, and recorded premium when computing the unit long-option value.
Greeks are raw central derivatives with explicit perturbation sizes.

The NVDA example compares CRR/LR across tree depths with fixed bumps, checks all
five call Greeks against BSM, varies both depth and spot perturbation for the
American put, and plots Delta/Gamma against spot. At 801 LR steps, the call
price error is about −8.16e−7 USD/share; Delta/Gamma errors are approximately
−3.02e−5 and −3.02e−6 with the displayed 1% spot perturbation. The remaining
finite-difference error does not disappear merely by adding tree steps.
For the American put, 1,601 to 3,201 LR steps changes the price by about
−6.68e−5 USD/share. This is a refinement check, not an analytic solution.

The TSLA example retains its historical screenshot and three parameter choices.
Scenario 2 remains selected. A fixed seed makes its 50,000-path simulation
reproducible. The analytic GBM endpoint distribution is specified from the model
parameters before looking at simulated endpoints; the fitted LogNormal remains
a visual comparison. The KS diagnostic now compares with the specified analytic
distribution, and a Monte Carlo standard-error check replaces an assertion that
a KS p-value must exceed 0.01. All probabilities use the analytic distribution.
The default seller POP is approximately 0.706433; the sampled value is 0.70734,
about 0.445 Monte Carlo standard errors away. Terminal ITM probability is
distinguished from actual exercise/assignment and from Delta. The established
`POE-POP` filename remains for link compatibility.

## Verification and review evidence

- Both computational notebooks were executed from L10a with their actual local
  `Include.jl`: all 40 NVDA and 22 TSLA code cells passed. Their fresh outputs are
  saved in the teaching notebooks. The two seeded TSLA executions produced
  identical saved outputs. The other two parameter scenarios also passed.
- The new package tests passed 90 checks covering independent European prices
  and all five Greeks, multiple spots and dividend yields, American exercise,
  existing CRR agreement, odd/even LR behavior, position-field independence,
  and invalid inputs. The focused regression run passed 162 checks.
- The full package run passed 2,075 checks with no numerical test failures,
  then stopped because Aqua was not available on that run's active load path.
  Running the installed Aqua separately passed all 11 QA checks. Thus 2,086
  checks passed across the two complementary runs; the full invocation itself
  was not a clean exit. No dependency files were changed for this workaround.
- Documenter built successfully with strict documentation checks; both new API
  anchors resolve in the generated site. Documentation has not been deployed.
  Public links to the new anchors require the normal documentation publication.
- All three notebooks pass nbformat validation, relative-link checks, three
  learning-objective/three-takeaway checks, and section-rule checks. Both
  examples have three tasks. Assertions use the prescribed final checks block.
- Markdown/math previews were generated with the installed VS Code notebook
  KaTeX renderer, with no math-rendering errors. Separate PDF proofs were
  inspected for prose and equations, and the saved plots were inspected at
  full size. PDF proofs omit code/output cells; executed notebook outputs and
  figures were checked separately.

Before snapshots, executed copies, rendering proofs, figures, and verification
logs are retained in the gitignored directory
`build/notebook-previews/L10a-updates-2026-10-11/`. The 2025 predecessor notebooks
were consulted before editing. Unrelated L9a/L9b and shared-package work in the
workspace was preserved. No commit, push, slide creation, or deployment was
performed as part of this update.

## Snapshot hashes

The SHA-256 values below identify the reviewed L10a snapshot and its new
package implementation and tests.

| File (relative to repository root) | SHA-256 |
| --- | --- |
| `lectures/week-10/L10a/CHEME-5660-L10a-Example-Greeks-PutCall-NVDA-Fall-2026.ipynb` | `8a34c33b85498ce75a85ab0c1ed5988af6b70271e6bcd74bba66ae108fe34c0d` |
| `lectures/week-10/L10a/CHEME-5660-L10a-Example-POE-POP-TSLA-Call-Fall-2026.ipynb` | `0adc5545670485fd1b359b4dc5599b59b8a2aeeb218dcfbac71afd5a9372a37b` |
| `lectures/week-10/L10a/CHEME-5660-L10a-Lecture-American-Derivatives-Greeks-Fall-2026.ipynb` | `d738fcd117037da218a697d98461364c50ffcf1921cee4d958f3d0418d535a5f` |
| `code/src/BinomialSensitivities.jl` | `3c06b01353f804aee100871ff3c45c124f5e337c720ad11634ff195e53d65f6d` |
| `code/test/test_binomial_sensitivities.jl` | `7884b72596ebc747d36037604d88c1e9c5ad511a8c02b738db3f9453dddbe0e4` |
