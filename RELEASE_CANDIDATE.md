# Release candidate review

## Scope

`0.3.0` release of the research and knowledge system. It adds a guided,
approval-gated setup workflow; permits the complete package to be installed
before local configuration exists; documents how the skills, knowledge store,
dependencies, installation, and release process fit together; and retains the
portable workflow-state and safe package-upgrade contracts developed for this
candidate.

## Included

- Twelve portable skills, including the new `research-tools-set-up`,
  `research-to-wiki`, and `wiki-audit`.
- A guided setup conversation that explains the system, elicits the knowledge
  root, independent follow-up routes, and local policy, then shows the complete
  mutation plan before writing.
- An install-before-configure bootstrap: the complete package, active profile
  template, and validator install without a profile; `install.sh --verify`
  remains the package-integrity and configuration-readiness gate.
- Persistent-writing skills stop and route to `research-tools-set-up` when the
  profile is missing or invalid instead of selecting a fallback location.
- Expanded README plus a separate `INSTALLATION.md`, with Obsidian identified
  as optional and third-party NotebookLM/YouTube tooling credited explicitly.
- `RELEASING.md` as the durable public release runbook; this file now owns only
  the `0.3.0` candidate state and evidence.
- Public Karpathy-wiki contract and profile template.
- Bundled macOS Apple Speech transcription package.
- Apache-2.0 license.
- Verified release archive path: GPG detached signature + SHA-256, archive
  extraction, then installation into immutable versioned user storage.
- Profile validator enforcing version 4, an absolute existing knowledge root,
  canonical raw/wiki/output/docs directories contained beneath it, and declared
  session-cache, operation-log, and decision-log files.
- Public upgrade contract preserving matching Claude/Codex stable-current
  release links while allowing configuration to happen after installation;
  legacy dotfiles migration stays private.
- Deterministic transcription launcher and build-artifact-free release staging.
- Concurrent installer serialization with a bounded 30-second lock wait.
- Relative-content manifests: repeat installation from separately extracted,
  identical signed archives succeeds; installed-content tampering fails
  `install.sh --verify`.
- Signing-key pinning: archive verification requires an independently known
  maintainer fingerprint and rejects an otherwise valid archive signed by a
  different key.
- Strict version-4 profile schema with canonical zones and no inert capability
  declarations.
- A free-form profile body for source routing, output policy, taxonomy, and
  local entry formats; portable YAML remains the validated profile contract.
- A Karpathy-wiki workflow contract: topic folders are optional navigation,
  wikilinks are a Markdown convention rather than an application dependency,
  every installation declares session cache/log/decision plus separate wiki
  maintenance and research-artifact follow-up routing, and the package credits
  the original LLM Wiki gist.
- Atomic package-owned current-pointer upgrades, while preserving collision
  refusal for all non-package skill links.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh` (clean install, repeat install, concurrent
  install, package-owned upgrade, runtime closure, tamper detection,
  non-mutating foreign-link collision, and profile validation)
- `bash tests/test-release.sh` (temporary-key signature and checksum verification,
  maintainer-fingerprint pinning, repeated verified-archive installation from
  separate extractions, and tamper rejection)
- `swift test` in `skills/transcribe/tools/apple-speech` (5 tests)
- `git diff --check`

On 2026-08-27, the three shell suites, five Apple Speech tests, and
`research-tools-set-up` skill validation passed against the working candidate.
These checks must be rerun from the final clean, pushed release commit before
tagging because the candidate has not yet reached that state.

## Independent review

Round 1: 1 Fatal, 4 Significant, 2 Minor. Fixed runtime contract staging,
helper path, undeclared private policy dependencies, and release path checks.

Round 2: 0 Fatal, 4 Significant, 2 Minor. Fixed preflight-before-mutation,
same-version content manifest failure, installed transcription path guidance,
and transcript YAML control-character escaping. Subsequent hardening added the
verified archive path, profile validation, migration contract, and remaining
portable audit cleanup; those changes have local regression coverage.

Round 3: 1 Fatal, 1 Significant, 1 Minor. The independent review rejected an
unanchored signing-key path, permissive profile schema, non-executable
migration contract, and source-checkout test artifact. The candidate now pins
the expected signer fingerprint, validates the declared profile schema,
provides migration contract verification fixtures, and isolates that test.

Round 4: the signer pinning initially accepted a multi-key keyring if the
expected key appeared first. It now binds GPG's `VALIDSIG` primary signer
fingerprint to the expected fingerprint; an independent re-review passed the
two-key attacker-signature regression.

Round 5: the isolated runtime evaluator could not start `gpg-agent` and
escalated for an evaluator-sandbox capability mismatch rather than a repository
finding. The signed-release suite subsequently passed directly in the capable
MacBook environment, along with the remaining required suites.

## Release-note draft

`v0.3.0` makes research-tools understandable and configurable as a complete
system. It adds the `research-tools-set-up` skill for a guided, approval-gated
configuration conversation; installs the full package before configuration so
that skill is available on first use; and keeps `install.sh --verify` as the
readiness gate.

The release also expands the workflow documentation, separates installation
and configuration into `INSTALLATION.md`, clarifies the AI-maintained knowledge
store and optional Obsidian client, and explicitly credits the third-party
NotebookLM and YouTube tooling used by optional integrations.

## Publication checklist

- [ ] Resolve all untracked release-input files and make `git status --short`
  empty; the archive builder includes untracked files outside its exclusions.
- [ ] Make `git diff --check` pass, including the current README whitespace.
- [ ] Commit the complete candidate and push `main`.
- [ ] Record the final commit below and rerun every verification command from
  that exact clean commit.
- [ ] Follow `RELEASING.md` to create and push the annotated `v0.3.0` tag.
- [ ] Build, sign, and locally verify the four release assets.
- [ ] Publish the GitHub release with the reviewed notes above.
- [ ] Redownload and verify the public assets.

## Publication record

- Target commit: pending
- Tag: `v0.3.0` (pending)
- Release URL: pending
- Published asset verification: pending

## Release status

Versions `0.1.0` and `0.2.0` are published. `0.3.0` is not yet ready to publish:
the working tree must be cleaned, committed, pushed, and reverified from its
final release commit before tagging.
