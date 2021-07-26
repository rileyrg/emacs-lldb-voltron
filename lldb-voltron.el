(defgroup rgr/llvm  nil
  "llvm options"
  :group 'rgr)

(defcustom rgr/lldb-ui-command "lldb-ui"
  "the ui/voltron command"
  :type 'string
  :group 'rgr/llvm)
(defcustom rgr/lldb-voltron-buffer-name "vterm-lldb-voltron"
  "the ui/voltron buffer base name"
  :type 'string
  :group 'rgr/llvm)

(define-minor-mode rgr/lldb-mode "my lldb mode" :lighter "lldb"
  :keymap '(
            ( [f10]   . (lambda()(interactive)(process-send-string (current-buffer) "thread step-over\n")))
            ( [f11]   . (lambda()(interactive)(process-send-string (current-buffer) "thread step-in\n")))
            ( [S-f11] . (lambda()(interactive)(process-send-string (current-buffer) "thread step-out\n")))
            ( [f12]  . (lambda()(interactive)(process-send-string (current-buffer) "thread step-inst\n")))))

(defun rgr/lldb-voltron-vterm(dir)
  "Run a vterm with lldb for the current buffer's directory, default DIR. Launch a lldb-ui instance unless prefix arg."
  (interactive "DDirectory:")
  (let* ((session-name (file-name-nondirectory(directory-file-name dir)))
         (lldb-ui-command (format "%s %s %s &" rgr/lldb-ui-command dir session-name))
         (vterm-buffer-name (format "*%s:%s*" rgr/lldb-voltron-buffer-name session-name)))
    (if (get-buffer vterm-buffer-name)
        (switch-to-buffer vterm-buffer-name)
      (progn
        (with-current-buffer (vterm)
          (process-send-string (current-buffer) (format "lldb && tmux kill-session -t %s && exit\n" session-name))
          (unless current-prefix-arg
            (call-process-shell-command lldb-ui-command)
            (process-send-string (current-buffer) "lv\n"))
          (rgr/lldb-mode))))))

(use-package projectile
  :bind
  (:map projectile-command-map ("D" . rgr/lldb-voltron-vterm))
  )

(provide 'lldb-voltron)
