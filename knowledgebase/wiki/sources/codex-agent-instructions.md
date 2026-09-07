# Codex agent-instruction discovery

Source: OpenAI, “Custom instructions with AGENTS.md,”
https://learn.chatgpt.com/docs/agent-configuration/agents-md, accessed
2026-09-06. Relevant section: “How Codex discovers guidance.”

OpenAI documents that Codex constructs its instruction chain once per run. At
project scope it starts at the project root and walks down to the current
working directory, loading at most one recognized instruction file per
directory. Files closer to the working directory appear later and therefore
override broader guidance.

Rig relies on this documented precedence by starting Nadia in her durable
`fleet/nadia/` home. Codex therefore receives root project instructions followed
by Nadia's closer `AGENTS.md`; her isolated worktree is granted separately as an
additional writable area.

