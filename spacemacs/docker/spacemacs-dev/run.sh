#!/usr/bin/env bash
# Start (or attach to) the spacemacs-dev container.
#
# Mounts:
#   this repo's spacemacs/ dir  -> /root/.spacemacs.d   (read-write, same files as the host)
#   a persistent volume         -> /root/.emacs.d       (Spacemacs develop clone + elpa)
#   $REPOS (optional)           -> /work                (test repos, e.g. vllm, verl)
#
# Env:
#   PROXY   http proxy for the container, default http://host.docker.internal:7897
#   REPOS   host directory to mount at /work
#   SPACEMACS_SRC  host directory with a Spacemacs checkout, mounted read-only at /mnt/spacemacs
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
dotdir=$(cd "$here/../.." && pwd)
name=${NAME:-spacemacs-dev}
proxy=${PROXY:-http://host.docker.internal:7897}

if ! docker image inspect spacemacs-dev >/dev/null 2>&1; then
  docker build --build-arg https_proxy="$proxy" --build-arg http_proxy="$proxy" -t spacemacs-dev "$here"
fi

if ! docker container inspect "$name" >/dev/null 2>&1; then
  args=(-d --name "$name" --hostname "$name"
        -e https_proxy="$proxy" -e http_proxy="$proxy" -e no_proxy=localhost,127.0.0.1
        -v spacemacs-dev-home:/root/.emacs.d
        -v "$dotdir":/root/.spacemacs.d)
  [[ -n ${REPOS:-} ]] && args+=(-v "$REPOS":/work)
  [[ -n ${SPACEMACS_SRC:-} ]] && args+=(-v "$SPACEMACS_SRC":/mnt/spacemacs:ro)
  docker run "${args[@]}" spacemacs-dev sleep infinity
fi
docker start "$name" >/dev/null
[[ $# -gt 0 ]] && exec docker exec -it "$name" "$@"
exec docker exec -it "$name" bash -l
