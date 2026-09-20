# Repository Working Agreements

## Lecture and Example Notebooks

- Before authoring, editing, or reviewing course notebooks, read [the shared notebook style guide](lectures/instructor/NOTEBOOK-STYLE-GUIDE.md). It records the September 10, 2026 reset and the reference passages from CHEME 5660 Fall 2025 and CHEME 5820 Spring 2026.
- Preserve the instructor's teaching voice, explanatory steps, and mathematical rigor. This guide supersedes conflicting older notebook-style skills and review prescriptions; do not run legacy style auto-fixes against it. Slide production is outside this reset.
- Use the three-underscore horizontal rule only at major-section boundaries immediately before a new level-two heading. Do not use it between level-three subsections or after the final section.
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
