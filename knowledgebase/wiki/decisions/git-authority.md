# Local Git authority

Date: 2026-09-07. Status: accepted.

All Rig seats and fleet members are authorized to use local Git for assigned
work. Seats may create branches, stage changes, and make local commits for
documentation and other scoped repository updates. MD may manage all fleet
branches and worktrees for onboarding, cross-boarding, validation, recovery,
and off-boarding.

Each fleet member may create, inspect, update, commit within, and safely retire
their own branch and worktree. This authority does not extend to another
member's checkout, the main checkout, or unrelated branches unless MD explicitly
reassigns scope.

Destructive operations require an exact target and verification that unique
work has been committed, transferred, or intentionally discarded. Remote
pushes, force-pushes, remote configuration changes, and Dolt remote sync remain
separately controlled by Aaron or MD.

This is repository authorization. A developer-level instruction or managed
sandbox may still deny `.git` writes for a particular session. Such a denial is
an external runtime restriction and cannot be removed by editing `AGENTS.md`.

Evidence: [operator direction](../sources/operator-git-authority.md).

