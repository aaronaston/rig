# Operator direction on the Roster and fleet work

Dates: 2026-09-07 to 2026-09-08. Sources: [initial direction](../../raw/2026-09-07-rig-roster-and-fleet-pull-direction.md), [interaction follow-up](../../raw/2026-09-07-rig-roster-interaction-decisions.md), [state-model decision](../../raw/2026-09-07-rig-roster-state-model-decision.md), [discovery/refresh decision](../../raw/2026-09-07-rig-roster-discovery-refresh-decision.md), and [name, state, and refresh correction](../../raw/2026-09-08-roster-name-state-and-refresh-direction.md).

Aaron initially named the left-side Emacs identity view with a redundant Rig
prefix, then corrected the user-facing component name to **Roster** because the
whole product is Rig. It should
open with `bin/rig-emacs`, show seats and fleet in separate sections, remain a
normal window that can be deleted, provide a command or key sequence to reopen
it, and open the selected identity's terminal buffer in the main Emacs window.
Detailed product requirements remain in Bead `beads-tests-vjz` while the design
is in progress.

Aaron subsequently accepted start-or-attach behavior when an actionable
identity is selected, `M-x rig-roster` as the global reopen command, and
`C-c r` from Rig terminal buffers. He proposed displaying name, task summary,
and a status indicator. Rig can directly observe tmux session presence and
Beads assignment, but the current launcher does not expose authoritative
real-time Codex working-versus-prompt-idle state; exact labels remain a product
decision.

Aaron accepted trying a V1 model that keeps lifecycle, session, and work state
separate. Fleet members have at most one active implementation bead, so no
active assignment means available or idle. MD may own multiple requirements;
the roster shows one current summary plus an additional-task count.

Aaron accepted declarative manifest discovery, refresh after Roster actions,
manual `g` refresh, and a twenty-percent left-side width bounded between
twenty-four and forty columns. After trying the first implementation, he
superseded its ten-second visible refresh with an exact two-minute cadence
because refresh briefly blocked Emacs input.

The corrected state model uses explicit labels. `active` is the lifecycle of
an enabled management seat; `ready` means a fleet member passed onboarding and
may accept work. Neither means that a process is present or busy. `running`
means only that the named tmux session exists. For a running session,
`attached` means one or more tmux clients are connected and `detached` means
zero clients are connected. Work assignment remains a separate dimension, and
none of these values claims real-time knowledge of Codex activity. Bead
`beads-tests-4kh` contains the corrected implementation and validation
contract.

Aaron accepted pull-based fleet work and approved Nadia's trial assignment. He
also directed MD to remove mailbox provisioning as a hard blocker. Beads issues
therefore remain the durable work and review system; mail may later provide
notification or wake-up behavior if Rig establishes a concrete need.
