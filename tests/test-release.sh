#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT
export GNUPGHOME="$TEST_DIR/gnupg"
mkdir -m 700 "$GNUPGHOME"
gpg --batch --passphrase '' --quick-generate-key 'research-tools test <test@example.invalid>' ed25519 sign 0 >/dev/null 2>&1
KEY="$(gpg --batch --with-colons --list-secret-keys | awk -F: '$1 == "fpr" {print $10; exit}')"
gpg --batch --armor --export "$KEY" > "$TEST_DIR/public.asc"
RESEARCH_TOOLS_GPG_KEY="$KEY" bash "$ROOT/scripts/build-release.sh" "$TEST_DIR/dist"
ARCHIVE="$TEST_DIR/dist/research-tools-$(tr -d '[:space:]' < "$ROOT/VERSION").tar.gz"
if tar -tzf "$ARCHIVE" | rg -q '(^|/)\.Ulysses-'; then
  exit 1
fi
bash "$ROOT/scripts/verify-release.sh" "$ARCHIVE" "$TEST_DIR/public.asc" "$KEY"
gpg --batch --passphrase '' --quick-generate-key 'other test <other@example.invalid>' ed25519 sign 0 >/dev/null 2>&1
OTHER_KEY="$(gpg --batch --with-colons --list-secret-keys | awk -F: '$1 == "fpr" {last=$10} END {print last}')"
gpg --batch --armor --export "$OTHER_KEY" > "$TEST_DIR/other.asc"
RESEARCH_TOOLS_GPG_KEY="$OTHER_KEY" bash "$ROOT/scripts/build-release.sh" "$TEST_DIR/other-dist"
OTHER_ARCHIVE="$TEST_DIR/other-dist/research-tools-$(tr -d '[:space:]' < "$ROOT/VERSION").tar.gz"
if bash "$ROOT/scripts/verify-release.sh" "$OTHER_ARCHIVE" "$TEST_DIR/other.asc" "$KEY"; then
  exit 1
fi
cat "$TEST_DIR/public.asc" "$TEST_DIR/other.asc" > "$TEST_DIR/two-keys.asc"
if bash "$ROOT/scripts/verify-release.sh" "$OTHER_ARCHIVE" "$TEST_DIR/two-keys.asc" "$KEY"; then
  exit 1
fi
INSTALL_HOME="$TEST_DIR/install-home"
HOME="$INSTALL_HOME" CODEX_HOME="$INSTALL_HOME/.codex" bash "$ROOT/scripts/install-release.sh" "$ARCHIVE" "$TEST_DIR/public.asc" "$KEY"
HOME="$INSTALL_HOME" CODEX_HOME="$INSTALL_HOME/.codex" bash "$ROOT/scripts/install-release.sh" "$ARCHIVE" "$TEST_DIR/public.asc" "$KEY"
test -L "$INSTALL_HOME/.claude/skills/research-topic"
test -L "$INSTALL_HOME/.codex/skills/research-topic"
test -L "$INSTALL_HOME/.claude/skills/research-tools-set-up"
test -f "$INSTALL_HOME/.local/share/research-tools/current/profiles/karpathy-wiki.example.md"
test -f "$INSTALL_HOME/.local/share/research-tools/current/scripts/validate_profile.py"
if HOME="$INSTALL_HOME" CODEX_HOME="$INSTALL_HOME/.codex" bash "$ROOT/install.sh" --verify; then
  exit 1
fi
printf x >> "$ARCHIVE"
if bash "$ROOT/scripts/verify-release.sh" "$ARCHIVE" "$TEST_DIR/public.asc" "$KEY"; then
  exit 1
fi
