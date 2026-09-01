# Releasing research-tools

This is the public, version-coupled maintainer runbook for producing a
`research-tools` GitHub release. Version-specific scope, evidence, release
notes, and publication results belong in `RELEASE_CANDIDATE.md`.

## Release contract

A release uses the version in `VERSION` and publishes:

```text
tag and title: v<version>

research-tools-<version>.tar.gz
research-tools-<version>.tar.gz.sha256
research-tools-<version>.tar.gz.asc
research-tools-release.asc
```

The checksum is signed, not the archive directly. The expected public signing
fingerprint is stored in `RELEASE_SIGNING_FINGERPRINT`; the matching public key
is `keys/research-tools-release.asc`. Never replace that public key as part of a
routine release. Key rotation requires a separately reviewed transition.

## Signing is a manual maintainer step

**The maintainer signs. An agent must never attempt it.** Signing is the one
step in this runbook that is not delegable: it is what binds a human decision to
the published artifact, and an agent that could sign unattended would remove that
binding.

An agent running this runbook stops at the build-and-sign step, hands the exact
command to the maintainer, and resumes at verification once the signed assets
exist. This is a deliberate gate, not an environment limitation to work around.
Do not attempt `gpg --pinentry-mode loopback`, do not pipe a passphrase from a
file or environment variable, and do not propose installing a GUI pinentry so the
prompt can be answered from an agent session. Every one of those defeats the
gate.

Mechanically, the signing key's passphrase is held by a TTY-bound pinentry, so an
agent session has no path to it and the attempt fails with
`gpg: signing failed: Inappropriate ioctl for device`. Treat that message as the
gate working, not as a problem to solve.

## Prerequisites

- Run from the repository root on a trusted machine with the release secret key
  available through GnuPG and an interactive pinentry path.
- Authenticate the intended GitHub account with `gh`.
- Install Bash, GnuPG, GitHub CLI, Python 3, Swift, and the standard macOS
  `shasum` utility.
- Review `RELEASE_CANDIDATE.md` and prepare its release-note draft.
- Ensure every intended change is committed. The archive builder packages the
  working tree, including untracked files not covered by its exclusions, so a
  clean tree is a release-integrity requirement.

Check the environment without changing remote state:

```bash
test "$(git branch --show-current)" = main
test -z "$(git status --short)"
git fetch origin main --tags
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"

VERSION_VALUE="$(tr -d '[:space:]' < VERSION)"
TAG="v$VERSION_VALUE"
COMMIT="$(git rev-parse HEAD)"
FINGERPRINT="$(tr -d '[:space:]' < RELEASE_SIGNING_FINGERPRINT)"

test -n "$VERSION_VALUE"
test -n "$FINGERPRINT"
if git rev-parse --verify --quiet "refs/tags/$TAG"; then
  echo "local tag already exists: $TAG" >&2
  exit 1
fi
test -z "$(git ls-remote --tags origin "refs/tags/$TAG" "refs/tags/$TAG^{}")"
gpg --list-secret-keys "$FINGERPRINT"
gh auth status
printf 'VERSION=%s\nTAG=%s\nCOMMIT=%s\n' "$VERSION_VALUE" "$TAG" "$COMMIT"
```

## Verify the candidate

Run all checks against the exact commit intended for release:

```bash
git diff --check
bash tests/test-contracts.sh
bash tests/test-install.sh
bash tests/test-release.sh
(
  cd skills/transcribe/tools/apple-speech
  swift test
)
```

Capture the commit and results in the release-session evidence. A commit cannot
contain its own SHA, so write the final commit into `RELEASE_CANDIDATE.md` only
in the post-publication follow-up commit. If any tracked content changes before
tagging, commit and push it, then rerun the checks against the new commit.

## Sweep the documentation before tagging

The test suites verify behavior. They verify nothing about whether the prose
still describes it. The `0.5.0` release turned up four documentation defects
with every suite green: a README section list naming sections the contract had
renamed, a compatibility section claiming one break when there were two, a
README that documented one deliverable's structure in full and left two others
to a prose sentence, and a release-note draft contradicting the compatibility
section beside it.

Only the first was caught before tagging. The structural-parity defect cost a
tag deletion and a second signing round from the maintainer; the other two were
caught late enough to be luck rather than process. Each was findable by reading
the documentation against the diff, which is what this step is.

Run this sweep against the candidate commit, before pushing the tag. It is a
required step, not a courtesy pass.

**Sweep mechanically; do not re-read.** Re-reading a document finds what you
expect it to say. Extract each claim-bearing construct and check it against
the source of truth.

1. **Renamed or removed identifiers.** For every section name, field name, or
   term the release changes, grep the whole tree for the *old* name. A hit
   outside `RELEASE_CANDIDATE.md` is drift; a hit inside it is usually
   deliberate history, so read it rather than assuming either way.

   ```bash
   git diff --stat "$(git describe --tags --abbrev=0 HEAD^)"..HEAD
   grep -rn -E '<old name>|<other old name>' --include='*.md' .
   ```

2. **Counting and absolute claims.** Grep for `never`, `always`, `only`, `all`,
   `cannot`, `unique`, and number words, then check each against what the
   release actually does. "One break" was wrong the moment a second one landed.

   ```bash
   grep -rn -E '\b(one|two|three|only|never|always|all|cannot|unique)\b' \
     README.md RELEASE_CANDIDATE.md
   ```

3. **Internal agreement within `RELEASE_CANDIDATE.md`.** Scope, Included,
   Compatibility, and the release-note draft each restate the same facts for a
   different audience. Read them against each other, not in sequence — the
   draft is published verbatim, so a contradiction there ships.

4. **Structural parity.** When the release changes what a skill produces, check
   that the README documents the new shape at the same depth as the shapes
   already there. A prose sentence beside a full section diagram reads as an
   afterthought and hides the change the release exists to make.

5. **Stale links and paths.** Confirm every relative link still resolves after
   any file moves in this release.

   ```bash
   grep -rn -oE '\]\([^)#][^)]*\)' README.md | sed 's/.*(\(.*\))/\1/' \
     | grep -v '^http' | while read -r f; do test -e "$f" || echo "missing: $f"; done
   ```

Fix anything the sweep finds, commit, push, and rerun both the suites and this
sweep against the new commit. The sweep is cheap before the tag exists and
expensive afterward: a tag that has been published cannot move, and one that
has not still costs a deletion and another signing round from the maintainer.

## Push and tag the exact commit

Push `main` first and confirm the remote branch resolves to the same commit:

```bash
git push origin main
COMMIT="$(git rev-parse HEAD)"
test "$(git ls-remote origin refs/heads/main | awk '{print $1}')" = "$COMMIT"

VERSION_VALUE="$(tr -d '[:space:]' < VERSION)"
TAG="v$VERSION_VALUE"
git tag -a "$TAG" "$COMMIT" -m "research-tools $VERSION_VALUE"
git push origin "$TAG"
```

Annotated tags have both a tag-object identity and a peeled commit identity.
Verify the peeled remote tag rather than comparing the tag-object SHA to the
commit SHA:

```bash
test "$(git rev-list -n 1 "$TAG")" = "$COMMIT"
REMOTE_TAG_COMMIT="$(git ls-remote origin "refs/tags/$TAG^{}" | awk '{print $1}')"
test "$REMOTE_TAG_COMMIT" = "$COMMIT"
```

Do not move or force-push a published release tag. A wrong tag is a
release-integrity incident requiring an explicit maintainer decision.

## Build, sign, and verify

Build only after the clean checkout, pushed commit, and remote tag agree.

**Maintainer runs this step** — it signs, and per the signing gate above an agent
must not run it. Run it from an interactive terminal so pinentry can prompt:

```bash
export GPG_TTY="$(tty)"
FINGERPRINT="$(tr -d '[:space:]' < RELEASE_SIGNING_FINGERPRINT)"
RESEARCH_TOOLS_GPG_KEY="$FINGERPRINT" bash scripts/build-release.sh dist
```

An agent driving the release stops here, hands the maintainer the command above,
and waits for the three `dist/` files to exist before continuing. Everything from
verification onward is agent-safe:

```bash
VERSION_VALUE="$(tr -d '[:space:]' < VERSION)"
FINGERPRINT="$(tr -d '[:space:]' < RELEASE_SIGNING_FINGERPRINT)"
bash scripts/verify-release.sh \
  "dist/research-tools-$VERSION_VALUE.tar.gz" \
  keys/research-tools-release.asc \
  "$FINGERPRINT"
```

Review the four exact upload paths before publication:

```bash
ls -l \
  "dist/research-tools-$VERSION_VALUE.tar.gz" \
  "dist/research-tools-$VERSION_VALUE.tar.gz.sha256" \
  "dist/research-tools-$VERSION_VALUE.tar.gz.asc" \
  keys/research-tools-release.asc
```

The current scripts prove archive integrity and signer identity. They do not
embed or independently attest the source commit; the clean, exact-tag checkout
checks above are therefore part of the release contract.

## Publish on GitHub

Write reviewed release notes to a temporary or ignored file, using the draft in
`RELEASE_CANDIDATE.md` as the source. Create the release only for the
already-pushed tag:

```bash
gh release create "$TAG" \
  "dist/research-tools-$VERSION_VALUE.tar.gz" \
  "dist/research-tools-$VERSION_VALUE.tar.gz.sha256" \
  "dist/research-tools-$VERSION_VALUE.tar.gz.asc" \
  keys/research-tools-release.asc \
  --title "$TAG" \
  --notes-file /path/to/reviewed-release-notes.md
```

Routine releases are public, not drafts, and not prereleases. If a staged draft
is desired, make that an explicit release decision rather than assuming the
historical releases used one.

## Verify the published release

Download the public assets into a new temporary directory and verify the same
contract consumers receive:

```bash
VERIFY_DIR="$(mktemp -d)"
gh release download "$TAG" --dir "$VERIFY_DIR"

test "$(find "$VERIFY_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')" = 4
cmp "$VERIFY_DIR/research-tools-release.asc" keys/research-tools-release.asc
bash scripts/verify-release.sh \
  "$VERIFY_DIR/research-tools-$VERSION_VALUE.tar.gz" \
  "$VERIFY_DIR/research-tools-release.asc" \
  "$FINGERPRINT"

gh release view "$TAG" \
  --json tagName,isDraft,isPrerelease,publishedAt,url,assets
```

Record the tag, commit, release URL, asset inventory, and verification result in
`RELEASE_CANDIDATE.md` as a post-publication follow-up commit. The temporary
verification directory may then be removed.

## Failure and recovery

Stop on any mismatch. Inspect the remote tag target, release metadata, asset
names, and checksums before changing remote state.

- Never force-push or silently replace a published tag.
- Do not assume uploading an identically named asset overwrites it.
- Preserve evidence for an incomplete or incorrect release before deciding
  whether to upload a missing asset or delete and recreate the release.
- Never replace `research-tools-release.asc` without an intentional,
  documented key rotation.
- After recovery, redownload and repeat the complete public-asset verification.

Historical `v0.1.0` and `v0.2.0` tags are lightweight. New releases use the
annotated-tag procedure above; the different historical form does not justify
rewriting old tags.
