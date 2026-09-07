# Emacs terminal backends for Rig

Retrieved: 2026-09-06.

## Local observation

Codex CLI completed startup and accepted input through Emacs's built-in `term`, but its in-place status updates accumulated as scrolling lines. Earlier, the alternate-screen interface also failed to remain visible, leading Rig to use `--no-alt-screen` as an interim workaround. These are observations from the Rig session, not claims that every Codex and `term` combination fails.

## GNU Emacs terminal

The [GNU Emacs terminal-emulator manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/Terminal-emulator.html) documents `term` and its character and line modes. It establishes that `term` is a terminal emulator but does not claim complete compatibility with every terminal application.

## Emacs-libvterm

The [emacs-libvterm README](https://github.com/akermu/emacs-libvterm/blob/master/README.md) describes `vterm` as a full terminal emulator backed by the external `libvterm` C library. It specifically contrasts `vterm` with the incomplete escape-code coverage and lower burst-output performance of the built-in `term` emulator.

Local verification found GNU Emacs 31.1 with dynamic-module support. Rig installed MELPA `vterm` version `20260730.1414`, built its native module using CMake and GNU libtool, loaded both `vterm.elc` and `vterm-module.so`, and created a smoke-test buffer in `vterm-mode`.

## Decision relevance

Rig uses `vterm` for the interactive Emacs display and keeps tmux as the persistence layer. Codex can therefore use its normal alternate-screen rendering. This addresses the observed class of cursor-redraw failures; the Codex interface still requires live verification in the graphical Emacs session.
