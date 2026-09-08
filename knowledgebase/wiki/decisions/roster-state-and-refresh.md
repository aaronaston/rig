# Roster state and refresh

Date: 2026-09-08. Status: accepted.

The Emacs identity sidebar is named **Roster**. User-facing buffer, title,
documentation, help, and messages use that name; internal `rig-` Lisp symbols
and tmux session names remain unchanged.

Each identity renders four independent state dimensions plus its task summary:

- **Lifecycle:** `active` means an enabled management seat. `ready` means a
  fleet member has passed onboarding gates and may accept work. Neither value
  is a busy signal or evidence of a running process.
- **Tmux:** `running` means the named tmux session exists; `stopped` means it
  does not. This does not reveal whether Codex is working or waiting for input.
- **Attachment:** for a running session, `attached` means one or more tmux
  clients are connected and `detached` means zero are connected. A stopped
  session has no attachment state. Failed metadata is shown as `unavailable`
  rather than guessed.
- **Work:** `assigned`, `idle`, or `unknown` comes from the identity's open
  and in-progress Beads assignments and remains separate from process state.

The Roster refreshes automatically every 120 seconds only while visible.
Manual `g` refresh and refresh after an identity action remain immediate. This
supersedes the original ten-second automatic interval, which Aaron observed
briefly blocking Emacs input.

Evidence: [operator direction](../sources/operator-roster-and-pull-direction.md)
and Bead `beads-tests-4kh`.
