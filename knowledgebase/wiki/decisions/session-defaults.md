# Seat and worker session defaults

Date: 2026-09-05; revised 2026-09-09. Status: accepted.

The singleton **seat** is Managing Director. A **Worker** is a durable named
generalist. A **Codex session** is one saved, resumable conversation occupied by
MD or a worker. Client, session ID, model, reasoning effort, and live tmux
process do not define the durable seat or worker.

MD sessions default to:

- runner: Codex CLI
- model: `gpt-5.6-sol` (Sol)
- reasoning effort: `high`

Worker execution sessions default to:

- runner: Codex CLI
- model: `gpt-5.6-luna` (Luna)
- reasoning effort: `high`

This split keeps the requirements, design, orchestration, and validation seat
on Sol/high while using the lower-cost Luna/high profile for bounded worker
implementation. Shared fleet defaults live in
[`fleet/session-defaults.toml`](../../../fleet/session-defaults.toml). A worker
may override individual values in an optional local `session-defaults.toml`;
the shared file remains the default for existing and future workers. The path
and filename use the retained fleet compatibility name.

These are defaults rather than constraints. Rig's launcher should read a
runner-neutral session description and translate it to the selected client. A
later session may use another client, provider, or model without renaming the
seat or worker. Codex-generated session IDs are discovered runtime history, not
static defaults; a worker may resume an earlier ID or begin a fresh session
without changing their durable identity.

The MD declaration is [`md/session-defaults.toml`](../../../md/session-defaults.toml). The exact model and Codex keys were verified against the [local CLI observation](../../raw/2026-09-05-codex-cli-observation.md) and official OpenAI documentation linked there. The initial MD direction is preserved [verbatim](../../raw/2026-09-05-md-session-defaults.md); the accepted fleet split is in the [operator runtime-policy source](../sources/operator-runtime-policy.md).

The Emacs launcher reads these runner-neutral declarations and emits the model,
reasoning, sandbox, and approval arguments for Codex CLI. A tmux session keeps
the live process and its launch configuration. Codex separately persists a
conversation under its session ID; `codex resume <SESSION>` or `/resume` reloads
that history, subject to the selected launch overrides and working-directory
choice documented by Codex.
