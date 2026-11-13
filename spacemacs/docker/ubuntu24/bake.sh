#!/usr/bin/env bash
# bake.sh - make Spacemacs ready to use with no network at start-up.
# Run by the Dockerfile (and by hand in a scratch container while developing).
# Needs: Emacs on PATH, Spacemacs in ~/.emacs.d, the config in ~/.spacemacs.d.
#   1. install every package the config asks for
#   2. run again and fail if anything is still being installed
#   3. native-compile all packages now, so Emacs does not do it at first use
set -euo pipefail
cd "$HOME"
here=$(cd "$(dirname "$0")" && pwd)
ln -sfn init.linux.el "$HOME/.spacemacs.d/init.el"
boot=(emacs --batch -l "$HOME/.emacs.d/early-init.el" -l "$HOME/.emacs.d/init.el"
      --eval "(run-hooks 'emacs-startup-hook)")
log=${BAKE_LOG:-/tmp/bake}; mkdir -p "$log"

echo "== 1. install packages"; t=$SECONDS
"${boot[@]}" </dev/null >"$log/install.log" 2>&1
echo "   $(grep -c 'installing package' "$log/install.log") installed in $((SECONDS-t)) s"

echo "== 2. second start must install nothing"; t=$SECONDS
"${boot[@]}" </dev/null >"$log/second.log" 2>&1
if grep -q 'installing package' "$log/second.log"; then
  grep 'installing package' "$log/second.log" | head; echo "packages still missing"; exit 1
fi
echo "   ok in $((SECONDS-t)) s, $(ls "$HOME"/.emacs.d/elpa/*/develop | grep -vc archives) package dirs"

echo "== 3. native-compile"; t=$SECONDS
"${boot[@]}" -l "$here/native-compile-all.el" </dev/null >"$log/native.log" 2>&1
tail -1 "$log/native.log"
echo "   $(find "$HOME/.emacs.d/eln-cache" -name '*.eln' | wc -l) .eln files in $((SECONDS-t)) s"
du -sh "$HOME/.emacs.d" "$HOME/.emacs.d/elpa" "$HOME/.emacs.d/eln-cache"
