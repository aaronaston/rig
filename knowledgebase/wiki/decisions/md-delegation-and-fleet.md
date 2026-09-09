# MD delegation and worker operating model

Date: 2026-09-06; revised 2026-09-09. Status: accepted. The specialized fleet
role model is superseded by the [named generalist worker
architecture](named-generalist-worker-architecture.md); the filename remains a
compatibility reference.

Aaron is Rig's operator. Managing Director is Aaron's delegate: MD accepts
direction, elicits material missing requirements, records work in Beads,
normally assigns substantial execution to named workers, and validates their
returned output. MD remains available for conversation and performs only the
investigation needed to understand intent, expose material choices, define safe
acceptance criteria, monitor work, and review results. MD retains direct
implementation ability where delegation would not help.
The operator retains authority to direct or override work.

MD owns worker onboarding, cross-boarding, and off-boarding, including unique
display name, stable slug, pronouns where expressed, durable home, worktree,
runtime defaults, Codex session-history association, and notification readiness.
Workers share the generalist Worker class rather than permanent specialist
roles. Runner, model, Codex session, and tmux process remain replaceable runtime
properties.

Workers are durable named collaborators rather than additional management
seats. Their homes currently live under the compatibility `fleet/` path, and
each uses a dedicated Git worktree to avoid concurrent edits in the main
checkout. Beads is the authoritative work and status system. Mail or another
wake-up channel, once configured, is notification transport rather than a
second task system.

Workers may launch bounded native subagents. Those children are transient task
threads, use task-specific labels rather than a durable worker's name, and
remain under the parent worker's scope and accountability.

For the first worker, MD selected **Nadia**, a woman using **she/her** pronouns.
She is a generalist Worker; the earlier Software Engineer specialization is
superseded. Her durable home is
[`fleet/nadia/`](../../../fleet/nadia/README.md).

Evidence: the original [operator direction](../sources/operator-fleet-direction.md)
and the superseding [named-worker direction](../sources/operator-named-worker-direction.md).
