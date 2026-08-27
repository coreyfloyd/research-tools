# Release candidate review

## Scope

`0.3.0` release of the approved research-to-knowledge system. It formalizes
portable workflow state—session cache, operation history, decisions, and two
independent follow-up routes—with per-installation locations and supports safe
upgrades from a previous package-owned release without changing unrelated skill
links.

## Included

- Eleven portable skills, including `research-to-wiki` and `wiki-audit`.
- Public Karpathy-wiki contract and profile template.
- Bundled macOS Apple Speech transcription package.
- Apache-2.0 license.
- Verified release archive path: GPG detached signature + SHA-256, archive
  extraction, then installation into immutable versioned user storage.
- Profile validator enforcing version 3, an absolute existing knowledge root,
  existing raw/wiki/output/docs directories contained beneath it, and declared
  session-cache, operation-log, and decision-log files.
- Migration contract requiring exact legacy-target replacement and matching
  Claude/Codex immutable release links.
- Deterministic transcription launcher and build-artifact-free release staging.
- Concurrent installer serialization with a bounded 30-second lock wait.
- Relative-content manifests: repeat installation from separately extracted,
  identical signed archives succeeds; installed-content tampering fails
  `install.sh --verify`.
- Signing-key pinning: archive verification requires an independently known
  maintainer fingerprint and rejects an otherwise valid archive signed by a
  different key.
- Strict version-3 profile schema and a reusable, read-only migration-handoff
  verifier with exact-link and dual-client-convergence fixtures.
- A free-form profile body for source routing, output policy, taxonomy, and
  local entry formats; portable YAML remains the validated profile contract.
- A Karpathy-wiki workflow contract: topic folders are optional navigation,
  wikilinks are a Markdown convention rather than an application dependency,
  every installation declares session cache/log/decision plus separate wiki
  maintenance and research-artifact follow-up routing, and the package credits
  the original LLM Wiki gist.
- Package-owned release-link upgrades, while preserving collision refusal for
  all non-package skill links.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh` (clean install, repeat install, concurrent
  install, package-owned upgrade, runtime closure, tamper detection,
  non-mutating foreign-link collision, and profile validation)
- `bash tests/test-release.sh` (temporary-key signature and checksum verification,
  maintainer-fingerprint pinning, repeated verified-archive installation from
  separate extractions, and tamper rejection)
- `bash tests/test-migration-contract.sh` (exact legacy-link preflight,
  dual-client release convergence, and collision rejection)
- `swift test` in `skills/transcribe/tools/apple-speech` (5 tests)
- `git diff --check`

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

## Release status

Versions `0.1.0` and `0.2.0` are published. Publish `0.3.0` only after this
release's verification evidence has been reviewed.
