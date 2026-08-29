---
name: research-feature
description: "Research competitor UX and established patterns before feature design, producing a durable distribution-ready artifact. Use for 'how do other apps handle X?' or standard-pattern research."
---

# Feature Research

Investigate how other products solve the same problem the feature being designed aims to address. Given a set of requirements, research how established products and competitors handle similar features. Identify common patterns, novel approaches, and user expectations.

When a supplied demo, talk, or video is material evidence, invoke `transcribe` to obtain it in the appropriate form before comparing patterns. Do not create a separate media-research workflow.

Firecrawl is a runtime-detected optional integration. Use it first for web search and page extraction when it is available. If it is unavailable or blocked for a source, use native web tools and state that fallback in the report.

Validate `~/.config/research-tools/profile.md` with `../../scripts/validate_profile.py`, resolved relative to this skill, before selecting the durable output location. If it is missing or invalid, stop and use `research-tools-set-up`; do not choose a fallback output path. This skill is read-only except for its required research artifact. Any proposed follow-up task uses `artifact_followup_destination`, never the wiki-maintenance route.

## Execution Modes

- **Current session** — create the durable artifact after research.
- **Dispatched** — when an orchestrator needs the work off its context, pass the requirements and durable destination. The worker must still create the same artifact rather than leaving search dumps in scratch.

## What to Investigate

- **Established products** that solve the same or similar problem
- **UX patterns** — how do users interact with this feature in other products?
- **Common approaches** — what do most products do? Is there a de facto standard?
- **Novel approaches** — any products doing something unusual that works well?
- **User complaints** — what do users dislike about existing implementations?
- **Accessibility and edge cases** — how do products handle error states, empty states, loading states?

## How to Research

1. Read the requirements to understand what the feature does and who it's for
2. Use Firecrawl first, when available, to find and extract how 3-5 established products handle this — search for "[feature] UX pattern", "[product] [feature] design". Use native web search as supplementary discovery or the fallback when Firecrawl is unavailable or blocked.
3. Check product review sites, Reddit discussions, and design case studies for user feedback
4. Look for Apple Human Interface Guidelines or platform-specific patterns if building for iOS/macOS
5. Identify what works, what frustrates users, and what's table stakes vs. differentiating

## Research artifact

Always write a durable artifact using [the shared research artifact contract](../research-absorb/references/artifact-contract.md). The feature comparison below supplies the findings section; add source URLs, scope/recency, evidence gaps, and a **Decisions** section with its execution appendix. At completion, report the artifact path and plan. The caller may invoke `research-absorb`; do not distribute or mutate a project directly.

## Findings format

```markdown
## Feature Research: [Feature Name]

### How Others Do It

**[Product A]**
- How it works: [description]
- What works well: [strengths]
- User complaints: [weaknesses]

**[Product B]**
- How it works: [description]
- What works well: [strengths]
- User complaints: [weaknesses]

### Common Patterns
- [Pattern 1]: Used by [products]. [Why it works.]
- [Pattern 2]: Used by [products]. [Why it works.]

### Novel Approaches
- [Approach]: [Product] does [X]. [Why it's interesting.]

### User Expectations (Table Stakes)
- [Feature users expect to exist based on market norms]

### Platform Conventions
- [Relevant HIG/Material/platform guidelines]

### Summary
[1-2 paragraphs synthesizing what the research suggests for our implementation]
```

## Constraints

- **Read-only research.** Do not edit or create project files; the only write is the required durable artifact.
- **Evidence-based.** Cite specific products and specific behaviors. Don't generalize without examples.
- **User perspective.** Focus on what works for users, not what's technically clever.
- **Include negative signals.** What users complain about is as valuable as what they like.
- **Disposition:** `research-absorb` owns approved downstream distribution; this skill produces its proposed plan.

## When NOT to Use

- General non-dev research → `research-quick`
- Implementation/bug research (libraries, APIs, diagnosis) → `research-dev`
- Deep topic research with persistent notebooks → `research-topic`
