#!/bin/sh
# /opt/spacemacs/bin/emacs - Spacemacs launcher.
# Everything lives under /opt/spacemacs; nothing is read from or written to $HOME.
#  - the editor's tools (ruff, basedpyright, rg, fd, jq, aspell) go on PATH for
#    Emacs only, so they never change what the surrounding image runs;
#  - python3 and uv from here go last: the image's own (or a project venv) win;
#  - repos mounted from a host belong to another user: allow git (Magit) to open
#    them, for Emacs only;
#  - without a UTF-8 locale Emacs skips its start-up step that points the native
#    code cache at this folder, and recompiles into ~/.emacs.d: default one.
S=/opt/spacemacs
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in *[Uu][Tt][Ff]*) ;; *) export LC_ALL=C.UTF-8 ;; esac
export SPACEMACSDIR=$S/spacemacs.d/
export PATH=$S/tools/bin:$PATH:$S/tools/fallback
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0='*'
exec $S/emacs/bin/emacs --init-directory=$S/emacs.d "$@"
