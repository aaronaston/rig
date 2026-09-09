# Rig Knowledgebase Index

Purpose: Preserve sources, decisions, and operating knowledge for a local
control center with one Managing Director seat and durable named generalist
workers

Start with the [overview](overview.md). Maintenance history is in the [log](log.md).

## Sources

- [Wheelhouse](sources/wheelhouse.md): shared chat, two primary essays, and an explicit correction.
- [Emacs terminal backends](sources/emacs-terminal-backends.md): observed built-in `term` limitations and the evidence for `vterm`.
- [Operator fleet direction](sources/operator-fleet-direction.md): accepted delegation, fleet lifecycle responsibility, worktree homes, and mailbox uncertainty.
- [Codex agent instructions](sources/codex-agent-instructions.md): documented project-root-to-working-directory instruction precedence used for fleet homes.
- [Codex session resume and agent threads](sources/codex-session-resume.md): official session-ID, `/resume`, `/rename`, `/fork`, and `/agent` behavior plus the current local environment observation.
- [Gas Town mail](sources/gastown-mail.md): persistent mailbox commands, town-level Beads storage, and the provider boundary behind `bd mail`.
- [Operator Git authority](sources/operator-git-authority.md): historical direction authorizing the MD seat and worker implementations to modify local Git state.
- [Operator Roster and fleet-pull direction](sources/operator-roster-and-pull-direction.md): corrected Roster name and state semantics, startup behavior, refresh cadence, pull-based work, Nadia trial, and optional-mail boundary.
- [Operator runtime policy](sources/operator-runtime-policy.md): Auto-review plus Sol/high for MD and Luna/high for fleet implementation.
- [Operator task-start Git direction](sources/operator-task-start-git-sync.md): synchronize after accepting new work, not while an identity is idle.
- [Operator named-worker direction](sources/operator-named-worker-direction.md): accepted singleton MD, named generalist workers, worker-managed subagents, tmux visibility, blockers, and resumable Codex session IDs.

## Decisions

- [Initial scope](decisions/initial-scope.md): confirmed requirements, including MD's they/them pronoun preference, and unresolved choices.
- [Seat and worker session defaults](decisions/session-defaults.md): Sol/high for MD and inherited Luna/high for workers, with Codex session IDs modeled as resumable runtime history.
- [Agent approval policy](decisions/agent-approval-policy.md): workspace-write with on-request Auto-review and explicit limits.
- [MD session lifecycle](decisions/session-lifecycle.md): Emacs attachment, tmux persistence, and deliberate session exit.
- [Seat home and work area](decisions/seat-home.md): `md/` as working directory with the parent repository available for shared work.
- [Named generalist worker architecture](decisions/named-generalist-worker-architecture.md): singleton conversational MD, durable named workers, session identity, tmux visibility, subagents, blockers, and standups.
- [Core and instance branches](decisions/core-and-instance-branches.md): worker-free core publication, instance ownership, and integration-branch updates.
- [MD delegation and workers](decisions/md-delegation-and-fleet.md): operator/MD authority, substantial-execution delegation, and instance worker onboarding.
- [Named worker lifecycle](decisions/fleet-member-lifecycle.md): onboarding, session history, tmux runtime, subagents, blocking, cross-boarding, off-boarding, and handoff.
- [Local Git authority](decisions/git-authority.md): scoped local Git rights for MD and named workers; remote authority remains separate.
- [Task-start Git synchronization](decisions/task-start-git-synchronization.md): clean-state and current-base gate after claim and before edits.
- [Roster state and refresh](decisions/roster-state-and-refresh.md): labelled lifecycle, tmux, attachment, and work semantics with a two-minute visible refresh.

## Syntheses

- [Rig operating architecture](../../ARCHITECTURE.md): canonical top-level model and operating loop.
- [Minimal control center](syntheses/minimal-control-center.md): implemented seat, worker, session, and delegation synthesis.
- [Rig README](../../README.md): current startup and interaction instructions.
- [Rig restart quickstart](../../quickstart.md): targeted session shutdown and Emacs restart with the roster sidebar.

## Seats

- [Managing Director](../../md/README.md): initial role seat and current definition boundary.

## Workers

- [Worker registry](../../fleet/README.md): named generalist worker homes and compatibility paths.
