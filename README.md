# research-tools

Portable research-to-knowledge skills for Agent Skills-compatible clients.

Inspired by [Andrej Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

The package supports durable research, explicit artifact disposition, curated Karpathy-wiki compilation, read-only audit, and runtime-detected optional Firecrawl and local Apple Speech integrations. Its canonical knowledge-root shape is `raw/`, `wiki/`, `output/`, and `docs/`; configure the root and local policy with `profiles/karpathy-wiki.example.md`.

## Local release-candidate verification

This checkout is not a published release. For an isolated local verification:

```bash
bash tests/test-contracts.sh
bash tests/test-install.sh
cd skills/transcribe/tools/apple-speech && swift test
```

Before installing, copy `profiles/karpathy-wiki.example.md` to
`~/.config/research-tools/profile.md`, set `knowledge_root`, and create the
canonical directories and declared state files. `install.sh` validates that
profile before changing any release or skill link. It then copies the package
to immutable per-user release storage and links skills through a stable
`~/.local/share/research-tools/current` pointer. It refuses to overwrite a
foreign skill link.

For published-release upgrades, see [MIGRATION.md](MIGRATION.md).

## Published-release installation

Each published GitHub Release will provide four matching assets: the versioned
archive, its SHA-256 file, a detached signature for that checksum file, and
the maintainer public key. Verify and install from local copies of the archive
and public key:

```bash
bash scripts/install-release.sh research-tools-<version>.tar.gz research-tools-release.asc <maintainer-fingerprint>
```

Obtain the maintainer fingerprint from an independent, maintainer-controlled
channel before downloading release assets; do not accept a fingerprint supplied
only alongside the archive. The installer imports the supplied public key into
a temporary keyring, requires its fingerprint to match that value, verifies the
detached signature and checksum, extracts the signed payload, and then runs its
installer. It writes an immutable per-version release tree under
`~/.local/share/research-tools/releases/` and links its skills into both Claude
and Codex. A repeated install of the same content is safe; a same-version,
different-content collision fails.

The current release-signing public key is
[`keys/research-tools-release.asc`](keys/research-tools-release.asc). Its
fingerprint is `09674AFF392661238F4ACBD9F32B3A412CD5EFC5`.
