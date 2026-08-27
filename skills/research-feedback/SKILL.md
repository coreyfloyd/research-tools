---
name: research-feedback
description: "Research lived community experience before adopting, upgrading, buying, or committing to something, including which forums or user groups to follow. Use for stability and wait-or-adopt decisions; use research-quick for general fact-finding."
---

# Research Feedback

When a user supplies an audio or video review, interview, or discussion as evidence, invoke `transcribe` before analysis. It only resolves the input; this skill still owns community-research scope and its required durable output.

Community-sentiment recon. Answers "what is it actually like to use/run/own this, according to the people doing it right now?" — and identifies **which communities to watch**. Always hits Reddit; always surfaces a recommended set of topic-appropriate forums and user groups.

Use Firecrawl first for web search and page extraction when it is available. If it is unavailable or blocked for a source, use native web tools and say so in the report; do not silently reduce community coverage.

Before checking local knowledge, choosing the durable report location, or running distribution, read `~/.config/research-tools/profile.md`.

This is the **experiential/sentiment** sibling of `research-quick`. Use the distinction below to pick the right one.

## When to Use vs. Not

| Use `research-feedback` | Use something else |
|---|---|
| "What's the real-world experience of running X?" | Authoritative facts/specs/how-to → `research-quick` |
| "Is the new beta/release stable enough to adopt?" | Code/library/bug diagnosis → `research-dev` |
| "What are people complaining about with X before I commit?" | Deep, persistent, cited report → `research-topic` |
| Decision gated on peer/community lived experience | Drafting content with citations → `content-research-writer` |
| The user wants to know **which communities** to follow on a topic | Pure fact lookup with one right answer |

The signature of this skill: it weights **lived experience over authority**, and it **recommends the community landscape**, not just an answer.

## Phase 0 — Check local knowledge

If the local profile defines a knowledge preflight, run it before external research. Surface useful matches and ask whether to use them; otherwise proceed silently.

## Phase 1 — Scope (infer; ask at most one question)

From the query, pin down:
- **Subject** — the thing being evaluated (product, OS/beta, tool, service, practice, place).
- **Decision context** — what the user is deciding (install / buy / adopt / wait / switch). This sets what "feedback" matters.
- **Recency sensitivity** — betas, new releases, fast-moving products: feedback older than the current version is noise. Note the version/date in scope.

Only ask if the wrong read would waste the search. One short question, then go.

## Phase 2 — Map the Community Landscape (REQUIRED, distinctive step)

Identify the venues where real users of this topic congregate. **Always include Reddit.** Then add the venue types that fit the topic — this list is itself an output the user requested:

| Topic type | Community venues to consider |
|---|---|
| **Apple / dev betas** | Reddit (r/iOSBeta, r/MacOSBeta, version subs), [Apple Developer Forums](https://developer.apple.com/forums/), MacRumors Forums, Hacker News |
| **Software / SaaS / tools** | Reddit, official community forum / Discourse, product Discord/Slack, Stack Exchange site, GitHub Discussions, Hacker News |
| **Hardware / gear** | Reddit, dedicated enthusiast forums (e.g. head-fi, mtbr), RTINGS forums, manufacturer forums |
| **Games** | Reddit, Steam discussions, official Discord, GameFAQs |
| **Hobbies / practice** | Reddit, dedicated forums, Facebook/Discord groups, Stack Exchange |
| **Places / travel** | Reddit (city/region subs), TripAdvisor forums, Fodor's, local FB groups |
| **Health / fitness** | Reddit, condition-specific forums, Examine.com community, patient groups |
| **Finance** | Reddit (r/personalfinance, r/Bogleheads), Bogleheads forum, FairMark |

Pick the 2–4 most relevant venues. Name any **user groups, Discords, or local meetups** worth following if they exist for the topic — this skill always surfaces them.

## Phase 3 — Firecrawl Research (parallel)

Run searches in parallel; don't serialize.

1. **Reddit — always.** `firecrawl_search` with `includeDomains: ["reddit.com"]` (or `site:reddit.com`). Target the decision: e.g. "<subject> stability daily driver worth it", "<subject> problems after a month". Pull the 4–8 most relevant threads.
2. **Primary community forum** for the topic (from Phase 2) — e.g. Apple Developer Forums, the product's Discourse, the enthusiast forum.
3. **Official source for hard constraints** when the decision has a factual gate (system requirements, compatibility, pricing). Sentiment can't override a hard requirement — check it.
4. **Read full Reddit threads** with the helper — comment bodies are the lived-experience signal this skill exists for:
   ```bash
   ../research-quick/reddit-read.sh "<thread-url>"
   ```
   Run it on the 3-5 most relevant threads. See `research-quick`'s Phase 2 step 4 for full usage detail (how it works, requirements, fallback). Scrape the **non-Reddit** forums with `firecrawl_scrape` as normal.
5. After each `firecrawl_search`, call `firecrawl_search_feedback` with the search ID to refund a credit.

## Phase 4 — Synthesize (sentiment-weighted)

- **Separate consensus from loud minority.** Many threads saying the same thing = signal. One viral complaint = note it, weight it down.
- **Rank recurring issues** by frequency × severity. Lead with what most affects the user's decision context.
- **Surface the contrarian + the positive** signal explicitly — don't only report problems.
- **Date everything.** For fast-moving topics, tie each finding to the version/build and flag when feedback predates the current release.
- **Respect hard gates.** If an official requirement blocks the option regardless of sentiment, lead with it.

## Output

Always write a durable artifact including the format below, all source URLs, recency/version scope, and [the shared research artifact contract](../research-absorb/references/artifact-contract.md). Add evidence gaps and a **Proposed distribution plan**. Use the local profile's destination; without one, ask for the destination before writing. Report the artifact path and plan; the caller may then invoke `research-absorb`.

## Output Format

```
**[Subject]** — [1–2 sentence overall read, with the decision verdict up front]

🟢/🟡/🔴 **Bottom line**: [recommendation tied to the user's decision context]

**Hard constraints** (only if any)
- [Requirement / compatibility / gate] ([official source](url))

**What people are saying**
- [Recurring theme — how widespread] — [r/sub or forum](url)
- [Second theme] — [source](url)
- [Contrarian / positive signal] — [source](url)

**Recurring issues, ranked**
1. [Issue] — [frequency/severity note]
2. [Issue] — …

**Communities to watch**
- [Venue] — [why / what's there] (url)
- [User group / Discord / forum] — (url)
```

Keep it tight. Consolidate agreeing sources. Make conflicts explicit. Always end with the **Communities to watch** block — surfacing the right venues is half the value of this skill.
