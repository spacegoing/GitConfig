;;; config.el --- sdefaults layer configuration  -*- lexical-binding: t -*-
;;
;; Plain variable settings and hooks that do not belong to one package.
;; Loaded before any package is configured, so only touch variables and hooks
;; here; package-specific code goes to packages.el.

;;; Code:

;; Auto-fill in text modes, 65 columns everywhere.
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(setq-default fill-column 65)

;; Dired: hide owner/size/date columns by default (toggle with `(').
(add-hook 'dired-mode-hook 'dired-hide-details-mode)

;; Magit: RET on a ref checks it out and focuses it; also offer branch creation.
(with-eval-after-load 'magit
  (setq magit-visit-ref-behavior '(checkout-any focus-on-ref create-branch)))

;; Mode line separators.
(setq powerline-default-separator 'arrow)

;; macOS: colours in the mode line look washed out with sRGB enabled.
(when (eq system-type 'darwin)
  (setq ns-use-srgb-colorspace nil))

;; Prefer splitting windows side by side.
(setq split-height-threshold 200)
(setq split-width-threshold 120)

;; No spell-checking in programming modes (flyspell-prog-mode is noisy).
(add-hook 'prog-mode-hook (lambda () (flyspell-mode -1)))

;; `jk' quickly in insert state returns to normal state.
(setq-default evil-escape-key-sequence "jk")
(setq-default evil-escape-delay 0.2)

;; Python: 4-space indentation.
(setq-default python-indent-offset 4)

;;; config.el ends here
