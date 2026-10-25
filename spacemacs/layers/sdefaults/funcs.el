;;; funcs.el --- sdefaults layer functions  -*- lexical-binding: t -*-

;;; Code:

(defun my-file-up-directory ()
  "Open the directory of the current buffer in dired (follows symlinks)."
  (interactive)
  (if default-directory
      (dired (expand-file-name default-directory))
    (error "No `default-directory' to open")))

;;; funcs.el ends here
