---
profile_version: 2
knowledge_root: /absolute/path/to/knowledge
raw_dir: raw
wiki_dir: wiki
output_dir: output
docs_dir: docs
hot_file: wiki/hot.md
operation_log_file: docs/log.md
decision_log_file: docs/DECISIONS.md
task_destination: "Describe the task system and routing rule for this knowledge base."
capabilities:
  firecrawl: false
  apple_speech: false
---

Copy to `~/.config/research-tools/profile.md` and set `knowledge_root`.

## Optional local policy

This body is intentionally free-form and remains outside the public package.
Use it for personal taxonomy, source-library routing, output conventions, and
knowledge-base operation rules. Skills that read the profile read this
free-form local policy body after the validated YAML frontmatter. The required
frontmatter fields configure the portable session cache, operation log,
decision log, and task destination; use this body to define their local shape.
