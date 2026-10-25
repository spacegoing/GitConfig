;;; funcs.el --- sdired layer functions  -*- lexical-binding: t -*-

;;; Code:

(defun my-dired-up-directory (&optional other-window)
  "Run dired on the parent of the current directory, following symlinks.
Same as `dired-up-directory' except the current directory is passed through
`file-truename' first. With prefix argument OTHER-WINDOW, display the parent
directory in another window."
  (interactive "P")
  (let* ((dir (file-truename (dired-current-directory)))
         (up (file-name-directory (directory-file-name dir))))
    (or (dired-goto-file (directory-file-name dir))
        ;; Only try dired-goto-subdir if buffer has more than one dir.
        (and (cdr dired-subdir-alist) (dired-goto-subdir up))
        (progn (if other-window (dired-other-window up) (dired up))
               (dired-goto-file dir)))))

;;; funcs.el ends here
