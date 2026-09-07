# Rig restart quickstart

Use this procedure to end every Rig-managed agent session, close the old Emacs
process, and restart Rig with the roster sidebar. It targets `rig-md` and
`rig-fleet-*` tmux sessions only; unrelated tmux sessions are left alone.

## 1. Finish agent handoffs

Before stopping a session, ask each working agent to finish or pause cleanly:

> Finish the current bounded work, update its Bead with a handoff, and return to
> the prompt. Do not begin unrelated work.

Wait for the agent to finish. If it changed code, confirm that unique work is
committed or otherwise preserved. Closing an Emacs window only detaches from
tmux; it does **not** stop the agent.

## 2. Stop every Rig session

Open a normal terminal and change to the repository:

```sh
cd /Users/aaron/development/tpsi/beads-tests
```

Optional: list the Rig sessions that will be targeted:

```sh
tmux list-sessions -F '#{session_name}' 2>/dev/null |
  grep -E '^rig-(md|fleet-)' || true
```

After the handoffs are complete, stop the MD session and every fleet session
without touching unrelated tmux sessions:

```sh
tmux list-sessions -F '#{session_name}' 2>/dev/null |
  while IFS= read -r rig_session; do
    case "$rig_session" in
      rig-md|rig-fleet-*) tmux kill-session -t "$rig_session" ;;
    esac
  done
```

Verify that none remain:

```sh
tmux list-sessions -F '#{session_name}' 2>/dev/null |
  grep -E '^rig-(md|fleet-)' || true
```

No output means all Rig sessions are stopped.

## 3. Quit the old Emacs process

In each Rig Emacs instance, use:

```text
C-x C-c
```

Do this after stopping the tmux sessions. Fully exiting Emacs ensures the next
process loads the current `emacs/rig.el`, including the roster implementation.

## 4. Restart Rig

From the repository root in a normal terminal:

```sh
./bin/rig-emacs
```

The launcher should:

- open a fresh MD session in the main `*rig-md*` window;
- open `*Rig Roster*` as the left sidebar;
- show **Managing Director** under **Seats**; and
- show **Nadia** under **Fleet**, initially as `ready | stopped`.

Move to Nadia's roster entry and press `RET` to start her Luna/high Auto-review
session in the main window. The roster remains open. Starting Nadia should
change her session state to `running` on the next refresh.

## Roster controls

- `RET` — start or attach the identity at point.
- `g` — refresh the roster immediately.
- `C-x 0` — close the roster window normally.
- `M-x rig-roster` — reopen the roster from anywhere.
- `C-c r` — reopen the roster from a Rig terminal buffer.

## Troubleshooting

- **Roster missing:** run `M-x rig-roster`. If that command is unavailable,
  fully quit Emacs and restart with `./bin/rig-emacs`.
- **Old session reappears:** inspect `tmux list-sessions`; stop the exact
  `rig-md` or `rig-fleet-<member>` session and launch again.
- **Vterm is unavailable:** run `./bin/rig-install-emacs-deps`, then restart
  Emacs.
- **Nadia says provisioning:** run `./bin/rig-fleet-onboard --check nadia` and
  resolve the reported gate before starting her.

Do not delete Nadia's worktree or branch during a normal session restart. Git
synchronization happens only after she claims her next Bead and before she
begins editing.
