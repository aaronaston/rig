# Named worker lifecycle

Date: 2026-09-06; revised 2026-09-09. Status: accepted. `fleet/` remains the
compatibility storage path.

A named worker has separate concerns: unique display name and routing slug,
durable home, Codex session history, tmux runtime, project worktree, Beads actor,
and notification channels. A worker is not fully ready merely because one of
these exists. Shared Beads access is required; mail is optional notification
infrastructure.

Codex starts in the durable worker home so the worker's closer `AGENTS.md`
refines root project guidance, following the documented [Codex instruction
discovery order](../sources/codex-agent-instructions.md). The worktree is an
additional writable area rather than the source of worker identity.

## Onboarding

MD records the requirement in Beads, selects a unique display name and stable
slug, creates the compatibility home `fleet/<worker>/`, defines runner-neutral
session defaults, provisions `fleet/<worker>/worktree` on a dedicated branch,
validates shared Beads access with the worker's actor identity, and launches a
session that loads the worker's instructions. MD then releases a bounded trial
Bead for the worker to claim and validates the returned evidence. A mailbox may
be provisioned later when Rig has a concrete asynchronous-notification need.

Workers normally inherit the shared runtime policy from the compatibility
`fleet/session-defaults.toml`: Codex CLI on Luna/high, workspace-write, and
Auto-review. A worker-specific session file is an optional override. MD remains
on Sol/high for requirements, design, orchestration, and validation.

The display name and slug identify the durable worker. Codex supplies a session
ID for one saved conversation history. A worker may accumulate several session
IDs; resuming an ID restores that history but does not define or replace the
worker. The current tmux session keeps the live process observable and is also
separate from the Codex session ID.

Onboarding evidence states are `provisioning`, `ready`, or `blocked`. The worker
record must not move to `ready` until required gates have direct evidence or MD
explicitly records a waiver. At most one top-level runtime may occupy a named
worker identity at once.

MD may provision the worktree directly, or the worker may create their own once
their durable home and instructions exist. Workers have local Git authority
only over their assigned branch and worktree; MD has local authority across
worker worktrees for lifecycle management and validation.

Synchronization is tied to accepting work, not to idle time or session startup.
After claiming each new Bead and before editing, the worker verifies a clean
worktree and resolved prior work, then updates their branch from the current
integration branch. In Rig's current local-only repository this is
`git -C worktree merge --ff-only main` from the worker's durable home, not
`git pull`. A failed fast-forward or unique prior work returns to MD for an
explicit disposition; it is not forced, automatically rebased, or discarded.
At handoff, the worker reports whether `main` advanced during implementation.

## Cross-boarding

Cross-boarding moves an existing worker to another repository without changing
their identity. MD closes or transfers active work, records the target and
access requirements in Beads, provisions a new isolated worktree, updates the
worker's work-area configuration, verifies target instructions and quality
gates, tests coordination routing, and assigns a bounded trial task. Old and new
project access may overlap only when the Bead explains why.

## Off-boarding

MD first stops new assignments, resolves or reassigns active Beads, captures a
final handoff, verifies that no unique work remains only in the worker's
worktree or notification channel, ends the runtime session, removes project
access and the worktree, disables notification routing, and records the worker
as `offboarded`. The durable identity and history remain unless Aaron explicitly
directs their removal. Destructive worktree removal requires an exact target and
a clean or preserved-work check.

## Git authority

The MD seat and all workers may use local Git for assigned work. MD may manage
worker branches and worktrees. Each worker may manage their own branch and
worktree, including local commits and safe removal, but may not alter another
worker's checkout or the main checkout without explicit reassignment. Remote
pushes, force-pushes, remote configuration, and Dolt remote sync are separate
authorities requiring direction from Aaron or MD.

Repository authorization cannot override a higher-level session sandbox. A
session denied `.git` writes must report that as an external runtime restriction,
not as a Rig policy decision.

## Subagents

A worker may launch bounded native Codex subagents for independent exploration,
testing, calculation, or review. Each child uses a task-specific label and must
not claim the durable worker's display name. The worker remains accountable for
scope, write isolation, synthesis, evidence, and handoff. Native children are
threads within the parent Codex workflow and do not receive a separate Rig
identity or tmux session.

## Beads work, blockers, and notification boundary

Worker execution uses a pull-first, push-capable Beads workflow. MD owns a Bead
while its requirements are being defined. Once it is execution-ready, MD may
release it to an unassigned, labelled ready pool or assign it directly to a
particular worker. A worker claims the Bead atomically, executes and validates
it in their own worktree, then returns the same in-progress Bead to MD with
review evidence. MD accepts and closes it or requests changes. Beads remain
authoritative for requirements, dependencies, ownership, evidence, review, and
completion.

Here, **pull-first** describes Beads work discovery and claiming. It does not
mean Git branches should be pulled or synchronized while workers are idle. In
V1, each worker has at most one active implementation Bead. A worker with no
active assignment is available to pull work. MD may hold multiple requirements
while defining and reviewing the worker queue.

When blocked, the worker records the question or dependency on the active Bead
and links a separate blocking Bead when warranted. Beads preserves that state
but does not wake a waiting Codex process. After the dependency is resolved and
recorded, Aaron or MD must deliver a live signal through tmux or a future
notification service. Standup should surface blockers, their resolver, stale
updates, worktree condition, and results awaiting review rather than creating a
second task system.

The installed `bd mail` command delegates to an external provider. On
2026-09-06 no `mail.delegate` was configured, and `bd mail inbox` returned
`no mail delegate configured`. Nadia's address is therefore reserved but not
provisioned. This does not block her readiness. Bead `beads-tests-dze.2` tracks
optional notification-provider evaluation. Until Rig needs an automatic wake-up
channel, Beads comments and state changes are the durable handoff record and
active tmux coordination supplies the live signal.

The documented upstream provider is [Gas Town mail](../sources/gastown-mail.md),
which stores mail in a town-level Beads database distinct from project issues.
Rig has no `gt` executable or town workspace. MD must therefore choose with
Aaron between adopting Gas Town's broader coordination layer and implementing
a smaller Rig-native notification mechanism if asynchronous wake-up becomes
necessary; configuring the string `gt mail` alone would not provision a mailbox.
