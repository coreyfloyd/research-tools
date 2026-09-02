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
  rm -rf "$TEST_HOME" "${COLLISION_HOME:-}" "${PROFILE_HOME:-}" "${CONCURRENT_HOME:-}" "${TAMPER_HOME:-}" "${UPGRADE_HOME:-}" "${BROKEN_HOME:-}" "${CURRENT_DIR_HOME:-}" "${RETIRED_HOME:-}" "${NOPY_HOME:-}" "${MISSINGLINK_HOME:-}" "${REMEDY_HOME:-}" "$BUILD_SENTINEL"
  exit "$status"
}
trap cleanup EXIT
release_manifest() {
  (
    cd "$1"
    manifest_paths="skills contracts"
    [ ! -d profiles ] || manifest_paths="$manifest_paths profiles"
    [ ! -f scripts/validate_profile.py ] || manifest_paths="$manifest_paths scripts/validate_profile.py"
    find $manifest_paths -type f -not -path '*/.build/*' -exec cksum {} \; | LC_ALL=C sort | cksum | awk '{print $1 ":" $2}'
  )
}
HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
if HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify; then
  exit 1
fi
test ! -e "$TEST_HOME/.config/research-tools/profile.md"
test -L "$TEST_HOME/.local/share/research-tools/current"
test -L "$TEST_HOME/.claude/skills/research-tools-set-up"
test -L "$TEST_HOME/.codex/skills/research-tools-set-up"
test -f "$TEST_HOME/.local/share/research-tools/releases/$VERSION/profiles/karpathy-wiki.example.md"
test -f "$TEST_HOME/.local/share/research-tools/releases/$VERSION/scripts/validate_profile.py"
mkdir -p "$TEST_HOME/.config/research-tools" "$TEST_HOME/knowledge/raw" "$TEST_HOME/knowledge/wiki" "$TEST_HOME/knowledge/output" "$TEST_HOME/knowledge/docs"
touch "$TEST_HOME/knowledge/wiki/hot.md" "$TEST_HOME/knowledge/docs/log.md" "$TEST_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$TEST_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$TEST_HOME/.config/research-tools/profile.md"
HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify
test -L "$TEST_HOME/.local/share/research-tools/current"
test "$(readlink "$TEST_HOME/.local/share/research-tools/current")" = "$TEST_HOME/.local/share/research-tools/releases/$VERSION"
test -f "$TEST_HOME/.local/share/research-tools/releases/$VERSION/contracts/karpathy-wiki.md"
test -f "$TEST_HOME/.local/share/research-tools/releases/$VERSION/profiles/karpathy-wiki.example.md"
test -f "$TEST_HOME/.local/share/research-tools/releases/$VERSION/scripts/validate_profile.py"
test -x "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/research-quick/reddit-read.sh"
test -x "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/transcribe/tools/apple-speech/run-transcribe.sh"
test ! -e "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/transcribe/tools/apple-speech/.build/research-tools-test-sentinel"
grep -Fq 'Karpathy-wiki contract' "$TEST_HOME/.local/share/research-tools/releases/$VERSION/skills/research-to-wiki/SKILL.md"
for skill in "$ROOT"/skills/*; do
  test -f "$skill/SKILL.md" || continue
  name="$(basename "$skill")"
  case "$(readlink "$TEST_HOME/.claude/skills/$name")" in
    "$TEST_HOME/.local/share/research-tools/current/skills/"*) ;;
    *) exit 1 ;;
  esac
  case "$(readlink "$TEST_HOME/.codex/skills/$name")" in
    "$TEST_HOME/.local/share/research-tools/current/skills/"*) ;;
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

BROKEN_HOME="$(mktemp -d)"
mkdir -p "$BROKEN_HOME/.config/research-tools" "$BROKEN_HOME/knowledge/raw" "$BROKEN_HOME/knowledge/wiki" "$BROKEN_HOME/knowledge/output" "$BROKEN_HOME/knowledge/docs" "$BROKEN_HOME/.claude/skills"
touch "$BROKEN_HOME/knowledge/wiki/hot.md" "$BROKEN_HOME/knowledge/docs/log.md" "$BROKEN_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$BROKEN_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$BROKEN_HOME/.config/research-tools/profile.md"
ln -s "$BROKEN_HOME/.local/share/research-tools/releases/0.2.0/skills/research-topic" "$BROKEN_HOME/.claude/skills/research-topic"
if HOME="$BROKEN_HOME" CODEX_HOME="$BROKEN_HOME/.codex" bash "$SOURCE_ROOT/install.sh"; then
  exit 1
fi
test "$(readlink "$BROKEN_HOME/.claude/skills/research-topic")" = "$BROKEN_HOME/.local/share/research-tools/releases/0.2.0/skills/research-topic"
test ! -e "$BROKEN_HOME/.local/share/research-tools/current"
test ! -e "$BROKEN_HOME/.local/share/research-tools/releases"

CURRENT_DIR_HOME="$(mktemp -d)"
mkdir -p "$CURRENT_DIR_HOME/.config/research-tools" "$CURRENT_DIR_HOME/knowledge/raw" "$CURRENT_DIR_HOME/knowledge/wiki" "$CURRENT_DIR_HOME/knowledge/output" "$CURRENT_DIR_HOME/knowledge/docs" "$CURRENT_DIR_HOME/.claude/skills" "$CURRENT_DIR_HOME/.local/share/research-tools/current/skills/research-topic"
touch "$CURRENT_DIR_HOME/knowledge/wiki/hot.md" "$CURRENT_DIR_HOME/knowledge/docs/log.md" "$CURRENT_DIR_HOME/knowledge/docs/DECISIONS.md" "$CURRENT_DIR_HOME/.local/share/research-tools/current/skills/research-topic/SKILL.md"
sed "s|/absolute/path/to/knowledge|$CURRENT_DIR_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$CURRENT_DIR_HOME/.config/research-tools/profile.md"
ln -s "$CURRENT_DIR_HOME/.local/share/research-tools/current/skills/research-topic" "$CURRENT_DIR_HOME/.claude/skills/research-topic"
if HOME="$CURRENT_DIR_HOME" CODEX_HOME="$CURRENT_DIR_HOME/.codex" bash "$SOURCE_ROOT/install.sh"; then
  exit 1
fi
test -d "$CURRENT_DIR_HOME/.local/share/research-tools/current"
test ! -e "$CURRENT_DIR_HOME/.codex/skills/research-topic"
test ! -e "$CURRENT_DIR_HOME/.local/share/research-tools/releases"

RETIRED_HOME="$(mktemp -d)"
mkdir -p "$RETIRED_HOME/.config/research-tools" "$RETIRED_HOME/knowledge/raw" "$RETIRED_HOME/knowledge/wiki" "$RETIRED_HOME/knowledge/output" "$RETIRED_HOME/knowledge/docs" "$RETIRED_HOME/.claude/skills" "$RETIRED_HOME/.codex/skills" "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9/skills/retired-skill" "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9/contracts"
touch "$RETIRED_HOME/knowledge/wiki/hot.md" "$RETIRED_HOME/knowledge/docs/log.md" "$RETIRED_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$RETIRED_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$RETIRED_HOME/.config/research-tools/profile.md"
printf '%s\n' '---' 'name: retired-skill' 'description: retired fixture' '---' > "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9/skills/retired-skill/SKILL.md"
printf '# contract\n' > "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9/contracts/karpathy-wiki.md"
release_manifest "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9" > "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9/manifest"
ln -s "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9" "$RETIRED_HOME/.local/share/research-tools/current"
ln -s "$RETIRED_HOME/.local/share/research-tools/current/skills/retired-skill" "$RETIRED_HOME/.claude/skills/retired-skill"
ln -s "$RETIRED_HOME/.local/share/research-tools/current/skills/retired-skill" "$RETIRED_HOME/.codex/skills/retired-skill"
if HOME="$RETIRED_HOME" CODEX_HOME="$RETIRED_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify; then
  exit 1
fi
if HOME="$RETIRED_HOME" CODEX_HOME="$RETIRED_HOME/.codex" bash "$SOURCE_ROOT/install.sh"; then
  exit 1
fi
test "$(readlink "$RETIRED_HOME/.claude/skills/retired-skill")" = "$RETIRED_HOME/.local/share/research-tools/current/skills/retired-skill"
test "$(readlink "$RETIRED_HOME/.codex/skills/retired-skill")" = "$RETIRED_HOME/.local/share/research-tools/current/skills/retired-skill"
test "$(readlink "$RETIRED_HOME/.local/share/research-tools/current")" = "$RETIRED_HOME/.local/share/research-tools/releases/0.0.9"

PROFILE_HOME="$(mktemp -d)"
mkdir -p "$PROFILE_HOME/.config/research-tools" "$PROFILE_HOME/knowledge/raw" "$PROFILE_HOME/knowledge/wiki" "$PROFILE_HOME/knowledge/output" "$PROFILE_HOME/knowledge/docs"
touch "$PROFILE_HOME/knowledge/wiki/hot.md" "$PROFILE_HOME/knowledge/docs/log.md" "$PROFILE_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$PROFILE_HOME/knowledge|" "$ROOT/profiles/karpathy-wiki.example.md" > "$PROFILE_HOME/.config/research-tools/profile.md"
HOME="$PROFILE_HOME" CODEX_HOME="$PROFILE_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
HOME="$PROFILE_HOME" CODEX_HOME="$PROFILE_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify

CONCURRENT_HOME="$(mktemp -d)"
mkdir -p "$CONCURRENT_HOME/.config/research-tools" "$CONCURRENT_HOME/knowledge/raw" "$CONCURRENT_HOME/knowledge/wiki" "$CONCURRENT_HOME/knowledge/output" "$CONCURRENT_HOME/knowledge/docs"
touch "$CONCURRENT_HOME/knowledge/wiki/hot.md" "$CONCURRENT_HOME/knowledge/docs/log.md" "$CONCURRENT_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$CONCURRENT_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$CONCURRENT_HOME/.config/research-tools/profile.md"
HOME="$CONCURRENT_HOME" CODEX_HOME="$CONCURRENT_HOME/.codex" bash "$SOURCE_ROOT/install.sh" >"$CONCURRENT_HOME/one.log" 2>&1 &
ONE_PID=$!
HOME="$CONCURRENT_HOME" CODEX_HOME="$CONCURRENT_HOME/.codex" bash "$SOURCE_ROOT/install.sh" >"$CONCURRENT_HOME/two.log" 2>&1 &
TWO_PID=$!
wait "$ONE_PID"
wait "$TWO_PID"
HOME="$CONCURRENT_HOME" CODEX_HOME="$CONCURRENT_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify
rm -rf "$CONCURRENT_HOME"

UPGRADE_HOME="$(mktemp -d)"
mkdir -p "$UPGRADE_HOME/.config/research-tools" "$UPGRADE_HOME/knowledge/raw" "$UPGRADE_HOME/knowledge/wiki" "$UPGRADE_HOME/knowledge/output" "$UPGRADE_HOME/knowledge/docs"
touch "$UPGRADE_HOME/knowledge/wiki/hot.md" "$UPGRADE_HOME/knowledge/docs/log.md" "$UPGRADE_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$UPGRADE_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$UPGRADE_HOME/.config/research-tools/profile.md"
for skill in "$ROOT"/skills/*; do
  test -f "$skill/SKILL.md" || continue
  name="$(basename "$skill")"
  mkdir -p "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/skills/$name" "$UPGRADE_HOME/.claude/skills" "$UPGRADE_HOME/.codex/skills"
  cp -R "$SOURCE_ROOT/skills/$name/." "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/skills/$name/"
  ln -s "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/skills/$name" "$UPGRADE_HOME/.claude/skills/$name"
  ln -s "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/skills/$name" "$UPGRADE_HOME/.codex/skills/$name"
done
cp -R "$SOURCE_ROOT/contracts" "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/contracts"
release_manifest "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9" > "$UPGRADE_HOME/.local/share/research-tools/releases/0.0.9/manifest"
HOME="$UPGRADE_HOME" CODEX_HOME="$UPGRADE_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
for skill in "$ROOT"/skills/*; do
  test -f "$skill/SKILL.md" || continue
  name="$(basename "$skill")"
  test "$(readlink "$UPGRADE_HOME/.claude/skills/$name")" = "$UPGRADE_HOME/.local/share/research-tools/current/skills/$name"
  test "$(readlink "$UPGRADE_HOME/.codex/skills/$name")" = "$UPGRADE_HOME/.local/share/research-tools/current/skills/$name"
done
test "$(readlink "$UPGRADE_HOME/.local/share/research-tools/current")" = "$UPGRADE_HOME/.local/share/research-tools/releases/$VERSION"

TAMPER_HOME="$(mktemp -d)"
mkdir -p "$TAMPER_HOME/.config/research-tools" "$TAMPER_HOME/knowledge/raw" "$TAMPER_HOME/knowledge/wiki" "$TAMPER_HOME/knowledge/output" "$TAMPER_HOME/knowledge/docs"
touch "$TAMPER_HOME/knowledge/wiki/hot.md" "$TAMPER_HOME/knowledge/docs/log.md" "$TAMPER_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$TAMPER_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$TAMPER_HOME/.config/research-tools/profile.md"
HOME="$TAMPER_HOME" CODEX_HOME="$TAMPER_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
printf x >> "$TAMPER_HOME/.local/share/research-tools/releases/$VERSION/skills/research-topic/SKILL.md"
if HOME="$TAMPER_HOME" CODEX_HOME="$TAMPER_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify; then
  exit 1
fi
rm -rf "$TAMPER_HOME"

# F2: no python3 on PATH must refuse before any filesystem changes, naming the tool.
NOPY_HOME="$(mktemp -d)"
NOPY_BIN="$NOPY_HOME/bin"
mkdir -p "$NOPY_BIN" "$NOPY_HOME/home"
ln -s "$(command -v bash)" "$NOPY_BIN/bash"
NOPY_STDERR="$NOPY_HOME/stderr.log"
if PATH="$NOPY_BIN" HOME="$NOPY_HOME/home" CODEX_HOME="$NOPY_HOME/home/.codex" bash "$SOURCE_ROOT/install.sh" 2>"$NOPY_STDERR"; then
  exit 1
fi
grep -q python3 "$NOPY_STDERR"
test ! -e "$NOPY_HOME/home/.local/share/research-tools/releases"

# F3: --verify must name a missing client skill link instead of failing silently.
MISSINGLINK_HOME="$(mktemp -d)"
mkdir -p "$MISSINGLINK_HOME/.config/research-tools" "$MISSINGLINK_HOME/knowledge/raw" "$MISSINGLINK_HOME/knowledge/wiki" "$MISSINGLINK_HOME/knowledge/output" "$MISSINGLINK_HOME/knowledge/docs"
touch "$MISSINGLINK_HOME/knowledge/wiki/hot.md" "$MISSINGLINK_HOME/knowledge/docs/log.md" "$MISSINGLINK_HOME/knowledge/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$MISSINGLINK_HOME/knowledge|" "$SOURCE_ROOT/profiles/karpathy-wiki.example.md" > "$MISSINGLINK_HOME/.config/research-tools/profile.md"
HOME="$MISSINGLINK_HOME" CODEX_HOME="$MISSINGLINK_HOME/.codex" bash "$SOURCE_ROOT/install.sh"
MISSINGLINK_PATH="$MISSINGLINK_HOME/.claude/skills/research-quick"
rm -f "$MISSINGLINK_PATH"
MISSINGLINK_STDERR="$MISSINGLINK_HOME/stderr.log"
if HOME="$MISSINGLINK_HOME" CODEX_HOME="$MISSINGLINK_HOME/.codex" bash "$SOURCE_ROOT/install.sh" --verify 2>"$MISSINGLINK_STDERR"; then
  exit 1
fi
grep -Fq "$MISSINGLINK_PATH" "$MISSINGLINK_STDERR"

# F7: refusal messages must carry a remedy.
REMEDY_HOME="$(mktemp -d)"
mkdir -p "$REMEDY_HOME/.claude/skills/research-quick"
REMEDY_STDERR="$REMEDY_HOME/stderr.log"
if HOME="$REMEDY_HOME" CODEX_HOME="$REMEDY_HOME/.codex" bash "$SOURCE_ROOT/install.sh" 2>"$REMEDY_STDERR"; then
  exit 1
fi
grep -Fq "collision: $REMEDY_HOME/.claude/skills/research-quick" "$REMEDY_STDERR"
grep -Fq "move or remove it and re-run install.sh" "$REMEDY_STDERR"
