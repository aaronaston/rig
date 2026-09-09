# Named generalist worker architecture

Date: 2026-09-09. Status: accepted.

Rig has one singleton management seat, **Managing Director (MD)**, and a
standing team of durable, uniquely named, generalist **Workers**. Aaron directs
MD. MD remains available for conversation, performs enough investigation to
clarify intent and acceptance, delegates substantial execution, monitors
blockers, and validates results. Worker expertise is supplied by the current
Bead, project instructions, sources, tools, skills, and constraints rather than
by a growing catalogue of permanent specialist roles.

Nadia remains a unique named Worker and uses she/her pronouns. Her display name
and stable slug address the durable collaborator. The prior Software Engineer
role is superseded. Additional workers should be onboarded when Rig needs more
durable concurrent capacity or another continuing working relationship, not
merely because a task enters a new domain.

Codex assigns a session ID to one saved conversation history. The ID can be
resumed and a worker may accumulate several such IDs over time. It does not
define the worker: durable identity survives a replaced process, model, runner,
worktree, or Codex session. Rig does not introduce a separate opaque worker UUID;
the stable slug is the routing and filesystem key. Static manifests declare the
display name and slug, while current and prior session IDs are runtime/history
metadata to be discovered and associated rather than hand-authored.

Every durable worker has a unique tmux session and Roster entry so authorized
collaborators can observe the live process. Native Codex subagents remain
transient children inside the accountable parent workflow. They use task labels,
never the parent worker's name, and do not become separate Rig workers or tmux
sessions. The parent worker owns the Bead, controls write isolation, consolidates
evidence, and returns the result to MD.

Beads is authoritative for assignments, dependencies, blockers, evidence,
review, and completion. It is not a wake-up transport. Resolving a blocker
therefore requires both a durable answer in Beads and a live signal to the
waiting worker through tmux or a future notification mechanism. A Rig standup
should summarize structured worker, task, runtime, worktree, child-work, and
review state, emphasizing exceptions that require Aaron or MD.

The existing `fleet/`, `member.toml`, `rig-fleet-*`, and related internal names
remain compatibility surfaces until a separate migration safely handles paths,
branches, worktrees, tmux sessions, tests, and operating habits. User-facing
materials and Roster grouping use **Workers** now.

The Codex behavior is supported by the [session resume and agent-thread
source](../sources/codex-session-resume.md). The complete operating model is
[Rig's top-level architecture](../../../ARCHITECTURE.md). Evidence is preserved in the [operator
direction](../sources/operator-named-worker-direction.md) and its [raw
record](../../raw/2026-09-09-named-generalist-worker-direction.md).
