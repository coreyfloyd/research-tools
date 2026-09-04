# Release candidate review

## Scope

`0.7.0` release of the research and knowledge system. It makes the answer an
explicit, required part of every research artifact, ships a complete example
artifact, and reframes the public documentation around the Question, Answer,
Action lifecycle.

## Included

- **Answer subsection in the artifact contract**: section 1, Question and
  Scope, now requires two subsections in order. `### Question` states the
  decision, target, or question, gives short codes when there are three or
  more, and names scope and what is out of scope. `### Answer` gives one entry
  per question with the answer first, followed by a **Confidence** line
  stating what the answer rests on and a **What would change the answer** line
  naming the evidence that would flip it. When the evidence supports no
  answer, the subsection says so and points to the Evidence Gaps row that
  would close it. The Answer must be readable without opening any later
  section, and the sizing rule keeps it short.
- **Example artifact**: `docs/examples/2026-09-03-fable-5-1-model-routing.md`
  is a complete artifact in the new shape, sanitized from a real session. The
  contract and the README both link to it.
- **README reframed around Question, Answer, Action**: the opening explains
  the lifecycle the system exists to close, with a diagram, and the artifact
  structure tree shows the two new subsections at the same depth as the seven
  sections.
- **Supported platforms and prerequisites**: INSTALLATION states macOS and
  Linux support, names WSL as the Windows route, and lists the packages each
  install route needs on macOS, Debian or Ubuntu, and Fedora.
- **Presentation deck**: `docs/presentation.html` is the meetup talk on the
  Question, Answer, Action lifecycle.

## Compatibility

Profiles are unchanged. Every profile that validated under `0.6.0` validates
under `0.7.0` with the same result. The profile version stays 4.

Installation and upgrade are unchanged. The release carries the same six
assets as `v0.6.0`.

One consumer-visible change to research artifacts: section 1 now requires the
`### Question` and `### Answer` subsections. The seven-section list is
unchanged, and `research-absorb` validates the absorption plan and its
execution rows, which the change does not touch, so an artifact written under
`0.6.0` remains valid input; only new artifacts carry the two subsections.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh`
- `bash tests/test-release.sh`
- `swift test` in `skills/transcribe/tools/apple-speech`
- `git diff --check`

On 2026-09-04, all three shell suites, the five Apple Speech tests, and
`git diff --check` passed from the clean, pushed release commit
`52d9384cfd3414c5011188c3fee3f6e3e794447a` before tagging.

## Release-note draft

`v0.7.0` makes the answer a required, visible part of every research artifact.
Section 1 now has a `### Question` subsection and a `### Answer` subsection.
The Answer gives one entry per question with the answer first, then a
Confidence line stating what it rests on and a What-would-change-the-answer
line naming the evidence that would flip it. When the evidence supports no
answer, the artifact says so and points at the gap that would close it. The
Answer is the first thing you judge, and it reads without the sections below.

A complete example artifact in this shape, sanitized from a real research
session, ships at `docs/examples/2026-09-03-fable-5-1-model-routing.md` and is
linked from the contract and the README.

The README now opens with the lifecycle the system exists to close: a
question moves through a grounded answer to an explicit action. INSTALLATION
states the supported platforms and lists the prerequisite packages for each
install route on macOS, Debian or Ubuntu, and Fedora. The meetup presentation
on the lifecycle is in `docs/`.

Profiles and installation are unchanged. Artifacts written under `0.6.0`
remain valid input to `research-absorb`.

## Publication checklist

- [x] Commit the complete candidate and push `main`.
- [x] Capture the final commit in the release-session evidence and rerun every
  verification command from that exact clean commit.
- [x] Follow `RELEASING.md` to create and push the annotated `v0.7.0` tag.
- [x] Build, sign, and locally verify the six release assets.
- [x] Publish the GitHub release with the reviewed notes above.
- [x] Redownload and verify the public assets.
- [x] Record the final commit, release URL, and public-asset verification
  below in a post-publication follow-up commit.

## Publication record

- Target commit: `52d9384cfd3414c5011188c3fee3f6e3e794447a`
- Tag: annotated `v0.7.0`, resolving to the target commit above
- Release URL:
  <https://github.com/coreyfloyd/research-tools/releases/tag/v0.7.0>
- Published asset verification: completed 2026-09-04; all six expected assets
  were downloaded, the public key and both scripts byte-matched the repository
  copies, the detached signature and SHA-256 checksum passed verification, and
  the downloaded archive compared equal to the locally built one.

## Release status

Versions `0.1.0` through `0.7.0` are published. The `v0.7.0` public assets
were downloaded and verified after publication.
