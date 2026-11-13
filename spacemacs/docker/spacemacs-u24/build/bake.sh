#!/usr/bin/env bash
# bake.sh - make Spacemacs ready to use with no network at start-up.
# Run by the Dockerfile (and by hand in a scratch container while developing).
# Needs the final layout: /opt/spacemacs/{bin/emacs,emacs.d,spacemacs.d}. Native
# code is tied to the path it was compiled at, so bake where it will be used.
#   1. install every package the config asks for
#   2. run again and fail if anything is still being installed
#   3. native-compile all packages now, so Emacs does not do it at first use
#   4. run a real session so Emacs' own built-in Lisp is compiled too
#   5. check the result: native code in use, every tool works, spell-check works
set -euo pipefail
S=/opt/spacemacs
here=$(cd "$(dirname "$0")" && pwd)
ln -sfn init.linux.el "$S/spacemacs.d/init.el"
boot=("$S/bin/emacs" --batch -l "$S/emacs.d/early-init.el" -l "$S/emacs.d/init.el"
      --eval "(run-hooks 'emacs-startup-hook)")
log=${BAKE_LOG:-/tmp/bake}; mkdir -p "$log"; cd /
trap 'echo "bake failed; last log lines:"; tail -n 15 "$log"/*.log' ERR

echo "== 1. install packages"; t=$SECONDS
"${boot[@]}" </dev/null >"$log/install.log" 2>&1
echo "   $(grep -c 'installing package' "$log/install.log") installed in $((SECONDS-t)) s"

echo "== 2. second start must install nothing"; t=$SECONDS
"${boot[@]}" </dev/null >"$log/second.log" 2>&1
if grep -q 'installing package' "$log/second.log"; then
  grep 'installing package' "$log/second.log" | head; echo "packages still missing"; exit 1
fi
echo "   ok in $((SECONDS-t)) s, $(ls "$S"/emacs.d/elpa/*/develop | grep -vc archives) package dirs"

echo "== 3. native-compile"; t=$SECONDS
"${boot[@]}" -l "$here/native-compile-all.el" </dev/null >"$log/native.log" 2>&1
n=$(find "$S/emacs.d/eln-cache" -name '*.eln' | wc -l)
echo "   $n .eln files in $((SECONDS-t)) s"
[ "$n" -gt 1000 ] || { echo "too few native files"; exit 1; }

echo "== 4. warm start"; t=$SECONDS
# Emacs compiles its own built-in Lisp the first time a session loads it. Run a
# real terminal session now, open the usual kinds of file, and wait until the
# background compiler is idle; then a second session must find nothing to do.
ec() { "$S/emacs/bin/emacsclient" -s bake --eval "$1" 2>/dev/null; }
warm() {
  TERM=xterm-256color "$S/tools/fallback/python3" -c 'import pty,sys; pty.spawn(sys.argv[1:])' \
    sh -c "stty rows 50 cols 200; exec $S/bin/emacs -nw --eval '(progn (setq server-name \"bake\") (server-start))'" \
    </dev/null >/dev/null 2>&1 &
  for _ in $(seq 1 600); do ec t >/dev/null && break; sleep 0.2; done
  ec "$1" >/dev/null || true
  for _ in $(seq 1 300); do
    [ "$(ec '(and (null comp-files-queue) (zerop (comp--async-runnings)))')" = t ] && break; sleep 2
  done
  queued=$(ec '(length comp-files-queue)' || echo unknown)
  flyspell_error=$(ec '(with-current-buffer "*Messages*" (save-excursion (goto-char (point-min)) (if (search-forward "Error enabling Flyspell" nil t) 1 0)))' || echo unknown)
  ec '(kill-emacs)' >/dev/null || true; wait || true
}
w=$(mktemp -d); printf 'import os\nx = 1\n' >"$w/w.py"; printf '{"a":1}\n' >"$w/w.json"
printf '# t\n' >"$w/w.md"; printf '(message "t")\n' >"$w/w.el"; printf 'helo wrld\n' >"$w/w.txt"
warm "(progn (dolist (f '(\"w.py\" \"w.json\" \"w.md\" \"w.el\" \"w.txt\")) (find-file (expand-file-name f \"$w\"))) (dolist (p '(magit lsp-mode lsp-ui company helm flycheck)) (require p)) (dired \"$w\") t)"
warm t
echo "   second session: $queued files left to compile, flyspell error: $flyspell_error, $((SECONDS-t)) s"
[ "$queued" = 0 ] && [ "$flyspell_error" = 0 ] || { echo "warm start check failed"; exit 1; }
rm -rf "$w"
echo "   $(find "$S/emacs.d/eln-cache" -name '*.eln' | wc -l) .eln files now"

echo "== 5. self-check"
"${boot[@]}" --eval "(progn (require 'magit) (unless (subr-native-elisp-p (symbol-function 'magit-status)) (error \"magit is not native-compiled\")) (dolist (p '(\"ruff\" \"basedpyright-langserver\" \"rg\" \"fd\" \"jq\" \"aspell\" \"python3\")) (unless (executable-find p) (error \"missing tool %s\" p))) (with-temp-buffer (text-mode) (insert \"helo wrld\") (flyspell-mode 1) (flyspell-buffer) (unless (seq-some (lambda (o) (overlay-get o 'flyspell-overlay)) (overlays-in (point-min) (point-max))) (error \"spell-check found nothing in a misspelt line\"))) (princ \"   self-check ok\n\"))" </dev/null 2>"$log/check.log" | grep "self-check ok"
for tool in rg fd jq; do "$S/tools/bin/$tool" --version >/dev/null; done
echo helo | "$S/tools/bin/aspell" -a 2>&1 | grep -q '^& helo' 
! echo helo | "$S/tools/bin/aspell" -a 2>&1 | grep -qi 'warning\|error'
# The native-compile workers are plain child Emacs processes and may leave an
# empty ~/.emacs.d/snippets behind. Remove empty leftovers; real files are an error.
[ ! -d "$HOME/.emacs.d" ] || find "$HOME/.emacs.d" -depth -type d -empty -delete
[ ! -e "$HOME/.emacs.d" ] || { echo "something wrote to ~/.emacs.d:"; find "$HOME/.emacs.d" | head; exit 1; }
du -sh "$S" "$S"/*
