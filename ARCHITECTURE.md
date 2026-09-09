# Rig operating architecture

Status: accepted 2026-09-09.

Rig is a local, observable control center for one conversational management
seat and a standing team of durable, named, generalist workers. Aaron directs
Managing Director (MD). MD stays available for requirements and decisions,
delegates bounded execution through Beads, monitors workers, and validates
their results. Workers may use transient native subagents, but the named worker
remains accountable for the work.

## System map

```text
Aaron
  └── Managing Director (MD) — singleton seat
        ├── Nadia — durable named Worker
        │     ├── temporary explorer subagent
        │     └── temporary reviewer subagent
        └── another durable named Worker
              └── temporary task-specific subagents
```

Rig deliberately avoids a catalogue of permanent specialist roles. **MD** is
the sole seat and authority boundary. **Worker** is the generic execution
class. Electronics, software, research, writing, or another unfamiliar domain
is assignment context, not a reason to invent a new durable role. A worker
receives the sources, tools, skills, constraints, and acceptance criteria that
the current Bead requires.

## The state model

These identifiers and resources are related, but none substitutes for another:

| Concept | Meaning | Lifetime |
| --- | --- | --- |
| Display name | The unique human-facing address of a durable worker, such as Nadia | Until deliberate off-boarding or rename |
| Slug | Stable routing and filesystem key, such as `nadia`; not a separate persona or opaque worker UUID | Normally the worker's lifetime |
| Codex session ID | Codex's identifier for one saved, resumable conversation history | One Codex conversation, including later resumes |
| tmux session | The live terminal process that makes a running MD or worker discoverable and attachable | Until that process exits or is stopped |
| Durable home | Identity bootstrap, preferences, session defaults, and continuity material | The worker's lifetime |
| Worktree and branch | Isolated project changes owned by the worker | Replaceable after work is preserved |
| Bead | Requirements, ownership, dependencies, blocker state, evidence, and handoff | The work item's lifetime |
| Native subagent thread | A bounded helper created inside a parent Codex workflow | The delegated subtask |

Rig does not need a second opaque `worker_id`. The unique display name and its
stable slug address the durable worker. Codex supplies `session_id` at runtime;
Rig associates it with that worker rather than declaring it by hand in the
worker manifest.

A worker may accumulate several Codex session IDs over their lifetime. Resuming
an ID continues that saved conversation; it does not create or define the
worker identity. Conversely, replacing a Codex session does not replace Nadia:
a new session starts in her durable home, loads her instructions and Beads
state, and continues under her name. At most one top-level runtime may occupy a
named identity at once unless Aaron explicitly authorizes a fork and gives it a
different operational identity.

Codex CLI supports `codex resume <SESSION>` and `/resume`; the saved-session
picker reloads the selected chat with its original history intact. `/rename`
adds a recognizable chat name, while `/fork` creates a new chat with a new ID.
See the [Codex session source
record](knowledgebase/wiki/sources/codex-session-resume.md).

## The operating loop

```text
Aaron and MD clarify intent
  -> MD records a bounded Bead and acceptance criteria
  -> MD selects or onboards a named generalist worker
  -> worker claims the Bead and synchronizes their clean worktree
  -> worker executes, optionally delegating bounded subagent work
  -> worker either records a blocker or returns evidence and committed work
  -> MD validates, requests changes, or accepts and closes the Bead
  -> shared decisions enter the knowledgebase
```

MD performs only the investigation needed to understand the request, expose
material choices, define safe scope, and validate the result. MD may implement
small or urgent changes directly, but lengthy exploration, implementation,
test output, and specialist investigation should normally move to a worker so
the Aaron-MD conversation remains responsive.

## Named workers and continuity

A name is an operational promise, not merely decoration. It identifies the
same durable home, working agreements, Beads actor, attributable history, and
contact point across replaceable sessions and worktrees. Nadia is therefore a
unique named generalist Worker, not the Software Engineer role and not a label
that MD may apply to an unrelated child agent.

Continuity is reconstructed from durable evidence rather than assumed model
memory:

- Beads is authoritative for assignments, blockers, dependencies, evidence,
  review, and completion.
- The knowledgebase contains shared sources, accepted decisions, and synthesis.
- The worker home contains identity bootstrap, stable preferences, and
  runner-neutral session configuration; it must not become a parallel task
  queue.
- Git preserves implementation history and isolates concurrent writers.
- Codex retains resumable session transcripts identified by session ID.
- tmux keeps the current process alive and observable while clients detach.

## Visibility and subagents

Every durable named worker has a unique tmux session and appears in the Roster.
Aaron, MD, or another authorized collaborator can attach to see the same live
terminal. Observation should eventually default to a read-only tmux attachment;
taking keyboard control should be explicit so two clients do not accidentally
type into the same session.

A worker may create native Codex subagents for independent, bounded work such
as exploration, testing, calculation, or review. The parent worker owns the
Bead, integrates the results, and remains accountable. A child uses a task
label such as `power-budget-reviewer`; it never impersonates Nadia or another
durable worker. Native children are agent threads inside the parent's Codex
workflow, not separate Rig workers or tmux sessions. In Codex CLI they can be
inspected with `/agent`. OpenAI recommends starting with read-heavy parallel
work and taking greater care with parallel writers because coordination and
conflicts increase; see the [official subagent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents).

Subagent delegation is bounded by the parent session's permissions, available
concurrency, and repository instructions. A worker must isolate write-heavy
children or keep the writing serialized. Child results that affect the task
are summarized into the parent Bead or committed artifact rather than being
left only in a transient thread.

## Blocking, wake-up, and standup

Beads records durable coordination; it does not by itself wake a waiting
process. When blocked, a worker records the question or dependency on the
active Bead and links a separate blocking Bead when the dependency warrants
one. The Roster should distinguish the worker's availability (`working`,
`waiting`, `idle`, or `stopped`) from the Bead's workflow state and from tmux
presence.

Unblocking has two parts:

1. Resolve and record the answer or dependency in Beads.
2. Deliver a live wake-up signal through an attached tmux client, an MD-to-worker
   prompt, or a future notification service.

A regular standup is a review of structured state, not a demand for fresh
status prose. It should surface each worker's current Bead, last meaningful
update, blockers and who can resolve them, tmux and attachment state, worktree
condition, active child work where observable, and results awaiting MD review.
MD summarizes exceptions and brings Aaron only the decisions that need him.

## Current compatibility boundary

Rig's current implementation still stores worker homes under `fleet/` and uses
internal names such as `member.toml`, `rig-fleet-*`, and `rig-fleet-member`.
These are compatibility paths and APIs, not the current conceptual model.
User-facing documentation and the Roster call the group **Workers**. Renaming
the storage and command surface is a separate migration because it affects
worktrees, branches, tmux names, scripts, tests, and saved operating habits.

## Deeper implementation questions

- How should Rig capture the current Codex session ID after launch and retain a
  resumable history per worker without writing stale IDs into static manifests?
- Should a stopped worker default to resuming their most recent clean session,
  or should MD choose between resume and a fresh session at dispatch time?
- What is the smallest reliable wake-up mechanism between a Beads state change
  and a waiting tmux-backed worker?
- Which worker and child-agent states can Codex expose reliably enough for the
  Roster and standup view?
- When should the compatibility `fleet/` paths and commands be migrated to
  `workers/`, and what backward compatibility is required?
