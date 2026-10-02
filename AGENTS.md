# Repository Working Agreements

## Week 7 pivot — October 1, 2026

- The former L7a utility-allocation and rebalancing material now teaches as
  L7b. The former L7b online-SIM and scenario-ensemble material is deferred in
  `lectures/archive/week-7-before-pivot-2026-10-01/`, with no new date assigned.
- New L7a resumes L6b at minimum-variance portfolios with SIM inputs: a concise
  theory review and the risky-assets example, followed by the risk-free asset,
  tangent portfolio, capital allocation line, and risky/risk-free example.
  BlackRock is the draft company profile.
- The client interview stays in L6b. Copy its `data/my-tickers.csv` and
  `data/my-client.toml` into L7a's local `data` folder after the interview, or use
  the examples' existing hardcoded defaults. Do not relocate the interview to
  L7a or make the Week 7 bundle depend on a Week 6 relative path.
- Read [the refactor handoff](lectures/instructor/WEEK-7-REFACTOR-HANDOFF.md)
  before follow-up work. Existing L6b review scores belong to their recorded
  snapshots; this structural refactor does not constitute a new polish review.

## Lecture and Example Notebooks

- Before authoring, editing, or reviewing course notebooks, read [the shared notebook style guide](lectures/instructor/NOTEBOOK-STYLE-GUIDE.md). It records the September 10, 2026 reset and the reference passages from CHEME 5660 Fall 2025 and CHEME 5820 Spring 2026.
- Preserve the instructor's teaching voice, explanatory steps, and mathematical rigor. This guide supersedes conflicting older notebook-style skills and review prescriptions; do not run legacy style auto-fixes against it. Slide production is outside this reset.
- Use the three-underscore horizontal rule at major-section boundaries immediately before a new level-two heading, and always end the final Summary and the closing Disclaimer and Risks section with it (instructor decision, September 29, 2026). Do not use it between level-three subsections.
- Include exactly three learning objectives in every lecture and example notebook.
- Include exactly three key takeaways in every lecture and example notebook.

## Week 5 refactor — September 18, 2026

- The original Week 5 is preserved in `lectures/archive/week-5-before-pivot-2026-09-18/`.
- The reviewed multiple-asset L5a material now teaches as L5b. The original minimum-variance L5b material is archived for the planned Week 6 refactor.
- New L5a covers single-asset GBM and NPV. Keep its **EMA theory as a concise theorem-style proposition** with the assumptions, update equations, and brief interpretation. The instructor liked the theory but requested a much shorter lecture section; the detailed development is preserved in the linked [EMA derivation notebook](lectures/week-5/L5a/advanced/ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb). Simulations, rolling trade calculations, and empirical scores remain in the separate worked example.
- Write all EMA estimates in terms of the course growth rate `g_k = log(S_k/S_(k-1))/Delta_t`, in inverse years. Initialize growth-rate variance as `sigma_0^2/Delta_t` and recover GBM volatility as `sqrt(v_k*Delta_t)`. Keep equations, code, labels, and units aligned; do not recast this material in terms of returns.
- L5a uses three separate examples: the NPV trade-rule notebook moved from L4b, the restored reviewed OoS notebook from the original L5a, and an EMA example narrowed from the generated combined notebook. Preserve the restored notebooks' reviewed content. Keep the lecture theory consistent with the EMA example and its local helpers.
- Read [the refactor handoff](lectures/instructor/WEEK-5-REFACTOR-HANDOFF.md) before follow-up work. Historical review scores refer to their saved snapshots, not to newly authored content.

## Completed L4a first-passage example review

- The L4a first-passage example review was completed September 13, 2026, with
  a score of 9.0/10. The [saved review record](lectures/instructor/L4a-FIRST-PASSAGE-REVIEW-HANDOFF.md)
  records the assessment, checks, and preferences. No proposals remain pending;
  read it before follow-up work and do not restart completed sections unless
  the instructor requests another round.

## Completed L4a N-ary example review

- The L4a N-ary example polish round was completed September 13, 2026, with a
  final score of 9.1/10. The [saved review record](lectures/instructor/L4a-NARY-REVIEW-HANDOFF.md)
  records accepted revisions and preferences. No proposals remain pending;
  read it before follow-up work and do not restart completed sections unless
  the instructor requests another round.

## Completed L4a execution-aware example review

- The L4a execution-aware example was reviewed September 13, 2026, with a
  score of 9.2/10. The requested polish was conditional on an initial score
  below 9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4a-EXECUTION-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b lecture review

- The L4b GBM lecture interactive review was completed September 11, 2026.
  [The saved review record](lectures/instructor/L4b-INTERACTIVE-REVIEW-HANDOFF.md)
  records approved edits, notation, and preferences. Read it before follow-up
  work; do not restart completed lecture sections. Companion examples still
  need the mean-growth notation aligned when their own review is requested.

## Completed L4b parameter example review

- The L4b parameter-estimation example polish round was completed September 13,
  2026, with a final score of 9.0/10. The
  [saved review record](lectures/instructor/L4b-PARAMETERS-REVIEW-HANDOFF.md)
  records the approved engineering assumption, wording preferences and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  completed sections unless the instructor requests another round.

## Completed L4b lattice-limit example review

- The L4b lattice-to-GBM example was reviewed September 13, 2026, with a score
  of 9.0/10. The requested polish was conditional on an initial score below
  9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4b-LATTICE-LIMIT-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b drift-uncertainty example review

- The L4b drift-uncertainty example was reviewed September 13, 2026, with a
  score of 9.1/10. The requested polish was conditional on an initial score
  below 9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4b-DRIFT-UNCERTAINTY-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b Monte Carlo example review

- The L4b Monte Carlo target-probability example was reviewed September 13,
  2026, with a score of 9.1/10. The requested polish was conditional on an
  initial score below 9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4b-MONTE-CARLO-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b first-passage example review

- The L4b GBM first-passage example was reviewed September 13, 2026, with a
  final score of 9.2/10. The
  [saved review record](lectures/instructor/L4b-FIRST-PASSAGE-REVIEW-HANDOFF.md)
  records the shorter Task 2, documented source functions, figure corrections,
  code-commenting pass, and validation. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L5a covariance example review

- The L5a covariance example was marked reviewed and complete September 14,
  2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-COVARIANCE-REVIEW-HANDOFF.md)
  records the approved sections, figure revisions, and validation. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5a single-asset GBM and NPV lecture review

- The new single-asset GBM and NPV L5a lecture was marked reviewed and complete
  by the instructor September 18, 2026, with a final editorial score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-SAGBM-NPV-REVIEW-HANDOFF.md)
  records the approved company profile, example callouts, prediction-band
  explanation, concise EMA wording, instructor preferences, and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  accepted sections unless the instructor requests another round. This review
  is separate from the earlier multiple-asset lecture review below.

## L5a single-asset GBM and NPV slides synchronization

- The current 22-page single-asset L5a deck was synchronized with the reviewed
  lecture and polished September 19, 2026, at the instructor's request, with
  a final editorial score of 9.2/10. The
  [saved record](lectures/instructor/L5a-SAGBM-NPV-SLIDES-REVIEW-HANDOFF.md)
  records the company resources, concise EMA theory, and rendered-slide checks.
  The instructor subsequently requested removal of the standalone “Pointwise
  Prediction Bands” slide; do not restore it. The 9.2/10 score describes the
  preceding 23-page snapshot. Read it before follow-up work. The instructor has
  not yet separately marked this slide review complete. The September 16
  slides review below covers the former multiple-asset deck, now taught as L5b.

## Completed L5a NPV trade-rule example polish review

- The GBM NPV trade-rule example, moved from L4b to L5a, was marked reviewed
  and complete by the instructor September 19, 2026, with a final editorial
  score of 9.1/10 (initial 9.0/10). The
  [saved review record](lectures/instructor/L4b-NPV-REVIEW-HANDOFF.md) records
  the approved objectives, explicit GBM-to-price-distribution explanation,
  equation formatting, parameter comments, figure label, and final checks.
  No proposals remain pending; read it before follow-up work and do not restart
  accepted sections unless the instructor requests another round.

## Completed L5a EMA example polish review

- The single-asset EMA example was marked reviewed and complete by the instructor
  September 18, 2026, with a final editorial score of 9.1/10 (initial 8.8/10). The
  [saved review record](lectures/instructor/L5a-EMA-REVIEW-HANDOFF.md)
  records the approved update explanations, shortened forecast section,
  simulation interpretation, Brier example, score interpretation, instructor
  feedback, and validation. No proposals remain pending; read it before
  follow-up work and do not restart accepted sections unless another round
  is requested.

## Completed L5a lecture review

- The L5a multiple-asset GBM lecture was marked reviewed and complete September 14,
  2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5a-LECTURE-REVIEW-HANDOFF.md)
  records the approved notation, derivations, instructor feedback, and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  completed sections unless the instructor requests another round.

## Completed L5a lecture slides review

- The L5a lecture slides were reviewed and completed September 16, 2026, with
  a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-SLIDES-REVIEW-HANDOFF.md) records
  the approved 37-page deck, L4a style reference, notation, practical Dirichlet
  explanations, portfolio-growth approximation, instructor preferences, and
  final checks. No slide proposals remain pending; read it before follow-up
  work and do not restart approved sections unless another round is requested.

## Completed L5a out-of-sample example review

- The L5a out-of-sample single-asset GBM example was marked reviewed and complete
  September 14, 2026, with instructor confirmation and a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-OOS-REVIEW-HANDOFF.md) records
  the histogram correction, shared ticker selection, three-task organization,
  documented helpers, instructor preferences, and validation. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5a Dirichlet example review

- The L5a Dirichlet portfolio weights example was marked reviewed and complete
  by the instructor on September 14, 2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-DIRICHLET-REVIEW-HANDOFF.md)
  records the approved terminology, table and figure revisions, annotated wealth
  derivation, and validation. No proposals remain pending; read it before
  follow-up work and do not restart completed sections unless the instructor
  requests another round.

## Completed L5a advanced covariance-estimation review

- The L5a advanced covariance-estimation example was marked reviewed and complete
  by the instructor September 14, 2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5a-ADVANCED-COVARIANCE-REVIEW-HANDOFF.md)
  records the approved spectral diagnostics, sampling-error explanation, figures,
  source functions, code-cell organization, and optimization closing. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5a rolling-correlation example review

- The L5a rolling-correlation example was marked reviewed and complete by the
  instructor September 14, 2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5a-ROLLING-CORRELATION-REVIEW-HANDOFF.md)
  preserves the earlier accepted sections, resumed assessment, source helpers,
  figure and mathematical checks, and preferences. No proposals remain pending;
  read it before follow-up work and do not restart completed sections unless
  the instructor requests another round.

## Completed L5b lecture review

- The L5b minimum-variance portfolio lecture was marked reviewed and complete
  by the instructor September 15, 2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5b-LECTURE-REVIEW-HANDOFF.md) records
  the approved frontier and CAL sections, concise input-estimation discussion,
  closing revisions, instructor preferences, and validation. No proposals remain
  pending; read it before follow-up work and do not restart completed sections
  unless the instructor requests another round.

## Completed L5b lecture slides review

- The L5b lecture slides were marked reviewed and complete by the instructor
  September 17, 2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5b-SLIDES-REVIEW-HANDOFF.md) records
  the approved 30-page deck, growth-rate notation, constraint and borrowing
  explanations, concise closing, and final checks. The instructor specified
  SIM rather than CAPM and authorized matching notebook scope edits. No slide
  proposals remain pending; read the record before follow-up work and do not
  restart approved sections unless another round is requested.

## Completed L5b minimum-variance example review

- The L5b data-driven minimum-variance example was marked reviewed and complete
  by the instructor September 16, 2026, with a final score of
  9.1/10. The [saved review record](lectures/instructor/L5b-MINVAR-REVIEW-HANDOFF.md)
  records the approved three-task organization, notation, optimization explanations,
  figures and tables, wealth/NPV distinction, closing, and validation. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5b multiple-asset GBM example review

- The L5b multiple-asset GBM portfolio example was marked reviewed and complete
  by the instructor September 16, 2026, with a final score of
  9.2/10. The [saved review record](lectures/instructor/L5b-MAGBM-REVIEW-HANDOFF.md)
  records the approved simulation and drift explanation, allocation and wealth
  development, pointwise bands, NPV table, source helper, preferences, and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  completed sections unless the instructor requests another round.

## Completed L5b advanced frontier-geometry review

- The L5b advanced frontier-geometry example was marked reviewed and complete
  by the instructor September 16, 2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5b-ADVANCED-FRONTIER-REVIEW-HANDOFF.md)
  records the derivations, two-fund construction, constraint comparison, figure
  preferences, explicit 50% position-limit terminology, and final validation.
  No proposals remain pending for this notebook; read the record before follow-up
  work and do not restart completed sections unless the instructor requests
  another round. The advanced estimation-risk review is also complete; see below.

## Completed L5b advanced estimation-risk review

- The advanced estimation-risk notebook was marked reviewed and complete by the
  instructor September 17, 2026, with a final score of 9.2/10 (initial 8.3/10).
  The [saved review record](lectures/instructor/L5b-ADVANCED-ESTIMATION-REVIEW-HANDOFF.md)
  records the three-task organization, resampling assumptions, normalizer and
  sensitivity distinctions, boxed compounding derivation, terminal-wealth box
  plots, instructor wording preferences, and validation. No proposals remain
  pending; read the record before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5b rolling-correlation example review

- The relocated L5b rolling-correlation advanced example was marked reviewed
  and complete by the instructor September 23, 2026. It was polished from
  8.3/10 (Codex 7.8) to 9.1/10 (Codex 8.8 before the last three small
  fixes). Prose was cut from about 3,050 to 1,950 words, with
  code and outputs unchanged. The [review record](lectures/instructor/L5b-ROLLING-CORRELATION-REVIEW-HANDOFF.md)
  lists the accepted edits, rejected Codex findings, and checks. No proposals
  remain pending. Do not restart the round unless the instructor requests another one.

## Completed week-5 code-commenting pass

- The instructor-requested commenting pass was completed September 17, 2026.
  All 175 code cells across nine computational notebooks now include teaching
  comments; the two lecture notebooks have no code cells. The
  [saved record](lectures/instructor/WEEK-5-CODE-COMMENTS-HANDOFF.md) records
  the scope, explanations, validation, and current notebook hashes. Executable
  syntax, Markdown, saved outputs, and metadata were preserved. Earlier review
  hashes refer to the pre-commenting snapshots; their approved sections and
  review scores remain closed.

## Completed Week 5 natural-language pass

- The instructor requested small wording changes across active Week 5 materials
  on September 19, 2026. The [saved record](lectures/instructor/WEEK-5-NATURAL-LANGUAGE-HANDOFF.md)
  records the prose edits, preserved calculations, and notebook/slide checks.
  Keep complete, natural sentences, including articles, verbs, and units phrasing.
  This was a targeted wording pass; existing section reviews and scores remain
  closed and refer to their recorded snapshots.

## Completed L6a minimum-variance lecture review

- The L6a data-driven minimum-variance lecture was marked reviewed and complete
  by the instructor September 24, 2026, with a final editorial score of 9.1/10.
  The [saved review record](lectures/instructor/L6a-LECTURE-REVIEW-HANDOFF.md)
  records the density pass, short-position development, complete GMV derivation
  companion, visual-first frontier, defined and annotated theorem-style boxes,
  long-only growth floor, wealth/NPV closing, and final checks. The instructor
  subsequently reconfirmed completion after the Dirichlet review, local sampling
  example, AllianceBernstein profile, and boxed-result follow-up edits; the saved
  record identifies that final snapshot. No proposals remain
  pending; do not restart approved lecture sections unless another round is
  requested. The minimum-variance data example has its own review.
- On September 25, 2026, the instructor requested a density and flow round
  (independent rating 8.5/10, final 9.0/10). The approved edits rebuilt the
  Estimated Inputs opening and Objective 3, fixed the frontier figure's
  attainable-region wording, moved the negative-weight example ahead of the
  GMV box, tightened transitions and redefinitions, and condensed the log-return
  and GBM-volatility material into a short note. The portfolio problem stays in
  the growth-rate covariance; self-contained box Setups were kept. The same handoff records the edits, checks, deferred items, and
  needed deck changes; the instructor has not yet separately marked it complete.
- A follow-up polish round the same day (independent rating 8.9/10, final
  9.2/10) removed nine clause semicolons, replaced the lecture's package-doc
  Dirichlet link, linked the held-out 2025 wealth comparison in Estimated Inputs,
  and fixed the Concept Review closer and reward-display spacing. The same
  handoff records the edits, declined suggestions, and one deck-sync item.

## Completed L6a multiple-asset GBM example polish

- The instructor marked the L6a multiple-asset GBM portfolio example polish
  complete September 26, 2026 (initial rating 8.2/10, final 9.0/10). The
  [saved review record](lectures/instructor/L6a-MAGBM-REVIEW-HANDOFF.md)
  records the four accepted steps: links to other weeks became references in
  words; Task 1 was tightened and reordered to build the pieces, then the model;
  Tasks 2 and 3 now recall the GMV problem and portfolio NPV from the L6a lecture,
  add `__What do we see?__` readings and types, and cut denials of unproposed
  misreadings. Task prose went from 3,008 to 2,282 words. It also records the
  Codex checks and accuracy fixes, and the saved snapshot. No proposals remain
  pending; do not restart approved sections unless another round is requested.
  Setup, Data, and Constants were not part of this round. Show future proposals
  as rendered before/after PNGs; the instructor found terminal markdown hard to
  read.

## Completed L6a GMV derivation companion review

- The instructor accepted a review of the L6a
  [GMV derivation companion](lectures/week-6/L6a/advanced/gmv-derivation/CHEME-5660-L6a-Derivation-GMV-Fall-2026.ipynb)
  on September 26, 2026, and marked it complete. The derivation matched the
  lecture's GMV-1 to GMV-3 boxes and was correct. The accepted fixes: weights
  defined as fractions of the initial investment (not "dollar weights"),
  positivity of the normalizing denominator argued from the positive-definite
  inverse where λ is solved, the standard-deviation sentence placed beside the
  boxed variance, a lead sentence that no longer names the multiplier before it
  is introduced, and the minimum variance stated in the third takeaway. The kept
  "does not change the minimizing weights" note on the factor of one half matches
  the lecture and answers a real student question. The advanced README now
  recommends the GMV derivation first.

## Completed L6a minimum-variance data example review

- The instructor marked the L6a data-driven minimum-variance example reviewed
  and complete September 26, 2026 (opening assessment 8.6/10, no rescoring).
  The [saved review record](lectures/instructor/L6a-MINVAR-REVIEW-HANDOFF.md)
  records the opening assessment and the one change made after it: Task 3 now
  also tests the shorts-allowed GMV portfolio out of sample, as a "blue sky"
  first implementation with no borrowing fee, collateral, or dividends owed, and
  a dashed navy wealth path. The cell 50 reading is a lead sentence,
  three labeled bullets, and a closing sentence. The opening assessment's density
  suggestions were not taken up. No proposals remain pending; do not restart
  the review unless the instructor asks for another round.

## Completed L6a slides review

- The instructor marked the L6a slides reviewed and complete September 26,
  2026, after asking to finish the remaining steps in one pass (initial 8.0/10,
  final 9.0/10). The only change requested after the previews was shorter text
  below the long-only box on page 17. The [saved review record](lectures/instructor/L6a-SLIDES-REVIEW-HANDOFF.md)
  records the sync with the stabilized lecture. Objective 3, the Dirichlet link,
  and Estimated Inputs now match the lecture. The buy-and-hold and log-return
  slides were removed, and a one-line conventions note replaces them. The
  GMV/frontier section follows the lecture's order: negative weight, boxed GMV,
  derivation with a companion link, frontier figure, then the boxed target
  problem and formula. The long-only section is the boxed LO-1 plus one
  growth-floor slide. The deck went from 25 to 23 pages with zero overfull
  boxes. Two lecture sentences now say the data example tests both GMV
  portfolios. No proposals remain pending; do not restart unless another round
  is requested.

## Completed L6a advanced frontier-geometry review

- The instructor marked the relocated L6a frontier-geometry advanced example
  reviewed and complete September 27, 2026 (initial 8.2/10, final 9.0/10). The
  [saved review record](lectures/instructor/L6a-FRONTIER-REVIEW-HANDOFF.md)
  records the six accepted steps and the September 27 follow-up. Links into
  other weeks were cut or named in words, the corrupted figures were repaired,
  and `Max |w_i|` table columns now carry the weight claims. Prose went from
  3,751 to about 2,500 words, with readings as short `__What do we see?__` lists.
  Task 3 solves each weight rule directly at the comparison targets instead of
  interpolating, and the interpolation helper was removed. The L6a lecture and
  advanced README now describe the constraint as a position cap. No proposals
  remain pending. Do not restart unless the instructor requests another round.

## Completed L6a code-commenting pass

- On September 27, 2026 the instructor asked for good docstrings and thorough
  comments in all L6a example code and `src`, because students read it. The
  pass covers all 80 code cells in the three examples and the frontier-geometry
  notebook, plus both `src` files, both `Include.jl` files, and the frontier
  reference page. The [saved record](lectures/instructor/L6a-CODE-COMMENTS-HANDOFF.md)
  holds the conventions, the validation, and the items that need code edits.
  Syntax-tree checks confirm that only comments and docstrings changed.

## Completed L6b slides review

- The instructor marked the L6b slides reviewed September 28, 2026, after a
  same-day pass over the lecture's objectives, example and advanced
  descriptions, and key takeaways (approved "as shown") and a deck sync with the
  bullets tightened to fit. The [saved review record](lectures/instructor/L6b-SLIDES-REVIEW-HANDOFF.md)
  holds the snapshot hashes, the lecture changes, the five synced frames, and
  the deliberately shortened Summary slide (no closing line). The lecture and deck edits are not yet
  committed: the instructor deferred the commit until the L6b example notebooks
  are reviewed. No proposals remain pending; do not restart unless another round
  is requested.

## Completed L6b bootstrap uncertainty example review

- The instructor marked the L6b bootstrap uncertainty example reviewed
  September 28, 2026 (initial 6.0/10, final 9.1/10). The
  [saved review record](lectures/instructor/L6b-BOOTSTRAP-REVIEW-HANDOFF.md)
  records the regroup into fit all firms and R², generate the bootstrap, and
  compare standard errors; the corrected Monte Carlo explanation; the new
  across-firm, standard-error, and coverage tables and histogram figure; the
  closing reading that answers the opening question; and the checks. Outputs are
  stored. Not yet committed: the instructor deferred the commit until all four
  L6b examples are reviewed. No proposals remain pending; do not restart unless
  another round is requested.

## Completed L6b SIM estimation example review

- The instructor marked the L6b SIM estimation example reviewed September 28,
  2026 (initial 6.5/10). Round 1 closed at 8.3, below the 9.0 threshold, and a
  second round closed at 9.0/10. The
  [saved review record](lectures/instructor/L6b-ESTIMATION-REVIEW-HANDOFF.md)
  records the steps and checks:
  - the standard opening;
  - task openers and subsections;
  - lecture recalls in place of re-derivations;
  - readings that hold for any ticker;
  - the stock versus index-fund contrast moved after the all-security fit;
  - five corrected claims;
  - prose cut from 2,197 to 1,651 words;
  - code lines reflowed to at most 100 characters;
  - the heatmap margin fix.
  The parameter archive stayed byte-identical through every re-execution. The
  round also changed one sentence of the L6b lecture, the example callout, to
  match the new order. Not yet committed: the instructor deferred the commit
  until all four L6b examples are reviewed. No proposals remain pending; do not
  restart unless another round is requested.

## Completed L6b SIM portfolio (RA) example review

- The instructor marked the L6b SIM portfolio (risky assets) example reviewed
  September 28, 2026 (initial 6.5/10). Round 1 closed at 8.6, below the 9.0
  threshold, and a second round closed at 9.0/10. The
  [saved review record](lectures/instructor/L6b-RA-REVIEW-HANDOFF.md) records
  the steps and checks:
  - the standard opening, with the setup, data, and Task 3 code ported from L6a;
  - lecture recalls in place of re-derivations;
  - `g_target` set to the middle floor of a common sweep, so other ticker lists run;
  - a figure panel for the SIM's risk misjudgment and the extra risk of its weights;
  - the covariance split as a display labeled "SIM keeps" and "SIM drops";
  - a weight reading tied back to the Task 1 pair table;
  - a closing answer to the opening question;
  - prose cut from 2,830 to about 2,150 words.
  Every stored text output matched after the round-2 re-execution. A final
  whole-notebook Codex check passed, and the instructor's cell 25 wording
  ("directly links") was applied after it. The instructor confirmed the
  notebook complete the same day. Not yet committed: the instructor deferred
  the commit until all four L6b examples are reviewed. No proposals remain
  pending; do not restart unless another round is requested.

## Completed L6b risky and risk-free (RRFA) example review

- The instructor marked the L6b tangent portfolio and capital allocation line
  (RRFA) example reviewed September 28, 2026 (initial 5.5/10). Round 1 closed at
  8.4, below the 9.0 threshold. A second round closed at 9.0/10, and Codex
  scored it 9.1 on its own. The
  [saved review record](lectures/instructor/L6b-RRFA-REVIEW-HANDOFF.md) records
  both rounds and their checks:
  - the standard opening, with setup, data, and Task 3 code ported from L6a;
  - one SIM frontier sweep with a tangency check, keeping the original CAL
    figure style at the instructor's request;
  - both tangent portfolios scored under the sample covariance (SIM 1.265
    against data 1.285 annualized);
  - a Task 3 reading that compares each complete portfolio with SPY at similar
    realized risk, as Objective 3 promises;
  - the fuller two-sentence Summary opener;
  - fixes for a `$k$th` render bug and a dead JLD2 anchor.
  Round 2 was word-neutral, and its only code change was two print lines. With
  this review, all four L6b examples are reviewed. The lecture, deck, and
  examples are not yet committed, because the instructor deferred that commit
  until now. No proposals remain pending; do not restart unless another round
  is requested.

## L6b advanced material cut to two notebooks

- On September 28, 2026 the instructor cut the L6b optional advanced notebooks
  from five to two. The review burden was high, and it was unclear whether
  students read them. Kept: residual diagnostics (`advanced/diagnostics/`) and
  estimation risk (`advanced/estimation-risk/`). Moved unchanged to
  [the archive](lectures/archive/week-6-L6b-advanced-cut-2026-09-28/README.md):
  the data-driven risk-free notebook, the markdown-only SIM theory notebook,
  and SIM parameter uncertainty in portfolios. Do not restore them or propose
  new L6b advanced notebooks unless the instructor asks.
- Follow-on edits: the lecture's advanced list and one lecture sentence
  linking the theory notebook, `advanced/README.md`, the slides' advanced frame
  (PDF rebuilt), the RRFA example's closing link (now the estimation-risk
  notebook, matching the deck), the diagnostics closing line, and the
  estimation-risk links and closing paragraph. The estimation-risk links still
  pointed to its pre-relocation L5b paths. The estimation-risk notebook ran in
  place with no errors, and its stored outputs were left as reviewed.
- Open for the L7b review: the L7b lecture cites "the ridge estimator of L6a's
  optional material," which no longer exists in live material.

## Completed L6b advanced estimation-risk review

- The instructor marked the L6b estimation-risk advanced notebook reviewed
  September 28, 2026 (initial 7.0/10, final 9.0/10). It had been reviewed as an
  L5b notebook on September 17. That review predates the current density rules
  and the L6b lecture's SIM-3 result. The
  [saved review record](lectures/instructor/L6b-ESTIMATION-RISK-REVIEW-HANDOFF.md)
  records the six accepted steps and their checks:
  - the input estimation and the four weight rules moved from Setup into
    Tasks 1 and 2;
  - the bootstrap loop keeps only the resampled inputs, and a Task 2
    `weights` cell computes the four rules;
  - `tangent_long_only` uses the lecture's exact SIM-3 solve and rescale
    instead of a 31-point grid (`src` and `docs` changed, tangent rows moved at
    most 0.007);
  - the introduction asks the L6b question, whether the means or the
    covariance moves the weights more, and Task 2 answers it;
  - prose went from 3,830 to 2,669 words;
  - the closing Codex fixes are applied.
  Every non-tangent output matched after re-execution. This supersedes the
  "stored outputs were left as reviewed" note above. Released as week-06.1.
- On September 30, 2026 the instructor asked for a second polish, voice, and
  organization round (opening 8.4/10, closing 9.0/10). The round-2 section of
  the same record lists the four changes: Task 2 now opens with the frontier
  figure before the four rules and resampled weights, blank lines separate
  every display from the prose, the title is "Estimation Risk in Portfolio
  Weights" to match the lecture list and README, and nine code comments lost
  denials or repeated prose. Prose is flat (2,635 to 2,642 words). Re-executed
  with every output matching week-06.1. The instructor accepted the round
  and marked it complete the same day. No proposals remain pending; do not
  restart unless another round is requested.

## Completed L6b advanced residual-diagnostics review

- The instructor marked the L6b residual-diagnostics advanced notebook reviewed
  September 28, 2026 (initial 6.0/10, final 9.0/10; Codex 7.6 to 9.0). The
  [saved review record](lectures/instructor/L6b-DIAGNOSTICS-REVIEW-HANDOFF.md)
  records the six accepted steps and their checks:
  - retitled "L6b Advanced: Residual Diagnostics and Two Bootstrap Methods",
    with a two-sentence lead-in that follows on from the bootstrap example;
  - regrouped as heavy tails (Task 1, a density and log-scale tail figure, and
    the Hill index against a Gaussian reference), then two bootstraps (Task 2),
    then dependence (Task 3);
  - Task 3 traces the lag-one dependence to VWAP averaging with an
    all-securities VWAP-versus-close table and a Working (1960) citation, and
    gives Newey-West as display equations computed with plain loops;
  - a false volatility-clustering claim, a stale ridge reference, and an
    unsupported all-firms extrapolation were cut;
  - all code rewritten as a lesson, with no lines over 100 characters;
  - prose is flat (1,583 to 1,589 words), and the longest sentence went from
    85 to 34 words.
  Re-executed with no errors. The stale 0.981 output is now 0.993. The lecture
  description and README still match. Not yet committed: it is part of the
  deferred L6b commit.
- Round 2, September 30, 2026: the instructor asked for another pass if the
  notebook scored below 9.0. It scored 8.6 (Codex 8.5), so a markdown-only
  round closed at 9.1 (Codex 9.0). Eight cells changed and no code: objectives reordered
  to follow the tasks, the Task 3 itinerary sentence cut, the Task 2 opener
  trimmed, a Newey-West lag rule of thumb (L near N^(1/4)) and a reading of the
  L = 0 row added, all word-neutral. The
  [saved review record](lectures/instructor/L6b-DIAGNOSTICS-REVIEW-HANDOFF.md)
  lists the Codex items declined and why. The instructor accepted the round
  the same day. No proposals remain pending; do not restart unless another
  round is requested.

## L6b client interview demo — September 30, 2026

- For the October 1 lecture, the instructor asked for a live demo modeled on the
  eCornell Session 1 ticker interview. [The interview](lectures/week-6/L6b/interview/interview.md)
  runs with Claude Code's AskUserQuestion UI. Three questions set a beta band,
  exclusions, and the client's risk-free fraction, and
  [`screen-tickers.jl`](lectures/week-6/L6b/interview/screen-tickers.jl) picks
  the firms. The instructor did not like the eCornell archetype lists, which were
  hand-picked large caps (AAPL, MSFT, JPM, and AMT in all five, and mostly
  2014–2024 winners in the growth lists). The screen is therefore a fixed rule:
  the top two SIM R² per GICS sector inside the band, never mean growth. Do not
  replace it with curated lists.
- The RA and RRFA examples read `data/my-tickers.csv` if it exists and otherwise
  use the thirteen L6a firms. RRFA also reads `data/my-client.toml` and labels
  the client's w_f in the Task 3 figure and table. Both files are gitignored.
  With no client files, every stored text output matched the reviewed
  September 28 outputs except the new ticker print line. The examples ran
  without errors on all three bands, with exclusions, add/drop, and a new w_f.
  Two tables no longer crop: the Task 3 table (`fit_table_in_display_horizontally`)
  and the RA weights table (`fit_table_in_display_vertically`).
- The instructor then split the lecture's Examples section in two (approved as
  previewed). In lecture: the L6a MAGBM carryover, the client interview, RA, and
  RRFA. Review on your own: SIM estimation and parameter uncertainty. These are
  core examples, distinct from the Optional Advanced Material. Their in-lecture
  stops are labeled "Example (review on your own):". The instructor moved the
  interview stop into one "Examples:" block with the RA stop, just before RA
  runs, and the RA stop now says "the client's firms." The
  L6b slides were synced to this split on September 30 for week-06.3 (see the
  [slides record](lectures/instructor/L6b-SLIDES-REVIEW-HANDOFF.md)).

## L6b tangent derivation companion — September 30, 2026

- At the instructor's request, a markdown-only [tangent derivation companion](lectures/week-6/L6b/advanced/tangent-derivation/CHEME-5660-L6b-Derivation-Tangent-Fall-2026.ipynb)
  follows the L6a GMV and target-growth companions. It derives the Sharpe-ratio
  gradient and the zero budget multiplier (T-2), the tangent weights (T-3), and
  why the GMV growth rate must exceed g_f (the normalizing denominator factors
  into a positive term times the GMV excess growth). It then gives the
  Cauchy–Schwarz bound on the Sharpe ratio and, as the instructor asked, the
  risky and risk-free problem with short positions, which selects the same risky
  mix and traces the CAL. The lecture's tangent box links it in one sentence,
  and `advanced/README.md` lists it second. As in L6a, it is not in the
  lecture's Optional Advanced Material list, so the two-notebook cap there is
  unchanged. Codex checked it twice (8.5, then 9/10 after fixes). The fixes
  assume M ≥ 2 and unequal expected growth rates, and they correct a long-only
  sentence: long-only bounds can change the risky direction, and the common
  direction lasts only until an upper bound binds. Codex's cuts to the
  zero-multiplier and scalar-k sentences were declined, since those sentences
  fill the lecture's gaps. The instructor has not yet reviewed the draft.

## Completed L7a lecture review

- The instructor marked the L7a SIM portfolios and risk-free asset lecture
  reviewed October 2, 2026, after a polish, voice, and organization round
  (initial 8.2/10, final 9.0/10; Codex 8.5 before the closing fix). The
  [saved review record](lectures/instructor/L7a-LECTURE-REVIEW-HANDOFF.md)
  lists the accepted steps and checks:
  - the Concept Review displays the SIM equation, defines its symbols where
    used, and drops the variance box that SIM-1 repeats;
  - the BlackRock profile has its founders, iShares, Aladdin, a dated
    internship line, and videos, with every fact sourced;
  - the opening, Objective 2, and the client-files note were rewritten;
  - the CAL derivation is one step per line, and the risk-free section is
    split into one cell per subsection;
  - the takeaways state results, and Takeaway 3 gives the condition
    two-fund separation needs.
  The two-fund separation subsection is unchanged. No proposals remain
  pending; do not restart unless another round is requested. The deck was
  synced and approved the same day (17 to 16 pages, zero overfull boxes); the
  record lists the frame changes. A follow-up the same day added the SIM
  covariance derivation to the Concept Review at the instructor's request:
  the diagonal and off-diagonal entries, with `=0` underbraces on the dropped
  terms, and the assembled matrix. The deck's Concept Review became two frames
  (17 pages). Later the same day, a two-matrix split showed where D_g comes
  from, and a five-line Var(g_p) derivation (the 2025 L8b route) was added
  before SIM-1. The deck gained a Portfolio Risk slide (18 pages).

## L6b SIM derivations for re-recording — October 2, 2026

- The instructor is re-recording L6b after a technical glitch and asked for
  the clearer SIM derivations developed for L7a. In the lecture, cell 8 now:
  - derives the diagonal variance step by step;
  - marks the dropped terms with `=0` underbraces;
  - shows the two-matrix split that defines D_g;
  - derives Var(g_p) from the L6a double sum.
  Cell 5's risk calculation also marks its zero term. The deck went from 29
  to 30 pages with zero overfull boxes. The
  [slides record](lectures/instructor/L6b-SLIDES-REVIEW-HANDOFF.md) lists the
  frames. Week 6 needs a week-06.4 release before students see the update.

## Completed L7a tangent derivation review

- The instructor asked for a polish round on the L7a tangent derivation
  companion if it scored below 9.0. It opened at 8.9 (Codex 8.9). One
  markdown-only step was approved October 2, 2026, and the round closed at
  9.1 (Codex 9.0). This is the instructor's first review of the September 30
  draft. The [saved record](lectures/instructor/L7a-TANGENT-DERIVATION-REVIEW-HANDOFF.md)
  lists the seven changed lines, the checks, and the declined suggestions:
  - why the means must differ;
  - the named L6a GMV derivation;
  - why the lecture's growth floor binds;
  - "feasible target" in the long-only note.
  The objectives, takeaways, and boxes are unchanged. The instructor marked the
  companion reviewed the same day. The L6b copy shipped in week-06.2 and still
  has the earlier text. No proposals remain pending; do not restart unless
  another round is requested.

## Interactive notebook polishing

For a "notebook polish round," use the versioned
[notebook-polish workflow](.agents/skills/notebook-polish/SKILL.md).
It preserves the opening assessment, section-by-section approval, and final
rescoring. [Moving this workflow to another machine](lectures/instructor/NOTEBOOK-POLISH-WORKFLOW.md)
describes the shared CHEME 5660/CHEME 5800 setup. Keep the workflow here as the
single maintained copy; CHEME 5800 links to it.

The instructor requested cleanup of `build/notebook-previews` on September 13,
2026. Historical preview links may no longer resolve; use the saved review
handoffs and regenerate previews from the current notebooks when needed.
