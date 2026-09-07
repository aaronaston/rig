# Gas Town mail

Sources, accessed 2026-09-06:

- Gas Town, `AGENTS.md`, “Gas Town Multi-Agent Communication,”
  https://github.com/gastownhall/gastown/blob/main/AGENTS.md
- Gas Town, `docs/design/architecture.md`, “Two-Level Beads Architecture,”
  https://github.com/gastownhall/gastown/blob/main/docs/design/architecture.md
- Gas Town, `internal/mail/router.go`, mail routing implementation,
  https://github.com/gastownhall/gastown/blob/main/internal/mail/router.go

Gas Town provides `gt mail inbox`, `read`, and `send` as persistent
agent-to-agent messaging. It distinguishes persistent mail from `gt nudge`,
which delivers immediate text to a running session.

Mail is not stored in an ordinary project's issue database. Gas Town documents
a two-level Beads architecture: town-level Beads hold mail and cross-rig agent
identity, while rig-level Beads hold project implementation issues. The mail
router resolves mail delivery to the town-level `.beads` database when a Gas
Town workspace is available.

Inference for Rig: setting `mail.delegate = "gt mail"` is not sufficient by
itself. Rig would also need the `gt` executable, a Gas Town town workspace,
agent/address registration, and lifecycle integration. Adopting that system is
an architectural choice, not a one-line mailbox toggle.

