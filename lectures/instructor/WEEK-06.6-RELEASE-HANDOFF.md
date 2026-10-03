# Week 06.6 release preparation — October 3, 2026

The instructor authorized committing and pushing the repository and publishing
a new Week 6 release. `week-06.5` is the latest published Week 6 release;
`week-06.6` is the next revision. The bundle contains both L6a and L6b.

## Changes since week-06.5

- L6b's Concept Review opening now explains which estimates determine the
  weights, how estimation error affects the allocation, and why we evaluate
  wealth and NPV on a separate period of prices. The instructor approved the
  three replacement paragraphs. All other notebook content is unchanged.
- The shared package includes the saved Cobb–Douglas and CES share-floor fix
  in `AdaptivePortfolio.jl`, with its regression tests. This allocator is not
  used by the Week 6 examples.
- The root README reflects the Week 7 teaching sequence.

The repository commit also preserves the saved Week 7 refactor, archives,
schedule updates, and Week 13/15 reference changes. Week 13 remains paused;
its files received no new edits during release preparation. The existing
L7b and L13a review records retain their open issues. Those weeks are not in
the Week 6 student ZIP.

## Local verification

- Built with `scripts/release-week.sh week-06.6`; checked the ZIP checksum.
- The ZIP has one bundle root, the root Julia environment and shared code,
  and only `lectures/week-6/`, with both L6a and L6b.
- All 15 bundled notebooks parse as JSON, contain no stored error outputs,
  and the bundle contains no author-machine paths.
- The bundled L6b lecture matches the edited authoring notebook.
- Extracted-bundle `Pkg.instantiate()` and package import succeeded under
  Julia 1.12.7, and all five `Include*.jl` files loaded successfully.
- All 274 adaptive-portfolio tests passed.
- All 14 changed/new repository notebooks parsed as JSON, and the archived
  October 2 Week 7 payload matched its recorded SHA-256 checksums.
- The Week 6 example and advanced notebooks are unchanged since week-06.5,
  so their computations were not rerun for this prose correction.
- The diff whitespace check passes with the schedule CSV's existing CRLF
  line endings recognized.

## Publication procedure

Push the repository commit, then push its annotated `week-06.6` tag. The
weekly release workflow builds and tests the tagged student bundle and creates
the draft release. Verify the uploaded ZIP and checksum before publishing.
