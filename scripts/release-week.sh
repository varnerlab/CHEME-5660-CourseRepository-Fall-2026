#!/usr/bin/env bash
# Build the standalone weekly student bundle: root environment + vendored code +
# one week's lectures, together with its SHA-256 checksum and release notes.
#
# Usage:
#   scripts/release-week.sh week-01.0   # release-tag form (what CI passes)
#   scripts/release-week.sh 1           # bare week number; revision defaults to 0
#
# Release tags are zero-padded and carry a revision (week-01.0), while lecture
# directories are not padded (lectures/week-1). This script maps between the two,
# so a correction to an already-published week ships as week-01.1 without moving
# any lecture folder.
#
# Outputs land in artifacts/ (gitignored):
#   CHEME-5660-Fall-2026-Week-NN.R.zip
#   CHEME-5660-Fall-2026-Week-NN.R.zip.sha256
#   RELEASE-NOTES-week-NN.R.md
set -euo pipefail

ARG="${1:-}"
[ -n "$ARG" ] || { echo "usage: $0 <week-tag|week-number>" >&2; exit 1; }

SPEC="${ARG#week-}"
if [[ "$SPEC" == *.* ]]; then
  WEEK_RAW="${SPEC%%.*}"
  REV="${SPEC#*.}"
else
  WEEK_RAW="$SPEC"
  REV=0
fi

[[ "$WEEK_RAW" =~ ^[0-9]+$ ]] || { echo "ERROR: bad week in '$ARG'" >&2; exit 1; }
[[ "$REV"      =~ ^[0-9]+$ ]] || { echo "ERROR: bad revision in '$ARG'" >&2; exit 1; }

WEEK_NUM=$((10#$WEEK_RAW))          # 01 -> 1, for the lecture directory
WEEK_PAD=$(printf '%02d' "$WEEK_NUM")  # 1  -> 01, for the tag and bundle name

TAG="week-${WEEK_PAD}.${REV}"
BUNDLE="CHEME-5660-Fall-2026-Week-${WEEK_PAD}.${REV}"

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEEK_DIR="$REPO/lectures/week-$WEEK_NUM"
[ -d "$WEEK_DIR" ] || { echo "ERROR: $WEEK_DIR does not exist" >&2; exit 1; }

OUT="$REPO/artifacts"
BUILD="$OUT/$BUNDLE"
mkdir -p "$OUT"
rm -rf "$BUILD"
mkdir -p "$BUILD/lectures" "$BUILD/scripts"

cp "$REPO/Project.toml" "$REPO/Manifest.toml" "$BUILD/"
cp "$REPO/README.md" "$REPO/LICENSE" "$BUILD/"
cp "$REPO/scripts/setup.jl" "$BUILD/scripts/"
mkdir -p "$BUILD/code"
cp "$REPO/code/Project.toml" "$REPO/code/LICENSE" "$REPO/code/README.md" "$BUILD/code/"
rsync -a \
  --exclude '.DS_Store' \
  --exclude '.ipynb_checkpoints' \
  "$REPO/code/src" "$BUILD/code/"
rsync -a \
  --exclude '.DS_Store' \
  --exclude '.ipynb_checkpoints' \
  --exclude '*.aux' \
  --exclude '*.fdb_latexmk' \
  --exclude '*.fls' \
  --exclude '*.log' \
  --exclude '*.out' \
  --exclude '*.xdv' \
  "$WEEK_DIR" "$BUILD/lectures/"

ARCHIVE="$OUT/$BUNDLE.zip"
rm -f "$ARCHIVE"
# Zip from artifacts/ so the archive carries one top-level bundle directory.
( cd "$OUT" && zip -qr "$ARCHIVE" "$BUNDLE" )
rm -rf "$BUILD"

# shasum on macOS, sha256sum on Linux runners.
if command -v sha256sum >/dev/null 2>&1; then
  ( cd "$OUT" && sha256sum "$BUNDLE.zip" > "$BUNDLE.zip.sha256" )
else
  ( cd "$OUT" && shasum -a 256 "$BUNDLE.zip" > "$BUNDLE.zip.sha256" )
fi

NOTES="$OUT/RELEASE-NOTES-$TAG.md"
cat > "$NOTES" <<EOF
## Week ${WEEK_PAD}

Download **\`$BUNDLE.zip\`** under **Assets** and extract it. Do not use GitHub's
automatically generated Source code ZIP or tarball; those contain the authoring
repository rather than the student bundle.

The attached \`$BUNDLE.zip.sha256\` file contains the SHA-256 checksum.

After extracting, open the bundle folder in VS Code and follow the setup steps in
its README. The bundle root contains \`Project.toml\`, \`Manifest.toml\`,
\`README.md\`, \`code/\`, \`scripts/\`, and \`lectures/week-${WEEK_NUM}/\`.
EOF

echo "tag=$TAG"
echo "archive=$ARCHIVE"
echo "checksum=$OUT/$BUNDLE.zip.sha256"
echo "notes=$NOTES"
