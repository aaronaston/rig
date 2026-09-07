# Fleet member lifecycle

Date: 2026-09-06. Status: adopted for the first-member implementation.

A fleet member has five separate concerns: identity, durable home, project
worktree, runtime session, and coordination channels. A member is not fully
ready merely because one of these exists. Shared Beads access is the required
coordination channel; mail is optional notification infrastructure.

Codex starts in the durable member home so the member's closer `AGENTS.md`
refines root project guidance, following the documented [Codex instruction
discovery order](../sources/codex-agent-instructions.md). The worktree is an
additional writable area rather than the source of member identity.

## Onboarding

MD records the requirement in Beads, selects and documents identity and role,
creates `fleet/<member>/`, defines runner-neutral session defaults, provisions
`fleet/<member>/worktree` on a dedicated branch, validates shared Beads access
with the member's actor identity, and launches a session that loads the member's
instructions. MD then releases a bounded trial bead for the member to claim and
validates the returned evidence. A mailbox may be provisioned and tested later
when Rig has a concrete asynchronous-notification requirement.

Fleet members normally inherit the shared fleet runtime policy rather than
copying it into each home: Codex CLI on Luna/high, workspace-write, and
Auto-review. A member-specific session file is an optional override. MD remains
on Sol/high for requirements, design, orchestration, and validation. Runtime
settings are launch-time state, so an already-running tmux session must be
stopped and relaunched before changed defaults can be validated.

Onboarding evidence states are `provisioning`, `ready`, or `blocked`. The
member record must not move to `ready` until required gates have direct
evidence or MD explicitly records a waiver.

MD may provision the worktree directly, or the member may create their own once
their durable home and instructions exist. Fleet members have local Git authority
only over their assigned branch and worktree; MD has local authority across fleet
worktrees for lifecycle management and validation.

## Cross-boarding

Cross-boarding moves an existing member to another repository without changing
their identity. MD closes or transfers active work, records the target and
access requirements in Beads, provisions a new isolated worktree, updates the
member's work-area configuration, verifies target instructions and quality
gates, tests Beads/mail routing, and assigns a bounded trial task. Old and new
project access may overlap only when the Bead explains why.

## Off-boarding

MD first stops new assignments, resolves or reassigns active beads, captures a
final handoff, verifies that no unique work remains only in the member's
worktree or mailbox, ends the runtime session, removes project access and the
worktree, disables mailbox routing, and records the member as `offboarded`.
The durable identity and history remain unless Aaron explicitly directs their
removal. Destructive worktree removal requires an exact target and a clean or
preserved-work check.

## Git authority

All Rig seats may use local Git for assigned documentation and repository work.
MD may manage fleet branches and worktrees. Each fleet member may manage their
own branch and worktree, including local commits and safe removal, but may not
alter another member's checkout or the main checkout without explicit
reassignment. Remote pushes, force-pushes, remote configuration, and Dolt remote
sync are separate authorities requiring direction from Aaron or MD.

Repository authorization cannot override a higher-level session sandbox. A
session denied `.git` writes must report that as an external runtime restriction,
not as a Rig policy decision.

## Beads work and mail boundary

Fleet implementation uses a pull-first, push-capable Beads workflow. MD owns a
bead while its requirements are being defined. Once it is implementation-ready,
MD may release it to an unassigned, labelled ready pool or assign it directly
to a particular member. A member claims the bead atomically, implements and
validates it in their own worktree, then returns the same in-progress bead to
MD with review evidence. MD accepts and closes it or requests changes. Beads
remain authoritative for requirements, dependencies, ownership, evidence,
review, and completion.

In V1, each fleet member has at most one active implementation bead. A member
with no active assignment is available to pull work. MD may hold multiple
requirements while defining and reviewing the fleet queue.

The installed `bd mail` command delegates to an external provider. On
2026-09-06 no `mail.delegate` was configured, and `bd mail inbox` returned
`no mail delegate configured`. Nadia's address is therefore reserved but not
provisioned. This does not block her readiness. Bead `beads-tests-dze.2` tracks
optional notification-provider evaluation. Until Rig identifies a need beyond
Beads polling and active-session coordination, Beads comments and state changes
are the durable handoff channel.

The documented upstream provider is [Gas Town mail](../sources/gastown-mail.md),
which stores mail in a town-level Beads database distinct from project issues.
Rig has no `gt` executable or town workspace. MD must therefore choose with
Aaron between adopting Gas Town's broader coordination layer and implementing
a smaller Rig-native mail delegate if asynchronous notification becomes
necessary; configuring the string `gt mail` alone would not provision a
mailbox.
