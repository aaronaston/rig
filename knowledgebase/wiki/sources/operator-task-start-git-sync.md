# Operator direction on task-start Git synchronization

Date: 2026-09-07. Source: [verbatim operator correction](../../raw/2026-09-07-task-start-git-sync.md).

Aaron rejected pre-synchronizing Nadia's branch while she was idle because the
integration branch could change again before her next assignment. He directed
seats and fleet members to synchronize when they start new work.

Rig interprets that trigger as: after the identity claims a new Bead and before
the first edit. Session startup or attachment is not sufficient because a
persistent session may span multiple tasks, and an idle session may start no
work at all. The current repository has no remote, so the concrete fleet
operation is a fast-forward from local `main`, not `git pull`.

Decision: [task-start Git synchronization](../decisions/task-start-git-synchronization.md).
