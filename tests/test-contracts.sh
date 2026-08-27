#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT="$ROOT/contracts/karpathy-wiki.md"
PROFILE="$ROOT/profiles/karpathy-wiki.example.md"
test -f "$CONTRACT"
test -f "$PROFILE"
test -f "$ROOT/MIGRATION.md"
grep -Fq 'exact legacy source' "$ROOT/MIGRATION.md"
grep -Fq 'release directory after the handoff' "$ROOT/MIGRATION.md"
grep -Fq 'never a backlog sweep' "$CONTRACT"
grep -Fq 'Reports are not raw compiler input' "$CONTRACT"
grep -Fq 'blind draft' "$CONTRACT"
grep -Fq 'read-only' "$CONTRACT"
grep -Fxq 'profile_version: 1' "$PROFILE"
PROFILE_ROOT="$(mktemp -d)"
trap 'rm -rf "$PROFILE_ROOT"' EXIT
mkdir -p "$PROFILE_ROOT/root/raw" "$PROFILE_ROOT/root/wiki" "$PROFILE_ROOT/root/output" "$PROFILE_ROOT/root/docs"
sed "s|/absolute/path/to/knowledge|$PROFILE_ROOT/root|" "$PROFILE" > "$PROFILE_ROOT/valid.md"
python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/valid.md" >/dev/null
sed "s|/absolute/path/to/knowledge|$PROFILE_ROOT/root|;s|raw_dir: raw|raw_dir: ../|" "$PROFILE" > "$PROFILE_ROOT/escape.md"
if python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/escape.md"; then exit 1; fi
sed '5i\
unknown_field: true' "$PROFILE_ROOT/valid.md" > "$PROFILE_ROOT/unknown-field.md"
if python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/unknown-field.md"; then exit 1; fi
sed '9i\
  unsupported_capability: true' "$PROFILE_ROOT/valid.md" > "$PROFILE_ROOT/unknown-capability.md"
if python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/unknown-capability.md"; then exit 1; fi
for skill in research-to-wiki wiki-audit; do
  grep -Fq 'Karpathy-wiki contract' "$ROOT/skills/$skill/SKILL.md" || exit 1
  grep -Fq '~/.config/research-tools/profile.md' "$ROOT/skills/$skill/SKILL.md" || exit 1
done
grep -Fq 'free-form local policy body' "$PROFILE"
grep -Fq 'free-form local policy body' "$ROOT/contracts/karpathy-wiki.md"
grep -Fq 'Obsidian-style wikilinks' "$CONTRACT"
if rg -n 'unified Obsidian vault|AI-vault|writing-corpus|R-004|wiki/people/' "$ROOT/skills" "$ROOT/contracts" "$ROOT/profiles" "$ROOT/README.md"; then
  exit 1
fi
if rg -n 'claude-dotfiles|research-skills|~/Obsidian|Corey|~/.claude/skills|~/Development|wiki/CLAUDE\.md|wiki/AGENTS\.md' "$ROOT/skills" "$ROOT/contracts" "$ROOT/profiles" "$ROOT/README.md" --glob '!*.swift'; then
  exit 1
fi
