#!/bin/bash
set -euo pipefail

ARCHIVE="${1:?archive required}"
KEYRING="${2:?keyring required}"
EXPECTED_FINGERPRINT="${3:?expected signing fingerprint required}"
for tool in gpg shasum tar; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "verify-release.sh: $tool is required but was not found on PATH" >&2
    exit 1
  fi
done
test -f "$ARCHIVE" && test -f "$ARCHIVE.sha256" && test -f "$ARCHIVE.asc"
GNUPGHOME="$(mktemp -d)"
trap 'rm -rf "$GNUPGHOME"' EXIT
export GNUPGHOME
gpg --batch --import "$KEYRING" >/dev/null
NORMALIZED_EXPECTED="$(printf '%s' "$EXPECTED_FINGERPRINT" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"
VERIFY_STATUS="$(gpg --batch --status-fd 1 --verify "$ARCHIVE.asc" "$ARCHIVE.sha256" 2>/dev/null)"
SIGNING_FINGERPRINT="$(printf '%s\n' "$VERIFY_STATUS" | awk '$1 == "[GNUPG:]" && $2 == "VALIDSIG" {print $NF; exit}')"
if [ "$SIGNING_FINGERPRINT" != "$NORMALIZED_EXPECTED" ]; then
  echo "signing fingerprint mismatch" >&2
  exit 1
fi
(cd "$(dirname "$ARCHIVE")" && shasum -a 256 -c "$(basename "$ARCHIVE").sha256")
