# MD session defaults

Date: 2026-09-05. Status: accepted.

The **seat** is Managing Director. A **session** is one invocation occupying that seat. Agent client, model, and reasoning effort belong to the session configuration and do not define MD's identity.

MD sessions default to:

- runner: Codex CLI
- model: `gpt-5.6-sol` (Sol)
- reasoning effort: `high`

These are defaults rather than constraints. Rig's launcher should read a runner-neutral session description and translate it to the selected client. A later session may use another client, provider, or model without renaming the seat or discarding its history.

The checked-in declaration is [`md/session-defaults.toml`](../../../md/session-defaults.toml). The exact model and Codex keys were verified against the [local CLI observation](../../raw/2026-09-05-codex-cli-observation.md) and official OpenAI documentation linked there. The user's direction is preserved [verbatim](../../raw/2026-09-05-md-session-defaults.md).

For the current Codex CLI, the launcher can express the defaults as `--model gpt-5.6-sol --config model_reasoning_effort=high`. The launcher itself has not yet been built.

