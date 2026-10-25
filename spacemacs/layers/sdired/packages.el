;;; packages.el --- sdired layer packages file for Spacemacs.  -*- lexical-binding: t -*-
;;
;; Author: spacegoing
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; Dired extras: dired+ (vendored in local/dired+/dired+.el, it is no longer
;; on MELPA) and a `P' binding that goes to the parent directory following
;; symlinks.

;;; Code:

(defconst sdired-packages
  '((dired :location built-in)
    (dired+ :location local)))

(defun sdired/post-init-dired ()
  (with-eval-after-load 'dired
    (require 'dired+)
    ;; `P': parent directory, resolving symlinks first (see funcs.el).
    (define-key dired-mode-map (kbd "P") 'my-dired-up-directory)))

(defun sdired/init-dired+ ()
  (use-package dired+
    :defer t
    :config
    ;; Reuse the same dired buffer when descending into directories.
    (diredp-toggle-find-file-reuse-dir 1)))

;;; packages.el ends here
