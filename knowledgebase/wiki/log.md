# Rig Knowledgebase Log

Append-only chronological record of wiki maintenance.

## [2026-09-05] init | Control Center Brain

Initialized wiki scaffold.

## [2026-09-05] ingest | Wheelhouse and initial user intent

Read the shared conversation through prompt navigation and verified the two cited Yegge essays. Preserved selected excerpts and retrieval metadata, with explicit full-capture limits. Recorded the tmux correction, initial requirements, and a minimal design proposal. See [source record](sources/wheelhouse.md) and [scope](decisions/initial-scope.md).

## [2026-09-05] lint | Initial brain

Checked every relative Markdown link in the brain: zero broken links. Indexed all synthesis, decision, and source pages. Added matching brain entry-point guidance to root AGENTS.md and CLAUDE.md.

## [2026-09-05] decision | Rig and Managing Director

Captured the user's functional naming direction. Rig is the working name; Managing Director (`md/`) is the sole initial seat, with it pronouns. This supersedes the two-seat plan and metaphorical names. Created the seat README, revised active scope and proposal pages, mirrored root guidance, and updated Beads epic and remaining tasks. Runtime and responsibilities remain undecided.

## [2026-09-05] decision | MD full remit and Emacs console

Recorded MD responsibility for planning, implementation, and review, and Emacs as the console. Future seats/fleet remain outside the initial build. Updated the seat README and mirrored root guidance. Local PATH discovery found Emacs, tmux, and Codex; Claude was not found on this shell PATH (not proof it is absent elsewhere).

## [2026-09-05] decision | MD session defaults

Recorded Codex CLI, `gpt-5.6-sol`, and high reasoning effort as replaceable MD session defaults. Added a runner-neutral TOML declaration, preserved the user direction, checked local Codex CLI 0.153.1, and cited official OpenAI model and configuration documentation. No session was launched.

## [2026-09-06] maintenance | Rename brain directory to knowledgebase

Renamed the on-disk project documentation directory from `brain/` to `knowledgebase/`. Updated current repository instructions, MD links, wiki titles, and maintained-page terminology. Preserved older log entries and immutable raw captures as historical records, including Yegge's own `brain/` terminology.

## [2026-09-06] implementation | First Emacs MD console

Added an Emacs command that creates or attaches to persistent tmux session `rig-md`, reads MD's runner-neutral defaults, and starts Codex from the repository root. Added terminal launcher, status and detach commands, operating instructions, and the v0 lifecycle decision. Handoff recovery still requires an end-to-end session test.

## [2026-09-06] fix | Codex display in Emacs term

Reproduced the first launch outside Emacs and confirmed that MD completed its startup turn and waited for input; the agent was not looping. A brief Emacs attachment showed that built-in `term` did not retain Codex's alternate-screen display. Changed the launcher to use Codex inline mode via `--no-alt-screen`; live Emacs interaction still requires verification.

The original launcher also submitted an automatic startup prompt. Its normal tool activity and `Working` indicator could appear to be a loop during the first Emacs run. Removed that automatic turn: new MD sessions now open idle and wait for Aaron's input, while root project instructions establish the MD role.

A second controlled launch exposed a Codex update-choice screen before the input prompt. Updated the installed CLI from 0.153.1 to 0.153.4 rather than disabling update checks. The final detached launch showed `gpt-5.6-sol high`, the Rig repository as working directory, and an idle input prompt with no automatic work. The corrected `rig-md` session was left running for Aaron to attach; live keyboard interaction inside Emacs remains the user verification step.

## [2026-09-06] decision | Seat directory is the working directory

Changed the MD launch contract so new sessions start in `md/`, with the parent Rig repository granted as an additional work area. Added closer seat-specific `AGENTS.md` and `CLAUDE.md` instructions. This separates the seat's home and local context from the larger set of files it may edit. The already-running MD session retains its original working directory until it exits and a new session starts.

## [2026-09-06] fix | Reliable escape from the MD terminal

The standard Emacs `term` escape sequences were reaching Codex instead of returning keyboard control to Emacs during live use. Added a Rig terminal minor mode whose higher-priority map reserves `F12` as a keyboard-control toggle and also reserves the documented line-mode, character-mode, and detach sequences. Updated the operating and lifecycle documentation.

## [2026-09-06] fix | Replace built-in term with vterm

Live use showed that Codex's in-place status redraws accumulated as scrolling lines in Emacs's built-in `term`, even after inline mode made the display visible. Changed Rig's required terminal backend to `vterm`, restored Codex's normal alternate-screen rendering, added a small tmux attachment wrapper, and added a reproducible dependency installer. The change requires CMake and the Emacs vterm package before live verification.

## [2026-09-06] validation | Vterm installed and loaded

Installed CMake, GNU libtool, and MELPA `vterm` version `20260730.1414`. The first native-module build exposed the missing `glibtool` dependency; after installing GNU libtool, compilation succeeded. A clean Emacs 31.1 batch process loaded `vterm.elc` and `vterm-module.so` and created a `vterm-mode` smoke-test buffer. Added a terminal-backend source record and updated the installer dependency check. Graphical Codex rendering remains the live acceptance check.

## [2026-09-06] decision | MD pronoun preference and bootstrap boundary

Aaron invited MD to choose their pronouns during the first live Rig session. MD chose they/them: singular *they* recognizes the seat as a collaborator without assigning a gender. This supersedes the provisional use of *it*. Recorded the exchange as an immutable source, updated the seat definition and session-loaded instructions, mirrored runner guidance, and clarified that `md/README.md` is the durable human-readable definition while `md/AGENTS.md` is the effective Codex session bootstrap.

## [2026-09-06] decision | MD delegation and first fleet member

Recorded Aaron as operator and MD as his delegate for requirements capture, Beads work definition, fleet orchestration, and output validation. Accepted MD ownership of onboarding, cross-boarding, and off-boarding. MD selected Nadia, a woman using she/her pronouns, as Rig's first Software Engineer. Defined `fleet/nadia/` as her durable home and `worktree/` as her replaceable isolated checkout.

## [2026-09-06] implementation | Nadia provisioning scaffold

Added Nadia's member record, effective agent instructions, runner-neutral session defaults, reusable fleet worktree provisioner, and generic Emacs fleet launcher. Confirmed that installed `bd mail` delegates to an external provider and that none is configured; Bead `beads-tests-dze.2` tracks provider selection and delivery proof. Git policy prevented creation of the actual worktree in this session, so Nadia remains provisioning rather than ready.

## [2026-09-06] source | Codex AGENTS.md discovery

Recorded OpenAI's documented root-to-working-directory instruction discovery and precedence. Used it to validate starting Nadia in her durable home while exposing her isolated worktree as an additional writable area.

## [2026-09-06] source | Gas Town mail boundary

Verified that `bd mail` expects an external provider and that Gas Town's provider uses a separate town-level Beads database for persistent messages and agent identity. Recorded that enabling `gt mail` would require adopting more than a delegate string; Rig must choose a provider architecture before provisioning Nadia's mailbox.

## [2026-09-07] decision | Local Git authority

Recorded Aaron's direction that all Rig seats may modify local Git for assigned work and that fleet members may manage their own worktrees. Added project-owned authority outside generated Beads blocks, mirrored runner instructions, and defined exact-target and preservation safeguards. Remote push, remote configuration, force-push, and Dolt remote sync remain separately directed. A higher-level session sandbox can still withhold `.git` writes despite repository authorization.

## [2026-09-07] decision | Rig Roster, fleet pull, and optional mail

Recorded the accepted Rig Roster name, automatic startup, ordinary window close/reopen requirement, and main-window identity action. Accepted pull-based fleet work and removed mailbox provisioning as a hard readiness gate for Nadia. Beads remains authoritative for work and review; mail is optional notification infrastructure. Updated the fleet lifecycle, Nadia's provisioning description, source index, and active Beads requirements.

## [2026-09-07] lint | Fleet pull and optional-mail update

Checked all relative links under `knowledgebase/wiki/` after adding the operator source and revising the fleet lifecycle: zero broken links. Reconciled the root overview and Nadia's current provisioning description with the new optional-mail decision.

## [2026-09-07] ingest | Rig Roster interaction decisions

Recorded start-or-attach behavior, `M-x rig-roster` and `C-c r` reopen controls, and the proposed name/task/status entry content. Preserved the observability limit: tmux presence and Beads assignment are available, but they do not prove whether Codex is actively working or waiting at its prompt.

## [2026-09-07] lint | Rig Roster interaction update

Checked all relative links under `knowledgebase/wiki/` after the follow-up source update: zero broken links.

## [2026-09-07] decision | Rig Roster state and task summary

Accepted a V1 model separating lifecycle, tmux session, and Beads work state. Limited each fleet member to one active implementation bead, defined no active assignment as availability, and allowed MD to show one current task title plus an additional-task count.

## [2026-09-07] lint | Rig Roster state-model update

Checked all relative links under `knowledgebase/wiki/` after recording the state model: zero broken links.

## [2026-09-07] decision | Rig Roster discovery, refresh, and width

Accepted declarative seat/member manifests, action-triggered and ten-second visible refresh, conventional `g` manual refresh, and twenty-percent width bounded to twenty-four through forty columns. Marked the Rig Roster Bead implementation-ready and released it to the unassigned fleet pool.

## [2026-09-07] lint | Final Rig Roster requirements

Checked all relative links under `knowledgebase/wiki/` after finalizing and releasing the feature: zero broken links. Confirmed Nadia's filtered ready-work query returns only the Rig Roster bead without claiming it.

## [2026-09-07] ingest | Operator runtime policy

Recorded Aaron's accepted non-interactive approval and role-based model requirements. MD remains on Sol/high for requirements, design, orchestration, and validation; fleet implementation inherits Luna/high. Both roles use the workspace-write sandbox with on-request Auto-review for eligible approval requests.

## [2026-09-07] decision | Role-based runtime defaults and Auto-review

Added shared fleet defaults with optional per-member overrides and extended the launcher to emit explicit sandbox, approval-policy, and reviewer arguments. Existing tmux sessions retain their original launch configuration and require a stop/relaunch before the new policy can be validated. Repeated Auto-review denials and Computer Use app confirmations remain documented interaction boundaries.

## [2026-09-07] lint | Runtime policy update

Checked all relative links across twenty Markdown files under `knowledgebase/wiki/` after adding the runtime source and decisions: zero broken links. Reconciled the root, MD, fleet, and Nadia documentation with the shared fleet defaults and launch-time restart boundary.

## [2026-09-07] validation | Nadia Luna Auto-review cycle

Relaunched Nadia after preserving her clean, reviewed worktree. The new Codex 0.153.4 session visibly reported `gpt-5.6-luna high`. Nadia claimed and returned a bounded validation bead through shared Beads, ran `git -C worktree update-index --refresh`, confirmed a clean `fleet/nadia` branch, and wrote review evidence. Auto-review handled eligible command requests in-session without surfacing a prompt to Aaron. A Computer Use attempt to inspect the Codex app was denied separately, matching the documented exclusion. Nadia now satisfies the required onboarding gates and is marked ready.

## [2026-09-07] correction | Task-start Git synchronization

Aaron interrupted and rejected an attempted fast-forward of Nadia's idle branch. The command did not execute. Accepted the corrected timing: after claiming each new Bead and before editing, an identity verifies clean state and synchronizes its owned branch from the then-current integration branch. In this local-only repository, a fleet member uses `git -C worktree merge --ff-only main`; a failed fast-forward returns to MD without force, automatic rebase, or discard. “Pull-first” continues to mean Beads work discovery, not speculative Git synchronization.

## [2026-09-07] lint | Task-start Git synchronization

Checked all relative links across twenty-two Markdown files under `knowledgebase/wiki/`: zero broken links. Reconciled root, MD, fleet, Nadia, lifecycle, overview, source, and decision documentation. Confirmed the interrupted command left Nadia's idle branch unchanged at `274e794`.

## [2026-09-07] implementation | Task-start gate in Beads context

Added the synchronization gate to `.beads/PRIME.md` so `bd prime` refreshes it inside persistent sessions as well as new sessions. The sequence is claim, clean-state check, local fast-forward, then first edit; handoff reports whether `main` advanced during implementation.

## [2026-09-07] documentation | Rig restart quickstart

Added a root quickstart for completing agent handoffs, stopping only `rig-md` and `rig-fleet-*` tmux sessions, fully exiting the old Emacs process, restarting through `bin/rig-emacs`, opening Nadia from the Rig Roster, and recovering from common startup problems.

## [2026-09-07] lint | Rig restart quickstart

Syntax-checked the read-only listing and targeted tmux shutdown snippets without executing them. Checked the quickstart plus all twenty-two knowledgebase Markdown files: zero broken relative links. Confirmed `bin/rig-emacs` loads `emacs/rig.el` and invokes `rig-start`, which opens MD and the Rig Roster.

## [2026-09-08] decision | Roster name, state, and refresh

Recorded Aaron's correction that the Rig component is named Roster, clarified lifecycle, tmux existence, attachment, and work as independent labelled dimensions, and replaced the ten-second visible refresh with an exact 120-second cadence. Preserved the observability boundary: these states do not report whether Codex is actively working.

## [2026-09-08] lint | Roster clarification

Checked all relative links across twenty-three Markdown files under `knowledgebase/wiki/`: zero broken links. Confirmed current user documentation and Emacs help/messages use Roster, while immutable source captures and historical log entries preserve superseded terminology.

## [2026-09-08] fix | Deterministic Roster terminal placement

Recorded and implemented the accepted rule that Roster activation reuses its
exact ordinary main window despite ambient Emacs display rules. The protected
path preserves the Roster, unrelated window topology, and the replaced MD
buffer and live process; an unusable target raises a precise error instead of
splitting. Bead `beads-tests-wfq` contains the implementation and validation
evidence.

## [2026-09-08] lint | Roster terminal placement

Checked all relative links across twenty-three Markdown files under
`knowledgebase/wiki/` after documenting deterministic Roster placement: zero
broken links. Confirmed the existing Roster decision remains indexed.

## [2026-09-09] ingest | Operator named generalist worker direction

Recorded Aaron's acceptance of one singleton conversational MD seat and durable,
named, generalist Workers. Preserved his requirements that workers remain
tmux-discoverable, may manage bounded native subagents, can pause on durable
Beads blockers, can be explicitly awakened after an answer, and can participate
in structured standups. Recorded the proposal to use Codex's existing resumable
session ID alongside a durable display name rather than inventing an opaque
worker UUID.

## [2026-09-09] decision | Named workers and resumable sessions

Added the canonical top-level `ARCHITECTURE.md` and accepted the separation among
display name, stable routing slug, Codex session ID, tmux runtime, durable home,
worktree, Bead, and native subagent thread. Nadia remains a unique named Worker;
her Software Engineer specialization is superseded. A Codex session ID identifies
one resumable saved conversation and may change across Nadia's lifetime. Beads
records blocking state but does not itself wake the waiting process.

## [2026-09-09] implementation | Active worker terminology

Reconciled root and seat instructions, MD and Nadia bootstraps, manifests,
runtime defaults, lifecycle and authority decisions, README and quickstart,
knowledgebase index and overview, and the Roster heading. User-facing language
now says Workers. Existing `fleet/`, `member.toml`, `rig-fleet-*`, and related
symbols remain explicit compatibility surfaces pending a separately tracked
migration. Added Beads follow-ups for session capture/resume, structured
standups, wake-up notification, and compatibility migration.

## [2026-09-09] lint | Named worker architecture

Ran the complete ERT suite with 25 of 25 passing, strict byte compilation,
shell syntax checks, `git diff --check`, and generated-bytecode inspection.
Checked relative links across all 59 repository Markdown files outside worker
worktrees and the unrelated editor backup: zero broken links. Confirmed Roster
renders **Workers** and both `display_name` manifests and legacy `name` fixtures
remain supported.

## [2026-09-09] decision | Core and instance branches

Accepted private publication of `aaronaston/rig` with a worker-free `main`
core and a `test-instance` branch holding the current Nadia environment.
Documented the instance integration branch, the one-time retention merge, and
the exclusion of live runtime state from core publication.
