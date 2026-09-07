# Agent approval policy

Date: 2026-09-07. Status: accepted.

Rig-launched MD and fleet sessions use this Codex policy:

```text
--sandbox workspace-write --ask-for-approval on-request --config approvals_reviewer=auto_review
```

This is Auto-review, not unrestricted execution. The workspace-write sandbox
boundary remains in force, while eligible escalation requests are decided by
the automatic reviewer instead of surfacing as interactive prompts to Aaron.
An approved request runs outside the sandbox for that command. A denied request
directs the agent to use a safer approach or stop.

OpenAI documents safety circuit breakers that restore user control after three
consecutive denials or ten denials among the last fifty reviews. Computer Use
app confirmation prompts are excluded from Auto-review. Rig therefore treats
Auto-review as non-interactive handling for eligible shell-command approvals,
not as a guarantee that every possible interaction can proceed unattended.

The launcher reads `sandbox_mode`, `approval_policy`, and `approvals_reviewer`
from the role's session defaults and emits the explicit long-form arguments.
Existing tmux sessions retain their original process configuration and must be
stopped and relaunched to adopt this policy. A bounded refreshed fleet cycle is
required before the non-interactive onboarding gate is considered proven.

Source: [operator runtime direction](../sources/operator-runtime-policy.md).
