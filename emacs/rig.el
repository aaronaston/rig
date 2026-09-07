;;; rig.el --- Emacs console for Rig sessions -*- lexical-binding: t; -*-

;; Rig keeps seat identity separate from the agent client and model used by a
;; particular session.  This first version exposes one seat: MD.

(require 'subr-x)
(require 'term)

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
  "Read and merge Rig's session and optional member configuration for SEAT."
  (let* ((seat-directory (rig--seat-directory seat))
         (session-file (expand-file-name "session-defaults.toml" seat-directory))
         (member-file (expand-file-name "member.toml" seat-directory)))
    (append (rig--read-string-config-file session-file t)
            (rig--read-string-config-file member-file))))

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
        (seat-directory (rig--seat-directory seat))
        command)
    (unless (and model effort)
      (user-error "Codex sessions require model and reasoning_effort"))
    (setq command
          (list (rig--required-executable "codex")
                "--model" model
                "--config" (format "model_reasoning_effort=%s" effort)
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

(defun rig--attach-tmux-session (name buffer-name label directory)
  "Attach NAME in BUFFER-NAME, identified as LABEL and rooted at DIRECTORY."
  (rig--ensure-terminal-backend)
  (let ((existing (get-buffer buffer-name)))
    (if (and existing (process-live-p (get-buffer-process existing)))
        (pop-to-buffer existing)
      (when existing
        (kill-buffer existing))
      (let* ((vterm-shell (expand-file-name "bin/rig-tmux-attach" rig-root))
             (vterm-kill-buffer-on-exit nil)
             (process-environment
              (cons (format "RIG_TMUX_SESSION=%s" name)
                    process-environment))
             (default-directory directory)
             (buffer (vterm buffer-name)))
        (with-current-buffer buffer
          (rig-terminal-control-mode 1)
          (setq-local rig--terminal-session-label label)
          (setq-local default-directory directory))
        (pop-to-buffer buffer)))))

(defun rig--open-session (seat name buffer-name label)
  "Open SEAT in tmux session NAME and terminal BUFFER-NAME labeled LABEL."
  (rig--ensure-terminal-backend)
  (let ((config (rig--read-session-config seat)))
    (rig--ensure-work-areas seat config))
  (unless (rig--tmux-session-live-p name)
    (rig--start-tmux-session name seat))
  (rig--attach-tmux-session name buffer-name label
                            (rig--seat-directory seat)))

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
