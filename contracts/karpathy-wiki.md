# Karpathy-wiki contract

## Topology

A knowledge root contains `raw/`, `wiki/`, `output/`, and `docs/`. A valid
profile resolves each configured directory beneath the canonicalized root.

## Curated compilation

Humans select a coherent raw-source subset. `research-to-wiki` compiles only
that subset, never a backlog sweep. A selected-subset manifest records each
source's root-relative path, original provenance, and requested disposition.
Reports are not raw compiler input. Sources marked `compile_exclude` are
excluded; `compile_mode: update` requires its targeted update workflow.

The compiler reads selected raw sources before existing wiki synthesis. After a
blind draft, it compares the closest existing articles and records actual
tensions or gaps rather than silently merging incompatible assertions. It uses
root-relative `sources:` paths, maintains affected topic indexes and the master
index, and records the final source disposition only after the result is known.

## Audit

`wiki-audit` is read-only. It records its scope and reports missing pages,
atomicity/collision candidates, link and source coverage, tensions, and gaps.
It cannot modify articles, raw sources, frontmatter, indexes, or operation logs.
