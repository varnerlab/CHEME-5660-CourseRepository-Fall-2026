# Week 5 refactor — September 18, 2026

The instructor authorized the implementation in [week-5-reactor.md](../../week-5-reactor.md).
His latest direction separates L5a into three examples: move the reviewed L4b NPV
notebook, restore the reviewed original OoS notebook, and narrow the generated
notebook to EMA. In a subsequent request, he asked for the EMA parameter theory
in the lecture notebook, then requested a shorter proposition with a linked
derivation. The lecture now states the update result; rolling trade
calculations, simulations, and empirical scores remain in the separate example.
The existing slides retain their brief EMA example description.

This record documents implementation and verification. It does not assign a new
instructor review score or reopen a completed review.

## Latest correction: LaTeX rendering in VS Code

The instructor identified broken notation at the bottom of the lecture's EMA
material. The issue was reproduced using VS Code's installed notebook math
renderer: `year$^{-1}$` and `year$^{-2}$` caused inline math delimiters to be
misinterpreted, corrupting the following parameter symbols and prose. All eight
instances across the lecture, EMA example, and derivation now put the complete
unit inside math, such as `$\mathrm{year}^{-1}$`. Blank lines also separate
display equations from surrounding prose for Markdown-renderer compatibility.

The earlier custom preview extracted equations before Markdown parsing and
missed this failure. The corrected notebooks were checked using the installed
VS Code math plugin without that preprocessing, and separately using
markdown-it-texmath. All 29 displays render, and no raw math delimiters remain
in the rendered prose. The lecture proposition, example update section, and
derivation were inspected visually. Code cells, saved outputs, execution counts,
and metadata are unchanged. Evidence and before/after images are under
`build/notebook-previews/L5a-latex-repair/`.

## Previous correction: EMA of growth rates

The lecture proposition, derivation, and EMA example now use the course growth
rate `g_k=log(S_k/S_(k-1))/Delta_t` in inverse years. The EMA updates mean growth
and growth-rate variance directly, with initialization `m_s=mu_g,0` and
`v_s=sigma_0^2/Delta_t`. GBM volatility is recovered as `sqrt(v_k*Delta_t)`;
arithmetic drift remains `mu_g,k + sigma_k^2/2`. The lecture retains the concise
proposition and links to the full derivation.

`AdaptiveGBM.jl` implements these growth-rate states and exposes `mu_g` and
`variance_growth` with their units. The optional forecast-interval diagnostics
also use growth rates over the forecast window, in inverse years. Their widths
and scores change units accordingly; NPV, target events, and Brier scores retain
their meaning. The helper reference and implementation plan use the same convention.

The corrected EMA notebook executes top to bottom with fresh outputs. All 101
focused numerical assertions pass, including independent weighted growth moments,
volatility scaling, a change of observation duration, and forecast-band units.
Comparison with the previous implementation checks the default 21-day forecasts,
a one-day window, and a later entry. The parameter estimates and probabilities
agree to numerical precision, with identical target outcomes and interval coverage.
The reviewed NPV and OoS notebooks remain unchanged.

The lecture, derivation, and EMA example were rendered and checked after the
correction. Local links, three objectives and takeaways, the concise lecture
scope, and units were verified. Evidence is under
`build/notebook-previews/L5a-ema-growth-rate/`. Earlier checks below record the
preceding organization and example-split work.

## Follow-up: concise EMA proposition and linked derivation

The instructor approved the EMA content but found its lecture organization too
long. The lecture now presents one theorem-style proposition containing the
initialization, centered moment updates, and GBM parameter conversion, followed
by short explanations of half-life and forecast timing. The section is reduced
from 1,019 to 283 whitespace-delimited words. Its objective and takeaway now
refer to applying the result rather than deriving it in the lecture.

The detailed development is preserved in the new
[EMA derivation notebook](../week-5/L5a/advanced/ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb):
exponential weights and half-life, centered variance and GBM parameters, and
forecasts using the updated estimates. It reuses the prior lecture development
and links to the existing worked example and source helper. It is a mathematical
notebook with three objectives and three takeaways, without executable cells.

The previous theory addition also corrected two broken advanced-example links
to the existing L4b filenames. At that stage, the three computational examples, their code, and saved outputs
were unchanged. The 78 assertions passed during that addition. The subsequent
growth-rate correction above updates the EMA implementation and its outputs.

Both notebooks were rendered and checked for readable equations and section
structure. Local links, three objectives/takeaways, preservation of the moved
mathematical development, and unchanged example hashes were verified. QA is in
`build/notebook-previews/L5a-ema-proposition/`; the earlier lecture development
is also retained under `build/notebook-previews/L5a-ema-theory/`.
The notebook-only follow-ups did not rebuild the earlier companion slide deck
or local student bundle. Their checks below describe the preceding example split.

## Teaching locations

| Material | Current location |
| --- | --- |
| L5a: RenTec, single-asset review, and NPV | [Lecture](../week-5/L5a/CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb), [18-page slides](../week-5/L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.pdf) |
| Reviewed NPV example, moved from L4b | [GBM NPV trade rule](../week-5/L5a/CHEME-5660-L5a-Example-GBM-NPV-TradeRule-Fall-2026.ipynb) |
| Reviewed original OoS example, restored | [Out-of-sample GBM](../week-5/L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb) |
| Separate EMA example | [Updating GBM parameters](../week-5/L5a/CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb) |
| Supporting mathematical development | [EMA derivation](../week-5/L5a/advanced/ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb) |
| Reviewed multiple-asset lecture, formerly L5a | [L5b lecture](../week-5/L5b/CHEME-5660-L5b-Lecture-MultipleAsset-GBM-Fall-2026.ipynb), [37-page slides](../week-5/L5b/slides/CHEME-5660-L5b-Slides-Fall-2026.pdf) |
| Reviewed covariance example, formerly L5a | [L5b covariance example](../week-5/L5b/CHEME-5660-L5b-Example-CovarianceMatrix-Fall-2026.ipynb) |
| Reviewed Dirichlet example, formerly L5a | [L5b Dirichlet example](../week-5/L5b/CHEME-5660-L5b-Example-Dirichlet-PortfolioWeights-Fall-2026.ipynb) |
| Reviewed advanced covariance and rolling-correlation examples | [L5b advanced index](../week-5/L5b/advanced/README.md) |
| Original minimum-variance L5b, reserved for future L6a | [Archived material](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/) |

The [Week 5 index](../week-5/README.md), root README, and schedule entries 5a/5b
reflect these placements. Schedule dates and Week 6 topic entries remain unchanged
pending that separate refactor. Two prerequisite references in the existing Week 6
lecture/slides point to the archived minimum-variance example; its teaching
content was not revised. Incoming L4b and L5b NPV links now resolve to L5a.

## Preservation and reuse

The [archive](../archive/week-5-before-pivot-2026-09-18/README.md) preserves the
complete original Week 5: 84 regular files, 28,891,722 bytes, no symbolic links.
Its inventory records source revision
`af75badf5789f497e747173ca2daf783627bc911`, original working-tree status, sizes,
and SHA-256 hashes. The saved environment and review records accompany the
payload. Six files under the original figures' ignored `.build/` directories
are also preserved in a checked tarball so they survive a future Git checkout.

All 58 code cells in the four relocated computational notebooks, including
comments, saved outputs, execution counts, and metadata, match the archived
originals. The multiple-asset lecture's mathematical development is preserved.
Changes concern lecture identifiers, navigation, and future minimum-variance
placement. Its OoS description again describes the restored price-band example.

L5a reuses the reviewed single-asset review and full L4b NPV development:
purchase/sale scenario, scaled NPV, GBM substitution, lognormal distribution,
normal threshold, and terminal target probability. The 2025 NPV discussion
informed the two-cash-flow abstract-asset connection. Optional uncertainty and
Monte Carlo descriptions reuse the reviewed L4b passages. The slides reuse the
reviewed GBM and NPV frames and the original OoS example description. The RenTec
profile cites the firm's own overview without attributing the classroom model
to its proprietary methods.

### Moved NPV example

The NPV notebook retains its reviewed text, executable calculations, defaults,
metadata, and saved outputs. Only its prerequisite link and parameter-file paths
changed. Its tasks remain: calculate the probability, verify the median gives
one half, and vary the target. Defaults remain AAPL, 63 trading intervals,
`g_y=0.05`, and target `rho=-0.15`; the EMA defaults do not replace these.

L4b and L5a had slightly different parameter tables under the same filename.
The moved example therefore loads its original file from
`L5a/data/npv/SAGBM-Parameters-Fall-2025.csv`. That copy has the original SHA-256
`85c0dfc1ad9b8283754d4ad914b9fec5a229717bc62a548b028ed9edaa0fffad`.
The original L5a table remains in place for OoS and EMA.

### Restored OoS example

The active OoS notebook is byte-for-byte identical to the archived reviewed
original, with SHA-256
`639b0a8715690d8c0af40d2bdd3ffdd61f7c4196caea4bf1bb47a0f7b8c1189f`.
Its three tasks remain: simulate one asset during 2025, examine pointwise bands
and observed coverage, and compare coverage across the shared ticker universe.
Its full-year window, SPY default, 100 paths, and seed 5660 are retained.

Historical review handoffs retain their assessments and record current locations.
The original OoS and NPV reviews remain closed and do not certify new EMA material.

## Separate EMA example

The generated combined notebook was narrowed to three tasks:

1. Initialize mean growth and volatility from 2014–2024, update the daily
   growth-rate moments using EMA, and plot the parameter estimates.
2. Compare frozen estimates, updated volatility, and updated mean growth with
   volatility through daily target probabilities and matched GBM simulations.
3. Compare Brier losses on the same ticker/date pairs and summarize the differences.

The initial January-trade reveal, its standalone Monte Carlo probability check,
and the duplicate prediction-band tutorial were removed. The example links to
NPV and OoS for those prerequisites.

Defaults are SPY, entry row 1, a 21-observation forward window, `Δt=1/252`,
annual continuously compounded benchmark `g_y=0.05`, target `rho_star=0`,
EMA half-life 21 observations, 100 plotted paths, and random seed 5660.
The entry index and window remain editable, including a one-day forecast.

At origin row `k`, sale is at `k+H`; forecast uncertainty spans `H*Δt`, while
discounting spans `(k+H-s)*Δt` from the original entry row `s`. The purchase price
stays fixed. Both frozen and EMA probabilities change with the current price
and prospective sale date. EMA initializes from the training baseline at entry,
with its first increment from `s` to `s+1`; there is no hidden 2025 warm-up.
Parameters remain fixed within each forecast. Both updating methods use the
same centered variance state. Forecast generation is separate from scoring
future sale outcomes.

The evaluation contains 417 eligible tickers and 250 aligned observations per
ticker, January 2–December 31, 2025. The union of testing and parameter-table
tickers contains 483 names: 59 lack estimates and seven have incomplete or
unaligned dates. The notebook identifies this as a selected evaluation sample,
uses VWAP as a price proxy, and excludes dividend cash flows from NPV.

The default comparison has 229 origins per ticker, or 95,493 forecasts per method.
Mean Brier losses are 0.11678 for frozen parameters, 0.11622 for EMA volatility,
and 0.12227 for EMA mean plus volatility. Differences from frozen are −0.00056
and +0.00549; respectively 48.441% and 38.369% of tickers improve. These are
paired descriptive comparisons with dependent, overlapping outcomes. The
example does not claim that EMA must help or that improved probabilities imply
higher trading profits. Numerical results remain in the example and this record.

## Verification

- The complete archive passes its SHA-256 inventory comparison. The restored
  OoS file and moved NPV content/input checks establish preservation directly.
- All seven active computational notebooks have executed top to bottom with
  Julia 1.12.7. The three L5a examples were executed after this split; the four
  unchanged relocated L5b examples passed during the preceding refactor.
  Reviewed notebooks were executed into evidence copies, preserving their
  original active outputs. EMA has fresh saved outputs.
- [Focused Julia checks](../../scripts/check-week5-adaptive.jl) now pass 101 assertions
  covering weighted EMA moments, prefix causality, initialization, shared
  variance, indexing, strict target events, deterministic limits, benchmark
  monotonicity, realized NPV, Brier/interval scores, and Monte Carlo agreement.
- Every active lecture/example has three objectives and three takeaways; the
  seven computational notebooks have three tasks. Relative links, local helper
  anchors, source dependencies, and slide targets resolve.
- The L4b, L5a, and L5b slides rebuild. Week 5 has 18 and 37 pages respectively,
  with no overfull or underfull box warnings. The revised lecture, three example
  notebooks, and changed slides are rendered and visually inspected. EMA figures
  have readable labels and common price limits across simulation panels.
- The local `week-05.1` student bundle is rebuilt with all three examples,
  including the separate NPV parameter file. ZIP integrity, checksum, resource,
  relative-link, and archive-exclusion checks pass. Extracted-bundle execution
  verifies NPV and EMA at entry row 1 / horizon 1 and entry row 30 / horizon 21.
  The EMA variants have 249 and 200 complete origins per ticker respectively.
- Local QA evidence is under ignored `build/notebook-previews/week-5-refactor/`
  and `build/notebook-previews/week-5-example-split/`.

## Deferred work

Week 6 authoring remains separate: L6a will reuse the archived data-driven
minimum-variance material; L6b will combine SIM estimation and SIM portfolios.
Bootstrap is reserved for SIM. The 2025 source inventory and reuse decisions
remain in [the plan](../../week-5-reactor.md). The original minimum-variance
notebooks and slides have not been rewritten.

No release was published, Git tag created, commit made, or remote updated.
