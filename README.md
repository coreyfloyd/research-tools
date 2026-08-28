# research-tools

`research-tools` is an opinionated research and knowledge system for
Claude Code and Codex. It provides skills for multiple types of research and workflows that span quick, in-chat research, reports, updating existing documentation, and creating a curated Karpathy-style wiki. It works with documents, websites, videos, and audio (Podcasts).

This is the system I developed for my own personal research - much of it was built to learn about AI itself. My favorite use case is ingesting knowledge from YouTube videos and my favorite podcasts in order to plan improvements to my AI systems.

The system is based around a workflow with three types activities:

1. **Research** gathers and evaluates evidence. Quick work stays in the
   conversation; substantial work produces a durable research artifact.
2. **Knowledge Distribution & Follow Up ** Update existing documents, your personal AI context, or create todos from useful knowledge from the current conversation.
3. **Personal Knowledge Curation** turns selected sources into atomic, linked wiki articles — for both yourself and your agents.

After installation, start with `research-tools-set-up`. It walks you through the
knowledge-store structure, local policy, and follow-up routing, then shows the
complete proposed configuration before creating or changing anything.

Major portions are inspired by [Andrej Karpathy's LLM Wiki gist][1], adding a convenient set of tools for capturing knowledge and making sure you research isn’t lost or underutilized.

## Research skills

There are three general-purpose skills to get most research questions started:

| Skill              | Use it when                                                                                         | Result and next step                                                                                            |
| ------------------ | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `research-quick`   | You need a cited answer to a general question.                                                      | Returns findings inline. No notebook or artifact workflow.                                                      |
| `research-sources` | You already have URLs, files, media, a source collection, or a named target to analyze.             | Produces a source-grounded artifact with a proposed distribution plan. Review it, then use `research-absorb`.   |
| `research-topic`   | You need substantial topic-first research, persistent sources, gap filling, and claim verification. | Produces a NotebookLM-backed artifact with a proposed distribution plan. Review it, then use `research-absorb`. |


In addition, there are three research skills for specific domains:

| Skill               | Use it when                                                                                                     | Result and next step                                                                                     |
| ------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `research-feature`  | You need competitor UX, established patterns, user expectations, or platform conventions before feature design. | Produces a comparison artifact with a proposed distribution plan. Review it, then use `research-absorb`. |
| `research-feedback` | An adoption, purchase, upgrade, or wait decision depends on current community experience.                       | Produces a sentiment-weighted artifact plus communities to watch. Review it, then use `research-absorb`. |
| `research-dev`      | You are investigating a bug, API behavior, library, or implementation approach.                                 | Returns diagnoses, competing explanations, and sources inline.                                           |


## Knowledge Distribution & Follow Up skills

These skills help you get research filed where it belongs.

| Skill               | Use it when                                                                                             | Result and next step                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `research-absorb`   | You created a research artifact and you are ready to move the knowledge into permanent locations.       | Executes the approved plan, records a terminal disposition for every row, then deletes the completed artifact.                           |
| `knowledge-capture` | Useful sources or synthesis exist in the current conversation and need a complete disposition proposal. | Inventories conversation knowledge, asks for approval, then performs only the approved captures. It does not process research artifacts. |

## Personal Knowledge Curation skills

| Skill              | Use it when                                                              | Result and next step                                                                             |
| ------------------ | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| `research-to-wiki` | A coherent, caller-selected subset of raw sources is ready to compile.   | Creates or updates atomic wiki articles, source status, indexes, and approved workflow records.  |
| `wiki-audit`       | You want a structural and source-coverage review of the configured wiki. | Writes a ranked report in `output/` without changing articles, sources, indexes, logs, or tasks. |

## Knowledge store

The system has four built in directories to hold all the created artifacts:

```text
<knowledge-root>/
├── raw/       # source material and provenance
├── wiki/      # compiled synthesis, topic indexes, and master index
├── output/    # research artifacts and audit reports
└── docs/      # AI-maintained operation history and durable decisions
```

The directory names are part of the public
[Karpathy-wiki contract][2]. The organization of the `wiki/`is customizable,
but relies on internal wikilinks for traversal by AI and wikilink-aware tools.

The wiki also comes with a  `wiki/hot.md` file that makes finding recent content quicker.

### Audit Tracking

In addition, the system writes records to help agents understand how to operate on the knowledge system itself, supporting your own custom workflows, including:
- an operation log,  `docs/log.md`;
- a decision log, `docs/DECISIONS.md`.

The installer validates this structure but does not create it.

## How the skills fit together

### Quick inline research

```text
question
  -> research-quick or research-dev
  -> cited answer in the conversation
```

Inline research does not automatically create a notebook, file, or knowledge
capture task.

### Durable research and distribution

```text
question or supplied evidence
  -> research-sources | research-topic | research-feature | research-feedback
  -> durable research artifact in output/
  -> review its proposed distribution plan
  -> research-absorb approval gate
  -> integrate | update named target | file follow-up task | discard
  -> delete the artifact after every row reaches a terminal disposition
```

These four skills share the [research artifact contract][3].
The artifact is durable enough to support review and execution, but it is
coordination material rather than a permanent archive.

If an approved row belongs in the wiki, `research-absorb` stages the selected
external sources and their provenance under `raw/research/`, then invokes
`research-to-wiki` on that curated subset. The research report itself is never
raw compiler input.

### Capture knowledge from a conversation

```text
current conversation
  -> knowledge-capture inventory and disposition proposal
  -> approval
  -> discard | retain output | capture provenance | preserve synthesis | compile
```

Use this path for knowledge created or discussed in the current conversation.
Use `research-absorb` instead when a durable research artifact already exists.

### Compile and audit an existing source collection

```text
caller-curated raw subset
  -> research-to-wiki
  -> wiki articles + indexes + source dispositions + workflow state
  -> wiki-audit (optional, read-only)
  -> ranked audit report in output/
```

Compilation is never a sweep of every uncompiled file in `raw/`. It reads the
selected raw sources before existing wiki synthesis, drafts claims, then checks
nearby articles for real tensions and gaps instead of silently blending
incompatible assertions.

## Example requests

Natural-language requests work across Agent Skills-compatible clients:

```text
Use research-quick to compare these two services and cite current sources.

Use research-sources to analyze these URLs, identify evidence gaps, and write
the durable artifact proposed by the skill.

Use research-topic to investigate this question deeply, verify the major
claims, and produce a proposed distribution plan.

Use research-feature to compare how established podcast apps handle this
interaction before we design it.

Use research-feedback to determine whether users consider this release stable
enough to adopt and identify the communities worth following.

Run research-absorb on output/2026-08-27-example.md. Validate and show me its
existing plan before applying anything.

Use research-to-wiki on these three selected files under raw/research/.

Audit the configured wiki with wiki-audit. Do not modify it.
```

## External and optional integrations

- **NotebookLM** is the persistent source and synthesis layer used by
  `research-sources` and `research-topic`. Agent access is provided by the
  third-party [notebooklm-py][4] CLI and its `notebooklm` Agent Skill, not by
  Google or this package. `research-dev` also uses that CLI when it is
  available. This package does not install it, authenticate it, or validate
  the integration.
- **YouTube library search** is an optional upstream source-discovery step. A
  separate `youtube` Agent Skill can use the third-party [yt-dlp][5] CLI to
  inspect public playlists or retrieve subtitles, then hand selected URLs to
  NotebookLM. Neither that skill nor `yt-dlp` is bundled or required by this
  package; NotebookLM can index a supplied YouTube URL directly.
- **Firecrawl** is optional and detected at runtime. Relevant skills prefer it
  when available and fall back to native web tools when it is unavailable or
  blocked.
- **Apple Speech** source is bundled under the `transcribe` skill and built on demand.
  The local route requires macOS 26 or later; otherwise the calling workflow
  must use another input route.
- Full Reddit-thread reading used by `research-quick` and `research-feedback`
  requires an interactive macOS session with Safari signed into Reddit. Other
  sources continue through the available web tools.
- **Obsidian** is an optional client for browsing the Markdown wiki. The file
  contract uses wikilinks whether or not Obsidian is installed; Obsidian adds
  native link resolution, backlinks, and graph views.

## Installation and configuration

See [Installation and configuration][6] for the installed layout,
checkout and signed-release installation, the guided configuration workflow,
manual configuration, and verification commands.

[1]:	https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
[2]:	contracts/karpathy-wiki.md
[3]:	skills/research-absorb/references/artifact-contract.md
[4]:	https://github.com/teng-lin/notebooklm-py
[5]:	https://github.com/yt-dlp/yt-dlp
[6]:	INSTALLATION.md
