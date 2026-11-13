#!/usr/bin/env bash
# bundle-tools.sh - copy rg, fd, jq and aspell (with its English dictionary) out
# of Ubuntu's packages into one relocatable folder, so the editor does not
# depend on apt packages being installed in the image it is copied into.
#   bundle-tools.sh /opt/spacemacs/tools
# Needs: apt packages ripgrep fd-find jq aspell aspell-en patchelf.
set -euo pipefail
dst=$1; mkdir -p "$dst"/{bin,lib,libexec,share/aspell}
libs_of() { ldd "$1" | awk '$3 ~ /^\// {print $3}' \
  | grep -Ev '/(libc|libm|libdl|libpthread|librt|libresolv|libgcc_s|libstdc\+\+|ld-linux[^/]*)\.so' || true; }
put() { # put <binary> <dest dir> <name>: copy it, copy its libraries, point it at them
  cp -L "$1" "$2/$3"
  for l in $(libs_of "$1"); do cp -Ln "$l" "$dst/lib/"; done
  patchelf --set-rpath "$dst/lib" "$2/$3"; }
put /usr/bin/rg     "$dst/bin" rg
put /usr/bin/fdfind "$dst/bin" fd
put /usr/bin/jq     "$dst/bin" jq
put /usr/bin/aspell "$dst/libexec" aspell
for l in "$dst"/lib/*.so*; do patchelf --set-rpath "$dst/lib" "$l"; done
# aspell looks for its data in fixed /usr paths: keep data and dictionaries
# together here and tell it where they are.
cp -rL /usr/lib/aspell/. /var/lib/aspell/. "$dst/share/aspell/"
# Its filter modules (*.amf, *-filter.so) are in an arch-named sub-folder.
filters=$(cd "$dst/share/aspell" && ls -d */ | head -1)
printf '#!/bin/sh\nexec %s/libexec/aspell --data-dir=%s/share/aspell --dict-dir=%s/share/aspell --filter-path=%s/share/aspell/%s "$@"\n' \
  "$dst" "$dst" "$dst" "$dst" "${filters%/}" > "$dst/bin/aspell"
chmod +x "$dst/bin/aspell"
ls "$dst/bin" "$dst/lib"; du -sh "$dst"
