# Operator direction: local Git authority

Date: 2026-09-07
Source: Aaron, direct conversation with Managing Director
Capture status: complete for this instruction

> Ok, so AGENTS.md provided the policy (the root level one,
> ~/development/tpsi/beads-tests/AGENTS.md? If so, let's change it. All seats
> and fleet members should be able to modify git. Seat members should be able
> to do that for documentation updates. Fleet members should be able to manage
> their own worktrees.

Clarification recorded by MD: the root instructions contained a conservative
local policy, but a separate developer-level session rule and read-only `.git`
permission also blocked the current session. This decision changes Rig's
repository policy; it cannot grant permissions withheld by the session host.

