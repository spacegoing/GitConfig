# docker run -itd --name dev -v $(pwd):/root/host doom-emacs-arm bash
FROM --platform=linux/arm64 ubuntu:22.04

# Set non-interactive frontend and locale
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt-get clean

RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    software-properties-common \
    gpg-agent \
    git \
    fd-find \
    pandoc \
    shellcheck \
    && apt-get clean

RUN add-apt-repository -y ppa:ubuntuhandbook1/emacs && \
    apt-get update && \
    apt-get install -y emacs

# Install Doomemacs
WORKDIR /root
RUN mkdir -p snippets
RUN git clone --depth 1 https://github.com/doomemacs/doomemacs .config/emacs
RUN cat <<EOF >> /root/.config/emacs/config.el
(setq package-archives '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("org" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/org/")))
EOF
# '

ENV PATH="/root/.config/emacs/bin:${PATH}"
RUN yes | doom install
RUN doom sync

# Doom Deps
RUN FONT_NAMES="NFM.ttf" && \
    BASE_URL="https://raw.githubusercontent.com/rainstormstudio/nerd-icons.el/main/fonts" && \
    FONT_DEST="/usr/local/share/fonts" && \
    mkdir -p "$FONT_DEST" && \
    for font in $FONT_NAMES; do \
    echo "Downloading $font..." && \
    wget -q --show-progress -O "$FONT_DEST/$font" "$BASE_URL/$font" ; \
    done && \
    echo "Updating font cache..." && \
    fc-cache -fv

ARG RG_VERSION=14.1.1
RUN set -eux; \
    # Manually determine architecture using uname for better portability
    ARCH=$(uname -m); \
    case "$ARCH" in \
    "x86_64") RG_ARCH="x86_64" ;; \
    "aarch64") RG_ARCH="aarch64" ;; \
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac; \
    \
    wget -q "https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-${RG_ARCH}-unknown-linux-gnu.tar.gz" \
    -O /tmp/ripgrep.tar.gz; \
    tar -xzf /tmp/ripgrep.tar.gz -C /usr/local/bin --strip-components=1 "ripgrep-14.1.1-${RG_ARCH}-unknown-linux-gnu/rg"; \
    rm /tmp/ripgrep.tar.gz;
