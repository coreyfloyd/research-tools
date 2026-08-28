# Upgrading a published research-tools release

The public installer upgrades only a published research-tools release. It
creates package-owned skill links through one stable `current` pointer, so a
completed upgrade activates all package skills together. A foreign skill link,
broken link, or real directory is a collision and remains unchanged.

This repository does not migrate legacy dotfiles or vault skill links. Such a
migration is installation-specific and belongs to the private integration that
owns its exact historical paths and approved manifest.

## Profile version 4

Before installing a version-4 profile release, create
`~/.config/research-tools/profile.md` from the public template, set an existing
absolute `knowledge_root`, and ensure its canonical `raw/`, `wiki/`, `output/`,
and `docs/` directories plus the three state files already exist:

```yaml
profile_version: 4
hot_file: wiki/hot.md
operation_log_file: docs/log.md
decision_log_file: docs/DECISIONS.md
wiki_followup_destination: Describe the backlog or task route for knowledge-base maintenance.
artifact_followup_destination: Describe the task system and routing rule for research findings that affect another project.
```

The two follow-up destinations are intentionally independent and may name
external systems. The profile body defines entry formats and any routing
distinctions. State-file locations are configurable within the knowledge root;
the four canonical directories are not.
