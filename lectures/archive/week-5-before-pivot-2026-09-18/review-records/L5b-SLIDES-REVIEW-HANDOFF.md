# L5b lecture slides — completed interactive polish

**Status: reviewed and complete September 17, 2026.** The instructor approved
every section, ending with individual approval of “Estimating Portfolio Inputs,”
“Optional Advanced Material,” “Summary,” and the closing transition. All approved
changes are saved; no slide proposals remain pending. Final editorial score:
**9.2/10**, from **8.2/10**. Do not restart completed sections unless another
round is requested.

The instructor explicitly confirmed the completed review with
“Ok - record this as reviewed.”

- [Final slide PDF](../week-5/L5b/slides/CHEME-5660-L5b-Slides-Fall-2026.pdf)
- [Beamer source](../week-5/L5b/slides/CHEME-5660-L5b-Slides-Fall-2026.tex)
- [Aligned lecture notebook](../week-5/L5b/CHEME-5660-L5b-Lecture-MAGBM-Data-Portfolios-Fall-2026.ipynb)
- [Lecture review and September 17 scope amendment](L5b-LECTURE-REVIEW-HANDOFF.md)

The native Beamer/XeLaTeX workflow, course theme, and font sizes were preserved.
The deck expanded from 24 to 30 pages to separate mathematical steps and their
interpretation. It remains a companion to the lecture notebook, with the title
first and disclaimer second. The instructor requested the same section-by-section
review used for [L5a](L5a-SLIDES-REVIEW-HANDOFF.md).

## Assessment

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and lecture alignment | 8.1 | 9.3 |
| Organization and sequence | 8.8 | 9.3 |
| Narrative and interpretation | 8.0 | 9.2 |
| Presentation | 8.4 | 9.3 |
| Density and note-taking | 7.5 | 9.0 |
| Overall | 8.2 | 9.2 |

These are editorial judgments. The principal improvements are consistent
growth-rate notation, clearer distinctions between optimization and buy-and-hold
wealth, explicit constraint reasoning, and concrete explanations of two-fund
separation and borrowing. The frontier and tangent derivations still require
deliberate classroom pacing and spoken explanation.

## Approved changes

- Kept exactly three objectives on one slide. The instructor repeatedly requested
  tighter wording and specified 70–80 words. The final bullets contain 75 words,
  including their labels, and preserve the notebook's conceptual scope. Example
  links use descriptive titles rather than long filenames.
- Separated multiple asset GBM, covariance estimation, and wealth/scaled NPV.
  Used `mu_g` for model means and `g-prime` for estimated means. Distinguished
  growth-rate covariance `Sigma_g` from covariance rate `C`, including units and
  `C = Delta t Sigma_g`. Retained a closing sentence after the GBM bullets.
- Separated expected growth, exact buy-and-hold wealth, portfolio variance, and
  two-asset diversification. The weighted-growth model chooses weights; fixed
  share counts determine the subsequent wealth calculation. Defined the NPV
  benchmark as `g_y`.
- Explained the conversion from growth rates to log returns, including covariance
  and target scaling. Distinguished growth-rate standard deviation from volatility
  and stated the units used on the lecture's risk axis.
- Made explicit that the closed-form GMV problem allows shorts and has no growth
  constraint. Put the Lagrange-multiplier derivation on a separate slide. Presented
  the long-only quadratic program and explained constraints in sequence: first
  obtain long-only GMV, then impose the growth floor.
- Distinguished the full target-growth frontier from its efficient branch.
  Retained the approved vector frontier figure. Explained the practical long-only
  sweep, low targets that return GMV, and infeasible targets above the largest
  sample mean. Omitted the proposed standalone “Sweeping a Growth Floor” slide
  because the instructor found it unclear and questioned its need.
- Developed the capital allocation line, interval versus annualized Sharpe ratios,
  and tangent weights in separate slides. Preserved the positive-definite
  covariance and GMV-growth conditions for the tangent closed form. Annualization
  uses `sqrt(tau/Delta t)` with `tau = 1 year`, under independent increments and
  constant parameters.
- Reused the approved vector CAL figure and updated the Makefile to build it.
  Preserved concise lending, fully risky, and borrowing bullets. The instructor
  tried expanded bullets, then explicitly requested the original shorter version.
- Rewrote two-fund separation as two choices: choose the risky asset mix, then
  choose how much wealth to invest in it. Explained borrowing rules with $100 of
  wealth, a $150 risky investment, and a $50 loan. The no-borrowing and higher-rate
  cases connect financing opportunities to the choice of risky fund.
- Replaced the long estimation-risk discussion with the approved notebook treatment:
  covariance versus mean inputs, the AMD estimate comparison, underestimated
  variance, evaluation on 2025 prices, and the portfolio-simulation example.
- Replaced advanced-notebook filenames with descriptive links and question-led
  explanations. Identified the frontier example's 50% position-magnitude limit
  and the estimation example's evaluation of long-only allocations on the same
  2025 prices. Kept three summary takeaways and a direct transition to SIM.

## Scope and instructor preferences

- **The course proceeds to SIM, not CAPM.** Remove the market-portfolio/CAPM
  identification from this lecture. The instructor explicitly authorized matching
  notebook edits with “Yes, align the notebook too.” The CAPM section and its
  Objective 3 and Takeaway 3 references were removed from the notebook; two-fund
  separation now leads directly to input estimation. Other notebook content and
  metadata were preserved. The lecture handoff records this narrow amendment.
- Keep explanations concrete and economical. The instructor rejected abstract
  borrowing descriptions; preserve the approved dollar example. Do not restore
  expanded CAL figure bullets or the redundant growth-floor slide.
- Preserve the instructional sequence and intermediate mathematics while reducing
  repeated prose. Keep lead-ins and useful closing sentences around bullet lists.
  Do not shrink the course fonts to fit more text.
- Preview links should be separate and PNGs opened in VS Code for review. Approved
  sections remain closed unless the instructor requests another round.

## Final validation

- The canonical `make slides` build succeeded with 30 pages, no overfull or
  underfull boxes, and no unresolved-reference warnings.
- The canonical source exactly matches the approved final draft. Text extracted
  from all 30 canonical PDF pages matches that draft's PDF.
- Rendered and individually inspected every final slide at 1440-pixel width.
  No clipping, overlap, missing mathematics, or unintended title wrapping was
  found. The original course fonts and figure styling were retained.
- Verified three objectives, three takeaways, title/disclaimer order, and absence
  of CAPM references and legacy mean macros in slide content.
- All eight notebook-link occurrences resolve to six existing repository targets;
  both figure files resolve. This checks local destinations, not remote HTTP
  availability.
- The explicitly aligned lecture notebook remained unchanged during final slide
  application. Its scope edit passed schema, structure, preservation, and visual
  checks, as recorded in the lecture handoff. No Julia computation was rerun for
  this slide review.
- Scoped whitespace checks passed. Other concurrent notebook work was preserved.
  No commit or push was made.

Final source SHA-256:
`61f2686b564a1c5b76cda98a6a9e687f269ebdb789276358de43bbfcc21d8cb5`

Final PDF SHA-256:
`c96a90fea2122e1a417de9f73d7a9af8b60dc23abb4485ce5989a46ce171972f`

Aligned lecture notebook SHA-256:
`d0fb3ae529194f004f9da166f2dcb05ab65b4ecafeecceb1ee2f50777f7913a5`

Detailed approvals, drafts, previews, compile logs, and final validation are in
`build/notebook-previews/L5b-slides-review/`. That ignored directory is disposable;
this handoff is the durable record. No further slide review is pending.
