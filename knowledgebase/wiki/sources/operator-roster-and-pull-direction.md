# Operator direction on the Rig Roster and fleet work

Date: 2026-09-07. Sources: [initial direction](../../raw/2026-09-07-rig-roster-and-fleet-pull-direction.md), [interaction follow-up](../../raw/2026-09-07-rig-roster-interaction-decisions.md), [state-model decision](../../raw/2026-09-07-rig-roster-state-model-decision.md), and [discovery/refresh decision](../../raw/2026-09-07-rig-roster-discovery-refresh-decision.md).

Aaron named the planned left-side Emacs identity view **Rig Roster**. It should
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

Aaron accepted declarative manifest discovery, refresh after roster actions,
a ten-second refresh while visible, manual `g` refresh, and a twenty-percent
left-side width bounded between twenty-four and forty columns. The complete
implementation and validation contract is maintained in Bead
`beads-tests-vjz`.

Aaron accepted pull-based fleet work and approved Nadia's trial assignment. He
also directed MD to remove mailbox provisioning as a hard blocker. Beads issues
therefore remain the durable work and review system; mail may later provide
notification or wake-up behavior if Rig establishes a concrete need.
