# Rig Beads Workflow Context

Use the root Beads workspace as Rig's durable task and status system. The
knowledgebase preserves sources, decisions, and synthesis; it is not a parallel
task queue.

## Authority

- The MD seat and named workers are authorized to use local Git in their
  assigned source worktrees, subject to the scope in the applicable
  `AGENTS.md` files. The source repository owns implementation history; the
  separate project operating home owns worker identity and project task state.
- MD may create, inspect, repair, and retire worker worktrees and
  branches after preserving or deliberately disposing of unique work.
- Workers may manage their own worktree and branch. They must not modify
  another worker's worktree or branch, or the main checkout, unless MD
  explicitly reassigns that scope.
- Remote pushes, force-pushes, remote configuration changes, and Dolt remote
  synchronization require separate direction from Aaron or MD.
- A higher-level sandbox or orchestrator restriction still wins. If one blocks
  an authorized operation, report that external restriction precisely.

## Workflow

- Run `bd where`, `bd ready`, then `bd show <id>` before starting assigned work.
- The operating launcher explicitly supplies `BEADS_DIR` to source worktrees.
  `bd where` must resolve to the operating home's `.beads/` directory. Do not
  initialize a nested worker-local database or treat the historical colocated
  database path as the new authority; it remains compatibility material.
- Create a Beads issue before implementation when no suitable issue exists.
- Claim work with `bd update <id> --claim`.
- After claiming and before the first edit, synchronize the owned branch from
  the current integration branch. Verify the worktree is clean and prior work
  is resolved first. The worker's operating-home configuration declares that
  branch; from the durable worker home—not from the operating repository root
  or inside the source worktree—a core implementation worker runs
  `git -C worktree merge --ff-only main`. Do not update idle branches
  speculatively. If fast-forward is impossible, stop and return the divergence
  to MD without forcing, rebasing, or discarding.
- Use inline `bd update` flags; do not use interactive `bd edit`.
- Keep discovered follow-up work, dependencies, and blockers in Beads rather
  than Markdown TODO lists.
- Close completed issues with `bd close <id> --reason="..."` only after the
  acceptance criteria and relevant validation have been satisfied.
- Before ending an implementation session, close completed issues, run the
  relevant quality gates, and report changed files, validation, issue status,
  whether `main` advanced during implementation, and any remaining publication
  or synchronization step.

## Useful Commands

```bash
bd ready
bd list --status=open
bd list --status=in_progress
bd blocked
bd show <id>
bd update <id> --claim
bd close <id> --reason="Completed"
bd stats
```

The source repository's remote configuration and the operating home's Beads
database are separate concerns. Beads data remains under the operating home
unless Aaron or MD separately configures and directs database synchronization;
remote Git publication likewise remains separately authorized.
