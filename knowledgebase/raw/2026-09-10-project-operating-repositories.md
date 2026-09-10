# Operator conversation: project operating repositories

Captured 2026-09-10 from the current Aaron/MD conversation.

Aaron: "I think each project will have a dedicated team (and beads database)."

Aaron: "Ok, so I should have aaronaston/rig and maybe
aaronaston/rig-test-instance as the operating repo?"

MD proposed separate software, operating-home, and source-worktree paths, with
Nadia implementing core on main-based worktrees and identity/configuration in
the operating repository. MD noted that the current launchers needed changes.

Aaron: "Ok, can we do it? Is there a bead to pick up to implement this?"

MD created beads-tests-dze.17 for the split and updated beads-tests-dze.16 for
the project-owned Beads database portability decision. MD clarified that the
database means issues, dependencies, comments, ownership, and handoff evidence,
separate from ordinary Git history and the Markdown knowledgebase.

Aaron: "Ok, let's work on .17."
