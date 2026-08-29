# Release candidate review

## Scope

`0.4.2` release of the research and knowledge system. It makes two additions to
the shared research artifact contract — a required search record and an explicit
execution route on every decision — and turns the Reddit reader from a
Safari-specific helper into a route contract that local policy can satisfy any
number of ways.

## Included

- **Search record**: a new required artifact section recording what was searched
  beyond the supplied sources and how each result was used. Searches that
  returned nothing are evidence and must state how the negative was verified,
  and the section distinguishes "searched directly and absent" from "absent from
  indirect search" because the two carry different confidence. Channels left
  unsearched — because the runtime is blocked from them or the cost exceeded the
  stakes — are recorded rather than omitted.
- **Execution route on the decision surface**: every decision states
  `Executes as: task filed — another session runs it` or
  `Executes as: inline by research-absorb on approval`. Act decisions default to
  a filed task and Keep decisions to inline execution; when an Act item is small
  enough that inline execution is tempting, the choice becomes an explicit
  option inside the decision instead of a silent judgment call. The execution
  appendix still carries the mechanics, but the route the user approves now
  appears on the surface they judge.
- **Blocked-channel routes**: local policy may name alternate retrieval paths
  for channels the primary runtime cannot reach. The Reddit reader is now
  specified as a route — load the thread in the user's signed-in browser,
  extract the rendered text — with the bundled Safari helper as the reference
  implementation. A runtime's own browser-automation tool, another browser's
  scripting interface, or delegating the read to an agent runtime with access
  are equally valid when local policy names them. `research-sources`,
  `research-quick`, and `research-feedback` consult local policy for such a
  route before accepting reduced coverage.
- **Documentation alignment**: the README's artifact-structure diagram and the
  `research-sources` section list both name the search record.

No profile schema change and no installation or upgrade change: version-4
profiles remain valid, artifacts written against `0.4.1` remain readable, and
every `0.4.1` consumer upgrades with no migration.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh`
- `bash tests/test-release.sh`
- `swift test` in `skills/transcribe/tools/apple-speech`
- `git diff --check`

On 2026-08-29, all three shell suites, the five Apple Speech tests, and
`git diff --check` passed from the clean, pushed release commit
`2496c0ff7dfcb10b97b2367b15b5101398d074fe` before tagging.

## Release-note draft

`v0.4.2` adds two required elements to the research artifact contract and
generalizes how research reaches channels a runtime is blocked from.

Artifacts now carry a **search record**: what was searched beyond the supplied
sources, how each result was used, and which channels were skipped and why. A
search that returns nothing is treated as evidence and has to say how the
negative was verified, and the record separates "searched directly and absent"
from "absent from indirect search" because those support different conclusions.

Every decision now states its **execution route** on the decision surface
itself — a filed task another session runs, or inline execution by
`research-absorb` on approval. Act decisions default to a task and Keep
decisions to inline; when inline execution of an Act item is tempting, that
becomes a stated option rather than a silent choice.

Reading login-walled community threads is now defined as a **route**, not a
tool: load the thread in the user's signed-in browser and extract the rendered
text. The bundled Safari helper is the reference implementation of that route;
a runtime's browser-automation tool, another browser's scripting interface, or
delegating the read to an agent runtime with access are equally valid when the
profile's local policy names them. The research skills consult local policy for
such a route before settling for snippet-level coverage.

Profiles, installation, and upgrade are unchanged from `0.4.1`.

## Publication checklist

- [x] Commit the complete candidate and push `main`.
- [x] Capture the final commit in the release-session evidence and rerun every
  verification command from that exact clean commit.
- [x] Follow `RELEASING.md` to create and push the annotated `v0.4.2` tag.
- [x] Build, sign, and locally verify the four release assets.
- [x] Publish the GitHub release with the reviewed notes above.
- [x] Redownload and verify the public assets.
- [x] Record the final commit, release URL, and public-asset verification
  below in a post-publication follow-up commit.

## Publication record

- Target commit: `2496c0ff7dfcb10b97b2367b15b5101398d074fe`
- Tag: annotated `v0.4.2`, resolving to the target commit above
- Release URL:
  <https://github.com/coreyfloyd/research-tools/releases/tag/v0.4.2>
- Published asset verification: completed 2026-08-29; all four expected assets
  were downloaded, the public key byte-matched the repository key, the detached
  signature and SHA-256 checksum passed verification, and the extracted archive
  compared equal to `git archive v0.4.2`.
- Build note: the archive was built from a detached worktree checked out at the
  tag and written to an output directory outside the packaged tree, so the
  published payload matches the tagged commit exactly and no build output is
  packaged into the archive. See the release-integrity follow-up filed against
  `scripts/build-release.sh`.

## Release status

Versions `0.1.0` through `0.4.2` are published. The `v0.4.2` public assets
were downloaded and verified after publication.
