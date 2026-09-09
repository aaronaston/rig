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

## First Named Worker

MD selected [Nadia](fleet/nadia/README.md), a named generalist Worker who uses
she/her pronouns, as Rig's first worker. Her display name identifies the durable
collaborator; her Codex session ID identifies the current resumable conversation.
Her durable home is `fleet/nadia/`; her isolated checkout belongs at
`fleet/nadia/worktree/` on branch `fleet/nadia`.

The `fleet/` directory and `rig-fleet-*` commands are current compatibility
names. They implement the worker model but have not yet been migrated because
their paths are embedded in worktrees, branches, tmux sessions, tests, and
operating habits.

Provision the worktree once:

```sh
./bin/rig-fleet-onboard --check nadia
./bin/rig-fleet-onboard nadia
```

Then launch Nadia in a new Emacs instance:

```sh
./bin/rig-fleet-emacs nadia
```

From an existing Emacs instance, load `emacs/rig.el` and run the compatibility
command `M-x rig-fleet-member`. Worker sessions use tmux names and buffers
derived from the stable worker slug; Nadia uses `rig-fleet-nadia` and
`*rig-fleet-nadia*`. `M-x rig-fleet-member-status` and
`M-x rig-fleet-member-detach` accept the same slug. Worker sessions inherit a
distinct `BEADS_ACTOR` from the worker record.

Workers inherit [`fleet/session-defaults.toml`](fleet/session-defaults.toml):
Luna with high reasoning, the same workspace-write sandbox, and Auto-review. A
worker's optional `session-defaults.toml` can override individual values. These
settings are fixed when a Codex process starts; resuming a saved session may
apply explicit launch-time overrides permitted by Codex.

A worker branch is synchronized at task start, not while idle. After claiming a
new Bead and before editing, the worker verifies a clean worktree and
fast-forwards from the then-current local `main`. Because this repository has
no remote, that operation is a local merge rather than `git pull`.

`bd mail` is not itself a mailbox: it delegates to a configured external provider. No provider is configured yet, so Nadia's mailbox address is reserved but not operational. Until delivery is proven, use Beads comments and notes for handoff.

Mail is optional notification infrastructure, not an onboarding gate or a task
ledger. Nadia is ready: her worktree, identity, shared Beads access, reviewed implementation
trial, and refreshed Luna/high Auto-review validation cycle are proven.

Project knowledge starts at [`knowledgebase/wiki/index.md`](knowledgebase/wiki/index.md). Work is tracked in Beads.
