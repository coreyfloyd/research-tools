#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT="$ROOT/contracts/karpathy-wiki.md"
PROFILE="$ROOT/profiles/karpathy-wiki.example.md"
# Leakage guards must FAIL CLOSED. These were written with `rg`, which is not a
# POSIX tool and is absent from a bare shell: `if rg ...; then exit 1; fi` then
# returned 127, the guard fell through, and the suite still exited 0 — so the
# checks protecting a public release from private paths and names passed
# vacuously. Use grep and treat anything other than a definite "no match" as a
# failure.
scan() {
  local desc="$1"; shift
  local out status
  out="$(grep "$@" 2>&1)" && status=0 || status=$?
  case "$status" in
    1) return 0 ;;
    0) printf '%s: leaked\n%s\n' "$desc" "$out" >&2; exit 1 ;;
    *) printf '%s: scan failed (grep exit %s)\n%s\n' "$desc" "$status" "$out" >&2; exit 1 ;;
  esac
}

test -f "$CONTRACT"
test -f "$PROFILE"
test -f "$ROOT/MIGRATION.md"
test -f "$ROOT/skills/research-tools-set-up/SKILL.md"
grep -Fq 'published research-tools release' "$ROOT/MIGRATION.md"
grep -Fq 'does not migrate legacy dotfiles' "$ROOT/MIGRATION.md"
grep -Fq 'never a backlog sweep' "$CONTRACT"
grep -Fq 'Reports are not raw compiler input' "$CONTRACT"
grep -Fq 'drafts before reading existing wiki' "$CONTRACT"
grep -Fq 'read-only' "$CONTRACT"
grep -Fxq 'profile_version: 4' "$PROFILE"
scan 'retired profile fields' -nE '^(raw_dir|wiki_dir|output_dir|docs_dir|capabilities):' "$PROFILE"
grep -Fxq 'hot_file: wiki/hot.md' "$PROFILE"
grep -Fxq 'operation_log_file: docs/log.md' "$PROFILE"
grep -Fxq 'decision_log_file: docs/DECISIONS.md' "$PROFILE"
grep -Fq 'wiki_followup_destination:' "$PROFILE"
grep -Fq 'artifact_followup_destination:' "$PROFILE"
if grep -Fq 'task_destination:' "$PROFILE"; then exit 1; fi
PROFILE_ROOT="$(mktemp -d)"
trap 'rm -rf "$PROFILE_ROOT"' EXIT
mkdir -p "$PROFILE_ROOT/root/raw" "$PROFILE_ROOT/root/wiki" "$PROFILE_ROOT/root/output" "$PROFILE_ROOT/root/docs"
touch "$PROFILE_ROOT/root/wiki/hot.md" "$PROFILE_ROOT/root/docs/log.md" "$PROFILE_ROOT/root/docs/DECISIONS.md"
sed "s|/absolute/path/to/knowledge|$PROFILE_ROOT/root|" "$PROFILE" > "$PROFILE_ROOT/valid.md"
python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/valid.md" >/dev/null
sed '5i\
raw_dir: custom-raw' "$PROFILE_ROOT/valid.md" > "$PROFILE_ROOT/noncanonical-topology.md"
if python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/noncanonical-topology.md"; then exit 1; fi
sed '5i\
unknown_field: true' "$PROFILE_ROOT/valid.md" > "$PROFILE_ROOT/unknown-field.md"
if python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/unknown-field.md"; then exit 1; fi
sed '5i\
capabilities:\
  firecrawl: false' "$PROFILE_ROOT/valid.md" > "$PROFILE_ROOT/inert-capabilities.md"
if python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/inert-capabilities.md"; then exit 1; fi
sed '/wiki_followup_destination:/d' "$PROFILE_ROOT/valid.md" > "$PROFILE_ROOT/missing-wiki-followup.md"
if python3 "$ROOT/scripts/validate_profile.py" "$PROFILE_ROOT/missing-wiki-followup.md"; then exit 1; fi
for skill in research-to-wiki wiki-audit; do
  grep -Fq 'Karpathy-wiki contract' "$ROOT/skills/$skill/SKILL.md" || exit 1
  grep -Fq '~/.config/research-tools/profile.md' "$ROOT/skills/$skill/SKILL.md" || exit 1
done
grep -Fq 'free-form local policy body' "$PROFILE"
grep -Fq 'free-form local policy body' "$ROOT/contracts/karpathy-wiki.md"
grep -Fq 'Obsidian-style wikilinks' "$CONTRACT"
grep -Fq 'session cache' "$CONTRACT"
grep -Fq 'wiki follow-up destination' "$CONTRACT"
grep -Fq 'artifact follow-up destination' "$CONTRACT"
grep -Fq 'must not infer' "$CONTRACT"
grep -Fq 'Andrej Karpathy' "$CONTRACT"
grep -Fq 'canonical directories' "$CONTRACT"
grep -Fq 'runtime-detected optional integrations' "$CONTRACT"
for skill in research-sources research-topic research-feature research-feedback research-absorb; do
  grep -Fq 'artifact_followup_destination' "$ROOT/skills/$skill/SKILL.md" || exit 1
done
grep -Fq 'artifact_followup_destination' "$ROOT/skills/knowledge-capture/SKILL.md"
# research-feature and research-feedback produce deliverables, not absorb handoffs.
for skill in research-feature research-feedback; do
  grep -Fq 'research-absorb` does not apply' "$ROOT/skills/$skill/SKILL.md" || exit 1
  if grep -Fq 'artifact-contract.md' "$ROOT/skills/$skill/SKILL.md"; then exit 1; fi
  if grep -Fq 'Findings format' "$ROOT/skills/$skill/SKILL.md"; then exit 1; fi
done
grep -Fq '## Sources' "$ROOT/skills/research-feature/SKILL.md"
grep -Fq '## Communities to watch' "$ROOT/skills/research-feedback/SKILL.md"
if grep -Fq 'research-feature, or research-feedback' "$ROOT/skills/research-absorb/SKILL.md"; then exit 1; fi
for skill in research-to-wiki wiki-audit; do
  grep -Fq 'wiki_followup_destination' "$ROOT/skills/$skill/SKILL.md" || exit 1
done
for skill in research-sources research-topic research-feature research-feedback research-dev research-quick; do
  grep -Fq 'runtime-detected' "$ROOT/skills/$skill/SKILL.md" || exit 1
done
grep -Fq 'runtime-detected' "$ROOT/skills/transcribe/SKILL.md"
for skill in research-sources research-topic research-feature research-feedback research-absorb knowledge-capture research-to-wiki wiki-audit; do
  grep -Fq 'scripts/validate_profile.py' "$ROOT/skills/$skill/SKILL.md" || exit 1
  grep -Fq 'research-tools-set-up' "$ROOT/skills/$skill/SKILL.md" || exit 1
done
grep -Fq 'profiles/karpathy-wiki.example.md' "$ROOT/skills/research-tools-set-up/SKILL.md"
grep -Fq 'scripts/validate_profile.py' "$ROOT/skills/research-tools-set-up/SKILL.md"
grep -Fq 'Do not write or change configuration until the user approves' "$ROOT/skills/research-tools-set-up/SKILL.md"
scan 'private vault vocabulary' -rnE 'unified Obsidian vault|AI-vault|writing-corpus|R-004|wiki/people/' "$ROOT/skills" "$ROOT/contracts" "$ROOT/profiles" "$ROOT/README.md"
scan 'private paths and names' -rnE --exclude='*.swift' 'claude-dotfiles|research-skills|~/Obsidian|Corey|~/[.]claude/skills|~/Development|wiki/CLAUDE[.]md|wiki/AGENTS[.]md' "$ROOT/skills" "$ROOT/contracts" "$ROOT/profiles" "$ROOT/README.md"
