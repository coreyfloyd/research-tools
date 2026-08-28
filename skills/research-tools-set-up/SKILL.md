---
name: research-tools-set-up
description: Guide a user through configuring or repairing a research-tools knowledge root and profile. Use after installation, when setup is incomplete, or when the user wants to understand or change how the research workflows store and route work.
---

# Configure research-tools

Configure the system through a conversation. The purpose of this skill is not merely to produce a valid file: help the user understand the storage model, make the choices that belong to them, and see how those choices affect later research and knowledge workflows.

The installed, version-matched template is [`profiles/karpathy-wiki.example.md`](../../profiles/karpathy-wiki.example.md). The canonical structural check is [`scripts/validate_profile.py`](../../scripts/validate_profile.py). Resolve both relative to this skill so the configuration matches the active package release.

## Explain the model first

Before asking for values, explain that one knowledge root contains:

- `raw/`: selected source material and provenance;
- `wiki/`: compiled articles and indexes, including `wiki/hot.md` as the recent-context entry point;
- `output/`: durable research artifacts and audit reports awaiting review or distribution;
- `docs/`: AI-maintained operating records, including the operation log and decision log.

Explain that wikilinks are part of the portable Markdown contract, while Obsidian is an optional client. Explain the main flow: research creates an inline answer or an artifact; an approved distribution step moves useful findings to named targets, follow-up work, or the wiki; wiki compilation and audit then operate on the configured root.

## Inspect before asking

Read `~/.config/research-tools/profile.md` if it exists. Inspect referenced paths without modifying them. Distinguish among:

- no profile;
- a structurally invalid or incomplete profile;
- a valid profile whose local policy may still need clarification;
- a requested change to an existing configuration.

Do not assume that an existing directory is disposable or dedicated to this package. Preserve existing files and the free-form profile body unless the user explicitly approves changing them.

## Discuss the user-owned choices

Ask only for choices that cannot be inferred safely, and explain each before requesting it:

1. The absolute knowledge-root location.
2. The route for wiki-maintenance follow-ups.
3. The independent route for research findings that require work in another project.
4. Any local policy the agents should follow: taxonomy, source-library routing, output naming, operation/decision log formats, and local boundaries.
5. Whether the user plans to use Obsidian or another wikilink-aware client. This changes the usage guidance, not the profile schema.

The two follow-up routes may be different and must be concrete enough for another agent to execute. Do not accept the unchanged instructional placeholders from the example profile as configured destinations.

## Present the complete change before writing

Show the proposed values and an exact mutation list: directories to create, files to create, profile fields to add or change, and policy-body edits. Call out everything that already exists and will be preserved.

Do not write or change configuration until the user approves that complete proposal. Installation and configuration are separate authorization boundaries; the fact that the package is installed is not approval to create a knowledge root.

## Apply an approved configuration safely

After approval:

1. Create only missing canonical directories: `raw/`, `wiki/`, `output/`, and `docs/`.
2. Create only missing state files: `wiki/hot.md`, `docs/log.md`, and `docs/DECISIONS.md`. Never truncate them.
3. Create or update `~/.config/research-tools/profile.md` from the active example schema. Use root-relative state paths and preserve unapproved frontmatter values and body content.
4. Run the active `scripts/validate_profile.py` against the resulting profile.
5. If validation fails, report the exact failure and propose the smallest repair; do not replace the profile wholesale.
6. If validation succeeds, summarize the configured root and routes, then teach the user one short first workflow appropriate to their goal.

Structural validation proves that the required paths and fields exist. It does not prove that the local taxonomy, route descriptions, or operating policy are useful; confirm those meanings conversationally.
