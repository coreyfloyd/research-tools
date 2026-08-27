# Dotfiles migration contract

Do not run this migration against a live installation until the corresponding
dotfiles change has been reviewed.

The migration may replace only an extracted skill link whose existing target is
an exact legacy source recorded in the migration manifest. Any real directory,
broken link, or link to another source is a collision and must remain unchanged.
Both Claude and Codex must resolve every extracted skill to the same immutable
release directory after the handoff. A subsequent dotfiles installer run must
recognize package-owned links and skip them rather than relinking Codex to a
dotfiles source.

The dotfiles-side change owns the manifest and the behavior; this repository
only supplies the package release and the tests/contract it must satisfy.

Use `scripts/verify-migration-handoff.sh` with that private manifest before
changing links (`--preflight`) and after (`--verify`). The verifier is read-only:
it checks every manifest skill in both client directories, rejects collisions,
and confirms final convergence on the specified release directory.
