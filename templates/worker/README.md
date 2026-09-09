# Worker template

Copy this directory into `fleet/<worker-slug>/` in an instance branch, rename
`member.toml.example` to `member.toml`, and replace every placeholder before
launching the worker. The core `main` branch keeps this as a template and does
not onboard an identity itself.

Set `integration_branch` to the branch that combines the instance configuration
with current core changes. A worker starts a newly claimed Bead by merging that
branch into their clean worktree.
