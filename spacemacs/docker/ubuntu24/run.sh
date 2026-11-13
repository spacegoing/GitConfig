#!/usr/bin/env bash
# Build (once) and start the spacemacs-u24 container, then open a shell in it.
#
#   docker/ubuntu24/run.sh            # shell in the container; type `emacs`
#   docker/ubuntu24/run.sh emacs      # straight into Emacs
#
# The image is complete: Emacs, Spacemacs, all packages and the config are inside.
# Mounts (both optional):
#   $REPOS            -> /work                code to edit
#   this config dir   -> /root/.spacemacs.d   only with LIVE_CONFIG=1, to edit the
#                        config without rebuilding. New packages you add are then
#                        installed inside the container and lost when it is removed;
#                        rebuild the image to keep them.
#
# Env:  NAME (spacemacs-u24)  IMAGE (spacemacs-u24:latest)  REPOS  LIVE_CONFIG
#       DOCKER ("docker", or "sudo docker")
#       PROXY (unset; e.g. http://host.docker.internal:7897 on the Mac)
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
dotdir=$(cd "$here/../.." && pwd)
name=${NAME:-spacemacs-u24}; image=${IMAGE:-spacemacs-u24:latest}
read -r -a docker <<< "${DOCKER:-docker}"

if ! "${docker[@]}" image inspect "$image" >/dev/null 2>&1; then
  build=()
  [[ -n ${PROXY:-} ]] && build+=(--build-arg https_proxy="$PROXY" --build-arg http_proxy="$PROXY")
  "${docker[@]}" build "${build[@]}" -t "$image" -f "$here/Dockerfile" "$dotdir"
fi
if ! "${docker[@]}" container inspect "$name" >/dev/null 2>&1; then
  args=(-d --name "$name" --hostname "$name")
  if [[ -n ${LIVE_CONFIG:-} ]]; then
    # init.el is a per-machine symlink (git-ignored); this is a Linux machine.
    [[ -e $dotdir/init.el ]] || ln -sfn init.linux.el "$dotdir/init.el"
    args+=(-v "$dotdir":/root/.spacemacs.d)
  fi
  [[ -n ${REPOS:-} ]] && args+=(-v "$REPOS":/work)
  [[ -n ${PROXY:-} ]] && args+=(-e https_proxy="$PROXY" -e http_proxy="$PROXY" -e no_proxy=localhost,127.0.0.1)
  "${docker[@]}" run "${args[@]}" "$image" sleep infinity >/dev/null
fi
"${docker[@]}" start "$name" >/dev/null
if [[ $# -gt 0 ]]; then exec "${docker[@]}" exec -it -e TERM=xterm-256color "$name" bash -lc "$*"; fi
exec "${docker[@]}" exec -it -e TERM=xterm-256color "$name" bash -l
