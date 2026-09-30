# Week 06.2 release preparation — September 30, 2026

The instructor asked to commit, push, and release the Week 6 material with the
L6b work of September 28 to 30, including the client interview workflow. The
`week-06.1` tag and release already exist and are never moved, so this goes
out as `week-06.2`, a fix-only release of the complete week (L6a and L6b).
Every release is cumulative. This is a release check, not another editorial
review; the notebook reviews are closed in their own records.

## What changed since week-06.1

- **L6b lecture.** The Examples section is split into the examples worked in
  lecture (the L6a MAGBM carryover, the client interview, the SIM portfolio, and
  the tangent portfolio) and two to review on your own (SIM estimation and
  parameter uncertainty). The in-lecture stops are labeled accordingly, and the
  tangent box links the new derivation companion.
- **Client interview.** `L6b/interview/interview.md` runs three questions with
  Claude Code's AskUserQuestion UI, and `screen-tickers.jl` turns the answers
  into a ticker list by a fixed rule (top two SIM R² per GICS sector inside a
  beta band, never mean growth). It writes `data/my-tickers.csv` and
  `data/my-client.toml`, both gitignored. The RA and RRFA examples read those
  files when present and otherwise use the thirteen L6a firms; RRFA labels the
  client's risk-free fraction. Two tables no longer crop.
- **Tangent derivation companion.** A markdown-only notebook in
  `L6b/advanced/tangent-derivation/`, listed in the advanced README.
- **Advanced notebooks.** Diagnostics round 2 (markdown only, closed at 9.1)
  and estimation-risk round 2 (closed at 9.0), both accepted September 30.
- **Housekeeping.** `Include.jl` loads TOML for the client file. The style
  guide, AGENTS.md, the eCornell integration table, and the per-notebook review
  records are updated.

## Local verification

- All 15 tracked Week 6 notebooks validate against the notebook schema. Every
  lecture, example, advanced, and derivation notebook has three learning
  objectives and three key takeaways. Every `___` precedes a level-two heading
  or closes the final Disclaimer and Risks section. No saved setup output, error
  output, or author-machine path.
- Every local link in the 15 notebooks and 8 markdown files resolves inside
  `lectures/week-6`. The lecture's link to `interview/interview.md` and the
  interview's links to the two examples resolve. The 44 external links in the
  files changed since week-06.1 respond; the four DOI links that return 403 to
  scripts are the known publisher blocks and resolve through doi.org.
- The bundle was built with `scripts/release-week.sh week-06.2` from an export
  of the staged tree (`git archive`), as CI checks it out. Title
  "CHEME 5660 - Week 06", 141 files, one top-level directory, `lectures/week-6/L6a`
  and `L6b`, including `L6b/interview/` and `L6b/advanced/tangent-derivation/`.
  No `tmp/`, checkpoint, LaTeX build, or client files. The SHA-256 check passes
  (`30832c663e5f3354ff88a82b988b2531e1e43dcbec4b0009b5b9ea6b16605074` for the local build; CI's zip differs by timestamps).
- In the extracted bundle, `Pkg.instantiate()` and
  `using VLQuantitativeFinancePackage` succeed, all five `Include.jl` files
  load, and the bundle contains no author-machine path.
- The ten computational notebooks (L6a: data minimum variance, Dirichlet,
  multiple-asset GBM, frontier geometry. L6b: SIM estimation, parameter
  uncertainty, SIM portfolio, tangent portfolio, diagnostics, estimation risk)
  executed from the top inside the extracted bundle in fresh Julia 1.12.7
  kernels without errors, in 19 to 31 seconds each. Their stream outputs match
  the saved outputs cell for cell, except the fresh-run "Activating project"
  line under the setup cell of the frontier-geometry and estimation-risk
  notebooks, which the saved notebooks do not carry.
- `screen-tickers.jl --band=market --exclude=fossil --wf=0.25 --dry-run` ran
  inside the extracted bundle in about ten seconds from the bundle root, found
  the course environment on its own, and printed 20 tickers from 10 sectors
  without writing files. `git diff --check` passes.

## Known, not blocking

- The L6b slide deck's examples frame still lists the examples as before the
  in-lecture and review-on-your-own split, and does not mention the interview.
  The deck was last rebuilt September 29. Sync it when the slides are next
  revised.
- The frontier-geometry notebook still says "efficient branch" where the lecture
  says "efficient frontier" (carried from week-06.0).
- The interview's after-class note tells the instructor to restore the examples
  with `git checkout`; students in the bundle have no repository, and the
  note is for the instructor.

## Publication

Pushing the annotated tag `week-06.2` starts the release workflow, which builds
and tests the tagged commit and creates the draft release. Verify the draft's
assets and checksum, then publish it (runbook step 5). `gh` is not logged in
on this machine, so publication happens on GitHub.
