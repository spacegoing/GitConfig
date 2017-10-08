;; Same as `dired-up-directory', except for wrapping with `file-truename'.
(defun my-dired-up-directory (&optional other-window)
  ;; Run Dired on parent directory of current directory.
  ;; Follows symlinks for current directory. Find the parent
  ;; directory either in this buffer or another buffer. Creates a
  ;; buffer if necessary. If OTHER-WINDOW (the optional prefix
  ;; arg), display the parent directory in another window."
  (interactive "P")
  (let* ((dir  (file-truename (dired-current-directory)))
         (up   (file-name-directory (directory-file-name dir))))
    (or (dired-goto-file (directory-file-name dir))
        ;; Only try dired-goto-subdir if buffer has more than one dir.
        (and (cdr dired-subdir-alist)  (dired-goto-subdir up))
        (progn (if other-window (dired-other-window up) (dired up))
               (dired-goto-file dir)))))

