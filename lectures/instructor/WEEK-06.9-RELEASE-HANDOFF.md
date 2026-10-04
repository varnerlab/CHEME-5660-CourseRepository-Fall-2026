# Week 06.9 release preparation — October 4, 2026

The instructor found a notation clash in the L6b lecture and asked for a
commit, push, and another Week 6 release. `week-06.8` is already tagged, so
this release is `week-06.9`. It is cumulative and contains L6a and L6b.

## Changes since week-06.8

Only the "Parameter uncertainty and goodness of fit" cell (cell 7) of
`lectures/week-6/L6b/CHEME-5660-L6b-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb`
changed:

- The derivation labeled $(\hat{\mathbf X}^\top\hat{\mathbf X})^{-1}\hat{\mathbf X}^\top$
  as $\mathbf A$, which clashed with the MAGBM loading matrix
  ($\mathbf A\mathbf A^\top=\mathbf C$) defined in L5b and used in L6a. It is
  now the pseudoinverse $\hat{\mathbf X}^{+}$, which is also the
  $\mathbf V\mathbf\Sigma^{-1}\mathbf U^\top$ computed in the SVD estimation
  example.
- The "fixed" sentence names it: "We treat the market growth rates in
  $\hat{\mathbf X}$, and so its __pseudoinverse__ $\hat{\mathbf X}^{+}$, as
  fixed."
- "For a fixed matrix $\mathbf A$, ..." became
  "Then $\text{Cov}(\hat{\mathbf X}^{+}\boldsymbol\varepsilon)=\hat{\mathbf X}^{+}\,\text{Cov}(\boldsymbol\varepsilon)\,(\hat{\mathbf X}^{+})^\top$, which gives:",
  and the boxed line reads $\sigma^2\,\hat{\mathbf X}^{+}(\hat{\mathbf X}^{+})^\top$.

The cell went from 329 to 331 prose words. The instructor approved the
rendered before/after preview. The L6b slides state only the result and
never named the matrix, so the deck is unchanged. The SVD example's
$\mathbf\Sigma$ (singular values) versus $\mathbf\Sigma_g$ was left as-is by
request. Example notebooks, saved results, slides, and package code are
unchanged from week-06.8.

## Local verification

- Built with `scripts/release-week.sh week-06.9` from a `git archive` of the
  staged tree, so only tracked files entered the bundle. The checksum check
  passes. The bundle has one root, the environment and shared code, and only
  `lectures/week-6/` with L6a and L6b.
- All 15 bundled notebooks parse, with no saved error outputs or
  author-machine paths, and every local markdown link resolves inside the
  bundle. The bundled L6b lecture matches the working copy byte for byte.
- The edited cell renders with no KaTeX errors.
- Extracted-bundle `Pkg.instantiate()` and package import succeeded under
  Julia 1.12.7, and all five `Include*.jl` files loaded.
- `git diff --cached --check` passes.
- No code or computational notebook changed, so computations were not rerun
  for this notation correction.

## Publication procedure

Push the release commit and its annotated `week-06.9` tag. Wait for the
weekly release workflow to pass, verify the uploaded ZIP and checksum, then
publish the draft with notes describing this correction.
