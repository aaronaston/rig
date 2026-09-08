;;; rig-tests.el --- Tests for the Rig Emacs console -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defvar rig-root)

(add-to-list
 'load-path
 (expand-file-name "../emacs"
                   (file-name-directory
                    (or load-file-name buffer-file-name))))
(require 'rig)

(defmacro rig-test--with-temp-root (&rest body)
  "Run BODY with an isolated temporary Rig root."
  (declare (indent 0) (debug t))
  `(let* ((root (make-temp-file "rig-test-" t))
          (rig-root (file-name-as-directory root)))
     (unwind-protect
         (progn ,@body)
       (rig--roster-cancel-refresh)
       (when (get-buffer rig--roster-buffer-name)
         (kill-buffer rig--roster-buffer-name))
       (delete-directory root t))))

(defun rig-test--write-file (root relative contents)
  "Write CONTENTS under ROOT at RELATIVE."
  (let ((file (expand-file-name relative root)))
    (make-directory (file-name-directory file) t)
    (with-temp-file file
      (insert contents))))

(defun rig-test--issue (title updated &optional labels)
  "Make a task fixture with TITLE, UPDATED timestamp, and LABELS."
  (list (cons 'title title)
        (cons 'updated_at updated)
        (cons 'labels labels)))

(defun rig-test--fake-vterm (&optional buffer-name)
  "Create BUFFER-NAME and exercise vterm's real display call shape."
  (let ((buffer (get-buffer-create buffer-name)))
    (pop-to-buffer-same-window buffer)
    buffer))

(defun rig-test--write-nadia-fixture (root)
  "Write the minimal ready Nadia configuration under ROOT."
  (rig-test--write-file
   root "fleet/session-defaults.toml"
   (concat "runner = \"codex-cli\"\n"
           "model = \"gpt-5.6-luna\"\n"
           "reasoning_effort = \"high\"\n"
           "sandbox_mode = \"workspace-write\"\n"
           "approval_policy = \"on-request\"\n"
           "approvals_reviewer = \"auto_review\"\n"))
  (rig-test--write-file
   root "fleet/nadia/member.toml"
   (concat "slug = \"nadia\"\n"
           "name = \"Nadia\"\n"
           "status = \"ready\"\n"
           "worktree = \"worktree\"\n"
           "beads_actor = \"Nadia\"\n"))
  (make-directory (expand-file-name "fleet/nadia/worktree" root) t))

(ert-deftest rig-roster-discovers-and-orders-manifests ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "ops/seat.toml"
     (concat "slug = \"ops\"\n"
             "name = \"Operations\"\n"
             "beads_actor = \"Ops\"\n"))
    (rig-test--write-file
     root "md/seat.toml"
     (concat "slug = \"md\"\n"
             "name = \"Managing Director\"\n"
             "beads_actor = \"MD\"\n"))
    (rig-test--write-file
     root "fleet/zara/member.toml"
     (concat "slug = \"zara\"\n"
             "name = \"Zara\"\n"
             "status = \"ready\"\n"))
    (rig-test--write-file
     root "fleet/amy/member.toml"
     (concat "slug = \"amy\"\n"
             "name = \"Amy\"\n"
             "status = \"ready\"\n"))
    (pcase-let ((`(,seats ,fleet) (rig--discover-identities)))
      (should (equal (mapcar (lambda (item) (plist-get item :name)) seats)
                     '("Managing Director" "Operations")))
      (should (equal (mapcar (lambda (item) (plist-get item :name)) fleet)
                     '("Amy" "Zara")))
      (should (eq (plist-get (car seats) :kind) 'seat))
      (should (eq (plist-get (car fleet) :kind) 'fleet)))))

(ert-deftest rig-roster-derives-honest-session-and-work-state ()
  (let ((identity '(:name "Nadia" :actor "Nadia"
                    :tmux "rig-fleet-nadia")))
    (cl-letf (((symbol-function 'rig--tmux-session-live-p)
               (lambda (_name) t))
              ((symbol-function 'rig--tmux-attachment-state)
               (lambda (_name) "attached"))
              ((symbol-function 'rig--beads-issues)
               (lambda (_actor) nil)))
      (let ((state (rig--identity-state identity)))
        (should (equal (plist-get state :session) "running"))
        (should (equal (plist-get state :attachment) "attached"))
        (should (equal (plist-get state :work-state) "idle"))
        (should (equal (plist-get state :task-summary) "no active task"))))
    (cl-letf (((symbol-function 'rig--tmux-session-live-p)
               (lambda (_name) nil))
              ((symbol-function 'rig--beads-issues)
               (lambda (_actor)
                 (list (rig-test--issue "Implement roster" "2")))))
      (let ((state (rig--identity-state identity)))
        (should (equal (plist-get state :session) "stopped"))
        (should-not (plist-get state :attachment))
        (should (equal (plist-get state :work-state) "assigned"))))))

(ert-deftest rig-roster-detects-attached-tmux-session ()
  (cl-letf (((symbol-function 'rig--required-executable)
             (lambda (_name) "/test/bin/tmux"))
            ((symbol-function 'process-file)
             (lambda (&rest _args)
               (insert "2\n")
               0)))
    (should (equal (rig--tmux-attachment-state "rig-md") "attached"))))

(ert-deftest rig-roster-detects-detached-tmux-session ()
  (cl-letf (((symbol-function 'rig--required-executable)
             (lambda (_name) "/test/bin/tmux"))
            ((symbol-function 'process-file)
             (lambda (&rest _args)
               (insert "0\n")
               0)))
    (should (equal (rig--tmux-attachment-state "rig-md") "detached"))))

(ert-deftest rig-roster-reports-unavailable-tmux-attachment-metadata ()
  (cl-letf (((symbol-function 'rig--required-executable)
             (lambda (_name) "/test/bin/tmux"))
            ((symbol-function 'process-file)
             (lambda (&rest _args) 1)))
    (should (equal (rig--tmux-attachment-state "rig-md") "unavailable"))))

(ert-deftest rig-roster-preserves-unavailable-attachment-state ()
  (let ((identity '(:name "Nadia" :actor "Nadia"
                    :tmux "rig-fleet-nadia")))
    (cl-letf (((symbol-function 'rig--tmux-session-live-p)
               (lambda (_name) t))
              ((symbol-function 'rig--tmux-attachment-state)
               (lambda (_name) "unavailable"))
              ((symbol-function 'rig--beads-issues)
               (lambda (_actor) nil)))
      (let ((state (rig--identity-state identity)))
        (should (equal (plist-get state :session) "running"))
        (should (equal (plist-get state :attachment) "unavailable"))))))

(ert-deftest rig-roster-renders-unavailable-attachment-metadata ()
  (with-temp-buffer
    (cl-letf (((symbol-function 'rig--identity-state)
               (lambda (identity)
                 (append identity
                         '(:session "running"
                           :attachment "unavailable"
                           :work-state "idle"
                           :task-summary "no active task")))))
      (rig--insert-roster-section
       "Seats" '((:name "Managing Director" :lifecycle "active")) 40)
      (should (string-match-p "Tmux: running" (buffer-string)))
      (should (string-match-p "Attachment: unavailable"
                              (buffer-string))))))

(ert-deftest rig-roster-prioritizes-review-and-counts-additional-tasks ()
  (let ((issues
         (list
          (rig-test--issue "Newest ordinary" "2026-09-07T12:00:00Z")
          (rig-test--issue "Review me" "2026-09-06T12:00:00Z"
                           '("needs-review"))
          (rig-test--issue "Older ordinary" "2026-09-05T12:00:00Z"))))
    (should (equal (rig--task-summary issues) "Review me +2"))))

(ert-deftest rig-roster-width-is-bounded ()
  (cl-letf (((symbol-function 'frame-width)
             (lambda (&optional _frame) 100)))
    (should (= (rig--roster-window-width) 24)))
  (cl-letf (((symbol-function 'frame-width)
             (lambda (&optional _frame) 150)))
    (should (= (rig--roster-window-width) 30)))
  (cl-letf (((symbol-function 'frame-width)
             (lambda (&optional _frame) 300)))
    (should (= (rig--roster-window-width) 40))))

(ert-deftest rig-roster-keymaps-and-refresh-cadence-match-current-policy ()
  (should (eq (lookup-key rig-terminal-control-mode-map (kbd "C-c r"))
              #'rig-roster))
  (should (eq (lookup-key rig-roster-mode-map (kbd "g"))
              #'rig-roster-refresh))
  (should (eq (lookup-key rig-roster-mode-map (kbd "RET"))
              #'rig-roster-activate))
  (should (= rig--roster-refresh-seconds 120)))

(ert-deftest rig-roster-uses-the-roster-product-name ()
  (should (equal rig--roster-buffer-name "*Roster*"))
  (with-temp-buffer
    (rig-roster-mode)
    (should (equal mode-name "Roster"))))

(ert-deftest rig-roster-refresh-renders-sections-and-truncates ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "md/seat.toml"
     (concat "slug = \"md\"\n"
             "name = \"Managing Director\"\n"
             "status = \"active\"\n"
             "beads_actor = \"MD\"\n"))
    (rig-test--write-file
     root "fleet/nadia/member.toml"
     (concat "slug = \"nadia\"\n"
             "name = \"Nadia\"\n"
             "status = \"ready\"\n"
             "beads_actor = \"Nadia\"\n"))
    (cl-letf (((symbol-function 'rig--tmux-session-live-p)
               (lambda (name) (equal name "rig-md")))
              ((symbol-function 'rig--tmux-attachment-state)
               (lambda (_name) "detached"))
              ((symbol-function 'rig--beads-issues)
               (lambda (_actor)
                 (list
                  (rig-test--issue
                   "A deliberately very long task title for truncation"
                   "2")))))
      (let ((buffer (rig-roster-refresh)))
        (with-current-buffer buffer
          (should (eq major-mode 'rig-roster-mode))
          (should (string-match-p "Seats" (buffer-string)))
          (should (string-match-p "Fleet" (buffer-string)))
          (should (string-match-p "Managing Director" (buffer-string)))
          (should (string-match-p "Nadia" (buffer-string)))
          (should (string-match-p "\\`Roster\n" (buffer-string)))
          (should-not (string-match-p "Rig Roster" (buffer-string)))
          (should (string-match-p "active: enabled management seat"
                                  (buffer-string)))
          (should (string-match-p "ready: onboarding gates passed"
                                  (buffer-string)))
          (should (string-match-p "running: tmux session exists"
                                  (buffer-string)))
          (should (string-match-p "attached: tmux client connected"
                                  (buffer-string)))
          (should (string-match-p "detached: no tmux clients"
                                  (buffer-string)))
          (should (string-match-p "These do not show Codex activity"
                                  (buffer-string)))
          (should (string-match-p "Lifecycle: active" (buffer-string)))
          (should (string-match-p "Tmux: running" (buffer-string)))
          (should (string-match-p "Attachment: detached" (buffer-string)))
          (should (string-match-p "Lifecycle: ready" (buffer-string)))
          (should (string-match-p "Tmux: stopped" (buffer-string)))
          (should (string-match-p "Work: assigned" (buffer-string)))
          (should (string-match-p "Task:" (buffer-string)))
          (goto-char (point-min))
          (while (not (eobp))
            (should (<= (- (line-end-position) (line-beginning-position))
                        40))
            (forward-line 1)))))))

(ert-deftest rig-roster-truncation-preserves-additional-task-count ()
  (should
   (equal (rig--truncate-task-summary
           "A long task title that must shrink +2" 24 "Task: ")
          "A long task ti… +2")))

(ert-deftest rig-roster-close-and-reopen-is-window-local ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "md/seat.toml"
     (concat "slug = \"md\"\n"
             "name = \"Managing Director\"\n"
             "beads_actor = \"MD\"\n"))
    (cl-letf (((symbol-function 'rig--tmux-session-live-p)
               (lambda (_name) nil))
              ((symbol-function 'rig--beads-issues)
               (lambda (_actor) nil)))
      (delete-other-windows)
      (let ((main (selected-window))
            (roster (rig-roster)))
        (should (window-live-p roster))
        (should (= (window-total-width roster)
                   (rig--roster-window-width)))
        (delete-window roster)
        (should (window-live-p main))
        (should-not (get-buffer-window rig--roster-buffer-name))
        (should (window-live-p (rig-roster)))))))

(ert-deftest rig-roster-provisioning-error-identifies-missing-gate ()
  (rig-test--with-temp-root
    (let* ((home (expand-file-name "fleet/nadia/" root))
           (identity (list :name "Nadia"
                           :lifecycle "provisioning"
                           :home home
                           :worktree "worktree")))
      (should
       (string-match-p "missing worktree"
                       (rig--identity-provisioning-error identity)))
      (make-directory (expand-file-name "worktree" home) t)
      (should
       (equal
        (rig--identity-provisioning-error identity)
        "Nadia is provisioning; MD has not marked onboarding complete")))))

(ert-deftest rig-roster-action-routes-to-main-and-preserves-roster ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "md/seat.toml"
     (concat "slug = \"md\"\n"
             "name = \"Managing Director\"\n"
             "status = \"active\"\n"
             "beads_actor = \"MD\"\n"))
    (let (opened selected-at-open)
      (cl-letf (((symbol-function 'rig--tmux-session-live-p)
                 (lambda (_name) nil))
                ((symbol-function 'rig--beads-issues)
                 (lambda (_actor) nil))
                ((symbol-function 'rig--open-session)
                 (lambda (seat tmux buffer label &optional target-window)
                   (setq opened (list seat tmux buffer label target-window)
                         selected-at-open (selected-window)))))
        (delete-other-windows)
        (let ((roster (rig-roster)))
          (with-selected-window roster
            (rig-roster-activate))
          (should
           (equal opened
                  (list "md" "rig-md" "*rig-md*" "Managing Director"
                        selected-at-open)))
          (should-not (eq selected-at-open roster))
          (should (window-live-p roster)))))))

(ert-deftest rig-roster-launch-ignores-hostile-display-rule ()
  (rig-test--with-temp-root
    (rig-test--write-nadia-fixture root)
    (let* ((md-buffer (get-buffer-create "*rig-md*"))
           (md-process (make-pipe-process
                        :name "rig-test-md" :buffer md-buffer :noquery t))
           (display-buffer-alist
            '(("\\`\\*rig-fleet-nadia\\*\\'" display-buffer-pop-up-window))))
      (unwind-protect
          (cl-letf (((symbol-function 'rig--ensure-terminal-backend)
                     #'ignore)
                    ((symbol-function 'rig--tmux-session-live-p)
                     (lambda (_name) t))
                    ((symbol-function 'rig--tmux-attachment-state)
                     (lambda (_name) "attached"))
                    ((symbol-function 'rig--beads-issues)
                     (lambda (_actor) nil))
                    ((symbol-function 'vterm) #'rig-test--fake-vterm))
            (delete-other-windows)
            (let ((main-window (selected-window)))
              (set-window-buffer main-window md-buffer)
              (let ((roster-window (rig-roster)))
                ;; Prove this ambient rule reproduces the reported third
                ;; window before exercising Rig's protected placement path.
                (select-window main-window)
                (rig-test--fake-vterm "*rig-fleet-nadia*")
                (let ((bug-window (selected-window)))
                  (should (= (length (window-list nil 'nomini)) 3))
                  (should-not (eq bug-window main-window))
                  (delete-window bug-window))
                (kill-buffer "*rig-fleet-nadia*")
                (select-window roster-window)
                (goto-char (point-min))
                (search-forward "Nadia")
                (beginning-of-line)
                (rig-roster-activate)
                (should (= (length (window-list nil 'nomini)) 2))
                (should (window-live-p roster-window))
                (should (eq (window-buffer roster-window)
                            (get-buffer rig--roster-buffer-name)))
                (should (window-live-p main-window))
                (should (eq (selected-window) main-window))
                (should (eq (window-buffer main-window)
                            (get-buffer "*rig-fleet-nadia*")))
                (should (buffer-live-p md-buffer))
                (should (process-live-p md-process)))))
        (when (process-live-p md-process)
          (delete-process md-process))
        (dolist (name '("*rig-md*" "*rig-fleet-nadia*"))
          (when (get-buffer name)
            (kill-buffer name)))))))

(ert-deftest rig-terminal-target-preserves-unrelated-window-topology ()
  (let ((target-buffer (get-buffer-create "*rig-test-target*"))
        (unrelated-buffer (get-buffer-create "*rig-test-unrelated*")))
    (unwind-protect
        (cl-letf (((symbol-function 'rig--ensure-terminal-backend) #'ignore)
                  ((symbol-function 'vterm) #'rig-test--fake-vterm))
          (delete-other-windows)
          (let* ((target-window (selected-window))
                 (unrelated-window (split-window-right)))
            (set-window-buffer target-window target-buffer)
            (set-window-buffer unrelated-window unrelated-buffer)
            (let ((windows-before (window-list nil 'nomini)))
              (rig--attach-tmux-session
               "rig-fleet-nadia" "*rig-fleet-nadia*" "Nadia"
               default-directory target-window)
              (should (equal (window-list nil 'nomini) windows-before))
              (should (eq (window-buffer target-window)
                          (get-buffer "*rig-fleet-nadia*")))
              (should (eq (window-buffer unrelated-window) unrelated-buffer))
              (should (eq (selected-window) target-window)))))
      (dolist (name '("*rig-test-target*" "*rig-test-unrelated*"
                      "*rig-fleet-nadia*"))
        (when (get-buffer name)
          (kill-buffer name))))))

(ert-deftest rig-terminal-target-reuses-live-buffer-in-exact-window ()
  (let* ((fleet-buffer (get-buffer-create "*rig-fleet-nadia*"))
         (fleet-process (make-pipe-process
                         :name "rig-test-nadia" :buffer fleet-buffer
                         :noquery t)))
    (unwind-protect
        (cl-letf (((symbol-function 'rig--ensure-terminal-backend) #'ignore))
          (delete-other-windows)
          (let* ((target-window (selected-window))
                 (other-window (split-window-right)))
            (set-window-buffer other-window fleet-buffer)
            (set-window-buffer target-window (get-buffer-create "*rig-md*"))
            (rig--attach-tmux-session
             "rig-fleet-nadia" "*rig-fleet-nadia*" "Nadia"
             default-directory target-window)
            (should (= (length (window-list nil 'nomini)) 2))
            (should (eq (selected-window) target-window))
            (should (eq (window-buffer target-window) fleet-buffer))
            (should (eq (window-buffer other-window) fleet-buffer))
            (should (process-live-p fleet-process))))
      (when (process-live-p fleet-process)
        (delete-process fleet-process))
      (dolist (name '("*rig-md*" "*rig-fleet-nadia*"))
        (when (get-buffer name)
          (kill-buffer name))))))

(ert-deftest rig-terminal-target-rejects-dead-window-precisely ()
  (delete-other-windows)
  (let ((dead-window (split-window-right))
        vterm-called)
    (delete-window dead-window)
    (cl-letf (((symbol-function 'rig--ensure-terminal-backend) #'ignore)
              ((symbol-function 'vterm)
               (lambda (&rest _args) (setq vterm-called t))))
      (let ((error
             (should-error
              (rig--attach-tmux-session
               "rig-fleet-nadia" "*rig-fleet-nadia*" "Nadia"
               default-directory dead-window)
              :type 'user-error)))
        (should
         (equal (error-message-string error)
                "Cannot display Rig terminal: target window is no longer live"))
        (should-not vterm-called)))))

(ert-deftest rig-direct-terminal-attach-retains-selected-window-behavior ()
  (unwind-protect
      (cl-letf (((symbol-function 'rig--ensure-terminal-backend) #'ignore)
                ((symbol-function 'vterm) #'rig-test--fake-vterm))
        (delete-other-windows)
        (let ((target-window (selected-window)))
          (rig--attach-tmux-session
           "rig-fleet-nadia" "*rig-fleet-nadia*" "Nadia"
           default-directory)
          (should (= (length (window-list nil 'nomini)) 1))
          (should (eq (selected-window) target-window))
          (should (eq (window-buffer target-window)
                      (get-buffer "*rig-fleet-nadia*")))))
    (when (get-buffer "*rig-fleet-nadia*")
      (kill-buffer "*rig-fleet-nadia*"))))

(ert-deftest rig-start-opens-md-and-roster-then-focuses-terminal ()
  (let (roster-window)
    (delete-other-windows)
    (let ((md-window (selected-window)))
      (cl-letf (((symbol-function 'rig-md)
                 (lambda () (select-window md-window)))
                ((symbol-function 'rig-roster)
                 (lambda ()
                   (setq roster-window
                         (split-window md-window 24 'left))
                   (select-window roster-window))))
        (rig-start)
        (should (eq (selected-window) md-window))
        (should (window-live-p roster-window))))))

(ert-deftest rig-md-command-uses-sol-high-and-auto-review ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "md/session-defaults.toml"
     (concat "runner = \"codex-cli\"\n"
             "model = \"gpt-5.6-sol\"\n"
             "reasoning_effort = \"high\"\n"
             "sandbox_mode = \"workspace-write\"\n"
             "approval_policy = \"on-request\"\n"
             "approvals_reviewer = \"auto_review\"\n"))
    (cl-letf (((symbol-function 'rig--required-executable)
               (lambda (name) (concat "/test/bin/" name))))
      (should
       (equal
        (rig--command-for-seat "md")
        (list "/test/bin/codex"
              "--model" "gpt-5.6-sol"
              "--config" "model_reasoning_effort=high"
              "--sandbox" "workspace-write"
              "--ask-for-approval" "on-request"
              "--config" "approvals_reviewer=auto_review"
              "--cd" (directory-file-name (expand-file-name "md" root))
              "--add-dir" (directory-file-name root)))))))

(ert-deftest rig-fleet-command-inherits-luna-high-and-auto-review ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "fleet/session-defaults.toml"
     (concat "runner = \"codex-cli\"\n"
             "model = \"gpt-5.6-luna\"\n"
             "reasoning_effort = \"high\"\n"
             "sandbox_mode = \"workspace-write\"\n"
             "approval_policy = \"on-request\"\n"
             "approvals_reviewer = \"auto_review\"\n"))
    (rig-test--write-file
     root "fleet/nadia/member.toml"
     (concat "beads_actor = \"Nadia\"\n"
             "worktree = \"worktree\"\n"))
    (cl-letf (((symbol-function 'rig--required-executable)
               (lambda (name) (concat "/test/bin/" name))))
      (should
       (equal
        (rig--command-for-seat "fleet/nadia")
        (list "/test/bin/codex"
              "--model" "gpt-5.6-luna"
              "--config" "model_reasoning_effort=high"
              "--sandbox" "workspace-write"
              "--ask-for-approval" "on-request"
              "--config" "approvals_reviewer=auto_review"
              "--cd" (directory-file-name
                        (expand-file-name "fleet/nadia" root))
              "--add-dir" (directory-file-name
                             (expand-file-name
                              "fleet/nadia/worktree" root))))))))

(ert-deftest rig-fleet-member-may-override-shared-session-defaults ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "fleet/session-defaults.toml"
     (concat "runner = \"codex-cli\"\n"
             "model = \"gpt-5.6-luna\"\n"
             "reasoning_effort = \"high\"\n"
             "sandbox_mode = \"workspace-write\"\n"
             "approval_policy = \"on-request\"\n"
             "approvals_reviewer = \"auto_review\"\n"))
    (rig-test--write-file
     root "fleet/nadia/session-defaults.toml"
     "model = \"gpt-5.6-sol\"\n")
    (cl-letf (((symbol-function 'rig--required-executable)
               (lambda (name) (concat "/test/bin/" name))))
      (should
       (equal (plist-get (rig--read-session-config "fleet/nadia") :model)
              "gpt-5.6-sol")))))

(provide 'rig-tests)

;;; rig-tests.el ends here
