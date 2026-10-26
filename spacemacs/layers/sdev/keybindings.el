;;; keybindings.el --- sdev layer global keys  -*- lexical-binding: t -*-
;;
;; Loaded after all packages are configured.

;; SPC h h h  highlight the symbol at point (colours: `hi-lock-face-defaults')
;; SPC h h u  remove a highlight
(spacemacs/declare-prefix "hh" "highlight")
(spacemacs/set-leader-keys
  "hhh" 'highlight-symbol-at-point
  "hhu" 'unhighlight-regexp)

;; SPC j m  symbol tree from the language server (lsp-ui-imenu)
;; SPC j M  symbol list: semantic when it is on, otherwise imenu (fed by lsp)
(spacemacs/set-leader-keys
  "jm" 'lsp-ui-imenu
  "jM" 'helm-semantic-or-imenu)
