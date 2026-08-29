# Release candidate review

## Scope

`0.4.1` release of the research and knowledge system. It rewrites the shared
research artifact contract around the decisions the user must make: a new
required report shape, a two-class decision taxonomy, an evidence-sufficiency
rule for adoption decisions, defined trial options, and demotion of the
mechanics table to an execution appendix.

## Included

- **Report shape**: required sections become question/scope, source findings,
  applicability (evidence measured against the user's existing systems via
  local policy), decisions, provenance, and evidence gaps. A sizing rule ties
  report depth to the decision set — one finding per claim that changes a
  decision; successful verification collapses to provenance lines.
- **Decision taxonomy**: two classes. **Act** is triggered by operational
  implication (any change to a system the user runs), not installability, and
  carries 2–4 options with tradeoffs plus a recommendation. **Keep** items
  state what is gained, what skipping loses, the step, confidence, and cost.
  Rejected candidates are recorded inline in their parent decision; plan
  approval covers discards, and no standalone drop-confirmation section
  exists.
- **Evidence sufficiency**: derived from the decision set, not source count.
  An Act decision about adopting third-party work requires real-world usage,
  sentiment, and maintenance evidence gathered through the producer's
  evidence-improvement path. A "gather more evidence" recommendation means the
  research stopped early, with named exceptions for first-party-only evidence
  and cost exceeding stakes.
- **Trial options**: a trial must use the source's own adoption mechanism
  (deviating only for a stated risk) and define success criteria, a review
  date, and a removal path; otherwise it is a deferral, not an option.
- **Execution appendix**: the seven-column mechanics table is no longer the
  decision surface. Rows are machine-actionable, keyed by decision ID, and
  invalid without a parent decision. `research-absorb` validates that
  derivation and treats plan approval as the explicit discard for
  inline-rejected candidates.
- **Producer alignment**: `research-sources` gains the evidence-sufficiency
  trigger; `research-feature`, `research-feedback`, and `research-topic`
  reference the Decisions section in place of the former "Proposed
  distribution plan".

No profile schema change: version-4 profiles remain valid, and installation
and upgrade contracts are unchanged from `0.3.0`.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh`
- `bash tests/test-release.sh`
- `swift test` in `skills/transcribe/tools/apple-speech`
- `git diff --check`

On 2026-08-29, all three shell suites, the five Apple Speech tests, and
`git diff --check` passed from the clean, pushed release commit
`51c90412810fff2c9ab582528235dd841de1aa2b` before tagging.

## Release-note draft

`v0.4.1` rewrites the research artifact contract around the decisions research
exists to enable. Reports now separate findings about the sources from an
applicability section that measures the evidence against the user's own
systems, and report depth scales with the decision set rather than with source
volume or analysis effort.

Decisions come in two classes: **Act** (does this change a system you run —
triggered by operational implication, not installability) with 2–4 options,
tradeoffs, and a recommendation; and **Keep** (what knowledge persists) with
explicit skip-cost, confidence, and execution cost per item. Considered-and-
rejected candidates stay inline, so approving the plan covers the discards.

Adoption decisions about third-party work now require evidence the primary
source cannot contain — real-world usage, sentiment, and maintenance signals —
and a recommendation that amounts to "gather more evidence" is defined as
research that stopped early. Trial options must name success criteria, a
review date, and a removal path. The execution mechanics table moves to an
appendix keyed by decision IDs for `research-absorb` to validate and run.
Profiles and installation are unchanged.

## Publication checklist

- [x] Commit the complete candidate and push `main`.
- [x] Capture the final commit in the release-session evidence and rerun every
  verification command from that exact clean commit.
- [x] Follow `RELEASING.md` to create and push the annotated `v0.4.1` tag.
- [x] Build, sign, and locally verify the four release assets.
- [x] Publish the GitHub release with the reviewed notes above.
- [x] Redownload and verify the public assets.
- [x] Record the final commit, release URL, and public-asset verification
  below in a post-publication follow-up commit.

## Publication record

- Target commit: `51c90412810fff2c9ab582528235dd841de1aa2b`
- Tag: annotated `v0.4.1`, resolving to the target commit above
- Release URL:
  <https://github.com/coreyfloyd/research-tools/releases/tag/v0.4.1>
- Published asset verification: completed 2026-08-29; all four expected assets
  were downloaded, the public key byte-matched the repository key, and the
  detached signature and SHA-256 checksum passed verification.

## Release status

Versions `0.1.0` through `0.4.1` are published. The `v0.4.1` public assets
were downloaded and verified after publication.
