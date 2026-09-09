# Codex session resume and agent-thread controls

Source: “Slash commands in Codex CLI,” OpenAI, [official Codex CLI command
documentation](https://learn.chatgpt.com/docs/developer-commands.md?surface=cli),
accessed 2026-09-09. Relevant sections: `codex resume`, “Resume a saved chat
with `/resume`,” “Switch agent threads with `/agent`,” `/rename`, `/fork`, and
status-line session ID.

OpenAI documents that `codex resume` continues an interactive session by ID and
that `/resume` reloads a selected saved chat with its original history intact.
`/rename` changes the saved chat's recognizable name without changing its
transcript, while `/fork` creates a new chat with a fresh ID. The CLI status line
can include the current session ID.

OpenAI also documents `/agent` and `/subagents` as the interface for switching
to a spawned agent thread to inspect or continue its work. This supports Rig's
boundary: a native child is visible inside the parent Codex client, but it is
not thereby a separate tmux-backed durable worker.

Rig's live 2026-09-09 MD environment exposed equal `CODEX_SESSION_ID` and
`CODEX_THREAD_ID` UUID values. That is a local runtime observation, not a
promise that every runner or future Codex release uses the same environment
variables. Rig should discover supported session metadata rather than require a
hand-authored ID in a static worker manifest.
