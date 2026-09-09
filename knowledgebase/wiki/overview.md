# Rig Knowledgebase

## Purpose

Preserve sources, decisions, and operating knowledge for a local control center
with one Managing Director seat and durable named generalist workers

## Current Synthesis

The [shared-chat findings and cited essays](sources/wheelhouse.md) provide the
starting context. Rig has one singleton management seat, Managing Director in
root `md/`, and durable named generalist Workers stored under the compatibility
`fleet/` path by individual instances. MD uses they/them pronouns by their
expressed bootstrap preference. Aaron is the operator; MD is his conversational
delegate for requirements, Beads work definition, worker orchestration, blocker
resolution, and output validation. The `main` branch is worker-free core;
instance branches supply their own workers.

## Open Questions

The [named-worker architecture](decisions/named-generalist-worker-architecture.md),
[delegation decision](decisions/md-delegation-and-fleet.md), and [worker
lifecycle](decisions/fleet-member-lifecycle.md) define the operating boundary.
Codex session-ID capture/resume, automatic wake-up, structured standup, and
compatibility-path migration remain implementation questions tracked in Beads.
Use this knowledgebase for sources and decisions, not a second task queue.

Return to the [index](index.md).
