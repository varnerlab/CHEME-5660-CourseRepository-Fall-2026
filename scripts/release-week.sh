#!/bin/sh
# Build the standalone weekly bundle: root env + vendored package + one week's lectures.
# Usage: scripts/release-week.sh <week-number>
set -eu
N="$1"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WEEK="$REPO/lectures/week-$N"
[ -d "$WEEK" ] || { echo "ERROR: $WEEK does not exist" >&2; exit 1; }
BUILD="$REPO/artifacts/build-week-$N"
rm -rf "$BUILD" && mkdir -p "$BUILD/lectures"
cp "$REPO/Project.toml" "$REPO/Manifest.toml" "$BUILD/"
rsync -a --exclude '.git' "$REPO/code" "$BUILD/"
rsync -a "$WEEK" "$BUILD/lectures/"
mkdir -p "$REPO/artifacts"
( cd "$BUILD" && zip -qr "$REPO/artifacts/week-$N.zip" . )
rm -rf "$BUILD"
echo "artifacts/week-$N.zip"
