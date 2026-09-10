;;; rig-instance-tests.el --- Separate operating home tests -*- lexical-binding: t; -*-

(require 'rig-tests nil t)

(ert-deftest rig-instance-separates-discovery-runtime-and-source ()
  (rig-test--with-temp-root
    (let ((rig-software-root (file-name-as-directory (expand-file-name "software" root))))
      (make-directory rig-software-root)
      (rig-test--write-nadia-fixture root)
      (rig-test--write-file root "rig.toml" "project_root = \"source\"\n")
      (make-directory (expand-file-name "source" root))
      (should (equal (rig--project-root)
                     (file-name-as-directory (expand-file-name "source" root))))
      (should (= 1 (length (cadr (rig--discover-identities)))))
      (let ((first (rig--fleet-tmux-session "nadia")))
        (should (equal first (plist-get (car (cadr (rig--discover-identities))) :tmux)))
        (let ((rig-root rig-software-root))
          (should-not (equal first (rig--fleet-tmux-session "nadia")))
          (should-not (cadr (rig--discover-identities))))))))

(ert-deftest rig-instance-routes-worker-database-explicitly ()
  (rig-test--with-temp-root
    (rig-test--write-nadia-fixture root)
    (make-directory (rig--beads-directory))
    (cl-letf (((symbol-function 'rig--required-executable) #'identity))
      (let ((command (rig--session-process-command "fleet/nadia")))
        (should (member (concat "BEADS_DIR=" (rig--beads-directory)) command))
        (should (member "BEADS_ACTOR=Nadia" command))
        (should (member (rig--beads-directory) command))
        (should (member (expand-file-name "fleet/nadia/worktree" root) command))))))

(ert-deftest rig-instance-roster-overrides-inherited-beads-directory ()
  (rig-test--with-temp-root
    (let ((process-environment (copy-sequence process-environment))
          captured)
      (setenv "BEADS_DIR" "/wrong/project/.beads")
      (cl-letf (((symbol-function 'rig--required-executable) #'identity)
                ((symbol-function 'process-file)
                 (lambda (&rest _)
                   (setq captured (getenv "BEADS_DIR"))
                   (insert "[]") 0)))
        (should-not (rig--beads-issues "MD"))
        (should (equal captured (rig--beads-directory)))
        (should (equal (getenv "BEADS_DIR") "/wrong/project/.beads"))))))

(ert-deftest rig-instance-md-gets-project-and-operating-work-areas ()
  (rig-test--with-temp-root
    (rig-test--write-file root "rig.toml" "project_root = \"../source\"\n")
    (should (equal (rig--work-area-directories "md" nil)
                   (list rig-root (rig--project-root))))))

(ert-deftest rig-instance-refuses-launch-without-project-database ()
  (rig-test--with-temp-root
    (should-error (rig--session-process-command "md") :type 'user-error)))
