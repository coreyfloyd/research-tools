#!/bin/bash
set -euo pipefail

MODE="${1:?usage: verify-migration-handoff.sh --preflight|--verify MANIFEST CLAUDE_SKILLS CODEX_SKILLS RELEASE_DIR}"
MANIFEST="${2:?manifest required}"
CLAUDE_SKILLS="${3:?Claude skills directory required}"
CODEX_SKILLS="${4:?Codex skills directory required}"
RELEASE_DIR="${5:?release directory required}"

case "$MODE" in
  --preflight|--verify) ;;
  *) echo "invalid mode: $MODE" >&2; exit 1 ;;
esac

test -f "$MANIFEST"
while IFS=$'\t' read -r skill legacy_source; do
  [ -n "$skill" ] || continue
  case "$skill" in \#*) continue ;; esac
  [ -n "$legacy_source" ] || { echo "missing legacy source for $skill" >&2; exit 1; }
  for target in "$CLAUDE_SKILLS/$skill" "$CODEX_SKILLS/$skill"; do
    if [ "$MODE" = "--preflight" ]; then
      if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$legacy_source" ]; then
        echo "migration collision: $target" >&2
        exit 1
      fi
    elif [ ! -L "$target" ] || [ "$(readlink "$target")" != "$RELEASE_DIR/skills/$skill" ]; then
      echo "migration mismatch: $target" >&2
      exit 1
    fi
  done
done < "$MANIFEST"
