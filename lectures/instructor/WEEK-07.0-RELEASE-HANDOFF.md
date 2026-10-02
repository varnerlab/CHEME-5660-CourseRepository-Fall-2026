# Week 07.0 release preparation — October 2, 2026

The first Week 7 release, containing **L7a only** (October 6). Under the
per-meeting rule, `week-07.0` ships L7a, and L7b will follow as `week-07.1`.
The instructor is still revising L7b, so it is not part of this commit.

## Contents

- **Lecture.** SIM Portfolios and a Risk-Free Asset. It was reviewed October
  1–2 and closed at 9.0. On October 2 it gained the derivations of where the
  SIM inputs, $\mathbf{D}_g$, and $\mathrm{Var}(g_p)$ come from. See the
  [review record](L7a-LECTURE-REVIEW-HANDOFF.md).
- **Deck.** The 18-page companion deck, with zero overfull boxes.
- **Examples.** Compare data-driven and SIM portfolios (RA), and the tangent
  portfolio and capital allocation line (RRFA). Both are copies of the
  reviewed L6b examples.
- **Advanced.**
  - The tangent derivation, reviewed October 2 and closed at 9.1. See its
    [record](L7a-TANGENT-DERIVATION-REVIEW-HANDOFF.md).
  - The estimation-risk notebook, a copy of the reviewed L6b version.

## Fixed for this release

- **Forward pointers removed.** The lecture's closing line linked to
  `../L7b/…`, which is dead in an L7a-only bundle. It now ends on what L7a did:
  "We can now take any set of firms, build their SIM inputs, and choose a
  complete portfolio that matches a client's tolerance for risk." The deck's
  last slide, "Next in L7b: …", now reads "The tangent portfolio supplies the
  risky fund, and lending or borrowing sets the complete portfolio's risk."
- **Week 7 README moved.** `lectures/week-7/README.md` linked L7b and held the
  instructor's client-file commands, so it would have shipped dead links. It
  moved to [WEEK-7-INDEX.md](WEEK-7-INDEX.md). Its L7b list now matches the
  current folder, and its three inbound links were updated.

## Committed with this release

- The L7a folder, and the pre-pivot archive
  `lectures/archive/week-7-before-pivot-2026-10-01/`. The archive holds the
  original Week 7 files, so the 11 old L7a files appear as renames into it.
- The L7a and Week 7 instructor records.
- The `.gitignore` entries for client files.
- The eCornell notice.
- `AGENTS.md`.

Left uncommitted for the L7b release: `lectures/week-7/L7b/`, the L7b trim
archive, the L13a and L15a pointer edits, the root README, and the schedule
rows.

## Local verification

- **Trial bundle.** A trial bundle was built from a temporary index, which
  left the real index untouched.
  - In the extracted bundle, `Pkg.instantiate()` and
    `using VLQuantitativeFinancePackage` succeeded.
  - The RA (21 code cells), RRFA (19), and estimation-risk (27) notebooks ran
    from the top in fresh Julia 1.12.7 kernels (`julia-1.12`) without errors.
  - Every text output matched the saved output. The only difference was the
    setup cell's "Activating project" line, which the saved notebook correctly
    omits.
- **Final bundle.** The release bundle was built from the staged tree with
  `scripts/release-week.sh week-07.0`.
  - Title "CHEME 5660 - Week 07 (L7a)", with `included=L7a`.
  - SHA-256 check passes:
    `ebe408969034a582e257c63df4240caf7ef62cd0156c3ecf1f3321519db77180`.
  - It has the same 121 files as the trial bundle, with identical contents.
- **Notebook checks.** All five L7a notebooks have 3 objectives and 3
  takeaways, and `___` before every level-two heading and at the end. Every
  relative link and image resolves inside `L7a/`. The deck's repository links
  resolve.
- No author-machine path appears. `git diff --check` passes.

## Notes

- The notebooks' saved kernelspec is `julia-cheme5660`, the same as the
  released L6b examples. The release workflow's own test does not depend on
  it.
- The examples use the thirteen default firms unless the instructor copies
  the L6b interview files into `L7a/data/`, as described in
  [WEEK-7-INDEX.md](WEEK-7-INDEX.md). Those files are Git-ignored and do not
  ship.

## Publication

Pushing the annotated tag `week-07.0` starts the release workflow, which
creates the draft. Verify the assets and checksum, then publish it.
