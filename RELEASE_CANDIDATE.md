# Release candidate review

## Scope

`0.4.0` release of the research and knowledge system. It requires research
producers to propose named referents in the artifact distribution plan,
carries upstream disposition decisions into wiki compilation instead of
re-deriving them, slims and de-slops the skill set for cross-runtime
portability, reworks the README around Markdown output and Gemini Notebook
grounding, and makes the release leakage guards fail closed.

## Included

- **Named referents in the artifact contract**: evidence that establishes a
  person, organization, product, or concept as a substantive subject now emits
  its own distribution-plan row from the producer, which holds both the
  evidence and the authority to propose it. `knowledge-capture` applies the
  same bar to conversation subjects.
- **Upstream disposition carried into compilation**: `research-to-wiki`
  honors topic assignment, approved named referents, and page conventions
  decided by `research-absorb` or `knowledge-capture`; it re-derives routing
  only on direct invocation with no upstream plan. The former "blind compile"
  stance is reframed as draft-from-sources-first, preserving the
  anti-anchoring rule (draft before reading existing wiki synthesis).
- **Skill slimming and portability**: stale references removed
  (`research`, `content-research-writer`, `/dev-research`), Claude-Code tool
  names replaced with portable wording, external-skill references qualified,
  curly punctuation normalized, and the older research skills trimmed of
  filler while preserving procedures, tables, and output formats.
- **README rework**: Markdown-files-on-disk framing, wiki index files,
  Gemini Notebook (formerly NotebookLM) grounding rationale, and tool-assembly
  credits.
- **Release-guard hardening**: `tests/test-contracts.sh` leakage scans fail
  closed with POSIX grep instead of passing vacuously when `rg` is absent.

No profile schema change: version-4 profiles remain valid, and installation
and upgrade contracts are unchanged from `0.3.0`.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh`
- `bash tests/test-release.sh`
- `swift test` in `skills/transcribe/tools/apple-speech`
- `git diff --check`

Rerun every command from the final clean, pushed release commit before
tagging. Record the exact commit and results below in the post-publication
follow-up commit.

## Release-note draft

`v0.4.0` tightens how research findings reach durable knowledge. Research
producers now propose named referents — people, organizations, products, and
concepts that the evidence establishes as substantive subjects — as
first-class rows in the artifact distribution plan, and `research-to-wiki`
honors disposition decisions approved upstream instead of re-deriving them at
compile time. The compile stance is now draft-from-sources-first: the compiler
still drafts from raw sources before reading existing wiki synthesis, then
compares for tensions and gaps.

The skills are also slimmed for cross-runtime portability: stale skill and
tool references are gone, wording is runtime-neutral for Claude Code and
Codex, and the README now leads with the plain-Markdown knowledge store and
Gemini Notebook grounding. Release leakage guards fail closed. Profiles and
installation are unchanged from `v0.3.0`.

## Publication checklist

- [ ] Commit the complete candidate and push `main`.
- [ ] Capture the final commit in the release-session evidence and rerun every
  verification command from that exact clean commit.
- [ ] Follow `RELEASING.md` to create and push the annotated `v0.4.0` tag.
- [ ] Build, sign, and locally verify the four release assets.
- [ ] Publish the GitHub release with the reviewed notes above.
- [ ] Redownload and verify the public assets.
- [ ] Record the final commit, release URL, and public-asset verification
  below in a post-publication follow-up commit.

## Publication record

Pending publication.

## Release status

Versions `0.1.0`, `0.2.0`, and `0.3.0` are published. `0.4.0` is the current
candidate.
