---
name: research-dev
description: "Quick developer research for implementation or bug diagnosis, with targeted sources, competing explanations, and inline recommendations. Use to research a bug, API behavior, or implementation approach."
---

# Dev Research

Fast, inline research for implementation questions and bug diagnosis. No notebooks, no vault writes, no artifact generation — just targeted source scraping, synthesis, and multiple solution proposals delivered in the conversation.

For a supplied recording, conference talk, or video demonstration that is relevant to the diagnosis, invoke `transcribe` to obtain source text before continuing. This remains developer research, not a media-specific workflow.

Firecrawl is a runtime-detected optional integration. Use it first for web search and page extraction when it is available. If it is unavailable or blocked for a source, use native web tools and state that fallback; do not silently reduce source coverage.

Read `~/.config/research-tools/profile.md` before checking local knowledge. Use only the local-preflight policy it provides; this skill remains an inline response.

## When to Use

- `/dev-research [problem]`
- "Research this bug", "look into how X works", "find solutions for Y"
- Investigating a library/framework bug before filing an issue or working around it
- Researching implementation patterns for a feature you're about to build
- Deciding between competing approaches before writing code

## When NOT to Use

- Deep research requiring persistent notebooks and artifact generation → use `research`
- Writing/drafting content → use `content-research-writer`
- Questions answerable from model knowledge alone (no sources needed)

## Phase 1 — Scope

Ask these questions upfront in a single message. Don't proceed until you have enough to run targeted searches.

1. **Ask for sources first.** "What sites, docs, or repos should I check? Any specific URLs?" — user-provided sources are highest signal and should always be scraped first.

2. **Gather diagnostic context.** Ask:
   - What's the exact error message or stack trace (for bugs)?
   - What version of the library/framework/language?
   - What have you already tried or ruled out?
   - Which library or repo is involved (for GitHub issue searches)?

3. **Check local knowledge.** If the local profile defines a knowledge preflight, run it and report useful matches before external research.

4. **Check NotebookLM for existing notebooks when the CLI is installed.** Run `notebooklm list --json` and scan for topic matches. If one exists, query it:
   ```
   notebooklm use <notebook_id>
   notebooklm ask "<research question>"
   ```
   Report what the notebook says. If it already contains a good answer, surface it before running web research — it may be all that's needed. Do not create a notebook for this inline workflow.

## Phase 2 — Firecrawl Research

Run searches in parallel where possible.

1. **Scrape user-provided sources.** For each URL the user provided, use `firecrawl_scrape` to get the full page content. These take priority over anything else you find.

2. **Search GitHub Issues on the relevant repo.** This is the most commonly skipped step and often where known bugs and workarounds live:
   ```
   firecrawl_search "site:github.com/<owner>/<repo> <error or symptom>"
   ```
   Or if the repo is known: `gh search issues --repo <owner>/<repo> "<symptom>" --state all --limit 10`

3. **Run targeted dev searches.** Use `firecrawl_search` with queries that target high-signal sources:
   - Stack Overflow: `"<exact error message>" site:stackoverflow.com`
   - Official docs: `<library> <feature> site:<docs domain>`
   - Blog/implementation posts: `<library> <feature> implementation`

   Run 2-3 searches with different angles. Use the exact error message text when available — it's far more targeted than a paraphrased description.

4. **Check changelog/release notes if version-related.** If the bug may be a regression or there's a suspicion it's fixed in a newer version, scrape the library's CHANGELOG or releases page.

## Phase 3 — Inline Synthesis

Deliver everything inline in the conversation. Structure the response as:

### Diagnoses & Solutions

Present **multiple distinct diagnoses with solution proposals** unless a single root cause is clearly established by the sources. For each:
- **Diagnosis**: what's causing the problem
- **Solution**: concrete fix or workaround
- **Confidence**: high / medium / low, based on source quality and agreement
- **Source**: which URL(s) support this

If a single issue/fix is obvious and all sources agree, a single entry is fine — don't manufacture false uncertainty.

### Source URLs

List every source scraped, with a one-line description of what it contributed. Preserve every URL even if it was not quoted directly.

### Source Analysis

- **Correlations**: where multiple sources agree, reinforcing confidence
- **Contradictions**: where sources conflict — call these out explicitly with both positions
- **Gaps**: what the sources don't cover and where the user might look next

## Key Principles

- **Error text beats description.** If the user gives you an error message, use it verbatim in search queries. Paraphrasing misses exact matches.
- **GitHub Issues first for library bugs.** The maintainers' issue tracker is the most authoritative source on known bugs and their status.
- **Multiple proposals over false certainty.** If sources point to different root causes, present them all with confidence ratings rather than picking one.
- **No notebook, no vault.** This skill produces a conversation response only. If the user wants to persist findings, they can ask for a durable output separately.
- **Disposition:** A local profile may define checklist-time knowledge capture; this skill does not create a persistence path itself.
