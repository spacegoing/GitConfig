#!/usr/bin/env bash
# bake.sh - make Spacemacs ready to use with no network at start-up.
# Run by the Dockerfile (and by hand in a scratch container while developing).
# Needs the final layout: /opt/spacemacs/{bin/emacs,emacs.d,spacemacs.d}. Native
# code is tied to the path it was compiled at, so bake where it will be used.
#   1. install every package the config asks for
#   2. run again and fail if anything is still being installed
#   3. native-compile all packages now, so Emacs does not do it at first use
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

echo "== 4. self-check"
"${boot[@]}" --eval "(progn (require 'magit) (unless (subr-native-elisp-p (symbol-function 'magit-status)) (error \"magit is not native-compiled\")) (dolist (p '(\"ruff\" \"basedpyright-langserver\" \"rg\" \"fd\" \"jq\" \"aspell\" \"python3\")) (unless (executable-find p) (error \"missing tool %s\" p))) (princ \"   self-check ok\n\"))" </dev/null 2>"$log/check.log" | tail -1
# The native-compile workers are plain child Emacs processes and may leave an
# empty ~/.emacs.d/snippets behind. Remove empty leftovers; real files are an error.
[ ! -d "$HOME/.emacs.d" ] || find "$HOME/.emacs.d" -depth -type d -empty -delete
[ ! -e "$HOME/.emacs.d" ] || { echo "something wrote to ~/.emacs.d:"; find "$HOME/.emacs.d" | head; exit 1; }
du -sh "$S" "$S"/*
