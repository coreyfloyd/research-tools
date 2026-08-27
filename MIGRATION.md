# Dotfiles migration contract

Do not run this migration against a live installation until the corresponding
dotfiles change has been reviewed.

The migration may replace only an extracted skill link whose existing target is
an exact legacy source recorded in the migration manifest. Any real directory,
broken link, or link to another source is a collision and must remain unchanged.
Both Claude and Codex must resolve every extracted skill to the same immutable
release directory after the handoff. A subsequent dotfiles installer run must
recognize package-owned links and skip them rather than relinking Codex to a
dotfiles source.

The dotfiles-side change owns the manifest and the behavior; this repository
only supplies the package release and the tests/contract it must satisfy.

Use `scripts/verify-migration-handoff.sh` with that private manifest before
changing links (`--preflight`) and after (`--verify`). The verifier is read-only:
it checks every manifest skill in both client directories, rejects collisions,
and confirms final convergence on the specified release directory.

## Profile version 3

Before installing a version-3 profile release with profile validation enabled,
add these root-relative fields to `~/.config/research-tools/profile.md` and
ensure the three files already exist:

```yaml
profile_version: 3
hot_file: wiki/hot.md
operation_log_file: docs/log.md
decision_log_file: docs/DECISIONS.md
wiki_followup_destination: Describe the backlog or task route for knowledge-base maintenance.
artifact_followup_destination: Describe the task system and routing rule for research findings that affect another project.
```

The two follow-up destinations are intentionally independent and may name
external systems. The profile body defines entry formats and any routing
distinctions. Do not change paths merely to match this example; choose locations
appropriate to the configured knowledge root.
