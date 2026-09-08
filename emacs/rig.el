;;; rig.el --- Emacs console for Rig sessions -*- lexical-binding: t; -*-

;; Rig keeps seat and fleet identity separate from the agent client and model
;; used by a particular session.

(require 'subr-x)
(require 'term)
(require 'json)
(require 'seq)

;; Declared by vterm when that optional package is loaded.  Declare them here
;; so lexical byte compilation preserves the intended dynamic bindings.
(defvar vterm-shell)
(defvar vterm-kill-buffer-on-exit)
(declare-function vterm "vterm" (&optional buffer-name))
(declare-function vterm-copy-mode "vterm" (&optional arg))
(declare-function vterm-copy-mode-done "vterm" (&optional arg))

(defgroup rig nil
  "Manage Rig agent sessions from Emacs."
  :group 'tools)

(defcustom rig-root
  (file-name-as-directory
   (expand-file-name ".." (file-name-directory
                           (or load-file-name buffer-file-name))))
  "Absolute path to the Rig repository root."
  :type 'directory
  :group 'rig)

(defconst rig--md-seat "md")
(defconst rig--md-tmux-session "rig-md")
(defconst rig--md-buffer-name "*rig-md*")
(defconst rig--roster-buffer-name "*Roster*")
(defconst rig--roster-refresh-seconds 120)

(defvar rig--roster-refresh-timer nil
  "Timer used to refresh the Roster while it is visible.")

(defvar-local rig--terminal-session-label nil
  "Human-readable label for the Rig session in the current terminal buffer.")

(defcustom rig-terminal-backend 'vterm
  "Terminal emulator used for interactive Rig sessions."
  :type '(choice (const :tag "VTerm" vterm))
  :group 'rig)

(defvar rig-terminal-control-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<f12>") #'rig-terminal-toggle-control)
    (define-key map (kbd "C-c C-j") #'rig-terminal-emacs-mode)
    (define-key map (kbd "C-c C-k") #'rig-terminal-codex-mode)
    (define-key map (kbd "C-c d") #'rig-session-detach)
    (define-key map (kbd "C-c r") #'rig-roster)
    map)
  "Keys Rig reserves before a terminal process can receive them.")

(define-minor-mode rig-terminal-control-mode
  "Reserve reliable Emacs control keys in a Rig terminal buffer."
  :init-value nil
  :lighter " Rig"
  :keymap rig-terminal-control-mode-map)

(defun rig--required-executable (name)
  "Return the executable path for NAME, or raise a useful error."
  (or (executable-find name)
      (user-error "Rig requires `%s' on PATH" name)))

(defun rig--ensure-terminal-backend ()
  "Load and validate Rig's configured terminal emulator."
  (pcase rig-terminal-backend
    ('vterm
     (unless (or (require 'vterm nil t)
                 (progn
                   (require 'package)
                   (package-initialize)
                   (require 'vterm nil t)))
       (user-error
        "Rig requires Emacs vterm; run bin/rig-install-emacs-deps")))
    (_ (user-error "Unsupported Rig terminal backend: %s"
                   rig-terminal-backend))))

(defun rig--seat-directory (seat)
  "Return SEAT's durable home directory."
  (file-name-as-directory (expand-file-name seat rig-root)))

(defun rig--read-string-config-file (file &optional required)
  "Read top-level quoted string values from FILE.

When REQUIRED is non-nil, signal a user error if FILE is unreadable.  This is
intentionally not a general TOML parser."
  (if (not (file-readable-p file))
      (when required
        (user-error "Missing Rig configuration: %s" file))
    (let (config)
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (while (re-search-forward
                "^\\([[:alnum:]_-]+\\)[[:space:]]*=[[:space:]]*\"\\([^\"]+\\)\""
                nil t)
          (setq config
                (plist-put config
                           (intern (concat ":" (match-string 1)))
                           (match-string 2)))))
      config)))

(defun rig--read-session-config (seat)
  "Read and merge Rig's session and optional member configuration for SEAT.

Fleet members inherit the shared fleet session defaults.  A member-specific
session-defaults.toml is optional and takes precedence when present."
  (let* ((seat-directory (rig--seat-directory seat))
         (session-file (expand-file-name "session-defaults.toml" seat-directory))
         (member-file (expand-file-name "member.toml" seat-directory))
         (fleet-member-p (string-prefix-p "fleet/" seat))
         (fleet-defaults-file
          (expand-file-name "fleet/session-defaults.toml" rig-root)))
    (if fleet-member-p
        (append (rig--read-string-config-file session-file)
                (rig--read-string-config-file fleet-defaults-file t)
                (rig--read-string-config-file member-file))
      (append (rig--read-string-config-file session-file t)
              (rig--read-string-config-file member-file)))))

(defun rig--identity-from-manifest (file kind)
  "Return a Rig identity read from manifest FILE of KIND."
  (let* ((config (rig--read-string-config-file file t))
         (home (file-name-directory file))
         (slug (or (plist-get config :slug)
                   (file-name-nondirectory (directory-file-name home))))
         (seat (if (eq kind 'fleet) (format "fleet/%s" slug) slug))
         (name (or (plist-get config :name) (capitalize slug)))
         (actor (or (plist-get config :beads_actor) name)))
    (list :kind kind
          :slug slug
          :seat seat
          :name name
          :actor actor
          :lifecycle (plist-get config :status)
          :home home
          :worktree (plist-get config :worktree)
          :tmux (or (plist-get config :tmux_session)
                    (if (eq kind 'fleet)
                        (rig--fleet-tmux-session slug)
                      (format "rig-%s" slug)))
          :buffer (or (plist-get config :buffer_name)
                      (if (eq kind 'fleet)
                          (rig--fleet-buffer-name slug)
                        (format "*rig-%s*" slug))))))

(defun rig--discover-identities ()
  "Discover declared Rig seats and fleet members from their manifests."
  (let ((seat-files
         (file-expand-wildcards (expand-file-name "*/seat.toml" rig-root)))
        (fleet-files
         (file-expand-wildcards
          (expand-file-name "fleet/*/member.toml" rig-root))))
    (list
     (sort (mapcar (lambda (file)
                     (rig--identity-from-manifest file 'seat))
                   seat-files)
           (lambda (a b) (string-lessp (plist-get a :name)
                                        (plist-get b :name))))
     (sort (mapcar (lambda (file)
                     (rig--identity-from-manifest file 'fleet))
                   fleet-files)
           (lambda (a b) (string-lessp (plist-get a :name)
                                        (plist-get b :name)))))))

(defun rig--beads-issues (actor)
  "Return open and in-progress Beads issues assigned to ACTOR.

Return :unavailable when Beads cannot be queried."
  (condition-case nil
      (with-temp-buffer
        (let ((status
               (process-file
                (rig--required-executable "bd") nil t nil
                "-C" (directory-file-name rig-root)
                "list" "--assignee" actor
                "--status" "open,in_progress" "--json")))
          (if (not (eq status 0))
              :unavailable
            (goto-char (point-min))
            (let ((json-array-type 'list)
                  (json-object-type 'alist)
                  (json-key-type 'symbol)
                  (json-false nil)
                  (json-null nil))
              (json-read)))))
    (error :unavailable)))

(defun rig--issue-needs-review-p (issue)
  "Return non-nil when ISSUE has the needs-review label."
  (member "needs-review" (alist-get 'labels issue)))

(defun rig--issue-newer-p (a b)
  "Order issues A and B for the roster task summary."
  (let ((a-review (rig--issue-needs-review-p a))
        (b-review (rig--issue-needs-review-p b)))
    (if (eq (not (null a-review)) (not (null b-review)))
        (string> (or (alist-get 'updated_at a) "")
                 (or (alist-get 'updated_at b) ""))
      a-review)))

(defun rig--task-summary (issues)
  "Return the accepted short task summary for ISSUES."
  (cond
   ((eq issues :unavailable) "tasks unavailable")
   ((null issues) "no active task")
   (t
    (let* ((ordered (sort (copy-sequence issues) #'rig--issue-newer-p))
           (title (or (alist-get 'title (car ordered)) "untitled task"))
           (additional (1- (length ordered))))
      (if (> additional 0)
          (format "%s +%d" title additional)
        title)))))

(defun rig--identity-state (identity)
  "Add observable session and work state to IDENTITY."
  (let* ((issues (rig--beads-issues (plist-get identity :actor)))
         (session-live (rig--tmux-session-live-p
                        (plist-get identity :tmux)))
         (work-state (cond
                      ((eq issues :unavailable) "unknown")
                      ((null issues) "idle")
                      (t "assigned"))))
    (append identity
            (list :session (if session-live "running" "stopped")
                  :attachment (and session-live
                                   (rig--tmux-attachment-state
                                    (plist-get identity :tmux)))
                  :work-state work-state
                  :task-summary (rig--task-summary issues)))))

(defun rig--roster-window-width (&optional frame)
  "Return the bounded roster width for FRAME."
  (max 24 (min 40 (round (* 0.2 (frame-width frame))))))

(defvar rig-roster-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "g") #'rig-roster-refresh)
    (define-key map (kbd "RET") #'rig-roster-activate)
    map)
  "Keymap for Roster buffers.")

(define-derived-mode rig-roster-mode special-mode "Roster"
  "Read-only view of declared Rig identities and observable state."
  (setq-local truncate-lines t))

(defun rig--roster-entry-at-point ()
  "Return the roster identity at point, if any."
  (get-text-property (point) 'rig-identity))

(defun rig--truncate-task-summary (summary width prefix)
  "Fit SUMMARY after PREFIX within WIDTH, preserving a trailing +N count."
  (let ((available (max 1 (- width (string-width prefix)))))
    (if (string-match "\\(.*\\)\\( [+][0-9]+\\)$" summary)
        (let* ((title (match-string 1 summary))
               (suffix (match-string 2 summary))
               (title-width (max 1 (- available (string-width suffix)))))
          (concat
           (truncate-string-to-width title title-width nil nil "…")
           suffix))
      (truncate-string-to-width summary available nil nil "…"))))

(defun rig--insert-roster-section (title identities width)
  "Insert roster section TITLE with IDENTITIES truncated to WIDTH."
  (insert (propertize title 'face 'bold) "\n")
  (if (null identities)
      (insert "  None\n")
    (dolist (identity identities)
      (let* ((state (rig--identity-state identity))
             (lifecycle (or (plist-get state :lifecycle) "unknown"))
             (session (plist-get state :session))
             (attachment (plist-get state :attachment))
             (work-state (plist-get state :work-state))
             (task-prefix "Task: ")
             (task-line
              (concat task-prefix
                      (rig--truncate-task-summary
                       (plist-get state :task-summary)
                       width task-prefix)))
             (start (point)))
        (insert
         (truncate-string-to-width
          (format "  %s" (plist-get state :name)) width nil nil "…")
         "\n"
         (truncate-string-to-width
          (format "Lifecycle: %s" lifecycle) width nil nil "…")
         "\n"
         (truncate-string-to-width
          (format "Tmux: %s" session) width nil nil "…")
         "\n"
         (if attachment
             (concat
              (truncate-string-to-width
               (format "Attachment: %s" attachment) width nil nil "…")
              "\n")
           "")
         (truncate-string-to-width
          (format "Work: %s" work-state) width nil nil "…")
         "\n"
         task-line
         "\n")
        (add-text-properties
         start (point)
         (list 'rig-identity identity
               'mouse-face 'highlight
               'help-echo "RET: start or attach this Rig identity")))))
  (insert "\n"))

(defun rig-roster-refresh ()
  "Refresh the Roster immediately from manifests and live state."
  (interactive)
  (let* ((buffer (get-buffer-create rig--roster-buffer-name))
         (identity (and (eq (current-buffer) buffer)
                        (rig--roster-entry-at-point)))
         (identity-key (and identity
                            (cons (plist-get identity :kind)
                                  (plist-get identity :slug))))
         (groups (rig--discover-identities))
         ;; The side-window separator and terminal truncation glyph consume
         ;; two columns of the total width.
         (width (max 1 (- (rig--roster-window-width) 2))))
    (with-current-buffer buffer
      (unless (derived-mode-p 'rig-roster-mode)
        (rig-roster-mode))
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (propertize "Roster\n"
                            'face '(:weight bold :height 1.1)))
        (insert "g refresh  RET open\nC-x 0 close\n\n")
        (insert (propertize "State key\n" 'face 'bold))
        (insert "active: enabled management seat\n")
        (insert "ready: onboarding gates passed\n")
        (insert "running: tmux session exists\n")
        (insert "attached: tmux client connected\n")
        (insert "detached: no tmux clients\n")
        (insert "These do not show Codex activity.\n\n")
        (rig--insert-roster-section "Seats" (car groups) width)
        (rig--insert-roster-section "Fleet" (cadr groups) width)
        (goto-char (point-min))
        (when identity-key
          (let (match)
            (while (and (setq match
                              (text-property-search-forward
                               'rig-identity nil nil t))
                        (not
                         (let ((candidate
                                (get-text-property
                                 (prop-match-beginning match)
                                 'rig-identity)))
                           (and
                            (eq (plist-get candidate :kind)
                                (car identity-key))
                            (equal (plist-get candidate :slug)
                                   (cdr identity-key)))))))
            (when match
              (goto-char (prop-match-beginning match))))))
      buffer)))

(defun rig--roster-cancel-refresh ()
  "Cancel the roster refresh timer."
  (when (timerp rig--roster-refresh-timer)
    (cancel-timer rig--roster-refresh-timer))
  (setq rig--roster-refresh-timer nil))

(defun rig--roster-refresh-if-visible ()
  "Refresh the roster if visible, otherwise stop its timer."
  (if (get-buffer-window rig--roster-buffer-name t)
      (rig-roster-refresh)
    (rig--roster-cancel-refresh)))

(defun rig--roster-schedule-refresh ()
  "Schedule two-minute Roster refreshes while it is visible."
  (rig--roster-cancel-refresh)
  (setq rig--roster-refresh-timer
        (run-with-timer rig--roster-refresh-seconds
                        rig--roster-refresh-seconds
                        #'rig--roster-refresh-if-visible)))

(defun rig--resize-roster-window (window)
  "Resize roster WINDOW to the accepted bounded width when possible."
  (let ((delta (- (rig--roster-window-width (window-frame window))
                  (window-total-width window))))
    (unless (zerop delta)
      (ignore-errors (window-resize window delta t t)))))

;;;###autoload
(defun rig-roster ()
  "Open or focus the Roster in a normal left-side window."
  (interactive)
  (let* ((buffer (rig-roster-refresh))
         (window (or (get-buffer-window buffer t)
                     (display-buffer-in-side-window
                      buffer '((side . left)
                               (slot . -1)
                               (window-width . 0.2))))))
    (rig--resize-roster-window window)
    (rig--roster-schedule-refresh)
    (select-window window)
    (goto-char (point-min))
    (let ((match (text-property-search-forward
                  'rig-identity nil nil t)))
      (when match
        (goto-char (prop-match-beginning match))))
    window))

(defun rig--roster-main-window (roster-window)
  "Return the largest non-side window other than ROSTER-WINDOW."
  (car
   (sort
    (seq-filter
     (lambda (window)
       (and (not (eq window roster-window))
            (not (window-minibuffer-p window))
            (not (window-parameter window 'window-side))))
     (window-list nil 'nomini))
    (lambda (a b)
      (> (* (window-total-width a) (window-total-height a))
         (* (window-total-width b) (window-total-height b)))))))

(defun rig--identity-provisioning-error (identity)
  "Return a precise provisioning error for IDENTITY, or nil."
  (when (equal (plist-get identity :lifecycle) "provisioning")
    (let* ((worktree (plist-get identity :worktree))
           (path (and worktree
                      (expand-file-name worktree
                                        (plist-get identity :home)))))
      (if (and path (not (file-directory-p path)))
          (format "%s is provisioning; missing worktree %s"
                  (plist-get identity :name) path)
        (format "%s is provisioning; MD has not marked onboarding complete"
                (plist-get identity :name))))))

(defun rig-roster-activate ()
  "Start or attach the Rig identity on the current roster entry."
  (interactive)
  (let* ((identity (rig--roster-entry-at-point))
         (roster-window (selected-window))
         (error-message
          (and identity (rig--identity-provisioning-error identity)))
         (main-window (rig--roster-main-window roster-window)))
    (unless identity
      (user-error "No Rig identity on this line"))
    (when error-message
      (user-error "%s" error-message))
    (unless (window-live-p main-window)
      (user-error "Roster needs a main window for the terminal"))
    (select-window main-window)
    (rig--open-session (plist-get identity :seat)
                       (plist-get identity :tmux)
                       (plist-get identity :buffer)
                       (plist-get identity :name)
                       main-window)
    (rig-roster-refresh)
    (rig--roster-schedule-refresh)))

(defun rig--work-area-directories (seat config)
  "Return the writable project areas for SEAT described by CONFIG."
  (let ((worktree (plist-get config :worktree)))
    (if worktree
        (list (expand-file-name worktree (rig--seat-directory seat)))
      (list rig-root))))

(defun rig--ensure-work-areas (seat config)
  "Require all configured writable project areas for SEAT to exist."
  (dolist (directory (rig--work-area-directories seat config))
    (unless (file-directory-p directory)
      (user-error
       "Missing work area %s; run bin/rig-fleet-onboard %s"
       directory (file-name-nondirectory (directory-file-name
                                          (rig--seat-directory seat)))))))

(defun rig--codex-command (seat config)
  "Translate runner-neutral CONFIG into a Codex CLI command for SEAT."
  (let ((model (plist-get config :model))
        (effort (plist-get config :reasoning_effort))
        (sandbox (plist-get config :sandbox_mode))
        (approval-policy (plist-get config :approval_policy))
        (approvals-reviewer (plist-get config :approvals_reviewer))
        (seat-directory (rig--seat-directory seat))
        command)
    (unless (and model effort sandbox approval-policy approvals-reviewer)
      (user-error
       (concat "Codex sessions require model, reasoning_effort, sandbox_mode, "
               "approval_policy, and approvals_reviewer")))
    (setq command
          (list (rig--required-executable "codex")
                "--model" model
                "--config" (format "model_reasoning_effort=%s" effort)
                "--sandbox" sandbox
                "--ask-for-approval" approval-policy
                "--config" (format "approvals_reviewer=%s" approvals-reviewer)
                "--cd" (directory-file-name seat-directory)))
    (dolist (directory (rig--work-area-directories seat config) command)
      (setq command
            (append command
                    (list "--add-dir" (directory-file-name directory)))))))

(defun rig--command-for-seat (seat)
  "Return the process command for SEAT."
  (let* ((config (rig--read-session-config seat))
         (runner (plist-get config :runner)))
    (pcase runner
      ("codex-cli" (rig--codex-command seat config))
      (_ (user-error "Unsupported Rig session runner: %s" runner)))))

(defun rig--tmux-session-live-p (name)
  "Return non-nil when tmux session NAME exists."
  (eq 0 (call-process (rig--required-executable "tmux")
                      nil nil nil "has-session" "-t" name)))

(defun rig--tmux-attachment-state (name)
  "Return attachment state for existing tmux session NAME.

The result is `attached' for one or more clients, `detached' for zero clients,
or `unavailable' when tmux does not return valid metadata."
  (condition-case nil
      (with-temp-buffer
        (let ((status
               (process-file
                (rig--required-executable "tmux") nil t nil
                "display-message" "-p" "-t" name "#{session_attached}")))
          (if (not (eq status 0))
              "unavailable"
            (let ((count (string-trim (buffer-string))))
              (if (not (string-match-p "\\`[0-9]+\\'" count))
                  "unavailable"
                (if (> (string-to-number count) 0)
                    "attached"
                  "detached"))))))
    (error "unavailable")))

(defun rig--start-tmux-session (name seat)
  "Start tmux session NAME using the configuration for SEAT."
  (let* ((session-command (rig--session-process-command seat))
         (seat-directory (rig--seat-directory seat))
         (shell-command (mapconcat #'shell-quote-argument session-command " "))
         (errors (get-buffer-create "*rig-errors*"))
         (status (call-process
                  (rig--required-executable "tmux") nil errors nil
                  "new-session" "-d" "-s" name
                  "-c" (directory-file-name seat-directory)
                  shell-command)))
    (unless (eq status 0)
      (display-buffer errors)
      (error "Could not start Rig session %s; see *rig-errors*" name))))

(defun rig--session-process-command (seat)
  "Return the environment-wrapped process command for SEAT."
  (let* ((config (rig--read-session-config seat))
         (command (rig--command-for-seat seat))
         (actor (plist-get config :beads_actor)))
    (if actor
        (append (list (rig--required-executable "env")
                      (format "BEADS_ACTOR=%s" actor))
                command)
      command)))

(defun rig-terminal-emacs-mode ()
  "Give Emacs normal control of keys in the current Rig terminal."
  (interactive)
  (cond
   ((derived-mode-p 'vterm-mode)
    (unless (bound-and-true-p vterm-copy-mode)
      (vterm-copy-mode 1)))
   ((derived-mode-p 'term-mode) (term-line-mode))
   (t (user-error "This is not a Rig terminal buffer")))
  (message "Emacs keys active; press F12 to return keys to Codex"))

(defun rig-terminal-codex-mode ()
  "Give the Codex terminal normal control of keys in the current buffer."
  (interactive)
  (cond
   ((derived-mode-p 'vterm-mode)
    (when (bound-and-true-p vterm-copy-mode)
      (vterm-copy-mode-done nil)))
   ((derived-mode-p 'term-mode) (term-char-mode))
   (t (user-error "This is not a Rig terminal buffer")))
  (message "Codex keys active; press F12 to return keys to Emacs"))

(defun rig-terminal-toggle-control ()
  "Toggle keyboard ownership between Emacs and the Codex terminal."
  (interactive)
  (cond
   ((derived-mode-p 'vterm-mode)
    (if (bound-and-true-p vterm-copy-mode)
        (rig-terminal-codex-mode)
      (rig-terminal-emacs-mode)))
   ((derived-mode-p 'term-mode)
    (if (eq (current-local-map) term-raw-map)
        (rig-terminal-emacs-mode)
      (rig-terminal-codex-mode)))
   (t (user-error "This is not a Rig terminal buffer"))))

(defun rig--require-terminal-target-window (window)
  "Return WINDOW when it can safely display a Rig terminal.

Raise a precise user error when WINDOW is no longer live or is not an ordinary,
replaceable Emacs window."
  (unless (window-live-p window)
    (user-error "Cannot display Rig terminal: target window is no longer live"))
  (when (window-minibuffer-p window)
    (user-error "Cannot display Rig terminal: target window is a minibuffer"))
  (when (window-parameter window 'window-side)
    (user-error "Cannot display Rig terminal: target window is a side window"))
  (when (window-dedicated-p window)
    (user-error "Cannot display Rig terminal: target window is dedicated"))
  window)

(defun rig--show-terminal-buffer (buffer &optional target-window)
  "Show BUFFER in TARGET-WINDOW, or use normal display policy when nil.

An explicit target is authoritative: ambient `display-buffer-alist' rules may
not redirect the terminal or create another window."
  (if target-window
      (let ((window (rig--require-terminal-target-window target-window)))
        (set-window-buffer window buffer)
        (select-window window)
        buffer)
    (pop-to-buffer buffer)))

(defun rig--attach-tmux-session (name buffer-name label directory
                                      &optional target-window)
  "Attach NAME in BUFFER-NAME, identified as LABEL and rooted at DIRECTORY.

When TARGET-WINDOW is non-nil, display the terminal in that exact window
without consulting ambient display-buffer rules."
  (when target-window
    (rig--require-terminal-target-window target-window))
  (rig--ensure-terminal-backend)
  (let ((existing (get-buffer buffer-name)))
    (if (and existing (process-live-p (get-buffer-process existing)))
        (rig--show-terminal-buffer existing target-window)
      (when existing
        (kill-buffer existing))
      (let* ((vterm-shell (expand-file-name "bin/rig-tmux-attach" rig-root))
             (vterm-kill-buffer-on-exit nil)
             (process-environment
              (cons (format "RIG_TMUX_SESSION=%s" name)
                    process-environment))
             (default-directory directory)
             (buffer
              (if target-window
                  (with-selected-window target-window
                    (let ((display-buffer-overriding-action
                           (cons
                            (lambda (buffer _alist)
                              (let ((window
                                     (rig--require-terminal-target-window
                                      target-window)))
                                (set-window-buffer window buffer)
                                window))
                            nil)))
                      (vterm buffer-name)))
                (vterm buffer-name))))
        (with-current-buffer buffer
          (rig-terminal-control-mode 1)
          (setq-local rig--terminal-session-label label)
          (setq-local default-directory directory))
        (rig--show-terminal-buffer buffer target-window)))))

(defun rig--open-session (seat name buffer-name label &optional target-window)
  "Open SEAT in tmux session NAME and terminal BUFFER-NAME labeled LABEL.

When TARGET-WINDOW is non-nil, keep the session in that exact window."
  (when target-window
    (rig--require-terminal-target-window target-window))
  (rig--ensure-terminal-backend)
  (let ((config (rig--read-session-config seat)))
    (rig--ensure-work-areas seat config))
  (unless (rig--tmux-session-live-p name)
    (rig--start-tmux-session name seat))
  (rig--attach-tmux-session name buffer-name label
                            (rig--seat-directory seat)
                            target-window))

(defun rig--session-status (name label)
  "Report whether tmux session NAME for LABEL is running."
  (message "Rig %s session: %s"
           label
           (if (rig--tmux-session-live-p name) "running" "stopped")))

(defun rig--detach-buffer (buffer-name label)
  "Close BUFFER-NAME while leaving the tmux session for LABEL running."
  (let ((buffer (get-buffer buffer-name)))
    (when buffer
      (let ((process (get-buffer-process buffer)))
        (when (process-live-p process)
          (delete-process process)))
      (kill-buffer buffer)))
  (message "Detached from %s; its tmux session is still running" label))

(defun rig-session-detach ()
  "Detach the current Rig terminal without ending its tmux session."
  (interactive)
  (unless (and rig--terminal-session-label
               (bound-and-true-p rig-terminal-control-mode))
    (user-error "This is not a Rig terminal buffer"))
  (rig--detach-buffer (buffer-name) rig--terminal-session-label))

;;;###autoload
(defun rig-md ()
  "Open MD in Emacs, creating its persistent session when necessary."
  (interactive)
  (rig--open-session rig--md-seat rig--md-tmux-session
                     rig--md-buffer-name "MD"))

;;;###autoload
(defun rig-md-status ()
  "Report whether MD's persistent session is running."
  (interactive)
  (rig--session-status rig--md-tmux-session "MD"))

;;;###autoload
(defun rig-md-detach ()
  "Close MD's Emacs terminal while leaving its tmux session running.

  From the MD terminal, invoke this directly with `C-c d'."
  (interactive)
  (rig--detach-buffer rig--md-buffer-name "MD"))

;;;###autoload
(defun rig-start ()
  "Open MD and the Roster, leaving the terminal in the main window."
  (interactive)
  (rig-md)
  (let ((terminal-window (selected-window)))
    (rig-roster)
    (when (window-live-p terminal-window)
      (select-window terminal-window))))

(defun rig--fleet-seat (member)
  "Return the seat path for fleet MEMBER."
  (format "fleet/%s" member))

(defun rig--fleet-tmux-session (member)
  "Return the tmux session name for fleet MEMBER."
  (format "rig-fleet-%s" member))

(defun rig--fleet-buffer-name (member)
  "Return the Emacs buffer name for fleet MEMBER."
  (format "*rig-fleet-%s*" member))

;;;###autoload
(defun rig-fleet-member (member)
  "Open fleet MEMBER, creating their persistent session when necessary."
  (interactive "sFleet member slug: ")
  (unless (string-match-p "\\`[a-z0-9-]+\\'" member)
    (user-error "Invalid fleet member slug: %s" member))
  (let ((seat (rig--fleet-seat member)))
    (unless (file-directory-p (rig--seat-directory seat))
      (user-error "Unknown fleet member: %s" member))
    (rig--open-session seat
                       (rig--fleet-tmux-session member)
                       (rig--fleet-buffer-name member)
                       (capitalize member))))

;;;###autoload
(defun rig-fleet-member-status (member)
  "Report whether fleet MEMBER's persistent session is running."
  (interactive "sFleet member slug: ")
  (rig--session-status (rig--fleet-tmux-session member)
                       (capitalize member)))

;;;###autoload
(defun rig-fleet-member-detach (member)
  "Detach fleet MEMBER's terminal while leaving their session running."
  (interactive "sFleet member slug: ")
  (rig--detach-buffer (rig--fleet-buffer-name member)
                      (capitalize member)))

(provide 'rig)

;;; rig.el ends here
