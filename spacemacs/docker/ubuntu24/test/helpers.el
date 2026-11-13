;;; helpers.el --- introspection helpers for the test driver  -*- lexical-binding: t -*-
;; Requests are asynchronous so the driver never blocks Emacs itself.

(defvar drv/results nil "Alist of (key . value) filled by async requests.")

(defun drv/buf (name) (or (get-buffer name) (error "no buffer %s" name)))

(defun drv/ws (name)
  (with-current-buffer (drv/buf name)
    (if (bound-and-true-p lsp-mode)
        (mapcar (lambda (w)
                  (format "%s:%s" (lsp--client-server-id (lsp--workspace-client w))
                          (lsp--workspace-status w)))
                (lsp-workspaces))
      '("lsp-mode-off"))))

(defun drv/diags (name)
  (with-current-buffer (drv/buf name)
    (let (acc)
      (dolist (d (lsp--get-buffer-diagnostics))
        (let* ((src (or (lsp:diagnostic-source? d) "?")) (cell (assoc src acc)))
          (if cell (setcdr cell (1+ (cdr cell))) (push (cons src 1) acc))))
      acc)))

(defun drv/diag-messages (name)
  (with-current-buffer (drv/buf name)
    (mapcar (lambda (d) (format "%s: %s" (lsp:diagnostic-source? d)
                                (truncate-string-to-width (lsp:diagnostic-message d) 70)))
            (lsp--get-buffer-diagnostics))))

(defun drv/goto (name regexp &optional group)
  (with-current-buffer (drv/buf name)
    (goto-char (point-min))
    (if (re-search-forward regexp nil t)
        (progn (goto-char (match-beginning (or group 0)))
               (let ((w (get-buffer-window (current-buffer))))
                 (when w (set-window-point w (point))))
               (format "%s:%d %S" name (line-number-at-pos)
                       (buffer-substring-no-properties (point) (min (point-max) (+ (point) 16)))))
      (error "regexp not found: %s" regexp))))

(defun drv/result (key) (alist-get key drv/results))
(defun drv/clear (key) (setf (alist-get key drv/results) nil) t)

(defun drv/hover-async (name)
  (drv/clear 'hover)
  (with-current-buffer (drv/buf name)
    (lsp-request-async
     "textDocument/hover" (lsp--text-document-position-params)
     (lambda (r)
       (setf (alist-get 'hover drv/results)
             (if r
                 (let ((c (lsp:hover-contents r)))
                   (truncate-string-to-width
                    (replace-regexp-in-string
                     "\n" " " (if (lsp-markup-content? c) (lsp:markup-content-value c) (format "%s" c)))
                    90))
               "empty")))
     :error-handler (lambda (e) (setf (alist-get 'hover drv/results) (format "ERR %s" e)))
     :mode 'detached))
  t)

(defun drv/completion-async (name)
  (drv/clear 'completion)
  (with-current-buffer (drv/buf name)
    (lsp-request-async
     "textDocument/completion" (lsp--text-document-position-params)
     (lambda (r)
       (setf (alist-get 'completion drv/results)
             (let ((items (if (lsp-completion-list? r) (lsp:completion-list-items r) r)))
               (format "%d items, first: %s" (length items)
                       (mapconcat (lambda (i) (lsp:completion-item-label i))
                                  (seq-take (append items nil) 4) ", ")))))
     :error-handler (lambda (e) (setf (alist-get 'completion drv/results) (format "ERR %s" e)))
     :mode 'detached))
  t)

(defun drv/messages (n)
  (with-current-buffer "*Messages*"
    (mapconcat #'identity (last (split-string (buffer-string) "\n" t) n) "\n")))

(defun drv/warnings ()
  (if (get-buffer "*Warnings*") (with-current-buffer "*Warnings*" (buffer-string)) ""))

(defun drv/mem ()
  (format "emacs-rss=%dMB" (/ (alist-get 'rss (process-attributes (emacs-pid))) 1024)))

(defun drv/kill-all-files ()
  (dolist (b (buffer-list))
    (when (buffer-file-name b)
      (with-current-buffer b (set-buffer-modified-p nil))
      (kill-buffer b)))
  "killed")
