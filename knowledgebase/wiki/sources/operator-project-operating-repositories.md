# Operator project operating repository direction

Source: Aaron's current conversation with MD, 2026-09-10, preserved in the
[raw record](../../raw/2026-09-10-project-operating-repositories.md).

Aaron specified a dedicated team and Beads database for each project. He
accepted separate Rig software and operating repositories and asked MD to work
on `beads-tests-dze.17`. `aaronaston/rig-test-instance` is the working operating
repository name. No alternate name was accepted.

The [resulting design](../decisions/project-operating-repositories.md) separates
software selection, project identity/state, and assigned source worktrees.
Publication and live migration completion are evidence states, not implied by
the design agreement.
