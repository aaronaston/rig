# Wheelhouse source record

[Capture and source URLs](../../raw/2026-09-05-source-observations.md)

## S1: earlier ChatGPT discussion

Verified: the shared chat contains ChatGPT's Wheelhouse identification and architecture findings. It describes an operations console surrounding coding-agent clients, rather than a replacement inference loop. Its PTY code and dispatcher flows are sketches, not inspected Wheelhouse code. Its model names are contextual claims, not our runtime selections.

## S2: Yegge Part 1

Yegge describes a private, closed-source harness using Emacs, Bash, and tmux. His knowledge layout separates long-lived strategy in `brain/`, system explanations in `doc/`, task specifications in Beads, short operational facts in `bd remember`, and recurring procedures in skills. His deployed Beads uses shared Dolt; this does not establish our local configuration.

Correction to S1: direct `vterm` launch is only one proposed approach. The source explicitly mentions tmux; we cannot identify the exact Emacs terminal integration from these essays.

## S3: Yegge Part 2

Yegge distinguishes persistent seats from replaceable sessions, gives agents separate clones, and describes a handoff that writes continuity notes before restart. These are useful engineering inputs. His claims about model feelings and personhood are his position, not established technical prerequisites for this project.

## Application

See [initial scope](../decisions/initial-scope.md) and [proposed minimal design](../syntheses/minimal-control-center.md). The essays are reports about a private implementation, not an executable specification. We have not inspected its source code. Sources cited here are the relevant architecture citations recovered from the chat, not an exhaustive crawl of everything linked by the essays.
