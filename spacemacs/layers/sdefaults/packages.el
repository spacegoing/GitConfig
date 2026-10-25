;;; packages.el --- sdefaults layer packages file for Spacemacs.  -*- lexical-binding: t -*-
;;
;; Author: spacegoing
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; Small tweaks to packages that other Spacemacs layers own. Every function
;; here is a `post-init'/`pre-init' hook: it runs after/before the owning
;; layer configured the package. Nothing in this layer installs a package.

;;; Code:

(defconst sdefaults-packages
  '(recentf
    spaceline
    helm
    evil))

(defun sdefaults/post-init-recentf ()
  (with-eval-after-load 'recentf
    (setq recentf-exclude '("COMMIT_MSG" "COMMIT_EDITMSG" "github.*txt$"
                            "*tramp/" "/docker:" "/tmp/" "/sshx:" "/ssh:"
                            "/sudo:" "/TAGS$" "/GTAGS$" "/GRAGS$" "/GPATH$"
                            "\\.mkv$" "\\.mp[34]$" "\\.avi$" "\\.pdf$"
                            "\\.sub$" "\\.srt$" "\\.ass$" ".*png$"))
    (setq recentf-max-saved-items 2048)
    ;; Also record visited dired directories in the recent list so they show
    ;; up in `SPC f r' / helm-mini.
    (defun sdefaults//recentf-track-dired ()
      "Add the directory of the current dired buffer to `recentf-list'."
      (when (and (derived-mode-p 'dired-mode) default-directory)
        (recentf-add-file default-directory)))
    (add-hook 'dired-after-readin-hook #'sdefaults//recentf-track-dired)))

(defun sdefaults/pre-init-helm ()
  ;; macOS: use Spotlight's `mdfind' instead of `locate' for helm-locate
  ;; (SPC f L). Fuzzy matching must be off for mdfind to work.
  ;; https://github.com/emacs-helm/helm/issues/799
  (when (eq system-type 'darwin)
    (spacemacs|use-package-add-hook helm
      :post-config
      (setq helm-locate-fuzzy-match nil)
      (setq helm-locate-command "mdfind -name %s %s"))))

(defun sdefaults/post-init-evil ()
  ;; `^' opens the current file's directory in dired (follows symlinks).
  (define-key evil-motion-state-map (kbd "^") 'my-file-up-directory)

  ;; Emacs-style movement in insert state.
  (define-key evil-insert-state-map (kbd "C-p") 'previous-line)
  (define-key evil-insert-state-map (kbd "C-n") 'next-line)
  (define-key evil-insert-state-map (kbd "C-a") 'beginning-of-line-text)
  (define-key evil-insert-state-map (kbd "C-e") 'end-of-line))

(defun sdefaults/post-init-spaceline ()
  ;; Leaner mode line: no minor-mode lighters, no major-mode name.
  (spaceline-toggle-minor-modes-off)
  (spaceline-toggle-major-mode-off))

;;; packages.el ends here
