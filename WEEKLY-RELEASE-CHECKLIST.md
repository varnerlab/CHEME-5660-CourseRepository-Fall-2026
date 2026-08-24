# Weekly release checklist

Use this checklist before pushing a `week-NN.R` tag. The tag-triggered GitHub
Actions workflow builds and validates a draft release; review the draft and its
assets before publishing it.

## Week 2 follow-up from the Week 1 clean-machine test

The Week 1 bundle worked on a clean machine. On the first execution of the L1b
NPV notebook's `Include.jl`, Julia printed an informational message that 35
dependencies had precompiled while different versions were already loaded. All
notebook cells subsequently ran successfully.

Before releasing `week-02.0`:

- Record the Julia patch version used to prepare the release and compare it with
  the `julia_version` at the top of `Manifest.toml`. Week 1's manifest was
  generated with Julia 1.12.6 while the clean-machine test used a newer 1.12
  patch release.
- Decide whether notebook `Include.jl` files should continue to call
  `Pkg.instantiate()` after `scripts/setup.jl` has already instantiated the
  bundle. Avoid changing this behavior without a clean-depot test.
- Clear saved setup-only output from every Week 2 notebook, including package
  activation, precompilation, author-machine paths, and "wrong dep version
  loaded" messages. In particular, audit the advanced L2b notebooks.
- Build `week-02.0` locally and test the extracted ZIP with a clean Julia depot
  or a separate machine using the supported Julia 1.12 release.
- Run `julia scripts/setup.jl`, restart VS Code/Jupyter, select
  **Julia (CHEME 5660)**, and execute each student-facing Week 2 notebook from
  the top.
- If Julia reports that different dependency versions are currently loaded,
  restart the kernel once and rerun the notebook. The message should disappear;
  treat a repeated message or any subsequent load error as a release blocker.

## Standard release steps

1. Confirm the intended Week `N` materials and the repository are clean.
2. Run `./scripts/release-week.sh week-NN.R`.
3. Verify the ZIP structure, SHA-256 checksum, notebooks, figures, and data.
4. Test the extracted bundle's environment, package import, and every shipped
   `Include*.jl` file.
5. Commit and push the finalized materials to `main`.
6. Create and push an annotated `week-NN.R` tag on that exact commit.
7. Wait for the **Release weekly student bundle** workflow to pass.
8. Review the draft title, notes, ZIP, checksum, and GitHub-recorded asset
   digest, then publish the release.
