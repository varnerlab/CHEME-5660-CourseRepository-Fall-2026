# L4b lattice-limit conservative review

Reviewed September 11, 2026.

Notebook: [From the Binomial Lattice to Geometric Brownian Motion](../week-4/L4b/advanced/lattice-limit/CHEME-5660-L4b-Advanced-LatticeToGBM-Fall-2026.ipynb)

## Scope and references

The user requested diagnosis, conservative revision, and an audit for lost content and scope drift. Preserve the instructional structure, mathematical development, examples, tables, and student tasks; flag substantive teaching decisions instead of changing them.

References read: the shared notebook style guide, the approved L4b parameter-example setup and summary, and the approved Monte Carlo opening, setup, Constants introduction, summary, and simple-border table style.

## Diagnosis before revision

- The existing sequence is coherent: calibrate one lattice step, examine the terminal distribution, compare strict target probabilities. No reorganization was needed.
- Mean growth used the superseded `ḡ` / `\bar g` notation.
- Setup repeated package activation details and lacked the standard labeled Include panel. The three numbered sections lacked the approved Task headings and openings.
- In the terminal-moment explanation, “its mean” could refer to the up-count rather than the terminal log price ratio.
- The density description could imply that a discrete lattice has a continuous density. The plot actually displays node mass divided by log-price spacing.
- The target-probability description implied the implementation explicitly calculated the minimum up count; the code instead tests every node against the same strict target and sums successful-node probabilities.
- The takeaways used impersonal statements and could overstate the significance of the empirical inverse-square-root reference curve.
- The parameter introduction and extra disclaimer clause implied empirical estimation, although the notebook sets illustrative values.

## Revisions applied

- Aligned prose, equations, code variables, and the displayed parameter tuple with `μ_g` / `\mu_g`. Retained arithmetic drift `μ` and every parameter value.
- Applied the approved opening and setup conventions, keeping the L3b/L4a prerequisite connection.
- Labeled the existing three sections as Tasks and added concise task openings without moving cells or calculations.
- Made local wording corrections to terminal moments, mass-per-spacing plots, and the strict-node calculation. Preserved the moment derivation, central-limit explanation, integer boundary interpretation, and two-point stand-in analogy.
- Used the approved Constants language and corrected units and parameter provenance.
- Applied the approved simple-border PrettyTables style to both tables, preserving columns and numeric precision.
- Recast exactly three takeaways in the retrospective teaching voice, retaining calibration, distributional convergence, and target-probability convergence.
- Preserved the existing L9b references; corrected the closing description to derivative valuation. Removed only the unsupported estimation claim from the final disclaimer sentence.

## Audit and verification

- All 24 cells, their IDs, types, and order are preserved, including all 10 code cells. No examples, calculations, figures, or student tasks were removed.
- Every displayed equation matches the original after the mean-growth notation substitution.
- Code comparison confirms unchanged algorithms after accounting for the identifier rename, comment edits, and table-format keyword. Helper signatures, strict comparison, probability checks, mass-normalization check, step-count grids, and plotting code are preserved.
- Executed the notebook successfully with no error outputs; saved execution counts run from 1 through 10.
- All five moment-table rows and eleven convergence-table rows match the original numeric results exactly at the displayed precision.
- Both saved plot PNGs are byte-for-byte identical to the original outputs.
- Confirmed exactly three objectives, tasks, and takeaways; valid notebook structure; and working relative links.
- Inspected five rendered sections covering the entire notebook using local MathJax. Equations, panels, tables, plots, and section boundaries render correctly.
- The preservation audit caught and restored the explicit prerequisite and two-point analogy before completion. Retained the original descriptive substance of the Task 2 and Task 3 headings.

## Teaching choices left for discussion

1. **Existing L9b preview.** The notebook mentions risk-neutral probabilities in Task 1 and in the closing sentence. Both references remain; decide whether this preview is useful here. No risk-neutral formulas or additional derivative material were added.
2. **Existing error-rate discussion.** Task 3 names a Berry–Esseen-type argument without developing it. The empirical `C/sqrt(N)` reference curve and the distinction between that curve and a bound remain. Decide whether the named theorem belongs at this level; no error-bound derivation was added.
3. **Level of the convergence argument.** The notebook retains its explanatory central-limit argument and visual density comparison rather than adding a formal proof. A formal proof would need to account for the step distribution changing with the step count. [Jim Pitman's Berkeley notes on triangular arrays](https://www.stat.berkeley.edu/~pitman/s205f02/lecture10.pdf) are a possible instructor reference if such a proof is later requested. Do not silently expand the current notebook into that proof or into process-level convergence.

The conservative edit and audit are complete. These discussion items have not been approved for substantive revision.
