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

Build only after the clean checkout, pushed commit, and remote tag agree:

```bash
FINGERPRINT="$(tr -d '[:space:]' < RELEASE_SIGNING_FINGERPRINT)"
RESEARCH_TOOLS_GPG_KEY="$FINGERPRINT" bash scripts/build-release.sh dist

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
