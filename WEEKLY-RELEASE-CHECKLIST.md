# Weekly release runbook

This is the repeatable release procedure for CHEME 5660. It is designed to work
from any macOS or Linux machine with a fresh clone of the repository.

Pushing an annotated tag named `week-NN.R` starts
[the weekly release workflow](.github/workflows/release-week.yml). GitHub Actions
builds and tests the student bundle, attaches the ZIP and SHA-256 checksum to a
draft GitHub release, and leaves the final publication step to the instructor.

## At a glance

1. Synchronize a clean `main` branch and confirm the Julia version.
2. Set `WEEK_PAD`, `REVISION`, and the derived release variables.
3. Review and run the week's notebooks, slides, data, figures, and advanced
   material.
4. Build the ZIP locally and test the extracted bundle.
5. Commit the finalized materials and push `main`.
6. Create and push the annotated `week-NN.R` tag.
7. Wait for the tag-triggered GitHub Actions workflow to pass.
8. Verify the draft assets and checksum, then publish the release.

## Release identity

- Use `week-NN.0` for the first release of a week, such as `week-03.0`.
- Use `week-NN.1`, `week-NN.2`, and so on for corrections.
- Keep the week number zero-padded in the tag, but not in the lecture directory:
  `week-03.0` packages `lectures/week-3/`.
- Never move or overwrite a published tag or release asset. Publish a new
  revision instead.

## Requirements on a new machine

Install the following tools and make sure the repository is cloned with an
account that can push to `varnerlab/CHEME-5660-CourseRepository-Fall-2026`:

- Git
- Julia 1.12
- `rsync` and `zip`
- Python 3
- GitHub CLI (`gh`) for command-line review and publication, or a web browser
  for the equivalent GitHub steps

Start from an up-to-date `main` branch:

```bash
git switch main
git pull --ff-only origin main
git status --short --branch
julia --version
sed -n '1,6p' Manifest.toml
```

The working tree should be clean before release preparation. The local Julia
version should match the Julia 1.12 version recorded near the top of
`Manifest.toml`.

## 1. Prepare and review the week

Set the week and revision once. Change these two values for each release:

```bash
WEEK_PAD=03
REVISION=0
RELEASE_TAG="week-${WEEK_PAD}.${REVISION}"
WEEK_NUMBER=$((10#${WEEK_PAD}))
RELEASE_BUNDLE="CHEME-5660-Fall-2026-Week-${WEEK_PAD}.${REVISION}"
```

Review `lectures/week-${WEEK_NUMBER}/` before building:

- Confirm the required lecture and example notebooks are present.
- Confirm slide PDFs and any slide source intended for students are present.
- Confirm figures, datasets, `Include.jl` files, and optional `advanced/`
  material are present. The bundler copies the complete week directory, so
  these materials do not need to be listed separately.
- Run every student-facing notebook from the top.
- Clear saved setup-only output, including package activation, precompilation,
  author-machine paths, and dependency-version messages.
- Confirm every lecture and example notebook has exactly three learning
  objectives and exactly three key takeaways.
- Use `___` only immediately before a new level-two heading. Do not place it
  between level-three subsections or after the final section.

Treat notebook errors, missing resources, repeated dependency-version messages,
or author-machine paths as release blockers.

## 2. Build and test locally

Build the same artifact that GitHub Actions will build:

```bash
./scripts/release-week.sh "${RELEASE_TAG}"
```

Verify the checksum from the `artifacts/` directory because the checksum file
contains the ZIP basename:

```bash
(
    cd artifacts
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum -c "${RELEASE_BUNDLE}.zip.sha256"
    else
        shasum -a 256 -c "${RELEASE_BUNDLE}.zip.sha256"
    fi
)
```

Inspect and test the extracted bundle:

```bash
RELEASE_TEST_DIR="$(mktemp -d)"
python3 -m zipfile -e \
    "artifacts/${RELEASE_BUNDLE}.zip" \
    "${RELEASE_TEST_DIR}"
BUNDLE_DIR="${RELEASE_TEST_DIR}/${RELEASE_BUNDLE}"

julia --startup-file=no --project="${BUNDLE_DIR}" -e \
    'using Pkg; Pkg.instantiate(); using VLQuantitativeFinancePackage; println("SETUP-OK")'

while IFS= read -r INCLUDE_FILE; do
    julia --startup-file=no --project="${BUNDLE_DIR}" -e \
        'include(ARGS[1])' "${INCLUDE_FILE}"
done < <(find "${BUNDLE_DIR}/lectures/week-${WEEK_NUMBER}" \
    -name 'Include*.jl' | sort)
```

The ZIP should contain one top-level bundle directory with `Project.toml`,
`Manifest.toml`, `README.md`, `LICENSE`, `code/`, `scripts/`, and only
the requested `lectures/week-N/` directory.

## 3. Commit and push the finalized materials

Review the diff, commit the final state, and push `main`:

```bash
git diff --check
git status --short
git diff --stat
git add "lectures/week-${WEEK_NUMBER}"
# Also stage any intentional release-tool or root-environment changes.
git commit -m "Release ${RELEASE_TAG}: finalize student bundle"
git push origin main
```

The repository should be clean and synchronized after the push:

```bash
git status --short --branch
```

## 4. Tag the exact release commit

Create and push an annotated tag:

```bash
git tag -a "${RELEASE_TAG}" \
    -m "CHEME 5660 - Week ${WEEK_PAD}"
git push origin "${RELEASE_TAG}"
```

Pushing the tag starts the **Release weekly student bundle** workflow. Do not
create the GitHub release by hand while the workflow is running.

With GitHub CLI:

```bash
gh run list --workflow release-week.yml --limit 5
```

Alternatively, monitor the Actions page in GitHub. Wait for all workflow steps
to pass, including **Verify bundle contents**, **Test extracted bundle**, and
**Create draft GitHub release**.

## 5. Review and publish the draft

Inspect the draft before publication:

```bash
gh release view "${RELEASE_TAG}" \
    --json name,tagName,isDraft,isPrerelease,url,assets
```

Confirm:

- The title is `CHEME 5660 - Week NN`.
- The tag is `week-NN.R`.
- The release is a draft and is not marked as a prerelease.
- The assets are `${RELEASE_BUNDLE}.zip` and
  `${RELEASE_BUNDLE}.zip.sha256`.
- The release notes tell students to download the attached bundle rather than
  GitHub's automatically generated source-code archives.
- The checksum in the attached `.sha256` file matches GitHub's recorded
  SHA-256 digest for the ZIP.

Verify the two digests directly:

```bash
ATTACHED_CHECKSUM="$(gh release download "${RELEASE_TAG}" \
    --pattern '*.zip.sha256' --output -)"
GITHUB_DIGEST="$(gh release view "${RELEASE_TAG}" --json assets \
    --jq '.assets[] | select(.name | endswith(".zip")) | .digest | ltrimstr("sha256:")')"
CHECKSUM_DIGEST="$(printf '%s\n' "${ATTACHED_CHECKSUM}" | awk '{print $1}')"
test "${CHECKSUM_DIGEST}" = "${GITHUB_DIGEST}"
```

Publish the reviewed draft:

```bash
gh release edit "${RELEASE_TAG}" --draft=false
gh release view "${RELEASE_TAG}" \
    --json name,tagName,isDraft,url
```

The final `isDraft` value must be `false`. Open the reported URL once and
confirm that both assets are downloadable.

## If a release fails

- Do not force-move a tag that has been pushed to GitHub.
- Fix the problem on `main`, increment `REVISION`, and repeat the procedure
  with a new tag such as `week-03.1`.
- Do not replace an existing release asset with `--clobber`.
- Do not publish a draft whose workflow failed or whose checksum does not
  match.
