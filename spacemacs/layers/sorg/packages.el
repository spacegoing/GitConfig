;;; packages.el --- sorg layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: spacegoing <spacegoing@LCs-MacBook-Pro.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defconst sorg-packages '((org-mode local)))

(defun sdefaults/post-init-helm ()
  (use-package org-mode
    :defer t
    :init (progn
            (setq org-startup-indented t)
            (setq org-agenda-files '("/Users/spacegoing/macCodeLab-MBP2015/MyPrivate/orgagenda")))))

(defun sdefaults/post-init-company ()
  (spacemacs|add-company-hook org-mode)
  (push 'company-yasnippet company-backends-org-mode))

;;; packages.el ends here
