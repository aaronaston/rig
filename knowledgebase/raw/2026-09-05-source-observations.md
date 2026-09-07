# Source observations — 2026-09-05

This is a capture of selected excerpts and retrieval metadata, not a full transcript or article archive. Preserve this file unchanged; add later captures separately.

## S1 — Identify Wheelhouse Software

URL: https://chatgpt.com/share/6a9c8feb-19d8-83ea-a2eb-dbe09ca2891a

Read through the browser. Initially only some turns rendered; navigating the prompt list revealed the original identification and architecture walkthrough. Seven prompts were listed. The following excerpts are from the visible ChatGPT answers:

> Yes. The screenshot is mostly Emacs, but the interesting agent-management interface inside it is custom software Yegge built, which he calls Wheelhouse.

> I think the key distinction is: Wheelhouse is the harness, but the workers underneath it are still actual Claude agent processes/sessions.

> The Emacs UI is very likely acting as a programmable terminal/session manager around those processes, plus adding a lot of orchestration beside them.

> Wheelhouse provides continuity above the Claude session.

The walkthrough included PTYs, possible Emacs terminal packages, illustrative Elisp, model versus seat identity, separate clones, startup state, Beads, speculative headless dispatch, and a minimal console sketch. These were a mix of cited reporting and explicit inference. The final turns discussed saving ChatGPT memory and creating a separate project brief; neither action establishes that a local file exists here.

Citations exposed in the inspected architecture answers point to S2 and S3 below. No separate technical primary reference was exposed for the PTY explanation. The exact phrase “Wyvern’s Brain” was verified in S2, rather than in the inspected chat passages.

## S2 — The Shape of Things to Come, Part 1: The Continuous Thunderdome

Author: Steve Yegge. Page date: August 2026.
URL: https://yegge.ai/essays/the-shape-of-things-to-come/
Read via web retrieval on 2026-09-05.
Relevant sections: Wheelhouse: Gas Town Redux; Wyvern’s Brain.

Short exact excerpt: “tmux under the hood”

## S3 — The Shape of Things to Come, Part 2: Model Welfare for Agentic Engineers

Author: Steve Yegge. Page date: August 2026.
URL: https://yegge.ai/essays/model-welfare/
Read via web retrieval on 2026-09-05.
Relevant sections: Closing the Loop; The Anti-Clonking Device.

Short exact excerpt: “Every agent has their own clone that no other processes may touch.”

## Capture limits

Direct article downloads were attempted but shell DNS resolution failed. No full HTML copies are present. The browser content-export operation was unavailable. The selected chat excerpts above and these article metadata records are the preserved local evidence; the linked originals remain necessary for full context.
