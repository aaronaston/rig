# Proposed minimal Rig

Status: MD launcher implemented; first fleet-member provisioning is in progress. [Scope and naming](../decisions/initial-scope.md) reflect the latest user direction.
Background: [Wheelhouse source findings](../sources/wheelhouse.md).

A seat or fleet member has a durable role and home; a session is a running coding-agent client occupying that identity. Rig has Managing Director in root `md/` and fleet implementers under `fleet/`. Beads holds work and task history. The knowledgebase holds source-backed decisions and explanations.

The implemented first step starts or reconnects to MD using `M-x rig-md`. A proposed full cycle is to discuss a bounded task with Aaron, claim the bead, do the work, and save the result and continuity notes. Fresh-session handoff recovery remains to be implemented and proven.

MD accepts operator direction, clarifies and records requirements, delegates implementation, and validates outputs. Emacs is the console, while tmux keeps sessions alive when Emacs detaches. Runner-neutral defaults are translated to Codex CLI commands. The first fleet member is Nadia; her durable home survives replacement of her isolated worktree.

MD starts in `md/` with the main repository as an additional work area. A fleet member starts in their durable home, such as `fleet/nadia/`, with `worktree/` as an additional writable area. This makes closer member instructions effective while isolating code changes. See the [seat home](../decisions/seat-home.md) and [fleet lifecycle](../decisions/fleet-member-lifecycle.md) decisions.
