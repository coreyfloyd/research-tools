---
name: research-sources
description: Investigate supplied sources, improve an insufficient evidence set, or prepare a source-grounded update for an existing artifact. Use when a user provides URLs, documents, audio, video, YouTube, a source collection, or a named target; not for topic-first research without supplied evidence.
---

# Research Sources

Turn supplied evidence into a durable, source-grounded research artifact. This skill may analyze a fixed evidence set, improve an incomplete one, or prepare a proposal for an existing target. It does not directly promote knowledge or mutate a target without explicit authorization.

Before selecting an output location, read `~/.config/research-tools/profile.md`. Without a valid profile, ask before writing. Any proposed follow-up task in the artifact uses `artifact_followup_destination`, never the wiki-maintenance route.

## Modes

### Analyze supplied sources

Use when supplied evidence can answer the question. Add it to NotebookLM, inspect it, and synthesize the requested analysis. Preserve original URL or file provenance and the NotebookLM notebook ID.

### Improve evidence

Use when a supplied source, collection, notebook, or target cannot support the question. Identify the unanswered claim or missing perspective, discover the smallest useful additional evidence set, and add it before analysis. Read the [evidence-improvement procedure](references/improve-evidence.md) for NotebookLM discovery and source categorization.

### Update an existing target

Use when the caller identifies an existing document, wiki article, context file, or other artifact. Analyze the supplied evidence against the target and produce a source-grounded update proposal. Use **Improve evidence** only when the supplied evidence cannot support a safe proposal. Do not edit the target unless the caller explicitly authorizes it.

## Source handling

NotebookLM is the persistent, source-grounded synthesis layer. Firecrawl is a runtime-detected optional integration: for supplied web pages, use it first when available, then add the original URL to NotebookLM. Record a native-reader fallback when Firecrawl is unavailable.

For supplied audio or video, invoke `transcribe` to choose the input route. Prefer NotebookLM's native YouTube indexing when sufficient; use a local transcript only when the source or requested output requires one. Keep original media provenance alongside any transcript.

## Research artifact

Write one durable output using [the shared research artifact contract](../research-absorb/references/artifact-contract.md): question/scope, findings, source provenance, contradictions and gaps, and a **Proposed distribution plan**. If evidence was improved, record every added source and the precise gap it closed.

At completion, report the artifact path and its proposed plan. The caller may then invoke `research-absorb`; do not invoke it automatically or treat the artifact as raw wiki input.
