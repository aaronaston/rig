# Operator direction: non-interactive approvals and role-based models

Date: 2026-09-07

Source: Aaron, direct project conversation.

> “Have a look at https://learn.chatgpt.com/docs/agent-approvals-security. I think we want Auto-review mode --sandbox workspace-write --ask-for-approval on-request -c approvals_reviewer=auto_review.”

> “I need to adjust the (default) model used for the fleet. We're burning tokens like crazy. I need you to work on sol/high to capture the right requirements and design in beads, but the implementation/fleet can run lower at say luna/high.”

These statements are accepted operator requirements. They preserve the
workspace-write boundary while moving eligible approval decisions to
Auto-review, and distinguish MD's design/validation runtime from fleet
implementation defaults.

Official references, accessed 2026-09-07:

- OpenAI, “Auto-review”: https://learn.chatgpt.com/docs/sandboxing/auto-review
- OpenAI, “Agent approvals & security”: https://learn.chatgpt.com/docs/agent-approvals-security
- OpenAI, “GPT-5.6 Luna”: https://developers.openai.com/api/docs/models/gpt-5.6-luna
