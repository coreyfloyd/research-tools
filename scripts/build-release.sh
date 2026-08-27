#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
OUT="${1:-$ROOT/dist}"
KEY="${RESEARCH_TOOLS_GPG_KEY:?set RESEARCH_TOOLS_GPG_KEY to the signing key fingerprint}"
mkdir -p "$OUT"
ARCHIVE="$OUT/research-tools-$VERSION.tar.gz"
tar --exclude='.git' --exclude='dist' --exclude='.build' -czf "$ARCHIVE" -C "$(dirname "$ROOT")" "$(basename "$ROOT")"
shasum -a 256 "$ARCHIVE" > "$ARCHIVE.sha256"
gpg --batch --yes --local-user "$KEY" --detach-sign --armor --output "$ARCHIVE.asc" "$ARCHIVE.sha256"
