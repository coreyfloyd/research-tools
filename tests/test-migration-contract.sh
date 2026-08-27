#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
cleanup() {
  status=$?
  rm -rf "$TEST_ROOT"
  exit "$status"
}
trap cleanup EXIT

mkdir -p "$TEST_ROOT/legacy" "$TEST_ROOT/release/skills/research-topic" "$TEST_ROOT/claude" "$TEST_ROOT/codex"
printf 'research-topic\t%s\n' "$TEST_ROOT/legacy/research-topic" > "$TEST_ROOT/manifest.tsv"
ln -s "$TEST_ROOT/legacy/research-topic" "$TEST_ROOT/claude/research-topic"
ln -s "$TEST_ROOT/legacy/research-topic" "$TEST_ROOT/codex/research-topic"
bash "$ROOT/scripts/verify-migration-handoff.sh" --preflight "$TEST_ROOT/manifest.tsv" "$TEST_ROOT/claude" "$TEST_ROOT/codex" "$TEST_ROOT/release"
unlink "$TEST_ROOT/claude/research-topic"
unlink "$TEST_ROOT/codex/research-topic"
ln -s "$TEST_ROOT/release/skills/research-topic" "$TEST_ROOT/claude/research-topic"
ln -s "$TEST_ROOT/release/skills/research-topic" "$TEST_ROOT/codex/research-topic"
bash "$ROOT/scripts/verify-migration-handoff.sh" --verify "$TEST_ROOT/manifest.tsv" "$TEST_ROOT/claude" "$TEST_ROOT/codex" "$TEST_ROOT/release"
unlink "$TEST_ROOT/codex/research-topic"
ln -s "$TEST_ROOT/legacy/other" "$TEST_ROOT/codex/research-topic"
if bash "$ROOT/scripts/verify-migration-handoff.sh" --preflight "$TEST_ROOT/manifest.tsv" "$TEST_ROOT/claude" "$TEST_ROOT/codex" "$TEST_ROOT/release"; then
  exit 1
fi
