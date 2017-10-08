;;; packages.el --- sdired layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: spacegoing <spacegoing@LCs-MacBook-Pro.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defconst sdired-packages '((dired :location local) dired+))

(defun sdired/post-init-dired ()
  (use-package dired
    :defer t
    :config (progn
              (require 'dired+)
              (define-key dired-mode-map (kbd "P") 'my-dired-up-directory) ;; for symlink
              )))

(defun sdired/init-dired+ ()
  (use-package dired+
    :defer t
    :config (diredp-toggle-find-file-reuse-dir 1)))


;;; packages.el ends here
