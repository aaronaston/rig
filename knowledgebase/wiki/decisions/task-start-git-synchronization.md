# Task-start Git synchronization

Date: 2026-09-07. Status: accepted.

Every Rig identity synchronizes its owned work area when beginning a newly
accepted task. The synchronization point is after claiming the Bead and before
editing. It is not session startup, reconnection, or idle time.

For a worker using the current compatibility `fleet/<worker>/` home in this
local-only repository:

1. Verify the worker worktree is clean and prior work is resolved.
2. From the durable home, run `git -C worktree merge --ff-only <integration-branch>`,
   using the value in the instance worker record.
3. Begin implementation only after the fast-forward succeeds.
4. At handoff, report whether the integration branch advanced after implementation began.

The repository has no Git remote, so `git pull` is not the correct current
command. If a remote is added later, remote fetch/pull behavior remains subject
to the repository's authority policy and should be defined separately.

If the task-start fast-forward cannot succeed, or the worktree contains unique
prior work, the worker stops and returns the conflict to MD. They do not force,
automatically rebase, discard, or alter another identity's branch. MD records
the unique-work disposition and selects an integration strategy.

This timing avoids a false guarantee: updating an idle branch does not ensure
that it is current when implementation actually starts.

Source: [operator task-start direction](../sources/operator-task-start-git-sync.md).
