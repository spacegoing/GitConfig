# Spacemacs development container (Debian 13, Emacs 30 from Debian, arm64/amd64).
#
# Used to develop and verify ~/.spacemacs.d against the latest Spacemacs
# develop branch without touching the Emacs on the host.  Emacs runs in a
# terminal (emacs -nw) inside tmux; there is no X server here.
#
#   docker build -t spacemacs-dev docker/
#   docker/run.sh            # creates/attaches the container, see run.sh
FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      emacs-nox \
      git curl ca-certificates openssh-client gnupg \
      tmux less procps file \
      ripgrep fd-find \
      gcc libc6-dev make pkg-config \
      aspell aspell-en \
      locales \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 TERM=xterm-256color \
    PATH=/root/.local/bin:/root/.cargo/bin:$PATH
# Debian's /etc/profile resets PATH for login shells; keep the tool dirs there too.
RUN printf 'export PATH=/root/.local/bin:/root/.cargo/bin:$PATH\n' > /etc/profile.d/10-tool-dirs.sh

# uv: the only Python installer used here (basedpyright, ruff, project venvs).
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/root/.local/bin sh

# rustup with a stable toolchain and rust-analyzer, for the Rust test project.
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal \
      --component rust-analyzer --component rustfmt --component clippy

WORKDIR /root
CMD ["bash", "-l"]
