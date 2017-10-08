;;; packages.el --- sdefaults layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: spacegoing <spacegoing@LCs-MacBook-Pro.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `sdefaults-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `sdefaults/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `sdefaults/pre-init-PACKAGE' and/or
;;   `sdefaults/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst sdefaults-packages '((recentf :location local) bookmark+
                               sphinx-doc
                               matlab-mode
                               powerline))

(defun sdefaults/post-init-recentf ()
  (use-package recentf
    :defer t
    :config
    (progn
      (setq recentf-exclude '("COMMIT_MSG" "COMMIT_EDITMSG" "github.*txt$"
                              "*tramp/" "/docker:" "/tmp/" "/sshx:" "/ssh:"
                              "/sudo:" "/TAGS$" "/GTAGS$" "/GRAGS$" "/GPATH$"
                              "\\.mkv$" "\\.mp[34]$" "\\.avi$" "\\.pdf$"
                              "\\.sub$" "\\.srt$" "\\.ass$" ".*png$"))
      (setq recentf-max-saved-items 2048)

      ;; Recentf record buffers
      ;; todo: create banners in helm mini-buffer
      (defun recentf-track-opened-file ()
        "Insert the name of the dired or file just opened or written into the recent list."
        (let ((buff-name (or buffer-file-name
                             (and (derived-mode-p 'dired-mode)
                                  default-directory))))
          (and buff-name
               (recentf-add-file buff-name)))
        ;; Must return nil because it is run from `write-file-functions'.
        nil)
      (add-hook 'dired-after-readin-hook 'recentf-track-opened-file))))

(defun sdefaults/init-matlab-mode ()
  :defer t
  :init (setq auto-mode-alist (append '(("\\.m\\'" . matlab-mode))
                                      auto-mode-alist)))

(defun sdefaults/pre-init-powerline ()
  (progn))

;;; packages.el ends here
