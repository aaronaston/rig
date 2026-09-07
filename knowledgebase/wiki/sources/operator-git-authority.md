# Operator direction on Git authority

On 2026-09-07 Aaron directed that every Rig seat and fleet member be able to
modify local Git state. Seats need that authority for documentation updates;
fleet members need it to manage their own worktrees.

MD interprets this as authority for local status, diff, branches, staging,
commits, and scoped worktree operations. The instruction did not explicitly
grant remote publication, force-push, remote reconfiguration, or Dolt remote
synchronization, so those remain separate authorities.

Source: [complete direct instruction](../../raw/2026-09-07-local-git-authority.md).

