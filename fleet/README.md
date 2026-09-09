# Rig Workers

`fleet/` is the compatibility location for durable homes for Rig's named
generalist workers. The directory name is a compatibility surface; **Workers**
is the current concept. The core `main` branch deliberately contains no worker
home. An instance branch creates `fleet/<worker>/` from
[`templates/worker/`](../templates/worker/) and adds that home with
`git add -f`.

Each worker home is `fleet/<worker>/` and contains identity, operating
instructions, and optional worker-specific session overrides. Shared
[`session-defaults.toml`](session-defaults.toml) selects Codex CLI,
`gpt-5.6-luna`, high reasoning effort, a workspace-write sandbox, and
Auto-review for eligible approval requests. A worker's own
`session-defaults.toml` may override individual quoted values. Its `worktree/`
child is a local Git worktree for implementation and is intentionally ignored
by the main checkout. Replacing a worktree must not erase the worker's identity
or history.

Workers are generalists. The current Bead, project instructions, sources,
skills, tools, and acceptance criteria supply task-specific expertise. A new
domain does not require a new permanent role. A worker may create bounded native
subagents, but remains accountable for their combined result and must not give
a child the worker's durable name.

The worker's unique display name and stable slug identify the durable
collaborator. Codex supplies a session ID for each saved, resumable conversation.
A worker may have successive session IDs; resuming one restores that conversation
but does not define or replace the worker. tmux keeps the current process visible
and attachable independently of Codex transcript persistence.

Git synchronization is task-scoped. After claiming a new Bead and before
editing, a worker verifies their worktree is clean and runs
`git -C worktree merge --ff-only <integration-branch>` from their durable home.
`integration_branch` comes from that worker's `member.toml`; an instance branch
usually receives core releases by merging `main` before worker work begins. An
idle branch is not updated in anticipation of future work. A non-fast-forward
result or unique prior work is returned to MD for disposition; it is never
forced away.

Workers may manage their own local worktree and branch. MD may manage all
worker worktrees for lifecycle and validation purposes. Neither authority includes
remote publication unless Aaron or MD separately directs it.

The canonical model is [Rig's operating architecture](../ARCHITECTURE.md).
Lifecycle policy is recorded in the [worker lifecycle
decision](../knowledgebase/wiki/decisions/fleet-member-lifecycle.md).
