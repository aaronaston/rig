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

Activating an identity from the Roster reuses the exact ordinary main window
selected for that action. Ambient Emacs buffer-display rules must not redirect
the terminal into a newly split or unrelated window. The Roster and unrelated
window topology remain unchanged, and replacing an MD terminal view does not
kill its buffer, process, or persistent tmux session. If the chosen target is
no longer a live, replaceable ordinary window, Rig reports the specific problem
instead of creating another window.

Evidence: [operator direction](../sources/operator-roster-and-pull-direction.md)
and Beads `beads-tests-4kh` and `beads-tests-wfq`.
