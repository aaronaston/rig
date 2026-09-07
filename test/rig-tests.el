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
              ((symbol-function 'rig--beads-issues)
               (lambda (_actor) nil)))
      (let ((state (rig--identity-state identity)))
        (should (equal (plist-get state :session) "running"))
        (should (equal (plist-get state :work-state) "idle"))
        (should (equal (plist-get state :task-summary) "no active task"))))
    (cl-letf (((symbol-function 'rig--tmux-session-live-p)
               (lambda (_name) nil))
              ((symbol-function 'rig--beads-issues)
               (lambda (_actor)
                 (list (rig-test--issue "Implement roster" "2")))))
      (let ((state (rig--identity-state identity)))
        (should (equal (plist-get state :session) "stopped"))
        (should (equal (plist-get state :work-state) "assigned"))))))

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

(ert-deftest rig-roster-keymaps-and-refresh-cadence-match-v1 ()
  (should (eq (lookup-key rig-terminal-control-mode-map (kbd "C-c r"))
              #'rig-roster))
  (should (eq (lookup-key rig-roster-mode-map (kbd "g"))
              #'rig-roster-refresh))
  (should (eq (lookup-key rig-roster-mode-map (kbd "RET"))
              #'rig-roster-activate))
  (should (= rig--roster-refresh-seconds 10)))

(ert-deftest rig-roster-refresh-renders-sections-and-truncates ()
  (rig-test--with-temp-root
    (rig-test--write-file
     root "md/seat.toml"
     (concat "slug = \"md\"\n"
             "name = \"Managing Director\"\n"
             "beads_actor = \"MD\"\n"))
    (rig-test--write-file
     root "fleet/nadia/member.toml"
     (concat "slug = \"nadia\"\n"
             "name = \"Nadia\"\n"
             "status = \"ready\"\n"
             "beads_actor = \"Nadia\"\n"))
    (cl-letf (((symbol-function 'rig--tmux-session-live-p)
               (lambda (_name) nil))
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
          (should (string-match-p "ready | stopped" (buffer-string)))
          (should (string-match-p "assigned:" (buffer-string)))
          (goto-char (point-min))
          (while (not (eobp))
            (should (<= (- (line-end-position) (line-beginning-position))
                        40))
            (forward-line 1)))))))

(ert-deftest rig-roster-truncation-preserves-additional-task-count ()
  (should
   (equal (rig--truncate-task-summary
           "A long task title that must shrink +2" 24 "  assigned: ")
          "A long t… +2")))

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
                 (lambda (seat tmux buffer label)
                   (setq opened (list seat tmux buffer label)
                         selected-at-open (selected-window)))))
        (delete-other-windows)
        (let ((roster (rig-roster)))
          (with-selected-window roster
            (rig-roster-activate))
          (should
           (equal opened
                  '("md" "rig-md" "*rig-md*" "Managing Director")))
          (should-not (eq selected-at-open roster))
          (should (window-live-p roster)))))))

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
