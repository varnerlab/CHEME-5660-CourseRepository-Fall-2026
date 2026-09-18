# L4b Monte Carlo example — completed notebook review

Completed September 13, 2026. The instructor confirmed: “Ok - great. Let's mark this as reviewed”.

Notebook: [Monte Carlo versus the closed form](../week-4/L4b/advanced/monte-carlo/CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb).

The instructor requested polishing only if the initial score was below 9/10.
The current notebook scored **9.1/10**, exceeding that threshold. No notebook
revisions were proposed or applied in this round; the closing score remains
**9.1/10**. No proposals remain pending. Do not restart completed sections unless
the instructor requests another round.

Preserve the three-task sequence, current mean-growth notation, standard setup,
compact tables, and retrospective takeaways. In particular, retain the distinction
between sampling uncertainty and time-step approximation error, and calculate
antithetic standard errors from independent pair averages. Follow the
[shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md) for any future work.

## Assessment

| Dimension | Score | Evidence |
| --- | ---: | --- |
| Technical correctness | 9.4 | The normal-tail probability, Bernoulli standard error, exact and Euler transitions, and independent-pair standard error agree with the implementation and numerical checks. |
| Organization | 9.2 | Three tasks distinguish sampling uncertainty, time-step approximation, and variance reduction; the objectives and retrospective takeaways match. |
| Narrative and interpretation | 9.1 | Purposeful explanations connect equations, code, and output. Task 2 explicitly separates realized error from approximation bias. Task 1 repeats its standard-error interpretation in nearby paragraphs. |
| Presentation | 8.9 | Equations, compact tables, and both plots render clearly. Several long lines in the Euler simulation cell require horizontal scrolling. |
| Cognitive density and pacing | 8.8 | The three-task sequence is easy to follow; the Euler implementation cell is the densest passage and Task 1 could benefit from modest local tightening. |

These scores are editorial judgments, not measured learning outcomes. Classroom
feedback would be needed to judge pacing for students encountering the methods.
The minor observations above do not justify reopening the notebook under the
instructor's requested threshold.

## Verification

- Read all 24 cells and the local Include.jl file. Checked the current L4b lecture
  for notation, target-probability assumptions, and the exact transition; consulted
  its review record and the shared style guide. Read the original 2025 Monte Carlo
  passage; the shared 2025/5820 reference passages were also read in this session.
- Executed all ten code cells sequentially with Julia 1.12.7 and the course project,
  preserving the notebook-directory meaning of @__DIR__. This was script execution;
  the original notebook and its saved outputs were preserved. Displayed numerical
  results agree with the saved notebook outputs.
- Independently checked target_probability against a terminal lognormal tail at
  two holding periods and four targets, and checked the median target gives 0.5.
- Derived the one-step Euler target probability from its affine normal terminal
  price. Its analytic probability is 0.49149226197899154, consistent with the
  simulated 0.490395 within sampling variation.
- Checked that exact-simulation estimates and the one-step Euler estimate were
  within six sampling standard errors of their respective analytical probabilities.
  This is a numerical consistency check, not proof of confidence-interval coverage.
- Independently reconstructed antithetic outcomes using summed normal increments
  in the analytical terminal log return at target probabilities 0.25, 0.5, and 0.75.
  Simulated means and pair-based standard errors matched that calculation.
  Sample standard errors agreed with the analytical pair variance within 3%;
  the median case gave exactly 0.5 and zero standard error.
- Validated notebook schema, exactly three objectives/tasks/takeaways, local links,
  and major-section separator placement.
- Inspected six PNG sections of the full HTML export. All 42 math elements rendered
  without detected errors and both plots loaded. No page-wide overflow appeared
  at 1280 pixels; the long Euler code lines scroll within the cell.
- Verified the source notebook SHA-256 is unchanged.

## Default results

Closed-form target probability: 0.2933120829140676.
With 100000 independent paths: probability 0.29404, SE 0.0014407653466126952.
With 50000 antithetic pairs (100000 total paths): probability 0.29209,
SE 0.001102085718017703.
The smaller standard error measures improved precision; it does not guarantee
that an individual run lies closer to the closed-form answer.

Reviewed notebook SHA-256:
`3ed44793d8589e92ac2807ef25e7e1ce29c347c06a8efad8df303a029f419737`.

Previews use the prefix `build/notebook-previews/L4b-monte-carlo-initial`.
These local artifacts are ignored by Git. No commit or push was made.
