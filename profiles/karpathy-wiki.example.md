---
profile_version: 4
knowledge_root: /absolute/path/to/knowledge
hot_file: wiki/hot.md
operation_log_file: docs/log.md
decision_log_file: docs/DECISIONS.md
wiki_followup_destination: "Describe the backlog or task route for knowledge-base maintenance."
artifact_followup_destination: "Describe the task system and routing rule for research findings that affect another project."
---

Copy to `~/.config/research-tools/profile.md` and set `knowledge_root`.

## Optional local policy

This body is intentionally free-form and remains outside the public package.
Use it for personal taxonomy, source-library routing, output conventions, and
knowledge-base operation rules. Skills that read the profile read this
free-form local policy body after the validated YAML frontmatter. The required
frontmatter fields configure the portable session cache, operation log,
decision log, and two independent follow-up destinations; use this body to
define their local shape.
