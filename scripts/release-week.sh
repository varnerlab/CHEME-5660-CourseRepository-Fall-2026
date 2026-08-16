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
cp "$REPO/README.md" "$REPO/LICENSE" "$BUILD/"
mkdir -p "$BUILD/scripts" && cp "$REPO/scripts/setup.jl" "$BUILD/scripts/"
rsync -a --exclude '.git' --exclude 'Manifest.toml' "$REPO/code" "$BUILD/"
rsync -a "$WEEK" "$BUILD/lectures/"
mkdir -p "$REPO/artifacts"
rm -f "$REPO/artifacts/week-$N.zip"
( cd "$BUILD" && zip -qr "$REPO/artifacts/week-$N.zip" . )
rm -rf "$BUILD"
echo "artifacts/week-$N.zip"
