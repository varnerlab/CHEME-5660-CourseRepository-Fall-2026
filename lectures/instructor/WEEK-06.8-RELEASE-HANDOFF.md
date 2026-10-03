# Week 06.8 release preparation — October 3, 2026

The instructor asked for two changes to the L6a multiple-asset GBM example,
then a commit, push, and another Week 6 release. `week-06.7` is already
tagged, so this release is `week-06.8`. It is cumulative and contains L6a
and L6b.

## Changes since week-06.7

All changes are in
`lectures/week-6/L6a/CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb`
and its local helper code:

- **GMV problem (Task 2, "Choose the allocation").** The displayed problem
  is now the lecture's (LO-1) in full: the growth floor
  $(\mathbf g')^\top\mathbf w\geq g_\star$, the budget, and
  $0\leq w_i\leq 1$, one constraint per line with labels. The paragraph
  below it sets $g_\star=\min_i g_i'$ (passed as `R`) and says why the floor
  never binds. It replaces the paragraph that described the solver's `μ` and
  `R` inputs, which the instructor found confusing. One code comment now names
  `R` as $g_\star$.
- **Wealth figure (Task 2, "Summarize the simulated wealth").** The median
  and the 5–95 and 25–75 percentile bands are replaced by the simulated mean
  (expected wealth, dashed blue) and pointwise mean ± 1, 1.96, and 2.57
  standard-deviation bands in the same blue family (`:deepskyblue3`,
  `:deepskyblue2`, `:deepskyblue1`, narrowest to widest). Observed wealth (red)
  and SPY (gray dotted) are unchanged. The legend background is transparent,
  because the wider outer band otherwise showed a notch behind the legend.
- **Text.** The band description gives the normal-distribution coverage
  (about 68, 95, and 99 percent) and notes that simulated wealth is skewed to
  the right. The "What do we see?" reading now says that observed wealth stays
  above the inner band after about trading day 150, briefly rises above the
  middle band near day 238, and ends 1.74 standard deviations above the
  expected wealth. Key Takeaway 2 names the mean and standard deviation in
  place of percentiles.
- **Helper code.** `scaled_wealth_quantiles` was removed from `src/Compute.jl`
  because nothing calls it now. The mean and standard deviation are computed
  in the cell with `mean(..., dims=2)` and `std(..., dims=2)`. The comment in
  `Include.jl` was updated.

Task 3's NPV table still reports simulated percentiles of $\rho_T$. That is a
separate quantity and was not part of the request.

Checked values (Julia, default settings, seed 5660): pointwise coverage at
year end is 68.5, 95.2, and 98.8 percent for the three bands; above-band
fractions exceed below-band fractions (right skew); z = (observed − mean)/SD
exceeds 1 on days 153–250 except 171–173 and 176, exceeds 1.96 only on days
237–239, and equals 1.743 on day 250.

## Local verification

- The edited notebook was executed from the top with nbconvert (Julia
  1.12.7) and has no error outputs. Every text output matches week-06.7,
  so the allocation, Task 1 checks, and Task 3 NPV table are unchanged.
- Codex checked the edits against the notebook JSON, the lecture's (LO-1),
  and the figure's SVG coordinates. All eight correctness items were
  correct, including the band claims in "What do we see?". Two sentences
  over 25 words were tightened (cell 31 split; Key Takeaway 2 shortened
  within its two-sentence limit).
- Built with `scripts/release-week.sh week-06.8` from a `git archive` of the
  staged tree, so only tracked files entered the bundle. The checksum and ZIP
  integrity checks pass. The bundle has one root, the environment and shared
  code, and only `lectures/week-6/` with L6a and L6b.
- All 15 bundled notebooks parse, with no saved error outputs or
  author-machine paths. Every local markdown link resolves inside the
  bundle. The MAGBM notebook has 3 objectives, 3 takeaways, and `___` before
  each `##` and at the end. The bundled copy matches the working copy byte
  for byte.
- Extracted-bundle `Pkg.instantiate()` and package import succeeded under
  Julia 1.12.7, and all five `Include*.jl` files loaded.
- Because `Include.jl` and `src/Compute.jl` changed, all three L6a examples
  were run from the top inside the extracted bundle. None had errors, and
  their text outputs match the saved outputs.
- `git diff --cached --check` passes.

## Publication procedure

Push the release commit and its annotated `week-06.8` tag. Wait for the
weekly release workflow to pass, verify the uploaded ZIP and checksum, then
publish the draft with notes describing these changes.
