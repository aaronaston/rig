# Agent Instructions

## Rig Knowledgebase

Read [ARCHITECTURE.md](ARCHITECTURE.md) for Rig's operating model and
[knowledgebase/wiki/index.md](knowledgebase/wiki/index.md) for project sources,
scope, and decisions. Follow [knowledgebase/AGENTS.md](knowledgebase/AGENTS.md)
when maintaining the knowledgebase. Beads remains the task and status system;
the knowledgebase contains durable documentation, not a parallel task queue.
Aaron is the operator. Managing Director (MD), in the project's operating
home, is Aaron's singleton conversational delegate for requirements capture,
Beads work definition, worker orchestration, and validation. MD uses they/them
pronouns by their expressed preference. Durable named workers are generalists.
This source repository is implementation-only: it intentionally has no
project-owned worker identity or Beads authority. A separate project operating
home owns MD, worker identities, preferences, assignments, and the project
database; assigned source worktrees receive that database through an explicitly
supplied `BEADS_DIR`. Runner, model, Codex session ID, and tmux process remain
replaceable runtime properties. The historical colocated and instance-branch
layout remains compatibility material, not the ownership model. Ask design
questions in visible replies.

A Codex session launched through Rig may occupy the MD seat or a named worker
identity. MD starts in `md/`; a worker currently starts in the compatibility
path `fleet/<worker>/` and receives their isolated `worktree/` as an additional
work area. The worker's display name is durable; the Codex session ID identifies
one saved, resumable conversation and does not define the worker. Closer
`AGENTS.md` files refine these repository instructions. Read
[md/README.md](md/README.md) and [fleet/README.md](fleet/README.md). Wait for
Aaron or MD to assign work rather than inventing a startup task.

Named workers may launch bounded native subagents for independent work when
delegation is explicitly requested or authorized by applicable instructions.
Subagents use task-specific labels, never the durable worker's name. The parent
worker owns the Bead, consolidates results, and remains accountable. Serialize
write-heavy child work or provide isolated work areas. Durable workers remain
discoverable through their tmux sessions; native child threads are inspected
inside the parent Codex client rather than treated as separate Rig identities.

## Git Authority

Rig explicitly authorizes its seat and named workers to use local Git for assigned work. This project-owned policy supersedes the conservative local-Git default in generated Beads instruction blocks below.

- Seats may inspect Git state, create branches, stage changes, and make local commits for documentation and other assigned repository updates.
- MD may create, inspect, repair, and retire worker worktrees and branches as part of onboarding, cross-boarding, validation, and off-boarding.
- Workers may create, inspect, update, commit within, and retire their own worktree and branch. They must not modify another worker's worktree or branch, or the main checkout, unless MD explicitly reassigns that scope.
- Before destructive branch or worktree operations, resolve the exact target and verify that unique work is committed, transferred, or intentionally discarded.
- Remote pushes, force-pushes, remote configuration changes, and Dolt remote synchronization require separate direction from Aaron or MD. Local Git authority does not imply remote publication authority.
- A higher-level sandbox or orchestrator restriction can still prevent Git writes. If it does, report that external restriction precisely; do not reinterpret it as repository policy.

## Task-Start Git Synchronization

Synchronize when an identity starts a newly accepted task, not while its branch
is idle and not merely because a session starts or reconnects. After claiming
the Bead and before editing, verify the owned worktree is clean and prior work
is resolved, then update the owned branch from the current integration branch.

The worker's operating-home configuration records the assigned source
repository and integration branch. From the durable worker home—not from the
operating repository root or inside the source worktree—a worker runs
`git -C worktree merge --ff-only <integration-branch>`; this is not a `git pull`.
Core implementation workers normally integrate from `main`, while the
operating home remains the source of worker identity and task state.
If the fast-forward is impossible or unique prior work remains, stop and
return the conflict to MD without forcing, rebasing, or discarding.
At handoff, report whether the integration branch advanced during implementation. MD decides
how any resulting divergence is integrated. Seats follow the same clean-state
and current-base principle on their owned branch, subject to configured remotes
and the remote-operation authority above.

This project uses **bd** (beads) for issue tracking. Run `bd prime` for full workflow context.

> **Architecture in one line:** Issues live in a local Dolt database
> (`.beads/dolt/`); cross-machine sync uses `bd dolt push/pull` (a
> git-compatible protocol), stored under `refs/dolt/data` on your git
> remote — separate from `refs/heads/*` where your code lives.
> `.beads/issues.jsonl` is a passive export, not the wire protocol.
>
> See [SYNC_CONCEPTS.md](https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md)
> for the one-screen overview and anti-patterns (don't treat JSONL as the
> source of truth; don't `bd import` during normal operation; don't
> reach for third-party Dolt hosting before trying the default).

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work atomically
bd close <id>         # Complete work
bd dolt push          # Push beads data to remote
```

## Non-Interactive Shell Commands

**ALWAYS use non-interactive flags** with file operations to avoid hanging on confirmation prompts.

Shell commands like `cp`, `mv`, and `rm` may be aliased to include `-i` (interactive) mode on some systems, causing the agent to hang indefinitely waiting for y/n input.

**Use these forms instead:**
```bash
# Force overwrite without prompting
cp -f source dest           # NOT: cp source dest
mv -f source dest           # NOT: mv source dest
rm -f file                  # NOT: rm file

# For recursive operations
rm -rf directory            # NOT: rm -r directory
cp -rf source dest          # NOT: cp -r source dest
```

**Other commands that may prompt:**
- `scp` - use `-o BatchMode=yes` for non-interactive
- `ssh` - use `-o BatchMode=yes` to fail instead of prompting
- `apt-get` - use `-y` flag
- `brew` - use `HOMEBREW_NO_AUTO_UPDATE=1` env var

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:6cd5cc61 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->

<!-- BEGIN BEADS CODEX SETUP: generated by bd setup codex -->
## Beads Issue Tracker

Use Beads (`bd`) for durable task tracking in repositories that include it. Use the `beads` skill at `.agents/skills/beads/SKILL.md` (project install) or `~/.agents/skills/beads/SKILL.md` (global install) for Beads workflow guidance, then use the `bd` CLI for issue operations.

### Quick Reference

```bash
bd ready                # Find available work
bd show <id>            # View issue details
bd update <id> --claim  # Claim work
bd close <id>           # Complete work
bd prime                # Refresh Beads context
```

### Rules

- Use `bd` for all task tracking; do not create markdown TODO lists.
- Run `bd prime` when Beads context is missing or stale. Codex 0.129.0+ can load Beads context automatically through native hooks; use `/hooks` to inspect or toggle them.
- Keep persistent project memory in Beads via `bd remember`; do not create ad hoc memory files.

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.
<!-- END BEADS CODEX SETUP -->
