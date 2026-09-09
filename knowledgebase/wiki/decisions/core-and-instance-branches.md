# Core and instance branches

Date: 2026-09-09. Status: accepted.

Rig publishes a private repository named `aaronaston/rig`. The `main` branch is
the reusable, worker-free core. It contains the control center, templates,
shared defaults, tests, and operating policy, but no durable worker manifest or
worker home.

An instance branch adds durable workers and local operating configuration.
`test-instance` is the initial instance and owns Nadia. Core releases travel by
merging `main` into the instance branch. A worker does not merge `main`
directly: at task start they fast-forward their clean worktree from the
`integration_branch` declared in their instance `member.toml`.

The first transition resolves the intentional deletion of instance files from
`main` by retaining them on `test-instance`. Once that merge is committed,
future core-to-instance merges no longer revisit those paths. Worker homes are
ignored in the core checkout and explicitly added on the instance branch.

Beads and the knowledgebase remain shared project coordination material. Live
Beads exports, linked worktrees, tmux sessions, and editor lock files are local
runtime state and are not published as core source files.

Evidence: [operator direction](../sources/operator-core-instance-github-direction.md)
and its [raw record](../../raw/2026-09-09-core-instance-github-direction.md).
