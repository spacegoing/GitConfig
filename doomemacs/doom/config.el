;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Basic configuration
(setq user-full-name "SPACEGOING"
      user-mail-address "spacegoing@gmail.com")

(setq doom-theme 'doom-one)
(setq display-line-numbers-type t)
(setq org-directory "~/org/")

;; Performance optimizations
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; Evil configuration - Spacemacs-like escape sequences
(after! evil
        (setq evil-escape-key-sequence "fd")
        (setq evil-escape-delay 0.15)
        (define-key evil-insert-state-map (kbd "C-[") 'evil-normal-state)
        (define-key evil-visual-state-map (kbd "C-[") 'evil-normal-state)
        (define-key evil-replace-state-map (kbd "C-[") 'evil-normal-state))

;; Spacemacs-like major mode leader key
(setq doom-localleader-key ",")
(setq doom-localleader-alt-key "M-,")

;; Window management - Spacemacs style
(use-package! winum
              :init
              (setq winum-mode-line-position 1)
              :config
              (winum-mode +1)
              (map! :leader
                    :desc "Window 1" "1" #'winum-select-window-1
                    :desc "Window 2" "2" #'winum-select-window-2
                    :desc "Window 3" "3" #'winum-select-window-3
                    :desc "Window 4" "4" #'winum-select-window-4
                    :desc "Window 5" "5" #'winum-select-window-5
                    :desc "Window 6" "6" #'winum-select-window-6
                    :desc "Window 7" "7" #'winum-select-window-7
                    :desc "Window 8" "8" #'winum-select-window-8
                    :desc "Window 9" "9" #'winum-select-window-9))

(map! :leader
      (:prefix "w"
               :desc "Split window right" "/" #'split-window-right
               :desc "Split window below" "-" #'split-window-below))

;; Dired configuration
(defun my-dired-up-directory (&optional other-window)
  "Same as `dired-up-directory', except for wrapping with `file-truename'."
  (interactive "P")
  (let* ((dir (file-truename (dired-current-directory)))
         (up (file-name-directory (directory-file-name dir))))
    (or (dired-goto-file (directory-file-name dir))
        (and (cdr dired-subdir-alist) (dired-goto-subdir up))
        (progn (if other-window (dired-other-window up) (dired up))
               (dired-goto-file dir)))))

(defun my-file-up-directory ()
  "Open dired in the current file's directory."
  (interactive)
  (if default-directory
      (dired (expand-file-name default-directory))
    (error "No `default-directory' to open")))

(after! dired
        (define-key dired-mode-map (kbd "P") 'my-dired-up-directory)
        (map! :leader
              :desc "Open file's directory" "f j" #'my-file-up-directory))

;; Eglot configuration
(after! eglot
        ;; Force eglot to use pyright for Python
        (setf (alist-get 'python-mode eglot-server-programs)
              '("pyright-langserver" "--stdio"))
        (setf (alist-get 'python-ts-mode eglot-server-programs)
              '("pyright-langserver" "--stdio"))

        ;; Configure Pyright settings
        (setq-default eglot-workspace-configuration
                      '(:python (:analysis (:autoSearchPaths t
                                                             :useLibraryCodeForTypes t
                                                             :typeCheckingMode "standard"
                                                             :diagnosticMode "workspace"
                                                             :autoImportCompletions t))
                                :pyright (:disableOrganizeImports :json-false)))

        ;; Performance settings
        (setq eglot-sync-connect nil)
        (setq eglot-autoshutdown t)
        (setq eglot-send-changes-idle-time 0.5)

        ;; Ensure eglot starts automatically for Python files
        (add-hook 'python-mode-hook #'eglot-ensure)
        (add-hook 'python-ts-mode-hook #'eglot-ensure))

;; Python configuration
(after! python
        (setq python-shell-interpreter "python3"))

;; Formatting with Apheleia
(use-package! apheleia
              :config
              ;; Configure ruff for Python formatting
              (setf (alist-get 'python-mode apheleia-mode-alist)
                    '(ruff-isort ruff))
              (setf (alist-get 'python-ts-mode apheleia-mode-alist)
                    '(ruff-isort ruff))

              ;; Define the ruff formatters
              (setf (alist-get 'ruff apheleia-formatters)
                    '("ruff" "format" "-"))
              (setf (alist-get 'ruff-isort apheleia-formatters)
                    '("ruff" "check" "--select" "I" "--fix" "-"))

              ;; Enable apheleia mode globally
              (apheleia-global-mode +1))

;; Linting with Flycheck + Ruff
(after! flycheck
        ;; Define ruff checker
        (flycheck-define-checker python-ruff
          "A Python syntax and style checker using ruff."
          :command ("ruff" "check" "--output-format=concise" source)
          :error-patterns
          ((error line-start (file-name) ":" line ":" column ": " (id (one-or-more (not (any " ")))) " " (message) line-end))
          :modes (python-mode python-ts-mode)
          :next-checkers ((warning . python-mypy)))

        ;; Add ruff to the list of checkers
        (add-to-list 'flycheck-checkers 'python-ruff)

        ;; Configure checker chain for Python
        (defun my/python-flycheck-setup ()
          "Setup flycheck for Python with Ruff."
          (setq-local flycheck-checkers '(python-ruff))
          (setq-local flycheck-disabled-checkers '(lsp eglot python-pylint python-flake8 python-pycompile)))

        (add-hook 'python-mode-hook #'my/python-flycheck-setup)
        (add-hook 'python-ts-mode-hook #'my/python-flycheck-setup))

;; Python keybindings
(map! :after python
      :map python-mode-map
      :localleader
      ;; Code navigation
      (:prefix ("g" . "goto")
               :desc "Go to definition" "d" #'xref-find-definitions
               :desc "Go to definition" "g" #'xref-find-definitions
               :desc "Go to references" "r" #'xref-find-references
               :desc "Go to implementation" "i" #'eglot-find-implementation
               :desc "Go to type definition" "t" #'eglot-find-typeDefinition
               :desc "Go back" "b" #'xref-go-back)

      ;; Refactoring and formatting
      (:prefix ("r" . "refactor")
               :desc "Format buffer" "f" #'apheleia-format-buffer
               :desc "Rename symbol" "r" #'eglot-rename
               :desc "Organize imports" "i" #'python-isort-buffer)

      ;; Format with ==
      :desc "Format buffer" "=" #'apheleia-format-buffer
      (:prefix ("=" . "format")
               :desc "Format buffer" "=" #'apheleia-format-buffer
               :desc "Format region" "r" #'apheleia-format-region)

      ;; Help and documentation
      (:prefix ("h" . "help")
               :desc "Describe at point" "h" #'eldoc
               :desc "Show documentation" "d" #'eldoc-doc-buffer
               :desc "Show signature help" "s" #'eglot-signature-help-at-point)

      ;; Testing
      (:prefix ("t" . "test")
               :desc "Run pytest" "t" #'python-pytest
               :desc "Run pytest for function" "f" #'python-pytest-function
               :desc "Run pytest for file" "F" #'python-pytest-file
               :desc "Run pytest again" "r" #'python-pytest-repeat)

      ;; REPL
      (:prefix ("s" . "repl")
               :desc "Start Python REPL" "s" #'run-python
               :desc "Send region to REPL" "r" #'python-shell-send-region
               :desc "Send buffer to REPL" "b" #'python-shell-send-buffer
               :desc "Send function to REPL" "f" #'python-shell-send-defun)

      ;; LSP/Eglot specific
      (:prefix ("l" . "lsp")
               :desc "Restart LSP" "r" #'eglot-reconnect
               :desc "Shutdown LSP" "s" #'eglot-shutdown
               :desc "Show diagnostics" "d" #'flymake-show-buffer-diagnostics
               :desc "Code actions" "a" #'eglot-code-actions
               :desc "Format buffer" "f" #'eglot-format-buffer))

;; Also bind format to python-ts-mode
(map! :after python
      :map python-ts-mode-map
      :localleader
      :desc "Format buffer" "=" #'apheleia-format-buffer
      (:prefix ("=" . "format")
               :desc "Format buffer" "=" #'apheleia-format-buffer
               :desc "Format region" "r" #'apheleia-format-region))

;; Company/Corfu configuration
(after! corfu
        (setq corfu-cycle t
              corfu-auto t
              corfu-auto-delay 0.1
              corfu-auto-prefix 2
              corfu-preview-current 'insert))

;; Projectile performance
(after! projectile
        (setq projectile-indexing-method 'alien)
        (setq projectile-sort-order 'recently-active))

;; Magit configuration
(after! magit
        (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Helper function for debugging eglot
(defun my/eglot-debug-info ()
  "Show debug information about the current eglot session."
  (interactive)
  (if (eglot-current-server)
      (message "Eglot server running: %s" (eglot--project-nickname (eglot-current-server)))
    (message "No eglot server running")))

;; Add to Python mode hook to ensure everything is set up
(defun my/python-mode-setup ()
  "Custom Python mode setup."
  (setq-local tab-width 4)
  (setq-local python-indent-offset 4)
  (setq-local evil-shift-width 4))

(add-hook 'python-mode-hook #'my/python-mode-setup)
(add-hook 'python-ts-mode-hook #'my/python-mode-setup)

;; Create snippets directory
(make-directory (expand-file-name "snippets" doom-user-dir) t)
