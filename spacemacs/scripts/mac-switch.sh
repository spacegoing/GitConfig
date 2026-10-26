#!/usr/bin/env bash
# Switch this Mac to the new setup prepared by the 2026-10 overhaul:
#
#   1. ~/.emacs.d        -> ~/.emacs.d.bak-<date>        (old Spacemacs 2024-07 + its elpa)
#      ~/.emacs.d-next   -> ~/.emacs.d                   (Spacemacs develop, packages installed)
#   2. ~/.spacemacs.d/init.el -> init.macos.el           (the macOS dotfile)
#   3. prints how to put the new Emacs.app (emacs-plus@30, native-comp) in /Applications
#
# Nothing is deleted. Undo:  scripts/mac-switch.sh --undo <backup dir>
set -euo pipefail

dotdir=$(cd "$(dirname "$0")/.." && pwd)
emacsd=$HOME/.emacs.d
next=$HOME/.emacs.d-next
app=$(ls -d /opt/homebrew/Cellar/emacs-plus@30/*/Emacs.app | tail -1)

if [[ ${1:-} == --undo ]]; then
  bak=${2:?usage: mac-switch.sh --undo ~/.emacs.d.bak-YYYYMMDD}
  [[ -d $bak ]] || { echo "no such backup: $bak"; exit 1; }
  pgrep -x Emacs >/dev/null && { echo "quit Emacs first"; exit 1; }
  mv "$emacsd" "$next"
  mv "$bak" "$emacsd"
  echo "restored $emacsd from $bak; the new one is back at $next"
  echo "the dotfile symlink was left as is (ln -sfn <file> $dotdir/init.el to change it)"
  exit 0
fi

pgrep -x Emacs >/dev/null && { echo "quit Emacs first"; exit 1; }
[[ -d $next/core ]] || { echo "$next is not a Spacemacs checkout; run scripts/mac-prepare.sh first"; exit 1; }
[[ -f $dotdir/init.macos.el ]] || { echo "$dotdir/init.macos.el missing: is the spacemacs-overhaul branch checked out?"; exit 1; }

bak=$emacsd.bak-$(date +%Y%m%d)
[[ -e $bak ]] && bak=$bak-$(date +%H%M%S)
echo "==> $emacsd -> $bak"
mv "$emacsd" "$bak"
echo "==> $next -> $emacsd"
mv "$next" "$emacsd"
echo "==> $dotdir/init.el -> init.macos.el"
ln -sfn init.macos.el "$dotdir/init.el"
rm -f "$dotdir/.spacemacs.env"   # regenerated from the login shell on first start

cat <<EOF

Done. Start the new Emacs with:
    open $app
and, to have it in Launchpad/Spotlight (keeps your old /Applications/Emacs.app):
    ln -s $app /Applications/Emacs-30.app
Language servers: $dotdir/scripts/install-lsp-servers.sh (already run on this Mac).
Undo:  $0 --undo $bak
EOF
