# Project operating repositories

Date: 2026-09-10. Status: accepted design; migration tracked in
`beads-tests-dze.17`, database portability in `beads-tests-dze.16`.

Aaron clarified that each project has a dedicated team and Beads database.
He agreed to separate `aaronaston/rig` software from a private operating
repository, provisionally `aaronaston/rig-test-instance`, and directed MD to
implement `.17`. This supersedes the long-lived instance-branch model.
Source: [operator conversation](../../raw/2026-09-10-project-operating-repositories.md).

The operating home owns MD, worker identities, preferences, and project task
coordination. The assigned source repository owns implementation commits.
Rig software is an explicitly selected dependency. A Rig-development worker
branches from core `main` and returns core commits without instance ancestry.

`rig.toml` declares `software_root` and `project_root`, relative to the operating
home or absolute. The operating launcher `./rig` selects software and exports
`RIG_INSTANCE_ROOT`; `./rig worker-slug` opens a worker. `RIG_SOFTWARE_ROOT`
overrides the configured software checkout for deliberate candidate testing.
The loaded Emacs file determines helper-script location. Discovery and session
defaults come from the operating home; MD receives both that home and the
assigned project as work areas. Workers receive their owned worktree and the
project Beads directory. The source checkout is not implicitly their home.

Each operating home owns `.beads/`; launches explicitly set `BEADS_DIR`.
The installed Beads CLI honors it from worker directories. Beads history is
not ordinary Git source and must be backed up/restored separately. Existing
project history must be preserved, not replaced with a newly empty database.

New-layout tmux names carry a hash of the canonical operating-home path,
including explicitly configured names. Colocated legacy installations retain
their names. One Emacs process operates one home; use separate Emacs processes
for multiple projects. Moving a home changes its runtime namespace, so migrate
only after recording and deliberately stopping old runtimes. Saved Codex
conversation IDs remain separate from tmux names and directory paths.

## Bootstrap and migration

1. Create an independent private operating repository using
   `templates/instance/`. Set its paths; copy appropriate MD and worker defaults
   and identities. Rewrite bootstrap links to the assigned source, and preserve
   personal identity and saved conversation associations. Keep worker readiness
   at provisioning until the new topology passes its gates.
2. For a new project, initialize its Beads database in the operating home. For
   this existing project, use `.16` to restore and verify its full database
   history. Do not import passive JSONL as the normal migration mechanism.
3. Set each worker's `integration_branch` to the assigned source branch and
   use a new, unoccupied worker branch name. Run
   `RIG_INSTANCE_ROOT=/path/to/home /path/to/rig/bin/rig-fleet-onboard --check slug`
   then the same command without `--check`. This creates a source-repository
   worktree from the specified branch, independently of operating Git history.
4. Run `./rig` and inspect the Roster, Beads routing, runtime identity, and work
   areas. Validate a bounded named-worker core change before declaring migration
   complete. Candidate tests use a separate disposable operating home to avoid
   launching a second runtime for an existing durable identity.
5. Before live cutover, record active sessions, resolve active work, take a final
   database backup, and verify the restore. Retain the old instance branch and
   worktree until the new home is accepted. Remote repository creation and push
   remain separate from local preparation and Dolt synchronization.

Rollback before cutover is simply to keep using the existing operating checkout.
After cutover, stop new assignments, preserve new commits and database changes,
and reconcile those changes before returning to the old home. Never start both
copies of Nadia or treat a stale database snapshot as authoritative.

The old core-to-instance branch decision is retained as historical context.
The implementation preserves colocated launcher compatibility while the live
operating migration and database recovery are validated.

## Validation commands

Run the full suites from the software checkout:

```sh
emacs --batch -Q -l test/rig-tests.el -l test/rig-instance-tests.el -f ert-run-tests-batch-and-exit
python3 test/instance-topology.py
```

The topology test creates two disposable Git/Beads projects, runs the operating
launcher with a process recorder, provisions source worktrees, verifies database
isolation, commits actual fixture changes, and fast-forwards the source branch.
It does not impersonate Nadia or substitute for a live named-worker trial.
