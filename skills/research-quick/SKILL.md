---
name: research-quick
description: "Fast inline research on non-development topics—products, places, current events, decisions, health, finance, or travel—with cited findings in conversation. Use for general lookups; no notebook or artifact workflow."
---

# Quick Research

Zero-friction research for non-dev questions. Checks configured local knowledge first, then hits Reddit plus domain-appropriate authoritative sources via Firecrawl, synthesizes inline. No notebooks, no files written.

If a supplied audio or video source is needed as evidence, invoke `transcribe` to acquire its text before applying this workflow. The transcript is input evidence; this skill remains inline.

Use Firecrawl first for web search and page extraction when it is available. If it is unavailable or blocked for a source, use native web tools and say so in the response; do not silently reduce source coverage.

Read `~/.config/research-tools/profile.md` before checking local knowledge. Use only the local-preflight policy it provides; this skill remains an inline response.

## When NOT to Use

- Code, bugs, library questions → `research-dev`
- Deep research needing persistent notebooks → `research`
- Writing/drafting content with citations → `content-research-writer`

## Phase 0 — Check local knowledge

If the local profile defines a knowledge preflight, run it before web search. Surface useful matches and ask whether to use them before searching externally. Without a profile, proceed directly to source planning.

## Phase 1 — Source Planning

### Domain Classification (infer from query, don't ask)

| Domain | Signals in query | Sources to add |
|--------|-----------------|----------------|
| **Product/gear** | "should I buy", "best X", "X vs Y", "worth it", "review" | Wirecutter, RTINGS, Ars Technica, YouTube reviews |
| **Place/travel** | city name, "visit", "trip", "restaurant", "hotel", "neighborhood" | TripAdvisor, Atlas Obscura, local subreddits |
| **Health/wellness** | symptom, medication, diet, supplement, "is X safe" | Mayo Clinic, Examine.com, NIH/PubMed (via search) |
| **Finance/money** | investing, savings, budget, mortgage, tax, crypto | Investopedia, NerdWallet, Bogleheads |
| **Current events** | recent dates, news topics, "what happened with" | Google News via Firecrawl, AP, Reuters |
| **Concept/topic** | "what is", "how does", "explain", abstract nouns | Wikipedia, relevant subreddits |
| **Service/company** | brand name, app name, subscription, "is X legit" | Trustpilot, BBB, Reddit |
| **General/unclear** | anything else | Wikipedia + 2 Firecrawl web searches |

**If the domain is genuinely ambiguous** and the wrong source set would waste the search — ask upfront in one short question: "What kind of angle are you looking for — [option A] or [option B]?" Then go. Don't ask about anything else.

## Phase 2 — Firecrawl Research

Run all searches **in parallel** — don't wait for one before starting the next.

1. **Reddit** (always): `firecrawl_search("site:reddit.com <query>")` — pick the 3 most relevant threads
2. **Domain source 1**: first authoritative source from table above
3. **Domain source 2** (if warranted): second source or a broader Firecrawl web search
4. **Read full Reddit threads**: For the 2-3 most relevant Reddit results, run the helper to pull full post + comment text:
   ```bash
   ./reddit-read.sh "<thread-url>"
   ```
   Reddit blocks all programmatic scrapers (`firecrawl_scrape` → unsupported, `.json` → 403, `WebFetch` → blocked), but it serves the real page to the user's logged-in Safari. The helper loads each thread in Safari **in the background** (`open -g`, no focus steal), extracts the rendered text via AppleScript, and closes its own tab. Requires macOS + Safari signed into Reddit (interactive desktop session only — not usable headless/remote). For **non-Reddit** sources, use `firecrawl_scrape` as normal.
5. Call `firecrawl_search_feedback` with the search ID after each search to refund a credit

## Output Format

Deliver inline in the conversation. No files, no notebooks.

```
**[Topic]** — [2-sentence synthesis of the overall picture]

**What people say (Reddit)**
- [Finding 1] — [r/subreddit thread title](url)
- [Finding 2] — [r/subreddit thread title](url)
- [Finding 3] — [r/subreddit thread title](url)

**Key findings**
- [Point] ([Source](url))
- [Point] ([Source](url))
- [Conflicting view or caveat if any] ([Source](url))

**Bottom line**: [1-sentence recommendation or verdict, if the question calls for one]
```

Keep it tight. If sources agree, consolidate — don't repeat the same finding three times with three URLs. If they conflict, surface the conflict explicitly.

If a local profile defines a checklist-time knowledge-capture policy, it may review this research later; this skill itself remains inline.

Skip sections that don't apply (e.g., no "Key findings" section if Reddit threads already cover everything; no "Bottom line" for open-ended conceptual questions).
