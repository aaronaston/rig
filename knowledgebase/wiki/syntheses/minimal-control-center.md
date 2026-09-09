# Minimal Rig control center

Status: MD launcher implemented; Nadia is ready as the first named Worker.
[Scope and naming](../decisions/initial-scope.md) and the [named-worker
architecture](../decisions/named-generalist-worker-architecture.md) reflect the
latest operator direction.
Background: [Wheelhouse source findings](../sources/wheelhouse.md).

Rig has one singleton seat, Managing Director in root `md/`, and durable named
generalist Workers currently stored under the compatibility `fleet/` path. A
worker's display name and slug identify the durable collaborator. A Codex session
ID identifies one resumable saved conversation; tmux identifies and preserves
the current live terminal process. Beads holds work and task history. The
knowledgebase holds source-backed decisions and explanations.

The implemented first step starts or reconnects to MD using `M-x rig-md`. The
operating cycle is to discuss intent with Aaron, record a bounded Bead, delegate
substantial execution to a named worker, monitor blockers, validate the returned
evidence, and preserve shared decisions. Fresh-session ID capture and automatic
resume remain to be implemented and proven.

MD stays available for operator conversation, clarifies and records requirements,
delegates execution, and validates outputs. Emacs is the console, while tmux
keeps live processes visible when Emacs detaches. Runner-neutral defaults are
translated to Codex CLI commands. The first Worker is Nadia; her durable home
and name survive replacement of her isolated worktree and Codex session.

MD starts in `md/` with the main repository as an additional work area. A worker
starts in their durable home, such as `fleet/nadia/`, with `worktree/` as an
additional writable area. This makes closer worker instructions effective while
isolating code changes. See the [seat home](../decisions/seat-home.md) and
[worker lifecycle](../decisions/fleet-member-lifecycle.md) decisions.

MD sessions use Sol/high for requirements and validation. Worker sessions inherit
Luna/high for bounded execution. Both launch with workspace-write and
Auto-review; Nadia's refreshed validation cycle completed Beads and local Git
operations without surfacing a command approval to Aaron.

Workers may create bounded native subagents while retaining ownership of the
parent Bead and consolidated output. Native child threads are inspectable inside
the parent's Codex client but are not separate named workers or tmux sessions.
When a worker blocks, Beads preserves the question and dependency; tmux or a
future notification mechanism must separately deliver the wake-up signal after
the answer is recorded. A standup summarizes structured exceptions across
worker, task, runtime, worktree, and review state.
