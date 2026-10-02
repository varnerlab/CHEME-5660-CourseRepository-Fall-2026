# Week 06.5 release preparation — October 2, 2026

A fix-only release of the complete week (L6a and L6b), cut the same day as
`week-06.4`. The instructor asked to remove forward pointers into Week 7 from
L6b, following his rule against promising topics in future lectures. Every
release is cumulative.

## What changed since week-06.4

- **L6b lecture summary.** The closing line no longer previews L7a, L7b, and
  "deferred" online estimation. It ends on what L6b did: "We can now estimate
  a single index model from data, build portfolio inputs from it, and choose
  portfolios with or without a risk-free asset."
- **L6b deck.** The last slide replaces "Next: turn SIM parameters into daily
  preferences and rebalance the portfolio." with "One market factor supplies
  the portfolio inputs, and a risk-free asset lets us set the portfolio's
  risk." The new line follows the L4b deck's summary-style closing slide. The
  deck is still 30 pages, with zero overfull boxes.
- **L6b advanced README.** "They are optional and are not prerequisites for
  Week 7" is now "They are optional."

A scan of Week 6 for L7a, L7b, Week 7, "later material", and "deferred"
finds no remaining forward pointers.

## Local verification

- The bundle was built with `scripts/release-week.sh week-06.5` from an export
  of the staged tree.
  - Title "CHEME 5660 - Week 06", with L6a and L6b.
  - SHA-256 check passes:
    `656ad2efbba18dd2e9a19cf7bbbcfad27b12e47cc8bbc86f34eeb1e38415e55e` for the
    local build.
- In the extracted bundle:
  - `Pkg.instantiate()` and `using VLQuantitativeFinancePackage` succeed.
  - All five `Include.jl` files load.
  - No author-machine path appears.
- `git diff week-06.4` shows only the four files above. The lecture has no code,
  and no example notebook changed, so none were rerun.
- `git diff --check` passes.

## Scope

Week 6 only. The Week 7 refactor and L7a work remain uncommitted for the
`week-07.0` release.

## Publication

Pushing the annotated tag `week-06.5` starts the release workflow, which
creates the draft. Verify the assets and checksum, then publish it. The
`week-06.4` draft can be deleted unpublished, since 06.5 contains it.
