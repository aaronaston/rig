# Codex CLI observation — 2026-09-05

Local command inspected: `codex --help`, `codex --version`, and `codex exec --help`.

Observed version: `codex-cli 0.153.1`.

Observed interactive options include `--model <MODEL>`, `--config <key=value>`, `--profile <CONFIG_PROFILE_V2>`, and `--cd <DIR>`. The help output describes `--config` as a per-invocation override of configuration values.

Official sources checked:

- OpenAI, “GPT-5.6 Sol Model”: https://developers.openai.com/api/docs/models/gpt-5.6-sol
- OpenAI, “Configuration Reference”: https://learn.chatgpt.com/docs/config-file/config-reference

The model page identifies `gpt-5.6-sol` and lists `high` as a supported reasoning effort. The configuration reference identifies `model` and `model_reasoning_effort` as Codex configuration keys.

