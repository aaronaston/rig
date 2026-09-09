# Operator direction: named generalist workers

Date: 2026-09-09
Source: Aaron, direct conversation with Managing Director

Aaron accepted the proposed distinction between the singleton Managing Director
seat, durable named workers, replaceable sessions, isolated work areas, Beads
state, and transient native subagents. He directed MD to record the architecture
permanently at Rig's top level and reconcile the other project materials.

Aaron rejected pigeon-holing workers into specialist roles. Rig should begin
with only MD and a generic Worker class. MD should remain as free as possible
for conversation: perform enough investigation to understand and specify the
request, then normally delegate execution to a persistent worker. Workers may
manage their own subagents when required.

Aaron identified continuity, discoverability, escalation, pausing, unblocking,
and regular standups as reasons to retain named durable worker instances rather
than faceless automatons. Durable workers should be visible through tmux so
authorized collaborators can attach and observe their work. Beads may carry
blockers and answers, with a separate mechanism needed to signal a waiting
runtime to continue.

Aaron also proposed using Codex's existing resumable session identifier together
with a display name rather than inventing both a worker ID and a display name.
Rig must preserve the distinction between the durable named worker and one
Codex session history while taking advantage of `/resume` where appropriate.
