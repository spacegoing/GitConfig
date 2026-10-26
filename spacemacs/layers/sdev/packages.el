;;; packages.el --- sdev layer packages  -*- lexical-binding: t -*-
;;
;; sdev owns no package of its own; it only adds to packages that the
;; python, rust and lsp layers install (post-init functions).

(defconst sdev-packages
  '(lsp-mode
    python
    pyvenv
    code-cells))

(defun sdev/post-init-lsp-mode ()
  ;; pylsp runs ruff as a plugin; do not start the ruff server beside it.
  (when (eq python-lsp-server 'pylsp)
    (with-eval-after-load 'lsp-mode
      (add-to-list 'lsp-disabled-clients 'ruff))))

(defun sdev/post-init-python ()
  ;; , h s  show the signature of the call at point
  ;; , p    toggle header line: lsp breadcrumb <-> semantic sticky function
  (dolist (mode '(python-mode python-ts-mode))
    (spacemacs/set-leader-keys-for-major-mode mode
      "hs" 'lsp-signature-activate
      "p" 'my-toggle-headerline-modes)))

(defun sdev/post-init-pyvenv ()
  ;; Restart the buffer's language servers after SPC m v w / v a / v d.
  (dolist (f '(pyvenv-workon pyvenv-activate pyvenv-deactivate))
    (advice-add f :after #'my/python-lsp-restart-after-venv-change)))

(defun sdev/post-init-code-cells ()
  ;; Accept indented cell markers (# %% inside a function) and "# In[3]:".
  (with-eval-after-load 'code-cells
    (setq code-cells-boundary-regexp
          (rx (* (syntax whitespace))
              (+ (syntax comment-start))
              (or (seq (* (syntax whitespace)) "%" (group-n 1 (+ "%")))
                  (group-n 1 (+ "*"))
                  (seq " In[" (* (any space digit)) "]:"))))))
