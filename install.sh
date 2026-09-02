#!/bin/bash
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo "install.sh: python3 is required but was not found on PATH" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"
RELEASE_ROOT="$HOME/.local/share/research-tools/releases"
CURRENT_LINK="$HOME/.local/share/research-tools/current"
PROFILE="$HOME/.config/research-tools/profile.md"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
RELEASE_DIR="$RELEASE_ROOT/$VERSION"
LOCK_DIR="$HOME/.config/research-tools/.install-lock"
CLAUDE_DIR="$HOME/.claude/skills"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
manifest_listing() {
  manifest_root="${1:-$ROOT}"
  (
    cd "$manifest_root"
    manifest_paths="skills contracts"
    [ ! -d profiles ] || manifest_paths="$manifest_paths profiles"
    [ ! -f scripts/validate_profile.py ] || manifest_paths="$manifest_paths scripts/validate_profile.py"
    find $manifest_paths -type f -not -path '*/.build/*' -not -path '*/.Ulysses-*/*' -not -name '.DS_Store' -not -name '.Ulysses-*' -exec cksum {} \; | LC_ALL=C sort
  )
}
manifest_hash() {
  manifest_listing "${1:-$ROOT}" | cksum | awk '{print $1 ":" $2}'
}
manifest_hash_legacy() {
  manifest_root="${1:-$ROOT}"
  (
    cd "$manifest_root"
    manifest_paths="skills contracts"
    [ ! -d profiles ] || manifest_paths="$manifest_paths profiles"
    [ ! -f scripts/validate_profile.py ] || manifest_paths="$manifest_paths scripts/validate_profile.py"
    find $manifest_paths -type f -not -path '*/.build/*' -exec cksum {} \; | LC_ALL=C sort | cksum | awk '{print $1 ":" $2}'
  )
}
SOURCE_HASH="$(manifest_hash)"

copy_release_tree() {
  source="$1"
  destination="$2"
  mkdir -p "$destination"
  (
    cd "$source"
    tar --exclude='.build' --exclude='.DS_Store' --exclude='.Ulysses-*' -cf - .
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
    "$RELEASE_ROOT"/*/skills/"$skill"|"$CURRENT_LINK"/skills/"$skill") return 0 ;;
    *) return 1 ;;
  esac
}

replace_link() {
  destination="$1"
  source="$2"
  expected="$3"
  python3 - "$destination" "$source" "$expected" <<'PY'
import os
import sys

destination, source, expected = sys.argv[1:]
if os.path.lexists(destination):
    if not os.path.islink(destination) or os.readlink(destination) != expected:
        raise SystemExit(f"collision changed during install: {destination}")
elif expected != "__absent__":
    raise SystemExit(f"link disappeared during install: {destination}")
temporary = f"{destination}.research-tools.{os.getpid()}"
try:
    os.unlink(temporary)
except FileNotFoundError:
    pass
os.symlink(source, temporary)
os.replace(temporary, destination)
PY
}

set_current_release() {
  release="$1"
  expected="$2"
  python3 - "$CURRENT_LINK" "$release" "$expected" <<'PY'
import os
import sys

current, release, expected = sys.argv[1:]
if os.path.lexists(current):
    if not os.path.islink(current) or os.readlink(current) != expected:
        raise SystemExit(f"current pointer changed during install: {current}")
elif expected != "__absent__":
    raise SystemExit(f"current pointer disappeared during install: {current}")
temporary = f"{current}.research-tools.{os.getpid()}"
try:
    os.unlink(temporary)
except FileNotFoundError:
    pass
os.symlink(release, temporary)
os.replace(temporary, current)
PY
}

valid_release() {
  release="$1"
  [ "$(dirname "$release")" = "$RELEASE_ROOT" ] || return 1
  [ -d "$release" ] && [ -f "$release/manifest" ] || return 1
  stored="$(cat "$release/manifest")"
  [ "$(manifest_hash "$release")" = "$stored" ] || [ "$(manifest_hash_legacy "$release")" = "$stored" ]
}

CURRENT_RELEASE=""
validate_current_pointer() {
  if [ ! -e "$CURRENT_LINK" ] && [ ! -L "$CURRENT_LINK" ]; then
    return 0
  fi
  if [ ! -L "$CURRENT_LINK" ]; then
    echo "collision: current pointer is not a symlink" >&2
    return 1
  fi
  CURRENT_RELEASE="$(readlink "$CURRENT_LINK")"
  if ! valid_release "$CURRENT_RELEASE"; then
    echo "collision: current pointer is not a valid package release" >&2
    return 1
  fi
}

reject_retired_links() {
  for client_dir in "$CLAUDE_DIR" "$CODEX_DIR"; do
    [ -d "$client_dir" ] || continue
    for target in "$client_dir"/*; do
      [ -L "$target" ] || continue
      skill="$(basename "$target")"
      if is_package_release_link "$target" "$skill" && [ ! -f "$ROOT/skills/$skill/SKILL.md" ]; then
        echo "retired package skill: $target (move or remove it and re-run install.sh)" >&2
        return 1
      fi
    done
  done
}

validate_profile() {
  if [ ! -f "$PROFILE" ]; then
    echo "profile missing: run the research-tools-set-up skill after installing" >&2
    return 1
  fi
  validator="$ROOT/scripts/validate_profile.py"
  if [ -f "$CURRENT_LINK/scripts/validate_profile.py" ]; then
    validator="$CURRENT_LINK/scripts/validate_profile.py"
  fi
  python3 "$validator" "$PROFILE" >/dev/null
}

LOCK_HELD=0
release_lock() {
  if [ "$LOCK_HELD" = "1" ]; then
    rm -f "$LOCK_DIR/pid"
    rmdir "$LOCK_DIR" 2>/dev/null || true
    LOCK_HELD=0
  fi
}
interrupted() {
  release_lock
  trap - EXIT HUP INT TERM
  exit "$1"
}
acquire_lock() {
  attempts=0
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    if [ -f "$LOCK_DIR/pid" ]; then
      owner="$(cat "$LOCK_DIR/pid" 2>/dev/null || true)"
      if [ -n "$owner" ] && ! kill -0 "$owner" 2>/dev/null; then
        rm -rf "$LOCK_DIR"
        continue
      fi
    fi
    attempts=$((attempts + 1))
    if [ "$attempts" -ge 30 ]; then
      echo "install lock busy: $LOCK_DIR" >&2
      return 1
    fi
    sleep 1
  done
  printf '%s\n' "$$" > "$LOCK_DIR/pid"
  LOCK_HELD=1
  trap release_lock EXIT
  trap 'interrupted 129' HUP
  trap 'interrupted 130' INT
  trap 'interrupted 143' TERM
}

verify_check() {
  what="$1"
  path="$2"
  shift 2
  if ! "$@"; then
    echo "verify failed: $what $path" >&2
    exit 1
  fi
}

if [ "${1:-}" = "--verify" ]; then
  reject_retired_links
  verify_check "current pointer" "$CURRENT_LINK" test -L "$CURRENT_LINK"
  verify_check "current manifest" "$CURRENT_LINK/manifest" test -f "$CURRENT_LINK/manifest"
  current_manifest_hash="$(manifest_hash "$CURRENT_LINK")"
  recorded_manifest_hash="$(cat "$CURRENT_LINK/manifest")"
  verify_check "current manifest hash" "$CURRENT_LINK" test "$current_manifest_hash" = "$recorded_manifest_hash"
  verify_check "example profile" "$CURRENT_LINK/profiles/karpathy-wiki.example.md" test -f "$CURRENT_LINK/profiles/karpathy-wiki.example.md"
  verify_check "profile validator" "$CURRENT_LINK/scripts/validate_profile.py" test -f "$CURRENT_LINK/scripts/validate_profile.py"
  for name in "$ROOT"/skills/*; do
    [ -f "$name/SKILL.md" ] || continue
    skill="$(basename "$name")"
    verify_check "claude skill link" "$CLAUDE_DIR/$skill" test -L "$CLAUDE_DIR/$skill"
    claude_link_target="$(readlink "$CLAUDE_DIR/$skill")"
    verify_check "claude skill target" "$CLAUDE_DIR/$skill" test "$claude_link_target" = "$CURRENT_LINK/skills/$skill"
    verify_check "wiki contract" "$CURRENT_LINK/contracts/karpathy-wiki.md" test -f "$CURRENT_LINK/contracts/karpathy-wiki.md"
    verify_check "codex skill link" "$CODEX_DIR/$skill" test -L "$CODEX_DIR/$skill"
    codex_link_target="$(readlink "$CODEX_DIR/$skill")"
    verify_check "codex skill target" "$CODEX_DIR/$skill" test "$codex_link_target" = "$CURRENT_LINK/skills/$skill"
  done
  validate_profile
  exit 0
fi

mkdir -p "$(dirname "$LOCK_DIR")"
acquire_lock
validate_current_pointer

OLD_RELEASE=""
USES_CURRENT=0
reject_retired_links
for name in "$ROOT"/skills/*; do
  [ -f "$name/SKILL.md" ] || continue
  skill="$(basename "$name")"
  for target in "$CLAUDE_DIR/$skill" "$CODEX_DIR/$skill"; do
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ -L "$target" ] && [ "$(readlink "$target")" = "$RELEASE_DIR/skills/$skill" ]; then
        continue
      fi
      if is_package_release_link "$target" "$skill"; then
        existing="$(readlink "$target")"
        if [ ! -d "$existing" ]; then
          echo "collision: broken package link $target" >&2
          exit 1
        fi
        case "$existing" in
          "$CURRENT_LINK"/skills/"$skill") USES_CURRENT=1 ;;
          "$RELEASE_ROOT"/*/skills/"$skill")
            candidate="${existing%/skills/$skill}"
            if ! valid_release "$candidate"; then
              echo "collision: invalid package release $candidate" >&2
              exit 1
            fi
            if [ -n "$OLD_RELEASE" ] && [ "$OLD_RELEASE" != "$candidate" ]; then
              echo "package release mismatch: $target" >&2
              exit 1
            fi
            OLD_RELEASE="$candidate"
            ;;
        esac
        continue
      fi
      echo "collision: $target (move or remove it and re-run install.sh)" >&2
      exit 1
    fi
    :
  done
done
if [ "$USES_CURRENT" = "1" ] && [ -n "$OLD_RELEASE" ]; then
  echo "package release mismatch: current and direct links mixed" >&2
  exit 1
fi
if [ "$USES_CURRENT" = "1" ] && [ -z "$CURRENT_RELEASE" ]; then
  echo "collision: current skill link without current release" >&2
  exit 1
fi
mkdir -p "$CLAUDE_DIR" "$CODEX_DIR" "$RELEASE_ROOT"
TEMP_RELEASE="$RELEASE_ROOT/.$VERSION.$$"
rm -rf "$TEMP_RELEASE"
mkdir -p "$TEMP_RELEASE"
copy_release_tree "$ROOT/skills" "$TEMP_RELEASE/skills"
copy_release_tree "$ROOT/contracts" "$TEMP_RELEASE/contracts"
copy_release_tree "$ROOT/profiles" "$TEMP_RELEASE/profiles"
mkdir -p "$TEMP_RELEASE/scripts"
cp -p "$ROOT/scripts/validate_profile.py" "$TEMP_RELEASE/scripts/validate_profile.py"
if [ ! -d "$RELEASE_DIR" ]; then
  printf '%s\n' "$SOURCE_HASH" > "$TEMP_RELEASE/manifest"
  mv "$TEMP_RELEASE" "$RELEASE_DIR"
else
  EXISTING_MANIFEST=""
  [ -f "$RELEASE_DIR/manifest" ] && EXISTING_MANIFEST="$(cat "$RELEASE_DIR/manifest")"
  if [ -n "$EXISTING_MANIFEST" ] && [ "$(manifest_hash "$RELEASE_DIR")" = "$SOURCE_HASH" ]; then
    if [ "$EXISTING_MANIFEST" != "$SOURCE_HASH" ]; then
      printf '%s\n' "$SOURCE_HASH" > "$RELEASE_DIR/manifest"
    fi
    rm -rf "$TEMP_RELEASE"
  else
    echo "release version collision: $VERSION has different content" >&2
    diff <(manifest_listing "$ROOT") <(manifest_listing "$RELEASE_DIR") >&2 || true
    rm -rf "$TEMP_RELEASE"
    exit 1
  fi
fi
if [ -n "$OLD_RELEASE" ]; then
  if [ -z "$CURRENT_RELEASE" ]; then
    set_current_release "$OLD_RELEASE" "__absent__"
  elif [ "$CURRENT_RELEASE" != "$OLD_RELEASE" ]; then
    echo "package release mismatch: current and direct links differ" >&2
    exit 1
  fi
  CURRENT_RELEASE="$OLD_RELEASE"
elif [ -z "$CURRENT_RELEASE" ]; then
  set_current_release "$RELEASE_DIR" "__absent__"
  CURRENT_RELEASE="$RELEASE_DIR"
fi
for name in "$RELEASE_DIR"/skills/*; do
  [ -f "$name/SKILL.md" ] || continue
  skill="$(basename "$name")"
  for target in "$CLAUDE_DIR/$skill" "$CODEX_DIR/$skill"; do
    if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$CURRENT_LINK/skills/$skill" ]; then
      if [ -L "$target" ]; then expected="$(readlink "$target")"; else expected="__absent__"; fi
      replace_link "$target" "$CURRENT_LINK/skills/$skill" "$expected"
    fi
  done
done
set_current_release "$RELEASE_DIR" "$CURRENT_RELEASE"
if validate_profile >/dev/null 2>&1; then
  echo "research-tools $VERSION installed and configured"
else
  echo "research-tools $VERSION installed; run the research-tools-set-up skill to configure it"
fi
