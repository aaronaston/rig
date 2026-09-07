# Project Instructions for AI Agents

## Rig Knowledgebase

Read [knowledgebase/wiki/index.md](knowledgebase/wiki/index.md) for project sources, scope, and decisions. Follow [knowledgebase/AGENTS.md](knowledgebase/AGENTS.md) when maintaining the knowledgebase. Beads remains the task and status system; the knowledgebase contains durable documentation, not a parallel task queue. Working project name: Rig. Aaron is the operator. Managing Director (MD), in root `md/`, is Aaron's delegate for requirements capture, Beads work definition, fleet orchestration, and validation. MD uses they/them pronouns by their expressed preference. Fleet implementers live under `fleet/`; Nadia, a Software Engineer using she/her pronouns, is the first member. Runner and model remain replaceable session properties. Ask design questions in visible replies.

A Codex session launched through Rig may occupy the MD seat or a fleet identity. MD starts in `md/`; a fleet member starts in their durable `fleet/<member>/` home and receives their isolated `worktree/` as an additional work area. Closer instruction files refine these repository instructions. Read [md/README.md](md/README.md) and [fleet/README.md](fleet/README.md). Wait for Aaron or MD to assign work rather than inventing a startup task.

## Git Authority

Rig explicitly authorizes its seats and fleet members to use local Git for assigned work. This project-owned policy supersedes the conservative local-Git default in generated Beads instruction blocks below.

- Seats may inspect Git state, create branches, stage changes, and make local commits for documentation and other assigned repository updates.
- MD may create, inspect, repair, and retire fleet-member worktrees and branches as part of onboarding, cross-boarding, validation, and off-boarding.
- Fleet members may create, inspect, update, commit within, and retire their own worktree and branch. They must not modify another member's worktree or branch, or the main checkout, unless MD explicitly reassigns that scope.
- Before destructive branch or worktree operations, resolve the exact target and verify that unique work is committed, transferred, or intentionally discarded.
- Remote pushes, force-pushes, remote configuration changes, and Dolt remote synchronization require separate direction from Aaron or MD. Local Git authority does not imply remote publication authority.
- A higher-level sandbox or orchestrator restriction can still prevent Git writes. If it does, report that external restriction precisely; do not reinterpret it as repository policy.

This file provides instructions and context for AI coding agents working on this project.

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


## Build & Test

_Add your build and test commands here_

```bash
# Example:
# npm install
# npm test
```

## Architecture Overview

_Add a brief overview of your project architecture_

## Conventions & Patterns

_Add your project-specific conventions here_
