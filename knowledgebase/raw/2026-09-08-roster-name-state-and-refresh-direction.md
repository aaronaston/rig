# Operator direction: Roster name, state, and refresh

Date: 2026-09-08. Source: Aaron's feedback after trying the first Roster
implementation.

Aaron corrected the component name: the overall product is Rig, so the sidebar
should be called **Roster**, not **Rig Roster**.

He asked what the existing values meant, specifically `active` versus `ready`
and the meaning of `running`. He directed Rig to show whether the tmux session
is attached and observed that the automatic refresh briefly locked Emacs and
interfered with typing. He proposed reducing the automatic cadence to every two
minutes.

MD translated this into Bead `beads-tests-4kh`: render lifecycle, tmux
existence, tmux attachment, and work as separate labelled dimensions; define
the state values in the Roster without implying real-time Codex activity; and
refresh automatically every 120 seconds while preserving immediate manual and
action-triggered refresh.
