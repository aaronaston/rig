# Seat home and work area

Date: 2026-09-06. Status: adopted for Rig v0.

Each Rig seat starts in its own directory. For Managing Director, `md/` is both the durable seat home and the session's current working directory. This makes relative paths, file listings, and the phrase "working directory" resolve from the seat's own context.

The seat directory contains the role definition, seat-specific instructions, and session defaults. Codex loads repository instructions from the project root and then the closer `md/AGENTS.md`, allowing the seat file to refine the common rules.

MD still needs to implement work across Rig. The launcher therefore grants the parent repository as an additional work area. Seat home and work scope are separate concepts: `md/` supplies identity and local context, while the repository root supplies the shared project, knowledgebase, and Beads database.

This arrangement does not create code isolation for MD. Durable named workers
use separate worktrees for concurrent writing. Native subagents remain within
their parent's runtime authority and must not write concurrently in the same
checkout unless the parent provides additional isolation.
