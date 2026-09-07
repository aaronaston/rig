# Operator correction: synchronize Git at task start

Date: 2026-09-07

Source: Aaron, direct project conversation after interrupting an attempted idle
fast-forward of Nadia's branch.

> “I think this is backwards; Nadia should do the pull when she starts working. If we do this for her, the git repo may change (by someone else, me, you, another fleet member) before she starts again. seats and fleet members should always pull when the start something new?”

The interrupted command did not change Nadia's branch. Aaron's correction is
accepted as the task-start synchronization principle. Rig uses “synchronize”
rather than “pull” for the current repository because it has no Git remote.
