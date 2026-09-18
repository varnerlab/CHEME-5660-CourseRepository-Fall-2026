# Week 5 before the September 18 pivot

This verified snapshot preserves the reviewed multiple-asset GBM L5a and
minimum-variance portfolio L5b, including saved outputs and local build files.
`inventory.json` records the source revision, working-tree status, file sizes,
and SHA-256 hashes. `SHA256SUMS` covers every regular file in the payload;
symbolic links, if any, are recorded separately. Review records are copied
unchanged under `review-records/`. Root environment files are in `environment/`.

Six figure-build files are ignored by the original figure directories' own
`.gitignore` files. Their exact bytes are also stored in
`ignored-build-files.tar.gz`, with a separate SHA-256 checksum, so the archive
remains complete after a Git checkout. Extract that tarball from this archive
directory before verifying `SHA256SUMS` when those local files are absent.

The payload is byte-for-byte unchanged. To restore it, use a separate checkout
at the recorded revision and copy `week-5/` to `lectures/week-5/`. Restore the
saved root environment if needed. Do not overlay the active refactor accidentally.
Notebook setup finds the root Project.toml and the local course package in
`code/`; the market-data snapshots live in `code/src/data/`. The snapshot depends
on those versioned resources and the installed Julia environment. XeLaTeX and
the slide theme/fonts are needed for deck builds. Original links to other weeks
and instructor records resolve after restoring the original directory layout,
not necessarily from this deeper archive location.

The old L5a material is reused as the new L5b. The old L5b is preserved here for
the planned Week 6 L6a move; Week 6 authoring is deferred. This archive is outside
the active Week 5 tree and is excluded from the student weekly bundle.
