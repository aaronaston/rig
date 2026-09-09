# Operator named-worker direction

On 2026-09-09 Aaron accepted a Rig architecture with one singleton Managing
Director seat and durable, named, generalist workers. He rejected permanent
specialist role taxonomy as unnecessary: unfamiliar work should be expressed
through assignment context, skills, constraints, and acceptance criteria rather
than requiring a new worker role.

MD should remain available for conversation, requirements, dispatch, monitoring,
and validation, delegating most substantial execution to persistent workers.
Workers may create their own bounded native subagents while remaining accountable
for the parent Bead and consolidated result.

Aaron identified stable names, durable homes, tmux discoverability, blocking and
unblocking, and regular standups as useful continuity mechanisms. He also asked
Rig to use Codex's existing resumable session ID with a display name rather than
inventing another opaque worker ID. Rig interprets the display name and stable
slug as the durable worker address and the Codex session ID as replaceable,
resumable execution history associated with that worker.

Source: [direct operator instruction](../../raw/2026-09-09-named-generalist-worker-direction.md).
