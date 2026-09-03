# Release candidate review

## Scope

`0.6.0` release of the research and knowledge system. It makes the compiled
wiki optional to configure and to use, hardens the release build and install
path, and tightens the layout rule for absorption items in the research
artifact.

## Included

- **Optional wiki**: setup describes the wiki and the no-wiki alternative in
  neutral terms and asks the user to choose. A user who declines gets a
  knowledge root with `raw/`, `output/`, and `docs/` only, a profile that
  validates without `hot_file` or `wiki_followup_destination`, absorption plans
  and captures with no Wiki Additions class and no raw provenance staging, and
  a clear refusal from `research-to-wiki` and `wiki-audit` that points back to
  `research-tools-set-up`. The wiki can be enabled or disabled later through
  the same setup conversation; disabling never deletes an existing `wiki/`.
- **`wiki_enabled` profile field**: optional, lowercase `true` or `false`,
  absent means enabled. When `false`, either wiki-only field being present is a
  validation error, including a key left in place with its value emptied, so
  an accidental edit fails loudly instead of silently changing mode. The
  validator accepts full-line `#` comments in the frontmatter so the example
  profile can ship the disable line commented out.
- **`validate_profile.py --require-wiki`**: the two wiki skills validate with
  this flag and relay its refusal verbatim. Every other skill validates without
  it and is unaffected by the wiki state.
- **Release archive built from git**: `scripts/build-release.sh` packages the
  tree at `HEAD` with `git archive`, refuses a dirty tracked tree, and refuses
  when a `v<VERSION>` tag exists that `HEAD` is not. Untracked files can never
  be packaged.
- **Manifest ignores Finder droppings**: the release manifest excludes
  `.DS_Store` and `.Ulysses-*`, every stored-manifest check goes through one
  predicate, and manifests written by releases before this rule migrate
  instead of colliding.
- **Install and verify scripts as release assets**: `install-release.sh` and
  `verify-release.sh` are published unmodified alongside the four existing
  assets, so a release can be installed and verified from the published assets
  alone. `verify-release.sh` names a missing `gpg`, `shasum`, or `tar` before
  verifying.
- **Install preflight**: `install.sh` checks for `python3` up front, names the
  specific `--verify` check that failed, and states the remedy in each refusal.
- **Absorption item layout**: each item in a research artifact is a level-4
  heading naming the literal target path over a two-column `Field | Detail`
  table. The path never sits inside the table, because a long path in a header
  cell squeezes the field column.
- **Documentation alignment**: the Karpathy-wiki contract, README,
  INSTALLATION, and MIGRATION describe `raw/`, `output/`, and `docs/` as
  always present and `wiki/` plus its two profile fields as present only when
  the wiki is enabled. `MIGRATION.md`'s profile block is corrected.

## Compatibility

Existing version-4 profiles need no change. An absent `wiki_enabled` field
means the wiki stays enabled exactly as before, and every profile that
validated under `0.5.0` validates under `0.6.0` with the same result. The
profile version stays 4.

Installation and upgrade are unchanged for a repository clone. Published
releases through `v0.5.0` carry four assets and no install or verify script;
`v0.6.0` is the first release carrying all six, so it is the first that can be
installed from published assets alone.

One consumer-visible change to research artifacts: the absorption item layout
moved the target path from the table header to a heading above the table. An
artifact written under `0.5.0` still carries every field `research-absorb`
reads, so in-flight artifacts remain valid input; only new artifacts use the
new layout.

## Verification

- `bash tests/test-contracts.sh`
- `bash tests/test-install.sh`
- `bash tests/test-release.sh`
- `swift test` in `skills/transcribe/tools/apple-speech`
- `git diff --check`

Results are recorded in the publication record below against the exact
release commit.

## Release-note draft

`v0.6.0` makes the wiki optional. Setup now explains the compiled knowledge
base and the report-and-absorb workflow without it, and asks which you want.
Decline, and your knowledge root has `raw/`, `output/`, and `docs/` only, your
profile needs neither wiki field, absorption plans carry no Wiki Additions and
stage nothing into `raw/`, and `research-to-wiki` and `wiki-audit` refuse with
a pointer back to setup. Change your mind later and setup enables it, asking
only the wiki questions. Disabling never deletes an existing `wiki/`.

The switch is one optional profile field, `wiki_enabled`, which defaults to
enabled when absent. Setting it to `false` while leaving a wiki field in the
profile is a validation error, so an accidental edit fails instead of quietly
changing mode. Existing version-4 profiles need no change.

The release path is hardened. Archives are built from the git tree at `HEAD`,
never from the working directory, and the build refuses a dirty tree or a
mismatched tag. The release manifest ignores Finder droppings, and manifests
from earlier releases migrate. `install-release.sh` and `verify-release.sh`
are now published as release assets, so this is the first release that can be
installed and verified from the published assets alone. `install.sh` checks
for `python3` first and names the failing check and its remedy when it
refuses.

Research artifacts put each absorption item's target path in a heading above
its table instead of in the table header, which stops long paths from
squeezing the field column. Artifacts written under `0.5.0` remain valid
input to `research-absorb`.

## Publication checklist

- [ ] Commit the complete candidate and push `main`.
- [ ] Capture the final commit in the release-session evidence and rerun every
  verification command from that exact clean commit.
- [ ] Follow `RELEASING.md` to create and push the annotated `v0.6.0` tag.
- [ ] Build, sign, and locally verify the six release assets.
- [ ] Publish the GitHub release with the reviewed notes above.
- [ ] Redownload and verify the public assets.
- [ ] Record the final commit, release URL, and public-asset verification
  below in a post-publication follow-up commit.

## Publication record

Pending.

## Release status

Versions `0.1.0` through `0.5.0` are published. `0.6.0` is in preparation.
