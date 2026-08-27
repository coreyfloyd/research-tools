#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
RELEASE_ROOT="$HOME/.local/share/research-tools/releases"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
RELEASE_DIR="$RELEASE_ROOT/$VERSION"
LOCK_DIR="$RELEASE_ROOT/.install-lock"
CLAUDE_DIR="$HOME/.claude/skills"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
manifest_hash() {
  manifest_root="${1:-$ROOT}"
  (
    cd "$manifest_root"
    find skills contracts -type f -not -path '*/.build/*' -exec cksum {} \; | LC_ALL=C sort | cksum | awk '{print $1 ":" $2}'
  )
}
SOURCE_HASH="$(manifest_hash)"

copy_release_tree() {
  source="$1"
  destination="$2"
  mkdir -p "$destination"
  (
    cd "$source"
    tar --exclude='.build' -cf - .
  ) | (
    cd "$destination"
    tar -xf -
  )
}

is_package_release_link() {
  target="$1"
  skill="$2"
  [ -L "$target" ] || return 1
  case "$(readlink "$target")" in
    "$RELEASE_ROOT"/*/skills/"$skill") return 0 ;;
    *) return 1 ;;
  esac
}

LOCK_HELD=0
release_lock() {
  if [ "$LOCK_HELD" = "1" ]; then
    rmdir "$LOCK_DIR" 2>/dev/null || true
  fi
}
acquire_lock() {
  attempts=0
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge 30 ]; then
      echo "install lock busy: $LOCK_DIR" >&2
      return 1
    fi
    sleep 1
  done
  LOCK_HELD=1
  trap release_lock EXIT HUP INT TERM
}

if [ "${1:-}" = "--verify" ]; then
  test -f "$RELEASE_DIR/manifest"
  test "$(manifest_hash "$RELEASE_DIR")" = "$(cat "$RELEASE_DIR/manifest")"
  for name in "$ROOT"/skills/*; do
    [ -f "$name/SKILL.md" ] || continue
    skill="$(basename "$name")"
    test -L "$CLAUDE_DIR/$skill"
    test "$(readlink "$CLAUDE_DIR/$skill")" = "$RELEASE_DIR/skills/$skill"
    test -f "$RELEASE_DIR/contracts/karpathy-wiki.md"
    test -L "$CODEX_DIR/$skill"
    test "$(readlink "$CODEX_DIR/$skill")" = "$RELEASE_DIR/skills/$skill"
  done
  exit 0
fi

for name in "$ROOT"/skills/*; do
  [ -f "$name/SKILL.md" ] || continue
  skill="$(basename "$name")"
  for target in "$CLAUDE_DIR/$skill" "$CODEX_DIR/$skill"; do
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ -L "$target" ] && [ "$(readlink "$target")" = "$RELEASE_DIR/skills/$skill" ]; then
        continue
      fi
      if is_package_release_link "$target" "$skill"; then
        continue
      fi
      echo "collision: $target" >&2
      exit 1
    fi
    :
  done
done
mkdir -p "$CLAUDE_DIR" "$CODEX_DIR" "$HOME/.config/research-tools" "$RELEASE_ROOT"
acquire_lock
if [ ! -e "$HOME/.config/research-tools/profile.md" ]; then
  cp "$ROOT/profiles/karpathy-wiki.example.md" "$HOME/.config/research-tools/profile.md"
fi
if [ "${RESEARCH_TOOLS_VALIDATE_PROFILE:-0}" = "1" ]; then
  python3 "$ROOT/scripts/validate_profile.py" "$HOME/.config/research-tools/profile.md" >/dev/null
fi
TEMP_RELEASE="$RELEASE_ROOT/.$VERSION.$$"
rm -rf "$TEMP_RELEASE"
mkdir -p "$TEMP_RELEASE"
copy_release_tree "$ROOT/skills" "$TEMP_RELEASE/skills"
copy_release_tree "$ROOT/contracts" "$TEMP_RELEASE/contracts"
if [ ! -d "$RELEASE_DIR" ]; then
  printf '%s\n' "$SOURCE_HASH" > "$TEMP_RELEASE/manifest"
  mv "$TEMP_RELEASE" "$RELEASE_DIR"
else
  if [ ! -f "$RELEASE_DIR/manifest" ] || [ "$(cat "$RELEASE_DIR/manifest")" != "$SOURCE_HASH" ]; then
    echo "release version collision: $VERSION has different content" >&2
    rm -rf "$TEMP_RELEASE"
    exit 1
  fi
  rm -rf "$TEMP_RELEASE"
fi
for name in "$RELEASE_DIR"/skills/*; do
  [ -f "$name/SKILL.md" ] || continue
  skill="$(basename "$name")"
  for target in "$CLAUDE_DIR/$skill" "$CODEX_DIR/$skill"; do
    if [ -L "$target" ] && [ "$(readlink "$target")" != "$name" ]; then
      if is_package_release_link "$target" "$skill"; then
        unlink "$target"
      fi
    fi
    [ -L "$target" ] || ln -s "$name" "$target"
  done
done
