# Operator runtime policy

Date: 2026-09-07. Source: [verbatim operator direction](../../raw/2026-09-07-operator-runtime-policy.md).

Aaron accepted two linked runtime policies:

- MD uses Sol with high reasoning for requirements capture, design in Beads,
  orchestration, and validation.
- Fleet implementation defaults to Luna with high reasoning to reduce token
  cost, while retaining optional per-member overrides.
- Seats and fleet members use `workspace-write` with `on-request` approval and
  `approvals_reviewer=auto_review`, so eligible escalation requests are
  reviewed automatically instead of interrupting Aaron.

OpenAI describes Auto-review as replacing the human approval prompt while
preserving the configured sandbox boundary. A denial should send the agent
toward a safer route or cause it to stop; automatic circuit breakers can return
control to the user after repeated denials. Computer Use app confirmation
prompts are outside this policy.

The accepted implementation and restart boundary are recorded in the
[session-defaults decision](../decisions/session-defaults.md) and
[approval-policy decision](../decisions/agent-approval-policy.md).
