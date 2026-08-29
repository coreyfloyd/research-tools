# Research artifact contract

Every durable artifact produced by `research-sources`, `research-topic`,
`research-feature`, or `research-feedback` is a transient, evidence-grounded
handoff to `research-absorb`. It is not raw wiki input and it is not a final
archive. Its purpose is to let the user make the decisions the evidence raises,
then be executed and deleted.

## Required sections

1. **Question and scope** — the decision, target, or question addressed.
2. **Source findings** — synthesized claims about the sources themselves, with
   confidence and material contradictions.
3. **Applicability** — the evidence measured against the user's existing
   systems and recorded knowledge: overlap with what already exists, genuine
   deltas, and contradictions with current setup or beliefs. Resolve what "the
   user's systems" are from local policy (the profile and the knowledge store
   it points to), never from assumption.
4. **Decisions** — the proposed distribution plan (shape below).
5. **Sources and provenance** — supplied and discovered sources, original URLs
   or paths, relevant extracts/transcripts, retrieval fallback, and any
   notebook ID.
6. **Search record** — what was searched for beyond the supplied sources and
   how each result was used, including searches that returned nothing (a
   verified negative is evidence and must say how it was verified) and
   channels that were not searched because the runtime is blocked from them
   or the cost exceeded the stakes. Distinguish "searched directly and
   absent" from "absent from indirect search" — they carry different
   confidence. If local policy names an alternate route for a blocked
   channel, record whether it was used and why or why not.
7. **Evidence gaps** — unanswered questions and sources that could resolve
   them.

### Sizing rule

Depth scales with the decisions the artifact must enable — not with source
volume and not with analysis effort expended. Write one finding per claim that
changes a decision. Verification work that succeeded collapses to a provenance
line ("citations verified against the arXiv API"), not a section. Decisions
cite findings by ID; they do not restate them.

## Decisions

Two decision classes. Every actionable result belongs to one of them.

Every decision states its execution route on the decision surface itself, as
an explicit line: **"Executes as: task filed — another session runs it"** or
**"Executes as: inline by `research-absorb` on approval."** By default an Act
decision files a follow-up task for another session, and a Keep decision
executes inline during absorption. When an Act item is small enough that
inline execution is tempting, offer inline-vs-task as an explicit option
inside the decision — never a silent judgment call. The appendix's task-route
column carries the mechanics; the route the user is approving belongs on the
surface they judge.

### Act — does this change a system the user runs?

The trigger is operational implication, not installability: the evidence may
imply changing an agent harness, a workflow, a process, or a standing document,
whether or not the source is itself an installable tool. When the evidence
implies no operational change, say so in one line — that is the whole section.

Each Act decision presents 2–4 options with the tradeoffs of each, plus a
recommendation and the reason it beats the alternatives. A trial option is only
an option when it is defined: it uses the source's own installation or adoption
mechanism (deviating only for a stated risk), and it names success criteria, a
review date, and a removal path. An undefined trial is a deferral, not an
option.

### Keep — what knowledge persists?

One item per candidate piece of durable knowledge. Each item states: what the
user gets, what is lost by skipping it, the literal step taken, the confidence
level (and what that confidence is based on), and the cost to execute. Keep
only what would otherwise be re-derived or re-researched later.

### Rejected candidates stay inline

An action or keep-candidate that was considered and rejected is recorded inline
in its parent decision as rejected, with the reason. It is not escalated as its
own decision, and no standalone "confirm the drops" section exists. Approval of
the plan covers the discards. Escalate a rejection as a real decision only when
it forecloses something contentious the user might weigh differently.

## Evidence sufficiency

Sufficiency is derived from the decision set, not from the source count. Before
writing the Decisions section, check each decision: can its options actually be
chosen from the evidence gathered? An Act decision about adopting third-party
work always requires evidence the primary source cannot contain — real-world
usage, community sentiment, maintenance signals — bounded to what would change
the choice, gathered through the producing skill's evidence-improvement path.

Completion test: if a decision's recommended option amounts to "gather more
evidence," the research stopped early — go gather it. The exceptions are
evidence obtainable only first-party (by the user running it themselves) and
evidence whose collection cost exceeds the decision's stakes; name the
exception when relying on one.

### Named referents

Evidence may introduce a **named referent** — a person, organization, product,
or concept — that the material establishes as a substantive subject rather than
an incidental mention. A source's own author or subject counts, even when no
other source in the set names them. When a referent clears that bar, emit a
Keep item for it: it is a distinct actionable result from the findings it
appears in, and the producer is the only stage holding both the evidence and
the authority to propose it. Resolve its destination and page conventions from
local policy; do not invent a taxonomy. Emit no item when nothing clears the
bar — a considered-and-rejected note is not an item.

## Execution appendix

The decision sections are the surface the user judges. The mechanics of
executing them live in an appendix of machine-actionable rows keyed by decision
ID, for `research-absorb` to validate and run:

| ID | Decision | Destination and action | Target | Task route | Preconditions | Terminal disposition |
|----|----------|------------------------|--------|------------|---------------|----------------------|
| E1 | A1 | stage source then compile | named knowledge base area | — | approval; target available | integrated |

`Destination and action` must say whether the result needs source staging,
synthesis, direct document update, or a follow-up task. A follow-up task row
must name `artifact_followup_destination`, not the wiki-maintenance
destination. A wiki row names the supporting external source(s), not the
report as raw input. Rows derive from decisions; a row with no parent decision
is invalid.

## Lifecycle invariants

- The producer proposes the plan; `research-absorb` validates and executes an
  approved plan. It does not create a second plan.
- Every row ends as **integrated**, **target document updated**, **task filed**,
  or **explicitly discarded**. A pending row prevents cleanup.
- Approval of the plan is the explicit discard for every inline-rejected
  candidate; no per-item confirmation is required.
- No retain or archive state exists for the artifact. After all rows have a
  terminal disposition, `research-absorb` deletes the artifact.
- Do not treat a report as a raw wiki source. Preserve selected source
  provenance in canonical `raw/research/`, then use `research-to-wiki` for the
  curated subset. Promote a report to derived material only when it is itself
  a required durable transformation and approval covers that promotion.
