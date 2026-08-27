---
name: knowledge-capture
description: Review sources, synthesized findings, and artifacts from the current conversation; propose their complete durable disposition. Use when a user asks to capture knowledge, save research, or add selected material to a configured knowledge base.
---

# Knowledge Capture

Turn conversation knowledge into an explicit, complete disposition. Read `~/.config/research-tools/profile.md` before proposing any follow-up task: cross-project work uses `artifact_followup_destination`, not the wiki-maintenance route. This skill owns only knowledge preservation and routing; `record-update` owns work records and `harness-improve` owns lessons about the harness. A durable research artifact is processed by `research-absorb`, not by this session-capture workflow.

## Procedure

1. Inventory external sources, synthesized claims, and generated outputs from the conversation.
2. Classify each: discard; retain in `output/`; capture external provenance in `raw/research/`; preserve a reusable synthesis in `raw/derived/`; or compile into wiki knowledge.
3. Reconcile those items with the conversation's decisions and existing knowledge. Present one approval table. Every wiki recommendation is a complete action: capture required provenance **and run `research-to-wiki`**. Never stop at raw staging. A proposed cross-project follow-up names `artifact_followup_destination`.
4. After explicit approval, perform the approved captures and dispatch potentially lengthy `research-to-wiki` work headlessly. Report articles created/updated and the final disposition of every item.

## Boundaries

- Do not create tickets, update project status, or propose harness/rule changes; route those observations to their owners.
- Do not auto-promote. Approval is required before any capture or compile.
- Do not absorb a research artifact here; route it to `research-absorb`, which owns its approval gate and deletion.
