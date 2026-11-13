#!/usr/bin/env bash
# Runs INSIDE the spacemacs-u24 container: drive a real terminal Emacs (in a pty) through
# a developer session on /work repos and log what happened.   verify.sh <label>
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
label=${1:-v1}; LOG=/work/_verify/logs/$label; rm -rf "$LOG"; mkdir -p "$LOG"
now_ms() { echo $(( $(date +%s%N) / 1000000 )); }
log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOG/steps.log"; }
ec() { timeout 180 emacsclient -s test --eval "$1" 2>&1; }
wait_for() { local t0=$(now_ms) dl=$(( $(now_ms) + $1*1000 )) r
  while :; do r=$(ec "$2"); [[ "$r" != "nil" && -n "$r" && "$r" != *"rror"* ]] && { echo "$(( $(now_ms) - t0 ))ms -> $r"; return 0; }
    (( $(now_ms) > dl )) && { echo "TIMEOUT after $1s -> $r"; return 1; }; sleep 0.5; done; }
pkill -x emacs 2>/dev/null; sleep 1
t0=$(now_ms)
export TERM=xterm-256color
# a real terminal for Emacs without extra packages: a pty made by the bundled python
/opt/spacemacs/tools/fallback/python3 -c 'import pty,sys; pty.spawn(sys.argv[1:])' sh -c "stty rows 50 cols 200; exec emacs -nw --eval '(progn (setq server-name \"test\") (server-start))' 2> $LOG/emacs-stderr.log" </dev/null >$LOG/screen-raw.txt 2>&1 &
until emacsclient -s test --eval t >/dev/null 2>&1; do sleep 0.5; (( $(now_ms) - t0 > 900000 )) && { log "emacs did not start"; exit 1; }; done
log "emacs up after $(( $(now_ms) - t0 ))ms"
log "initialized: $(wait_for 120 "(and (boundp 'spacemacs-initialized) spacemacs-initialized)")"
ec "(progn (require 'lsp-mode) (load \"$here/helpers.el\"))" >/dev/null
# library stubs reached by go-to-definition: answer lsp's "Select action" question in advance (same as pressing d)
ec "(dolist (d '(\"/opt/spacemacs/tools\" \"/usr/lib\" \"/usr/local/lib\" \"/workspace/verl/.venv\")) (push d (lsp-session-folders-blocklist (lsp-session))))" >/dev/null
log "env: $(ec '(format "emacs=%s native=%s spacemacs=%s packages=%d undo=%s" emacs-version (native-comp-available-p) spacemacs-version (length package-alist) dotspacemacs-undo-system)')"
log "lsp: $(ec '(format "watchers=%s idle=%s lens=%s pyright=%s" lsp-enable-file-watchers lsp-idle-delay lsp-lens-enable lsp-pyright-langserver-command)')"
log "tools: $(ec '(mapconcat (lambda (p) (format "%s" (executable-find p))) (list "basedpyright-langserver" "ruff" "rg" "fd" "jq" "aspell" "git" "python3" "uv") " ")')"
log "home: emacsd=$(ec 'user-emacs-directory') dotdir=$(ec 'dotspacemacs-directory') native-magit=$(ec "(progn (require 'magit) (subr-native-elisp-p (symbol-function 'magit-status)))") in-home=$(ls -d ~/.emacs.d 2>/dev/null || echo none)"
( while emacsclient -s test --eval t >/dev/null 2>&1; do a=$(now_ms); emacsclient -s test --eval t >/dev/null 2>&1 || break; echo "$(date +%H:%M:%S) $(( $(now_ms) - a ))" >> "$LOG/latency.log"; sleep 0.3; done ) & MON=$!
for target in "verl:verl/trainer/ppo/ray_trainer.py" "vllm:vllm/v1/engine/async_llm.py" "Megatron-LM:megatron/core/transformer/transformer_layer.py" "transformers:src/transformers/trainer.py"; do
  repo=${target%%:*}; rel=${target#*:}; file=/work/$repo/$rel; buf=$(basename "$file")
  [[ -s $file ]] || { log "STEP $repo: missing $file"; continue; }
  log "STEP $repo: $rel ($(git -C /work/$repo ls-files | wc -l) files)"
  ec "(lsp-workspace-folders-add \"/work/$repo\")" >/dev/null
  log "  open:        $(wait_for 30 "(progn (find-file \"$file\") (symbol-name major-mode))")"
  log "  servers:     $(wait_for 120 "(let ((w (drv/ws \"$buf\"))) (and (>= (length w) 2) (cl-every (lambda (s) (string-match-p \"initialized\" s)) w) w))")"
  log "  diagnostics: $(wait_for 90 "(drv/diags \"$buf\")")"
  log "  point:       $(ec "(drv/goto \"$buf\" \"^from [a-z_.]+ import \\\\([A-Za-z_]+\\\\)\" 1)")"
  ec "(drv/hover-async \"$buf\")" >/dev/null; log "  hover:       $(wait_for 60 "(drv/result 'hover)")"
  log "  , g g:       $(wait_for 30 "(progn (with-current-buffer \"$buf\" (call-interactively (key-binding (kbd \", g g\")))) (let ((f (buffer-file-name (window-buffer)))) (and f (not (string= (file-name-nondirectory f) \"$buf\")) f)))")"
  ec "(switch-to-buffer \"$buf\")" >/dev/null
  ec "(with-current-buffer \"$buf\" (goto-char (point-max)) (insert \"\\nimport os\\nos.path.jo\") (drv/completion-async \"$buf\"))" >/dev/null
  log "  completion:  $(wait_for 60 "(drv/result 'completion)")"
  ec "(with-current-buffer \"$buf\" (goto-char (point-max)) (insert \"in('a')\\nimport collections_zz_unused\\nxx=1;yy  =  2\\n\"))" >/dev/null
  log "  lint:        $(wait_for 60 "(let ((m (seq-filter (lambda (m) (string-match-p \"zz_unused\" m)) (drv/diag-messages \"$buf\")))) (and m (car m)))")"
  log "  , = =:       $(wait_for 30 "(with-current-buffer \"$buf\" (call-interactively (key-binding (kbd \", = =\"))) (save-excursion (goto-char (point-max)) (and (search-backward \"xx = 1\" nil t) \"formatted by ruff\")))")"
  log "  , p x2:      $(ec "(with-current-buffer \"$buf\" (call-interactively (key-binding (kbd \", p\"))) (prog1 (format \"sticky=%s\" (bound-and-true-p semantic-stickyfunc-mode)) (call-interactively (key-binding (kbd \", p\")))))") breadcrumb=$(ec "(with-current-buffer \"$buf\" (bound-and-true-p lsp-headerline-breadcrumb-mode))")"
  ec "(run-at-time 0.2 nil (lambda () (with-current-buffer \"$buf\" (call-interactively (key-binding (kbd \"SPC g s\"))))))" >/dev/null
  log "  magit:       $(wait_for 60 "(let ((b (seq-find (lambda (b) (string-prefix-p \"magit: \" (buffer-name b))) (buffer-list)))) (and b (buffer-name b)))")"
  log "  $(ec '(drv/mem)') servers: $(ps -eo rss,comm | grep -E 'node|ruff' | awk '{printf "%s=%dMB ", $2, $1/1024}')"
  ec "(progn (dolist (b (buffer-list)) (when (string-prefix-p \"magit\" (buffer-name b)) (kill-buffer b))) (drv/kill-all-files))" >/dev/null; sleep 2
done
log "STEP json"
printf '{"b":[1,2,{"z":null,"a":true}],"model":"verl","a":"x"}' > /tmp/t.json
log "  open:   $(wait_for 30 "(progn (find-file \"/tmp/t.json\") (format \"%s lsp=%s\" major-mode (bound-and-true-p lsp-mode)))")"
log "  keys:   $(ec '(with-current-buffer "t.json" (format ", = ==%s , = s=%s , = m=%s , T h=%s" (key-binding (kbd ", = =")) (key-binding (kbd ", = s")) (key-binding (kbd ", = m")) (key-binding (kbd ", T h"))))')"
log "  , = =:  $(ec '(with-current-buffer "t.json" (call-interactively (key-binding (kbd ", = ="))) (format "%d lines" (count-lines (point-min) (point-max))))')"
log "  , = s:  $(ec '(with-current-buffer "t.json" (call-interactively (key-binding (kbd ", = s"))) (buffer-substring 1 12))')"
log "  , = m:  $(ec '(with-current-buffer "t.json" (call-interactively (key-binding (kbd ", = m"))) (buffer-string))')"
log "  flycheck: $(ec '(with-current-buffer "t.json" (format "%s" (and (bound-and-true-p flycheck-mode) (flycheck-get-checker-for-buffer))))')"
ec '(with-current-buffer "t.json" (set-buffer-modified-p nil) (kill-buffer))' >/dev/null
kill $MON 2>/dev/null
log "spell:    flyspell-error=$(ec '(with-current-buffer "*Messages*" (save-excursion (goto-char (point-min)) (if (search-forward "Error enabling Flyspell" nil t) t nil)))') compile-queue=$(ec '(length comp-files-queue)') aspell=$(echo helo | /opt/spacemacs/tools/bin/aspell -a 2>&1 | grep -c "^& helo" || true)"
log "warnings: $(ec '(drv/warnings)' | head -c 600)"
ec '(drv/messages 60)' > "$LOG/messages-tail.txt"
ec '(kill-emacs)' >/dev/null 2>&1; sleep 1
awk '{ n++; if ($2>max){max=$2; at=$1}; if ($2>1000) f1++; if ($2>300) f3++; sum+=$2 } END { printf "samples=%d mean=%.0fms max=%dms (at %s) >300ms=%d >1000ms=%d\n", n, sum/n, max, at, f3, f1 }' "$LOG/latency.log" | tee "$LOG/latency-summary.txt" >> "$LOG/steps.log"
log DONE
