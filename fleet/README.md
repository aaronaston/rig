# Rig Fleet

`fleet/` contains durable homes for Rig implementers. Fleet members are distinct
from the Managing Director seat: Aaron directs MD, MD assigns bounded Beads work
to fleet members, and MD validates their output before accepting it.

Each member home is `fleet/<member>/` and contains identity, operating
instructions, and replaceable session defaults. Its `worktree/` child is a local
Git worktree for implementation and is intentionally ignored by the main
checkout. Replacing a worktree must not erase the member's identity or history.

Fleet members may manage their own local worktree and branch. MD may manage all
fleet worktrees for lifecycle and validation purposes. Neither authority includes
remote publication unless Aaron or MD separately directs it.

Current roster:

- [Nadia](nadia/README.md) — Software Engineer; woman; she/her; provisioning

Lifecycle policy is recorded in the [fleet decision](../knowledgebase/wiki/decisions/fleet-member-lifecycle.md).
