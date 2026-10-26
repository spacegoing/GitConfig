;;; funcs.el --- sdev layer functions  -*- lexical-binding: t -*-
;;
;; Loaded before config.el (Spacemacs loads every layer's funcs.el first).

(defun sdev//prepend-to-path (&rest dirs)
  "Put each existing directory in DIRS at the front of PATH and `exec-path'."
  (dolist (dir dirs)
    (let ((d (expand-file-name dir)))
      (when (file-directory-p d)
        (add-to-list 'exec-path d)
        (unless (member d (split-string (or (getenv "PATH") "") path-separator))
          (setenv "PATH" (concat d path-separator (getenv "PATH"))))))))

;;;; Header line toggle (, p in python buffers)
;; lsp's breadcrumb is shown by default. `, p' swaps it for semantic's
;; sticky-function header and back. semantic-mode is switched on lazily the
;; first time, since the semantic layer is no longer loaded for every buffer.
(defvar my-headerline-toggle-state 'breadcrumb
  "Which header line is showing: `breadcrumb' or `stickyfunc'.")

(defvar-local sdev--semantic-wanted nil
  "Non-nil in buffers where `, p' asked for semantic (sticky function header).")

(defun sdev//semantic-inhibit ()
  "Keep semantic from parsing buffers that did not ask for it.
semantic-mode is global; without this, switching it on for one sticky
header would make it parse every file opened afterwards (one of the
old freeze sources on large Python repos)."
  (not sdev--semantic-wanted))

(defun my-toggle-headerline-modes ()
  "Toggle between lsp-headerline-breadcrumb-mode and semantic-stickyfunc-mode."
  (interactive)
  (if (eq my-headerline-toggle-state 'breadcrumb)
      (progn
        (when (fboundp 'lsp-headerline-breadcrumb-mode)
          (lsp-headerline-breadcrumb-mode -1))
        (require 'semantic)
        (setq sdev--semantic-wanted t)
        (make-directory semanticdb-default-save-directory t)
        (if (bound-and-true-p semantic-mode)
            (semantic-new-buffer-fcn)      ; parse just this buffer
          (semantic-mode 1))
        (semantic-stickyfunc-mode 1)
        (setq my-headerline-toggle-state 'stickyfunc))
    (semantic-stickyfunc-mode -1)
    (when (fboundp 'lsp-headerline-breadcrumb-mode)
      (lsp-headerline-breadcrumb-mode 1))
    (setq my-headerline-toggle-state 'breadcrumb)))

;;;; Restart the python language servers after a venv change
;; After `SPC m v w' / `SPC m v a' / `SPC m v d' the servers of the current
;; python buffer are restarted so basedpyright and ruff pick up the newly
;; selected interpreter and its site-packages.
(defun my/python-lsp-restart-after-venv-change (&rest _)
  "Advice for pyvenv commands: restart lsp in the current python buffer."
  (when (and (memq this-command '(pyvenv-workon pyvenv-activate pyvenv-deactivate))
             (derived-mode-p 'python-base-mode)
             (bound-and-true-p lsp-mode))
    (mapc #'lsp-workspace-restart (lsp-workspaces))))
