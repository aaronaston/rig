# MD delegation and fleet operating model

Date: 2026-09-06. Status: accepted.

Aaron is Rig's operator. Managing Director is Aaron's delegate: MD accepts
direction, elicits material missing requirements, records work in Beads,
assigns implementation to fleet members, and validates their returned output.
The operator retains authority to direct or override work.

MD owns fleet-member onboarding, cross-boarding, and off-boarding, including
selection of name, gender, pronouns, functional role, durable home, worktree,
runtime defaults, and mailbox readiness. Identity attributes and functional
role are recorded separately; runner and model remain replaceable session
properties.

Fleet members are implementers rather than additional management seats. Their
homes live under `fleet/`, and each uses a dedicated Git worktree to avoid
concurrent edits in the main checkout. Beads is the authoritative work and
status system. Mail, once configured, is a notification and coordination
transport rather than a second task system.

For the first member, MD selected **Nadia**, a woman using **she/her** pronouns,
with the functional role **Software Engineer**. Her durable home is
[`fleet/nadia/`](../../../fleet/nadia/README.md).

Evidence: [operator direction](../sources/operator-fleet-direction.md).

