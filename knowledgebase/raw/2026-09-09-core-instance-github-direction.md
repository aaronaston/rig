# Operator direction: Rig core and test instance

Date: 2026-09-09.

Aaron directed Rig to publish under the `aaronaston` GitHub account as a new
private repository named `rig`. `main` is the reusable core, with no onboarded
workers. The current environment, including Nadia, is the `test-instance`
branch. Core updates are merged from `main` into `test-instance`; worker
worktrees synchronize from the instance integration branch.
