;; AutoFill Mode
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Dired hide details
(add-hook 'dired-mode-hook 'dired-hide-details-mode)

;; AutoFill Mode
(setq-default fill-column 65)

;; Magit Configuration
(setq magit-visit-ref-behavior '(checkout-any focus-on-ref))
(add-to-list 'magit-visit-ref-behavior 'create-branch)

;; Pandoc Config
;; markdown mode variables
(setq markdown-local-header "/Users/spacegoing/macCodeLab-MBP2015/MarkdownConfig/Pandoc_Header/programming_notes_header")

;; paradox config
(setq paradox-github-token "9a43680a53cf280d4342761b4d75e311380bbb5f")

;; -------------- emacs ------------------
(set-frame-font "nil 22")
(setq initial-frame-alist (quote ((fullscreen . maximized))))


