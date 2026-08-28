# Research artifact contract

Every durable artifact produced by `research-sources`, `research-topic`,
`research-feature`, or `research-feedback` is a transient, evidence-grounded
handoff to `research-absorb`. It is not raw wiki input and it is not a final
archive.

## Required sections

1. **Question and scope** — the decision, target, or question addressed.
2. **Findings** — synthesized claims, with confidence and material
   contradictions or gaps.
3. **Sources and provenance** — supplied and discovered sources, original
   URLs or paths, relevant extracts/transcripts, retrieval fallback, and any
   NotebookLM notebook ID.
4. **Evidence gaps** — unanswered questions and sources that could resolve
   them.
## Proposed distribution plan

The artifact must include one row per actionable result, using this shape:

   | ID | Evidence | Destination and action | Target | Task route | Preconditions | Terminal disposition |
   |----|----------|------------------------|--------|------------|---------------|----------------------|
   | D1 | source-backed finding | stage source then compile | named knowledge base area | — | approval; target available | integrated |

   `Destination and action` must say whether the result needs source staging,
   synthesis, direct document update, or a follow-up task. A follow-up task
   row must name `artifact_followup_destination`, not the wiki-maintenance
   destination. A wiki row names the supporting external source(s), not the
   report as raw input.

## Lifecycle invariants

- The producer proposes the plan; `research-absorb` validates and executes an
  approved plan. It does not create a second plan.
- Every row ends as **integrated**, **target document updated**, **task filed**,
  or **explicitly discarded**. A pending row prevents cleanup.
- No retain or archive state exists for the artifact. After all rows have a
  terminal disposition, `research-absorb` deletes the artifact.
- Do not treat a report as a raw wiki source. Preserve selected source
  provenance in canonical `raw/research/`, then use `research-to-wiki` for the
  curated subset. Promote a report to derived material only when it is itself
  a required durable transformation and approval covers that promotion.
