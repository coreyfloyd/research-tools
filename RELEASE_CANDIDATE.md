# Release candidate review

## Scope

`0.5.0` release of the research and knowledge system. It restructures the
shared research artifact around three questions — what the sources say, whether
they can be trusted, and what to do with them — and replaces the two-class
decision surface with three absorption classes split by what the result
touches. `research-absorb` follows the restructured artifact and refuses
staging as an outcome. `research-feature` and `research-feedback` leave the
absorption lifecycle and define their own deliverables.

## Included

- **Content separated from commentary**: a new required **Source Summary**
  section carries what the sources actually say — the claims, frameworks,
  lists, and arguments themselves — in enough detail that every later section
  can be read and judged without opening a source. **Source findings** is
  renamed **Source Assessment** and scoped to source trust alone: reliability,
  method, contradictions, confidence, provenance caveats. **Applicability** is
  deleted as duplicative, because each absorption item now carries its own
  baseline in a `What exists now` field.
- **Three absorption classes**: **Decisions** becomes **How to Absorb**, split
  into **Actions** (anything that is not a document), **Wiki Additions** (the
  compiled knowledge base only), and **Document Updates** (every other file).
  Routing knowledge into a standing document can no longer be filed as an
  operational change. Every item has the same shape — What exists now /
  Change / Why / Confidence, plus Rejected when alternatives were declined —
  and options with a recommendation appear only when a genuine choice exists.
- **Absorb or discard; never stage**: staging a source without absorbing it is
  a failure state rather than an option, and `research-absorb` invalidates any
  execution row whose only outcome is staging. Wiki Additions and Document
  Updates always execute inline on approval; only an Action may be filed as a
  task for another session.
- **Reach the named target**: when the document the evidence is meant to serve
  does not exist yet, the knowledge routes into the standing document that
  does. A knowledge-base compile alone leaves the material invisible to the
  work that consumes it.
- **Evidence Record**: **Sources and provenance** and the `0.4.2` **Search
  record** merge into one section with one entry per source, so no retrieval
  fact appears twice. It still records what was searched beyond the supplied
  sources, how verified negatives were confirmed, channels skipped because the
  runtime is blocked or the cost exceeded the stakes, and whether a local-policy
  route for a blocked channel was used.
- **Gaps name their follow-up**: every gap states the follow-up that would close
  it, including an explicit **none** with its reason — unclosable, tracked
  elsewhere, or not worth the cost.
- **Writing rules**: every item must be answerable from the artifact itself,
  abbreviations are expanded on first use, three or more items become a list,
  absorption items and gaps are tables, and table cells carry no unbreakable
  tokens.
- **One definition of the section list**: producer skills no longer restate it.
  Four partial copies had already drifted from the contract.
- **Documentation alignment**: the README's artifact-structure diagram, its
  workflow steps, and its decision-class prose match the restructured contract.
- **Feature and feedback research are deliverables, not handoffs**:
  `research-feature` writes a design input document into the project beside
  the requirements it answers, with a per-claim sources table. `research-feedback`
  writes a decision memo — bottom line, hard constraints, community read,
  ranked issues, communities to watch, sources — that is read once and deleted,
  or filed with the project it serves (competitor research). Neither uses the
  shared artifact contract or `research-absorb`; each defines its document in
  its own SKILL.md, so the section list still lives in exactly one place per
  type.

## Compatibility

No profile schema change and no installation or upgrade change: version-4
profiles remain valid and every `0.4.2` installation upgrades with no migration.

One consumer-visible break. `research-absorb` now validates against a **How to
Absorb** section, so a research artifact written under `0.4.2` or earlier — one
carrying a **Decisions** section — is no longer a valid input. Absorb any
in-flight artifact before upgrading, or reshape it to the new contract
afterward. Artifacts produced by `0.5.0` are unaffected.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh`
- `bash tests/test-release.sh`
- `swift test` in `skills/transcribe/tools/apple-speech`
- `git diff --check`

## Release-note draft

`v0.5.0` restructures the research artifact around three questions: what the
sources say, whether they can be trusted, and what to do with them.

A new **Source Summary** section carries the content itself — the claims,
frameworks, and arguments — in enough detail that the rest of the artifact can
be judged without opening a source. **Source findings** becomes **Source
Assessment** and covers source trust alone. **Applicability** is gone, because
every absorption item now states the target's current state itself.

**Decisions** becomes **How to Absorb**, split by what the result touches:
**Actions** for anything that is not a document, **Wiki Additions** for the
compiled knowledge base, and **Document Updates** for everything else. Routing
knowledge into a standing document is no longer filed as an operational change.
Items share one shape — what exists now, the change, why, and confidence — and
present options with a recommendation only when a real choice exists.

Staging is now a failure state. An item may not propose an outcome that leaves
knowledge parked, and `research-absorb` rejects any execution row whose only
outcome is staging a source. Wiki Additions and Document Updates execute inline
on approval; only an Action may be filed as a task. When the document the
evidence serves does not exist yet, the knowledge routes into the standing
document that does.

**Sources and provenance** and `0.4.2`'s **Search record** merge into a single
**Evidence Record** with one entry per source, so no retrieval fact is written
twice. Every evidence gap must name the follow-up that would close it, including
an explicit *none* with its reason.

`research-feature` and `research-feedback` leave the absorption lifecycle.
Feature research is a design input document written into the project beside
its requirements; feedback research is a decision memo read once and deleted,
or filed with the project it serves. Neither goes through `research-absorb`.

Profiles, installation, and upgrade are unchanged from `0.4.2`. One break:
`research-absorb` validates against **How to Absorb**, so an un-absorbed
artifact written under `0.4.2` is no longer valid input — absorb it before
upgrading, or reshape it afterward.

## Publication checklist

- [ ] Commit the complete candidate and push `main`.
- [ ] Capture the final commit in the release-session evidence and rerun every
  verification command from that exact clean commit.
- [ ] Follow `RELEASING.md` to create and push the annotated `v0.5.0` tag.
- [ ] Build, sign, and locally verify the four release assets.
- [ ] Publish the GitHub release with the reviewed notes above.
- [ ] Redownload and verify the public assets.
- [ ] Record the final commit, release URL, and public-asset verification
  below in a post-publication follow-up commit.

## Publication record

Pending. Recorded in a post-publication follow-up commit.

## Release status

Versions `0.1.0` through `0.4.2` are published. `0.5.0` is an unpublished
candidate.
