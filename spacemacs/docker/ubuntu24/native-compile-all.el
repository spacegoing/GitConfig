;;; native-compile-all.el --- compile every installed package ahead of time  -*- lexical-binding: t -*-
;; Loaded by bake.sh after Spacemacs has started in batch mode. Without this,
;; Emacs compiles each package in the background the first time it is used.
(require 'comp)
(setq native-comp-async-jobs-number (max 1 (num-processors))
      native-comp-async-report-warnings-errors 'silent)
(native-compile-async (list package-user-dir) 'recursively)
(let ((running (if (fboundp 'comp--async-runnings) #'comp--async-runnings #'comp-async-runnings))
      (start (float-time)))
  (while (or comp-files-queue (> (funcall running) 0))
    (accept-process-output nil 2))
  (message "native-compile-all: done in %d s" (- (float-time) start)))
