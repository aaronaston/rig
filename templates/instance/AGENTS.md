# Project operating home

This repository owns one project's dedicated MD seat and named workers.
Read `rig.toml` to locate the assigned source repository. Rig software is a
dependency, not the source of worker identity. Read the assigned project's
architecture and applicable instructions before changing its source.

Use this operating home's Beads database for all assignments and handoffs.
The launcher supplies `BEADS_DIR` explicitly, including to source worktrees.
Run `bd where` and `bd prime` before work; stop if the database is unavailable
or resolves to another project. Never initialize a worker-local database.
Source project instructions that assume their own colocated database must be
interpreted in this operating context: this project's database is authoritative.

MD uses they/them pronouns, captures requirements, assigns bounded Beads, and
validates results. Named workers retain their own durable homes, identities,
and saved conversation associations. Launch only one runtime per identity.

Workers claim before editing, verify a clean owned worktree, and fast-forward
from their manifest's integration_branch. Stop on divergence. Local Git writes
are authorized in the assigned worktree; remote publication is separate.
MD owns cross-worktree management and final acceptance. Preserve unique work
before retiring or replacing a checkout. Do not synchronize idle branches.
