#!/usr/bin/env bash
# Build (once) and start the spacemacs-u24 container, then open a shell in it.
#
#   docker/ubuntu24/run.sh            # shell in the container; type `emacs`
#   docker/ubuntu24/run.sh emacs      # straight into Emacs
#
# Mounts:
#   this repo's spacemacs/ dir -> /root/.spacemacs.d   your config (read-write)
#   volume  $NAME-emacsd       -> /root/.emacs.d       Spacemacs + installed packages + native code cache
#   $REPOS (optional)          -> /work                code to edit
#
# Env:  NAME (spacemacs-u24)  IMAGE (spacemacs-u24:latest)  REPOS  DOCKER ("docker", or "sudo docker")
#       PROXY (unset; e.g. http://host.docker.internal:7897 on the Mac)
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
dotdir=$(cd "$here/../.." && pwd)
name=${NAME:-spacemacs-u24}; image=${IMAGE:-spacemacs-u24:latest}
read -r -a docker <<< "${DOCKER:-docker}"

# init.el is a per-machine symlink (git-ignored); this is a Linux machine.
[[ -e $dotdir/init.el ]] || ln -sfn init.linux.el "$dotdir/init.el"

if ! "${docker[@]}" image inspect "$image" >/dev/null 2>&1; then
  build=()
  [[ -n ${PROXY:-} ]] && build+=(--build-arg https_proxy="$PROXY" --build-arg http_proxy="$PROXY")
  "${docker[@]}" build "${build[@]}" -t "$image" "$here"
fi
if ! "${docker[@]}" container inspect "$name" >/dev/null 2>&1; then
  args=(-d --name "$name" --hostname "$name"
        -v "$name-emacsd":/root/.emacs.d
        -v "$dotdir":/root/.spacemacs.d)
  [[ -n ${REPOS:-} ]] && args+=(-v "$REPOS":/work)
  [[ -n ${PROXY:-} ]] && args+=(-e https_proxy="$PROXY" -e http_proxy="$PROXY" -e no_proxy=localhost,127.0.0.1)
  "${docker[@]}" run "${args[@]}" "$image" sleep infinity >/dev/null
fi
"${docker[@]}" start "$name" >/dev/null
if [[ $# -gt 0 ]]; then exec "${docker[@]}" exec -it -e TERM=xterm-256color "$name" bash -lc "$*"; fi
exec "${docker[@]}" exec -it -e TERM=xterm-256color "$name" bash -l
