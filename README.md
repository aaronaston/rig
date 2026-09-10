# Rig

Rig is a small Emacs control center for one conversational management seat and
durable, named, generalist workers. Aaron directs Managing Director (MD); MD
clarifies requirements, records work in Beads, delegates substantial execution,
and validates worker output. The canonical model is [Rig's operating
architecture](ARCHITECTURE.md).

For a complete shutdown and restart with the Roster sidebar, follow the
[restart quickstart](quickstart.md).

## Open MD

From this repository root:

```sh
./bin/rig-emacs
```

Emacs opens the `*rig-md*` buffer. A new MD session starts Codex CLI with the defaults in [`md/session-defaults.toml`](md/session-defaults.toml): Sol with high reasoning, a workspace-write sandbox, and Auto-review for eligible approval requests. Its working directory is `md/`, and [`md/AGENTS.md`](md/AGENTS.md) supplies seat-specific instructions. The parent Rig repository is also available as a work area. If MD is already running, Emacs reconnects to that session. Type in the buffer to talk to it.

Rig displays Codex through Emacs `vterm`, attached to the persistent tmux session. `vterm` supports the cursor movement and alternate-screen behavior that Codex uses to redraw live status. Install the Emacs dependency once with `./bin/rig-install-emacs-deps`; building it requires CMake and GNU libtool.

Inside an existing Emacs instance, load `emacs/rig.el` and run `M-x rig-md`. Use `M-x rig-md-status` to check the session. In MD's terminal buffer, press `F12` to enter or leave vterm copy mode. Copy mode gives normal keyboard control to Emacs; press `F12` again after returning to MD. On a Mac keyboard whose function row controls media, use `fn-F12`. The reserved `C-c C-j` and `C-c C-k` bindings explicitly select Emacs and Codex control, while `C-c d` detaches without stopping MD.

Rig uses tmux for live-process persistence. Closing Emacs leaves MD running.
Codex separately assigns a session ID to the saved conversation; `codex resume
<SESSION>` or `/resume` can reload that history after the process exits. A
Codex session ID belongs to one resumable conversation, not to MD or a worker's
durable identity. Ending an agent session remains a deliberate, manual handoff:
ask the identity to update its Bead and continuity records, wait for it to
finish, and then exit Codex. A dedicated handoff command is future work.

## Roster

Rig opens the `*Roster*` sidebar at startup. Each identity shows separate,
labelled lifecycle, tmux, attachment, work, and task fields:

- `active` means a management seat is enabled; it does not mean the agent is
  busy.
- `ready` means a worker passed the onboarding gates and may accept work;
  it does not mean a process exists.
- `running` means the named tmux session exists. It does not show whether Codex
  is working or waiting for input.
- `attached` means one or more tmux clients are connected; `detached` means a
  running session has no connected clients.
- `stopped` means the tmux session does not exist, so it has no attachment
  state.

The visible Roster refreshes every two minutes. Press `g` to refresh
immediately; opening an identity also refreshes it immediately. Opening an
identity from the Roster replaces the buffer shown in the existing main window
without splitting or rearranging other windows. The replaced terminal buffer
and its process remain alive for later reopening.

## Core and instances

`main` is Rig's worker-free software. Each project owns a dedicated team and
Beads database in a separate operating repository. Start from
[`templates/instance/`](templates/instance/), set `software_root` and
`project_root` in `rig.toml`, and launch `./rig` there. `./rig worker-slug` opens
a worker. The two paths may select different checkouts: tested software can
run the team while workers change the assigned source repository.

Worker manifests declare the source integration branch, usually `main`, not
an instance branch. The launcher supplies the operating home's `BEADS_DIR`
even when work happens in source worktrees. Existing colocated launchers remain
supported. See the [bootstrap and migration procedure](knowledgebase/wiki/decisions/project-operating-repositories.md)
before moving an existing team or database.

To onboard a worker in an instance, copy the files in
[`templates/worker/`](templates/worker/), substitute a unique slug and display
name, set `integration_branch`, track the home in the operating repository,
then provision and launch them:

```sh
RIG_INSTANCE_ROOT=/path/to/operating-home ./bin/rig-fleet-onboard --check <worker-slug>
RIG_INSTANCE_ROOT=/path/to/operating-home ./bin/rig-fleet-onboard <worker-slug>
RIG_INSTANCE_ROOT=/path/to/operating-home ./bin/rig-fleet-emacs <worker-slug>
```

The `fleet/` directory and `rig-fleet-*` commands are current compatibility
names. Worker sessions use tmux names and buffers derived from their stable
slug. `M-x rig-fleet-member`, `M-x rig-fleet-member-status`, and
`M-x rig-fleet-member-detach` accept that slug.

Workers inherit [`fleet/session-defaults.toml`](fleet/session-defaults.toml).
Their optional `session-defaults.toml` files can override individual values.
`bd mail` is optional notification infrastructure; Beads comments and notes
remain the durable handoff path until delivery is proven.

Project knowledge starts at [`knowledgebase/wiki/index.md`](knowledgebase/wiki/index.md). Work is tracked in Beads.
