;; Open file's parent directory
(defun my-file-up-directory ()
  (interactive)
  (if default-directory
      (dired (expand-file-name default-directory))
    (error "No `default-directory' to open")))

