# MD session lifecycle

Date: 2026-09-06. Status: adopted for Rig v0.

MD's session runs inside a tmux session named `rig-md`. Emacs owns the user-facing terminal buffer and can detach or reattach without ending Codex. Closing Emacs therefore leaves MD running.

Emacs attaches to tmux through `vterm`. Live use showed that the built-in `term` emulator mishandled both Codex's alternate screen and in-place status redraws: disabling the alternate screen made the session visible, but status updates accumulated as scrolling lines. `vterm` is a full terminal emulator backed by `libvterm`, so Codex now uses its normal alternate-screen interface. See the [terminal-backend source record](../sources/emacs-terminal-backends.md).

Codex starts with `md/` as its working directory. That directory contains the seat-specific instructions, role definition, and session configuration. The launcher grants the parent Rig repository as an additional work area, so MD can maintain shared code, the knowledgebase, and the root Beads workspace. See the [seat home decision](seat-home.md).

The Emacs command `rig-md` creates the tmux session if needed and attaches to it. A new Codex session starts idle; the launcher does not submit an automatic first prompt. A Rig-specific minor-mode map reserves `F12` before the terminal can receive it. `F12` toggles vterm copy mode, which gives keyboard control to Emacs while preserving the displayed terminal; `C-c C-j` and `C-c C-k` select Emacs and Codex control directly. In MD's terminal, `C-c d` invokes `rig-md-detach` and removes only the Emacs terminal client. Rig v0 does not provide a force-stop command. To end a session, Aaron first asks MD to update its Bead and continuity records, waits for completion, and then exits Codex normally.

This choice is an initial implementation default based on the earlier design recommendation. It can be revised after hands-on use.
