;;; config.el --- sdev layer: shared development settings  -*- lexical-binding: t -*-
;;
;; Everything here is machine independent and is used by both dotfiles
;; (init.macos.el and init.linux.el). Plain variables only; code that must
;; run when a package loads is in packages.el. Keys are in keybindings.el.
;;
;; Per-machine values (paths, interpreters, proxies) go to ~/.spacemacs.d/local.el.

;;;; Tool directories: language servers and the rust toolchain
;; ~/.local/bin : basedpyright + ruff  (scripts/install-lsp-servers.sh, via uv)
;; ~/.cargo/bin : rust-analyzer        (rustup component)
;; First on PATH so a stale `ruff' inside a conda env does not shadow them.
(sdev//prepend-to-path "~/.cargo/bin" "~/.local/bin")

;;;; lsp-mode: keep a large repo from freezing Emacs
;; These are the settings that made vllm / verl / Megatron usable. Each one
;; removes work that lsp-mode would otherwise do per directory or per
;; keystroke; none changes what you see while editing.
(setq lsp-enable-file-watchers nil        ; no walk of the repo + one watcher per dir
      lsp-idle-delay 0.5                  ; was 0.0: a request on every keystroke
      lsp-lens-enable nil                 ; code lenses: a request per visible line
      lsp-keep-workspace-alive nil        ; kill the server with its last buffer
      lsp-enable-suggest-server-download nil ; never prompt to npm-install a server
      lsp-log-io nil                      ; protocol log off (set t in local.el to debug)
      lsp-headerline-breadcrumb-enable t  ; the header line you are used to
      lsp-restart 'auto-restart)          ; a crashed server restarts, no prompt

;;;; Python: basedpyright + ruff server
;; basedpyright = pyright, pip/uv installable, node bundled. ruff's own
;; language server (`ruff server', ruff >= 0.5) runs beside it as an add-on.
;;
;;   from basedpyright : completion, goto definition/references, hover,
;;                       rename, syntax errors, undefined names, bad imports
;;   from ruff         : lint (F, E, I ...), SPC m = = format,
;;                       organize imports / fix-all code actions
;;
;; Why not pylsp: pylsp+jedi indexes the workspace in-process and hangs on
;; repos of this size. pylsp still works: set `python-lsp-server' to 'pylsp
;; in the dotfile and the tuning further down applies.
(setq lsp-pyright-langserver-command "basedpyright" ; starts basedpyright-langserver
      lsp-pyright-multi-root nil                   ; one server per project
      lsp-pyright-type-checking-mode "off"         ; "basic"/"standard" in local.el for type errors
      lsp-pyright-diagnostic-mode "openFilesOnly"  ; never analyse the whole repo
      lsp-pyright-disable-organize-imports t)      ; ruff owns imports
;; basedpyright can find the interpreter itself: an active venv (SPC m v w),
;; else ./venv or ./.venv in the project (uv convention), else `python' on PATH.

(setq lsp-ruff-server-command '("ruff" "server")
      lsp-ruff-show-notifications "off")

;; pylsp fallback tuning (used only when `python-lsp-server' is 'pylsp):
;; ruff does all linting, jedi's workspace symbol search is what hangs.
(setq lsp-pylsp-plugins-ruff-enabled t
      lsp-pylsp-plugins-jedi-symbols-enabled nil
      lsp-pylsp-plugins-pycodestyle-enabled nil
      lsp-pylsp-plugins-pyflakes-enabled nil
      lsp-pylsp-plugins-mccabe-enabled nil
      lsp-pylsp-plugins-pydocstyle-enabled nil
      lsp-pylsp-plugins-flake8-enabled nil
      lsp-pylsp-plugins-autopep8-enabled nil
      lsp-pylsp-plugins-yapf-enabled nil
      lsp-pylsp-plugins-pylint-enabled nil
      lsp-pylsp-plugins-rope-autoimport-enabled nil)

;;;; Python: conda / virtualenv switching
;; `SPC m v w' (pyvenv-workon) lists the envs under WORKON_HOME; point it at
;; the conda envs directory when the shell did not set it.
(unless (getenv "WORKON_HOME")
  (let ((envs (seq-find #'file-directory-p
                        (mapcar #'expand-file-name
                                '("~/mambaforge/envs" "~/miniforge3/envs"
                                  "~/miniconda3/envs" "~/anaconda3/envs"
                                  "~/.conda/envs")))))
    (when envs (setenv "WORKON_HOME" envs))))

;;;; Python: REPL
(when (executable-find "ipython")
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "-i --simple-prompt"))
(setq python-shell-completion-native-enable nil)

;;;; Rust: rust-analyzer through lsp-mode
;; rust-analyzer is the rustup component (`rustup component add
;; rust-analyzer'), found in ~/.cargo/bin. Diagnostics come from `cargo
;; check' on save; set `lsp-rust-analyzer-cargo-watch-command' to "clippy"
;; in local.el for clippy instead.
(setq lsp-rust-analyzer-server-command '("rust-analyzer")
      lsp-rust-analyzer-use-client-watching nil ; rust-analyzer watches, not Emacs
      lsp-rust-analyzer-cargo-watch-command "check"
      lsp-rust-analyzer-proc-macro-enable t
      lsp-rust-analyzer-cargo-run-build-scripts t
      rustic-format-on-save nil)                ; SPC m = = formats when you ask

;;;; Undo history
;; With `dotspacemacs-undo-system' 'undo-tree (macOS dotfile), do not write a
;; history file per buffer to .cache/undo-tree-history: saving/loading those
;; for big buffers is slow and the files corrupt easily (1200+ had piled up).
(setq undo-tree-auto-save-history nil)

;;;; semantic (only used by `, p' for the sticky function header)
;; Databases go to the Spacemacs cache, not ~/.emacs.d/semanticdb (that was
;; the "Create directory ... for SemanticDB?" question at exit), and semantic
;; parses only the buffers where `, p' was pressed (see funcs.el).
(setq semanticdb-default-save-directory
      (concat spacemacs-cache-directory "semanticdb/"))
(with-eval-after-load 'semantic
  (add-hook 'semantic-inhibit-functions #'sdev//semantic-inhibit))

;;;; Emacs 30 native compilation
;; Packages are compiled in the background after they are installed; their
;; warnings used to pop up a *Warnings* window on every first start.
(setq native-comp-async-report-warnings-errors 'silent)

;;;; Highlight colours for SPC h h h
(setq hi-lock-face-defaults
      '("hi-blue" "hi-aquamarine" "hi-pink" "hi-green-b" "hi-red-b" "hi-salmon"))
