# Rig Knowledgebase Operating Schema

This directory is the project's self-maintaining plain-Markdown knowledgebase. Raw sources are immutable inputs; wiki pages are maintained outputs. Root repository instructions still apply.

## Purpose

Preserve sources, decisions, and operating knowledge for a local control center
with one Managing Director seat and durable named generalist workers

## Audience

Aaron and the Managing Director seat

## Expected Source Types

shared-chat excerpts, essays, user design decisions

## Directory Contract

- `raw/`: immutable source files. Do not edit source content after ingest.
- `raw/assets/`: local attachments copied from sources when useful.
- `wiki/`: LLM-maintained Markdown pages.
- `wiki/index.md`: content-oriented catalog. Update after every material change.
- `wiki/log.md`: append-only chronological log. Do not rewrite prior entries.
- `wiki/sources/`
- `wiki/decisions/`
- `wiki/syntheses/`

## Link And Citation Style

Use standard Markdown links with relative paths. Cite source summaries and raw source paths where possible. Do not use Obsidian-only link syntax unless the user later changes this schema.

## Ingest Workflow

1. Resolve the source path and use the user's stated emphasis; ask only when needed.
2. Read the source from `raw/` or place a copy under `raw/` if the user supplied an external source.
3. Create or update a source summary under `wiki/sources/`.
4. Update relevant entity, topic, and synthesis pages.
5. Preserve contradictions and uncertainty explicitly.
6. Update `wiki/index.md`.
7. Append `## [YYYY-MM-DD] ingest | Source Title` to `wiki/log.md`.

## Query Workflow

1. Read `wiki/index.md`.
2. Search wiki pages with `rg`.
3. Read the relevant pages before answering.
4. Answer with citations to wiki pages and raw sources when available.
5. File useful project synthesis as already requested by Aaron, identifying proposals versus accepted decisions.

## Lint Workflow

Check for orphan pages, missing index entries, broken links, stale claims, contradictions, important concepts without pages, and source gaps. Append `## [YYYY-MM-DD] lint | Scope` to `wiki/log.md` after material lint passes.

## Project Conventions

- Use Beads for all task tracking and status. Keep task-specific findings with the bead; promote enduring explanations and decisions here.
- Use `bd remember` for short operational facts when explicitly requested; do not create MEMORY.md files.
- Cite title, author, URL, access date, and relevant section for web sources. Label excerpts and incomplete captures accurately.
- Distinguish user requirements, accepted decisions, proposals, source claims, and inference.
- Maintain one singleton Managing Director seat in root `md/`, with they/them
  pronouns by MD's expressed preference. Named generalist workers live under
  the compatibility `fleet/` path in project operating repositories. The historical
  instance branch remains until migration is validated. The core `main` branch
  contains no onboarded worker. Do not
  conflate the management seat, durable workers, or transient native subagents.
- Treat display name, stable routing slug, durable home, Codex session ID, tmux
  runtime, worktree, Beads actor, and notification channel as separate evidence
  states. Do not call a worker ready until required onboarding gates are proven
  or explicitly waived.
- A worker's Codex session ID identifies one resumable saved conversation, not
  the worker. Preserve shared decisions in the knowledgebase and task state in
  Beads rather than relying on a session transcript or worker-local files.
- Check relative links after material wiki changes and append the result to the log.

Initialized: 2026-09-05
