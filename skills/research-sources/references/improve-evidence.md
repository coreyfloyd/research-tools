# Improve evidence procedure

Use this procedure only for the **Improve evidence** mode of `research-sources`.

## Diagnose the gap

Start with the supplied source or collection. Identify the unsupported claim, missing primary account, unresolved contradiction, or missing perspective. Extract vendor names, paper or post titles, repository names, distinctive technical phrases, and disambiguation terms. The discovery question must name the gap it is meant to close.

## Discover with NotebookLM

Create a temporary notebook for discovery. Run NotebookLM deep research with the gap-specific query, wait for it to finish, then inspect the resulting sources. Use explicit notebook IDs in headless or parallel work.

`IMPORT_RESEARCH` may report a timeout after the research completes. Treat it as a warning, not proof of failure: list the notebook sources before retrying.

Preserve the relevance ordering reported by the deep-research result. Do not replace it with an alphabetical source list. Review the useful leading set and discard long-tail noise unless the caller requests broader coverage.

## Categorize candidates

Classify each candidate before adding it to the evidence set:

| Category | Meaning |
|---|---|
| PRIMARY | Official vendor material, an original paper, official documentation, a vendor repository, or an authoritative primary record. |
| SECONDARY | Substantive analysis from a known expert or reputable technical publication. |
| DERIVATIVE | Rehashes, generic introductions, listicles, or commentary that adds no useful evidence. |
| OFF-TOPIC | A semantic or brand collision unrelated to the stated gap. |
| BROKEN | Missing URL, inaccessible content, or a source that cannot be inspected. |

Default to PRIMARY when selecting sources to add. Include SECONDARY only when it supplies needed interpretation or context; retain remaining categories in the artifact evidence record without treating them as support.

## Resume the requested work

Add selected sources to the analysis notebook with original provenance. Record the gap each one closes, then resume the analysis or target-update proposal. Delete temporary discovery notebooks when their provenance is captured and they are no longer needed.

Do not archive discovered material, modify a target, or promote knowledge as a side effect of evidence improvement. Those actions remain approval-gated.
