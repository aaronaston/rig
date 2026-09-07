# Rig

Rig is a small Emacs control center for a management seat and persistent implementation fleet. Aaron directs Managing Director (MD); MD records requirements in Beads, delegates implementation, and validates fleet output.

For a complete shutdown and restart with the Rig Roster sidebar, follow the
[restart quickstart](quickstart.md).

## Open MD

From this repository root:

```sh
./bin/rig-emacs
```

Emacs opens the `*rig-md*` buffer. A new MD session starts Codex CLI with the defaults in [`md/session-defaults.toml`](md/session-defaults.toml): Sol with high reasoning, a workspace-write sandbox, and Auto-review for eligible approval requests. Its working directory is `md/`, and [`md/AGENTS.md`](md/AGENTS.md) supplies seat-specific instructions. The parent Rig repository is also available as a work area. If MD is already running, Emacs reconnects to that session. Type in the buffer to talk to it.

Rig displays Codex through Emacs `vterm`, attached to the persistent tmux session. `vterm` supports the cursor movement and alternate-screen behavior that Codex uses to redraw live status. Install the Emacs dependency once with `./bin/rig-install-emacs-deps`; building it requires CMake and GNU libtool.

Inside an existing Emacs instance, load `emacs/rig.el` and run `M-x rig-md`. Use `M-x rig-md-status` to check the session. In MD's terminal buffer, press `F12` to enter or leave vterm copy mode. Copy mode gives normal keyboard control to Emacs; press `F12` again after returning to MD. On a Mac keyboard whose function row controls media, use `fn-F12`. The reserved `C-c C-j` and `C-c C-k` bindings explicitly select Emacs and Codex control, while `C-c d` detaches without stopping MD.

Rig uses tmux for persistence. Closing Emacs leaves MD running. Ending an agent session remains a deliberate, manual handoff: ask MD to update its task and continuity records, wait for it to finish, and then exit Codex. A dedicated handoff command is future work.

## First Fleet Member

MD selected [Nadia](fleet/nadia/README.md), a Software Engineer who uses she/her pronouns, as the first fleet member. Her durable home is `fleet/nadia/`; her isolated checkout belongs at `fleet/nadia/worktree/` on branch `fleet/nadia`.

Provision the worktree once:

```sh
./bin/rig-fleet-onboard --check nadia
./bin/rig-fleet-onboard nadia
```

Then launch Nadia in a new Emacs instance:

```sh
./bin/rig-fleet-emacs nadia
```

From an existing Emacs instance, load `emacs/rig.el` and run `M-x rig-fleet-member`. Fleet sessions use tmux names and buffers derived from the member slug; Nadia uses `rig-fleet-nadia` and `*rig-fleet-nadia*`. `M-x rig-fleet-member-status` and `M-x rig-fleet-member-detach` accept the same slug. Fleet sessions inherit a distinct `BEADS_ACTOR` from the member record.

Fleet members inherit [`fleet/session-defaults.toml`](fleet/session-defaults.toml): Luna with high reasoning, the same workspace-write sandbox, and Auto-review. A member's optional `session-defaults.toml` can override individual values. These settings are fixed when a tmux session starts; stop and relaunch an existing session to apply changes.

A fleet branch is synchronized at task start, not while idle. After claiming a
new Bead and before editing, the member verifies a clean worktree and
fast-forwards from the then-current local `main`. Because this repository has
no remote, that operation is a local merge rather than `git pull`.

`bd mail` is not itself a mailbox: it delegates to a configured external provider. No provider is configured yet, so Nadia's mailbox address is reserved but not operational. Until delivery is proven, use Beads comments and notes for handoff.

Mail is optional notification infrastructure, not an onboarding gate. Nadia is
ready: her worktree, identity, shared Beads access, reviewed implementation
trial, and refreshed Luna/high Auto-review validation cycle are proven.

Project knowledge starts at [`knowledgebase/wiki/index.md`](knowledgebase/wiki/index.md). Work is tracked in Beads.
