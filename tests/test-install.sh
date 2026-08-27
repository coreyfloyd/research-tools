#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
TEST_HOME="$(mktemp -d)"
SOURCE_ROOT="$TEST_HOME/source"
cp -R "$ROOT" "$SOURCE_ROOT"
BUILD_SENTINEL="$SOURCE_ROOT/skills/transcribe/tools/apple-speech/.build/research-tools-test-sentinel"
mkdir -p "$(dirname "$BUILD_SENTINEL")"
touch "$BUILD_SENTINEL"
cleanup() {
  status=$?
  rm -rf "$TEST_HOME" "${COLLISION_HOME:-}" "${PROFILE_HOME:-}" "${CONCURRENT_HOME:-}" "${TAMPER_HOME:-}" "${UPGRADE_HOME:-}" "$BUILD_SENTINEL"
  exit "$status"
}
trap cleanup EXIT
HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify
test -f "$TEST_HOME/.config/research-tools/profile.md"
test -f "$TEST_HOME/.local/share/research-tools/releases/$VERSION/contracts/karpathy-wiki.md"
test -x "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/research-quick/reddit-read.sh"
test -x "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/transcribe/tools/apple-speech/run-transcribe.sh"
test ! -e "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/transcribe/tools/apple-speech/.build/research-tools-test-sentinel"
grep -Fq 'Karpathy-wiki contract' "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/research-to-wiki/SKILL.md"
for skill in "$ROOT"/skills/*; do
  test -f "$skill/SKILL.md" || continue
  name="$(basename "$skill")"
  case "$(readlink "$TEST_HOME/.claude/skills/$name")" in
    "$TEST_HOME/.local/share/research-tools/releases/"*) ;;
    *) exit 1 ;;
  esac
  case "$(readlink "$TEST_HOME/.codex/skills/$name")" in
    "$TEST_HOME/.local/share/research-tools/releases/"*) ;;
    *) exit 1 ;;
  esac
done
COLLISION_HOME="$(mktemp -d)"
mkdir -p "$COLLISION_HOME/.claude/skills"
mkdir -p "$COLLISION_HOME/custom-skill"
ln -s "$COLLISION_HOME/custom-skill" "$COLLISION_HOME/.claude/skills/research-topic"
if HOME="$COLLISION_HOME" CODEX_HOME="$COLLISION_HOME/.codex" bash "$SOURCE_ROOT/install.sh"; then
  exit 1
fi
test "$(readlink "$COLLISION_HOME/.claude/skills/research-topic")" = "$COLLISION_HOME/custom-skill"
test ! -e "$COLLISION_HOME/.config/research-tools/profile.md"
test ! -e "$COLLISION_HOME/.local/share/research-tools/releases"

PROFILE_HOME="$(mktemp -d)"
mkdir -p "$PROFILE_HOME/.config/research-tools" "$PROFILE_HOME/knowledge/raw" "$PROFILE_HOME/knowledge/wiki" "$PROFILE_HOME/knowledge/output" "$PROFILE_HOME/knowledge/docs"
touch "$PROFILE_HOME/knowledge/wiki/hot.md" "$PROFILE_HOME/knowledge/docs/log.md" "$PROFILE_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$PROFILE_HOME/knowledge|" "$ROOT/profiles/karpathy-wiki.example.md" > "$PROFILE_HOME/.config/research-tools/profile.md"
HOME="$PROFILE_HOME" CODEX_HOME="$PROFILE_HOME/.codex" RESEARCH_TOOLS_VALIDATE_PROFILE=1 bash "$SOURCE_ROOT/install.sh"
HOME="$PROFILE_HOME" CODEX_HOME="$PROFILE_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify

CONCURRENT_HOME="$(mktemp -d)"
HOME="$CONCURRENT_HOME" CODEX_HOME="$CONCURRENT_HOME/.codex" bash "$SOURCE_ROOT/install.sh" >"$CONCURRENT_HOME/one.log" 2>&1 &
ONE_PID=$!
HOME="$CONCURRENT_HOME" CODEX_HOME="$CONCURRENT_HOME/.codex" bash "$SOURCE_ROOT/install.sh" >"$CONCURRENT_HOME/two.log" 2>&1 &
TWO_PID=$!
wait "$ONE_PID"
wait "$TWO_PID"
HOME="$CONCURRENT_HOME" CODEX_HOME="$CONCURRENT_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify
rm -rf "$CONCURRENT_HOME"

UPGRADE_HOME="$(mktemp -d)"
for skill in "$ROOT"/skills/*; do
  test -f "$skill/SKILL.md" || continue
  name="$(basename "$skill")"
  mkdir -p "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/skills/$name" "$UPGRADE_HOME/.claude/skills" "$UPGRADE_HOME/.codex/skills"
  ln -s "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/skills/$name" "$UPGRADE_HOME/.claude/skills/$name"
  ln -s "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/skills/$name" "$UPGRADE_HOME/.codex/skills/$name"
done
HOME="$UPGRADE_HOME" CODEX_HOME="$UPGRADE_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
for skill in "$ROOT"/skills/*; do
  test -f "$skill/SKILL.md" || continue
  name="$(basename "$skill")"
  test "$(readlink "$UPGRADE_HOME/.claude/skills/$name")" = "$UPGRADE_HOME/.local/share/research-tools/releases/$VERSION/skills/$name"
  test "$(readlink "$UPGRADE_HOME/.codex/skills/$name")" = "$UPGRADE_HOME/.local/share/research-tools/releases/$VERSION/skills/$name"
done

TAMPER_HOME="$(mktemp -d)"
HOME="$TAMPER_HOME" CODEX_HOME="$TAMPER_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
printf x >> "$TAMPER_HOME/.local/share/research-tools/releases/$VERSION/skills/research-topic/SKILL.md"
if HOME="$TAMPER_HOME" CODEX_HOME="$TAMPER_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify; then
  exit 1
fi
rm -rf "$TAMPER_HOME"
