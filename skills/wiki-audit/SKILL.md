---
name: wiki-audit
description: Read-only structural audit of a configured Karpathy-wiki knowledge base. It checks atomicity, missing pages, hub coherence, structural health, source coverage, tensions, and gaps without resolving them.
---

# Vault Audit

Read `~/.config/research-tools/profile.md` and the [public Karpathy-wiki contract](../../contracts/karpathy-wiki.md) before auditing. Run only against the configured `knowledge_root`.
Produces a ranked report in the configured `output_dir`.
Modifies nothing.

**Pairs with checklist-vault.** checklist-vault captures change at session
end; wiki-audit catches problems on demand. Run wiki-audit when the user
suspects drift, asks for atomicity validation, or after a major compile pass.

**Rubric provenance.** Atomicity logic in this skill is grounded in the
2026-04-30 research synthesis at `output/2026-04-30-atomicity-research.md`.
Anchors: Karpathy's wiki pattern, zettelkasten.de's 5-signal atomicity
guide, Matuschak's evergreen notes, Milo's collision split trigger.

## When to Use

- "vault audit", "audit the vault", "audit wiki", "run an audit"
- "atomicity check", "are articles too big", "split candidates", "what's missing"
- After a compile pass that adds ≥10 articles
- Before a major taxonomy decision (folder split, ADR amendment)
- **NOT proactively triggered** — opt-in only

## Stance

- **Read-only.** Never writes to `wiki/`, `raw/`, or `docs/` during the audit pass.
- **Surface, don't resolve.** Conflicts with ADRs are reported as findings.
- **Multi-signal evidence.** Each test runs independently. A single article can
  trigger multiple tests; report all of them. Do not silently merge.
- **All articles, every run.** Apply every test to every article in `wiki/`.
- **More links, not less.** The dominant signal is graph health, not file size.
  Length is a secondary correlate only.

## Atomicity model

The public Karpathy-wiki contract defines the audit standards. This section contains only the measurement procedures for detecting violations at scale.

### Mode sensitivity thresholds

Mode is selected by `mode:` frontmatter; without it, use knowledge-access.

| Test | Knowledge-access | Practitioner-frameworks | Writing-output |
|---|---|---|---|
| Section-anchor collision threshold | ≥3 distinct callers | ≥3 distinct callers | ≥2 distinct callers |
| Length × fan-in interaction | High length OK if fan-in low | Hub articles (Watkins, Larson) exempt from length pressure; named-pattern atoms (e.g., [[heroes-problem]]) held to knowledge-access standard | Lower tolerance — publish-ready sections get extracted |
| 5-signal "Nothing removable" strictness | Tolerant — ancillary context fine | Tolerant for framework articles where the framework is the unit; strict for named-pattern atoms | Strict — extra prose marks padding |
| Hub-spawn signal | Triggers when 3+ siblings link to different sub-parts | Triggers when 3+ siblings link to different sub-parts | Triggers when 2+ siblings link to different sub-parts |

### Title quality

Every rename is a breaking change (titles-as-APIs). The audit produces candidates only; it never renames articles.

### Split trigger (collision-driven, replaces v1 line/section/source tests)

An article wants to be N-articles-linked-to-a-hub when:

- **Section-targeted wikilink fan-in ≥ 3** from distinct articles → that
  section wants its own page. *Primary quantitative signal.*
- **Hub-spawn signal:** if you'd write three sibling articles each linking
  to a *different* sub-part of this one, the article is already secretly N
  articles. Apply by reading the article alongside its inbound link contexts.
- **Connection weakness:** when a sibling links here and the link feels
  awkward or disambiguating ("see the section on X"), that's a collision.
  Hand-flag during inbound-link inspection.

### Length policy

Length is a **secondary correlate only**, not a primary test:

- Long article + low fan-in = thorough entity page (fine — Karpathy-shaped)
- Long article + high fan-in = hub waiting to explode

The signal is *length × section-targeted fan-in*, not either alone.

## Procedure

### 1. Scope

Count articles and confirm scope:

```bash
find "$WIKI_DIR" -name "*.md" -not -name "_index.md" -not -name "_master-index.md" -not -name "hot.md" -not -name "AGENTS.md" | wc -l
```

State the count to the user before starting.

### 2. Missing-page lint (Karpathy's check — primary "more links" test)

Find concepts mentioned across ≥3 articles without a wiki page of their own.
This is the test most absent from prior audit rubrics; runs first because
its findings are the highest-leverage moves toward "more links, not less."

Method:

1. Build inventory of existing wiki page basenames (lowercase + space-aware
   variants for matching).
2. Extract bare-text Title Case 2–4-word phrases from each article's body
   (strip frontmatter, wikilinks `[[...]]`, code fences and inline code,
   headings, URLs, markdown link syntax).
3. Skip phrases starting with sentence-starter capitalized words (The, A,
   When, etc. — full list in the script).
4. Count distinct articles each phrase appears in.
5. Filter: ≥3 distinct articles AND not already a wiki page AND not a
   curated noise term (Best Practices, App Store, etc.).
6. Categorize by folder type (AI-vault / writing-corpus / cross-folder).
7. **Stub-worthy vs page-worthy distinction** (per Matuschak: "Backlinks
   can be used to implicitly define nodes"). For each ≥3-mention concept
   without a page, classify by whether the bare-text mentions raise
   tensions/contradictions/synthesis questions:
   - **Wikilink-only** — bare mentions are congruent. Promote to wikilinks
     pointing at a *not-yet-created* target. Backlinks panel does the
     implicit definition; create a real page only later if synthesis
     pressure builds.
   - **Stub page** — mentions are mostly congruent but the term has a
     stable referent worth disambiguating. Create a 1-paragraph stub.
   - **Full page** — mentions raise tensions, contradictions, or require
     synthesis. Create a real page with assertions.
   The default is wikilink-only — fewer new files, denser graph. Escalate
   to stub or page only when the article-side mentions demand it.
8. Group findings:
   - **A. Missing entity pages** (person, product, concept) — create new (full page)
   - **A2. Stub-worthy concepts** — create 1-paragraph stubs (a concept's referent is stable, but no synthesis pressure yet)
   - **A3. Wikilink-only candidates** — promote bare text to wikilinks pointing at not-yet-created targets; let backlinks panel define implicitly
   - **B. Wikilink fixes** (page exists; bare mentions should become links)
   - **C. Career-corpus candidates** (specific to user's history; user-decision)
   - **D. Verification needed** (Title Case fragments, ambiguous matches)

Reference Python implementation lives in the skill's procedure history
(see prior audits). Re-encode if needed; the heuristic is stable.

**Method limitations to document in report:**
- Misses lowercase concepts (cognitive load, deep modules) — augment with
  curated lowercase-concept list when the vault has stable concept hubs
- Title Case fragments split at word boundaries can produce false fragments
  (e.g., "Designing Data" + "Intensive Applications" = the same book)
- Generic-noise filter is hand-curated; tune per run

### 3. Section-targeted wikilink fan-in (collision test — primary split signal)

Find articles whose **sections** are linked to from ≥3 distinct other
articles. Each such section wants its own page.

```bash
grep -roh '\[\[[^]]*#[^]]*\]\]' "$WIKI_DIR" | \
  sed 's/|.*\]\]/]]/' | \
  sort | uniq -c | awk '$1 >= 3' | sort -rn
```

Caveat: section wikilinks include `|alias` syntax that needs normalization
(strip alias before counting). Threshold ≥3 from distinct callers — count
unique source files, not raw occurrences.

For each article whose section meets the threshold:
- Read the section to assess whether it's a coherent atom (5-signal check)
- Examine the linking contexts: are they all linking to the same idea, or
  the section is being used as a topical anchor for related-but-distinct
  ideas?
- Apply the hub-spawn signal qualitatively for borderline cases

### 4. Hub coherence

For each article with ≥5 inbound wikilinks (a "hub"):

- Read the article's stated domain (from intro / Key Takeaways / opening H1)
- Sample inbound-link contexts (5–10 representative callers)
- Assess: do the inbound topics cohere with the stated domain?
- Heterogeneous inbound = the hub is two hubs fused → split candidate
- Homogeneous inbound = healthy hub

Report: hubs that need splitting + hubs that are healthy.

### 5. 5-signal article quality pass (qualitative)

Articles failing 2+ quality signals are findings (not necessarily atomicity failures — they may be padding, premature drafts, or filler).

At knowledge-base scale this is too much for one orchestrator pass — sample representative articles per folder, or dispatch a subagent with the full list and the public contract. Mark this section as **partial** if not done exhaustively.

### 6. Structural health

| Check | Method |
|---|---|
| Length violations | Articles >200 lines without `length_justified:` (informational, not action — length is secondary) |
| Single-article topic folders | `find wiki/ -mindepth 1 -maxdepth 1 -type d` then count non-`_index.md` files in each |
| Orphan articles | Articles with zero inbound `[[wikilinks]]` from non-index pages |
| Broken wiki links | Wikilink targets that do not resolve beneath the configured knowledge root. |
| Forward references | Wikilinks to not-yet-created articles; note as expected if a compile pass is in progress. |
| Misused wikilinks | Raw filenames used as `[[wikilink]]` targets — should be `sources:` frontmatter or markdown links |
| Stale frontmatter | Articles missing required fields (`topic:`, `sources:` for compiled articles) |

### 7. Content quality

- **Padding around thin sources** (per R-008) — long article from a thin source
- **Dense-linking check** — per the public contract, absent
  links are a compile defect, not acceptable output. For each article:
  1. Extract bare-text mentions of concepts that have existing wiki pages
     (cross-reference §2B findings — page exists, bare mention found).
  2. Flag articles where ≥3 such unwired mentions exist.
  3. Apply the writing-output threshold only to articles explicitly marked
     `mode: writing-output`.
  Report as **wikilink fixes** grouped by article, not by concept.
- **Trailing link-dump sections** — flag articles with `## Related`, `## See also`, `## Further reading`, or `## How it connects` sections that are **bare wikilink lists with no annotation** (`- [[foo]]` / `- [[bar]]` / `- [[baz]]` — no contextual sentence per entry). Trailing curated sections are valid when annotated — each entry has a substantive sentence explaining why it relates. Report association-quality fixes only when that annotation is absent.
- **Entity drift** — `kind: entity` pages with declining backlink counts;
  judge qualitatively against the public contract's entity/page guidance

### 8. Hub coverage (people / R-004 compliance)

Per R-004 (amended 2026-04-29): person-entities live in `wiki/people/`;
all other entity types live in their most-related topic folder.

- Walk all `kind: entity` pages
- Classify each as person / concept / tool / org / product / protocol /
  language / framework / platform / book
- Person-entities outside `wiki/people/` → flag for migration
- Non-person entities inside `wiki/people/` → flag as misplaced

### 9. Source coverage

#### 9a. raw/research/ (external sources)

Walk `raw/research/`. For each file, check whether any wiki article
references it via `sources:` frontmatter (vault-root-relative path; both
list and inline frontmatter formats).

**Exclude from "unreferenced" count:**
- Files with `source_of: derived` frontmatter (derived files are outputs of
  other ingestions, not primary sources awaiting compile)
- Files with `kind: bookmark` (bookmarks compile to wiki/bookmarks.md, not
  via sources frontmatter — per ADR-020)

#### 9b. raw/archive/ (writing corpus)

Same method as 9a. The bulk of `raw/archive/` is the deferred writing
corpus per `wiki/hot.md`; the count is reported for awareness, not as an
action item.

### 10. Cross-article contradiction and tension detection

Find wiki articles that make incompatible or differently-qualified claims about the same concept. This is semantic, not structural — distinct from §2 missing-page lint (which classifies mention-density, not claim coherence).

**Boundary with §2:** §2 finds concepts mentioned ≥3 times without a page. §10 finds concepts that *have* pages but where two or more existing articles assert things that conflict or tension each other.

**Sampling strategy** (not exhaustive — ~170 articles is n²):

1. **Within-folder clusters** — for each domain folder with ≥5 articles, identify articles sharing a subject and compare their key claims.
2. **High-fan-in hub neighbors** — for each hub with ≥5 inbound links (identified in §4), sample the 5 nearest neighbors (articles that both link to it). Compare their claims about the hub concept.
3. **Compile-flagged articles** — grep `wiki/` for `## Tensions` sections written by the compile pass. These are already-identified conflicts; aggregate and verify they're still unresolved.

For each candidate pair/cluster:
- Read Key Takeaways and the specific claim in body context
- Classify:
  - **Direct contradiction** — Article A says X; Article B says ¬X about the same referent
  - **Scope tension** — Article A says "X always"; Article B says "X depends on context Y"
  - **Term drift** — same label used with different meanings across articles
- Record: Article A ↔ Article B, claim X vs. claim Y, classification, which is likely more accurate (or whether synthesis is needed)

**Stance:** surface findings only. Propose whether a `## Tensions` section should be added to one or both articles — don't write it.

**Scale limit:** document in report how many clusters were sampled and which were skipped. Mark as **partial** if the full wiki wasn't covered; carry forward skipped folders to next audit.

### 11. Gap detection

Find knowledge the wiki depends on but doesn't cover. Three distinct gap types — each is different from §2 missing-page lint.

**Boundary with §2:** §2 = bare-text Title Case phrases appearing in ≥3 articles without a page (heuristic coverage scan). §11 = articles that *semantically depend* on a concept — they build on it, not just mention it — where that concept has no page or only a thin stub.

**Gap types:**

1. **Dependency gaps** — for a sample of articles (same clusters as §10), identify concepts the article's reasoning depends on (not just mentions). Check whether each has a full wiki page or only a stub. If a stub: is it sufficient for the dependent article, or does it need expansion? Flag under-specified stubs as gaps, not just missing pages.

2. **Source-implied gaps** — cross-reference §9 source coverage findings. If an existing wiki article references concept X, and there's a raw source in `raw/research/` or `raw/archive/` covering X that hasn't been compiled (`ingestion_status: false`), flag it as a gap with fill path: "compile from raw/[path]".

3. **Structural gaps** — wiki has article A (prerequisite concept) and article C (advanced application), but nothing in between. Flag where the logical bridge is missing.

4. **Compile-flagged gaps** — grep `wiki/` for `## Gaps` sections written by the compile pass. Aggregate into this report; verify fill paths are still valid.

**Output per gap:**
- Gap name + one-sentence description of what's missing
- Which articles depend on it (≥2 = higher priority)
- Fill path: `external research needed` / `compile from raw/[path]` / `synthesize from [[A]] + [[B]]`
- Priority: **Must** (blocks understanding of ≥3 articles), **Should** (improves coherence of ≥2), **Can** (nice to have)

**Roadmap proposal:** gaps rated Must or Should with a clear fill path are proposed as roadmap candidates in the output report. Present each as: "Create [[concept-name]] — [one-line reason] — fill: [path]."

**Stance:** read-only. Surface findings; propose roadmap items; don't create pages.

### 12. Output report

Write to `output/YYYY-MM-DD-wiki-audit.md` with frontmatter:

```yaml
---
source: audit
status: report
created: YYYY-MM-DD
scope: <article count> articles, <raw counts> raw files
---
```

Report structure:

1. **Summary** — counts per category, top-priority findings
2. **Missing-page lint** — categorized A / B / C / D from §2
3. **Collision split candidates** — section-fan-in findings from §3, with
   atomicity assessment per candidate
4. **Hub coherence** — split candidates + healthy hubs from §4
5. **5-signal quality findings** — articles failing 2+ signals from §5
6. **Structural health** — sections per check
7. **Content quality** — padding, missing cross-links, entity drift
8. **Hub coverage** — R-004 compliance from §8
9. **Source coverage** — raw/research/ and raw/archive/ from §9
10. **Cross-article contradictions and tensions** — findings from §10. Per entry: Article A ↔ Article B, claim vs. claim, classification (direct contradiction / scope tension / term drift), proposed resolution or `## Tensions` addition. Sampling coverage documented.
11. **Gap inventory** — findings from §11. Per entry: gap name, dependent articles, fill path, priority. Must/Should gaps proposed as roadmap candidates. Compile-flagged gaps (aggregated `## Gaps` sections) included with verification status.
12. **Priority ranking** — Must / Should / Can / Not assessed

### 13. Log entry

Report the proposed operation-log entry; do not write it because this audit is read-only:

```
## [YYYY-MM-DD HH:MM] audit | <one-line summary>
```

Wait for user approval before appending.

## Deliverables

After running:

1. `output/YYYY-MM-DD-wiki-audit.md` — the report
2. `docs/log.md` — one-line audit entry (with approval)
3. Surfaced findings — stated to user inline so they're visible without
   reading the report file

## What this skill does NOT do

- Atomize, split, or merge articles
- Move files between folders
- Create entity/concept pages
- Resolve ADR tensions, contradictions, or gaps (only surfaces them)
- Write `## Tensions` or `## Gaps` sections into articles (compile's job — audit proposes, compile writes)
- Modify frontmatter
- Auto-commit findings
- Update STATUS.md or ROADMAP.md (checklist-vault's job)
- Run typed-relationship audits (separate dimension — see ROADMAP)
- Run freshness/lifecycle audits (separate dimension — see ROADMAP)
- Run connection-density audits (separate dimension — see ROADMAP)

If the audit surfaces work that needs doing, propose follow-up actions —
don't execute them.

## Open questions

- **Q1 — Atom-size pole:** ~~deferred~~ **Resolved 2026-05-03** via
  folder-as-proxy mode determination above. Knowledge-access folders
  calibrate Karpathy/Matuschak-sized; writing-output folders calibrate
  Zettelkasten/Luhmann-sized. Per-article frontmatter `mode:` flag
  available as override. Future refinement: per-article calibration if
  folder defaults prove wrong in practice.
- **Q2 — Doto reframe:** ~~deferred~~ **Resolved 2026-05-03** by the same
  mode-split. The Doto critique ("atomicity is a writing-output
  discipline") motivated the per-mode sensitivity. Knowledge-access mode
  applies atomicity loosely (Doto's critique stands for that mode);
  writing-output mode applies it strictly (Doto's prerequisite holds for
  that mode).

## Example invocation

```
User: vault audit
Claude: Running wiki-audit on 163 articles in wiki/...

§2 Missing-page lint:
- 4 person-entities missing pages (Will Larson, Paul Hudson, Prithvi
  Rajasekaran, author names)
- 6 wikilink fixes (Agent SDK → agent-sdk-overview, etc.)
- 5 Athletic-era career terms (decision call)

§3 Collision split candidates: 0 sections meet ≥3 fan-in threshold

§4 Hub coherence: 22 hubs, all coherent

§6 Structural health:
- 1 orphan article
- 0 broken wiki links
- ~12 misused wikilinks

§8 R-004 compliance:
- 1 person-entity outside wiki/people/ (karpathy.md → migrate)

§10 Cross-article contradictions (sampled configured wiki folders):
- [[agent-loops]] ↔ [[claude-code-workflow]]: term drift — "agent" means autonomous loop in one, single-turn call in the other → propose §Tensions in both
- 1 compile-flagged tension in [[ai-specification-principles]] already documented (verified still open)
- Sampling: 2/5 domain folders covered; wiki/software-development/ + others deferred

§11 Gap inventory:
- progressive-specification (Must) — [[ai-specification-principles]] + [[claude-code-workflow]] both depend on it; fill: synthesize from those two articles
- compile-flagged gaps: 1 in [[ai-collaboration-failure-modes]] (fill: compile from raw/research/X)
- Roadmap proposals: 2 (progressive-specification, session-memory-model)

Report: output/2026-04-30-wiki-audit.md
Propose log entry: "## [2026-04-30 HH:MM] audit | 163 articles, 4 missing person-pages, 1 term-drift tension, 2 roadmap gap proposals"

Proceed with log append?
```
