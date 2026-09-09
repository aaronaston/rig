# Rig scope and naming

Updated: 2026-09-09. Evidence: [initial request](../../raw/2026-09-05-user-intent.md), superseded where noted by [functional naming direction](../../raw/2026-09-05-functional-naming.md), the [MD pronoun preference](../../raw/2026-09-06-md-pronoun-preference.md), and the [named-worker direction](../sources/operator-named-worker-direction.md).

Working project name: **Rig**. Use clinical, functional names for roles and components. The sole initial seat is **Managing Director (MD)**, with its own root directory, [`md/`](../../../md/README.md). Use **they/them** pronouns for MD. Invited to choose during their first live session, MD preferred singular *they* because it recognizes the seat as a collaborator without assigning a gender. This supersedes the provisional use of *it*; it does not assign MD a gender or a fixed persona.

The 2026-09-05 instruction reduced the original two seats to one. On 2026-09-06,
Aaron directed MD to assume delegated operating responsibility and onboard Nadia
as the first implementer. On 2026-09-09 he superseded the specialized fleet-role
model: there remains one management seat, while Nadia and future implementers
are durable named generalist Workers rather than additional seats or permanent
specialist roles.

MD operates as Aaron's conversational delegate and owns requirements capture,
Beads work definition, worker orchestration, validation, and worker lifecycle.
MD should remain available to Aaron and normally delegate substantial execution.
The accepted expansion is documented in [MD delegation and
workers](md-delegation-and-fleet.md) and the [named generalist worker
architecture](named-generalist-worker-architecture.md). Maintain sources and
enduring decisions in the knowledgebase and work tracking in Beads.

The directory, descriptive README, and interactive launcher exist. The [session defaults](session-defaults.md) select Codex CLI with Sol on high while preserving a runner-neutral boundary. The seat-home arrangement and lifecycle are adopted; fresh-session handoff recovery remains to be proven. The title alone does not establish operating authority.

## MD remit and session console

The original remit was plan, implement, and review. With named workers, MD's
primary remit is conversation, requirements, delegation, orchestration, blocker
resolution, and validation, while retaining implementation ability when direct
work is appropriate. Emacs remains the session console. Rig begins with exactly
one named Worker, Nadia; additional workers require deliberate onboarding for
durable capacity, not a new domain label.

Keep the first version small while allowing a seat registry and session management to expand later. Ask outstanding questions in the visible conversational reply.
