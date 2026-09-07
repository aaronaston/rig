# Role-based session defaults

Date: 2026-09-05; revised 2026-09-07. Status: accepted.

The **seat** is Managing Director. A **session** is one invocation occupying that seat. Agent client, model, and reasoning effort belong to the session configuration and do not define MD's identity.

MD sessions default to:

- runner: Codex CLI
- model: `gpt-5.6-sol` (Sol)
- reasoning effort: `high`

Fleet implementation sessions default to:

- runner: Codex CLI
- model: `gpt-5.6-luna` (Luna)
- reasoning effort: `high`

This split keeps the requirements, design, orchestration, and validation seat
on Sol/high while using the lower-cost Luna/high profile for bounded fleet
implementation. Shared fleet defaults live in
[`fleet/session-defaults.toml`](../../../fleet/session-defaults.toml). A member
may override individual values in an optional local `session-defaults.toml`;
the shared file remains the default for existing and future fleet members.

These are defaults rather than constraints. Rig's launcher should read a runner-neutral session description and translate it to the selected client. A later session may use another client, provider, or model without renaming the seat or discarding its history.

The MD declaration is [`md/session-defaults.toml`](../../../md/session-defaults.toml). The exact model and Codex keys were verified against the [local CLI observation](../../raw/2026-09-05-codex-cli-observation.md) and official OpenAI documentation linked there. The initial MD direction is preserved [verbatim](../../raw/2026-09-05-md-session-defaults.md); the accepted fleet split is in the [operator runtime-policy source](../sources/operator-runtime-policy.md).

The Emacs launcher reads these runner-neutral declarations and emits the model,
reasoning, sandbox, and approval arguments for Codex CLI. A tmux session keeps
the configuration with which its Codex process started; changed defaults take
effect only after that session is stopped and relaunched.
