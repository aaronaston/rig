# Rig test instance

This branch is a private, working Rig instance. It owns Nadia's durable home
under `fleet/nadia/`, her worker branch, and its instance-specific operating
state. `main` is the worker-free Rig core.

To receive a core release, first make this branch clean and then merge `main`
into `test-instance`. Resolve only intentional core/instance boundary changes,
run the Rig validation suite, and commit the merge. A worker beginning a new
Bead synchronizes their clean worktree from `test-instance`, not directly from
`main`.

Nadia's `member.toml` declares `integration_branch = "test-instance"`. The
field is the source of truth for this instance's worker base branch.
