# syntax=docker/dockerfile:1
#
# spacemacs-u24: Spacemacs as one self-contained folder, on Ubuntu 24.04.
#
# Everything the editor needs is under /opt/spacemacs and is made at build time:
#
#   /opt/spacemacs/bin/emacs     launcher (the only thing to put on PATH)
#   /opt/spacemacs/emacs         Emacs 30 (terminal build, native compilation),
#                                with the shared libraries it needs in lib/
#   /opt/spacemacs/tools         basedpyright, ruff, rg, fd, jq, aspell;
#                                fallback/ holds uv and a python3 used only when
#                                the surrounding image has none
#   /opt/spacemacs/emacs.d       Spacemacs (develop), every package installed
#                                and native-compiled (bake.sh)
#   /opt/spacemacs/spacemacs.d   the config from this repo
#
# Nothing is downloaded when a container starts and nothing lives in $HOME.
#
# Use it in another Ubuntu 24.04 image (same Ubuntu as verlai/verl:uv.cu130.dev5)
# with two lines; that image only needs git:
#   COPY --from=spacemacs-u24:latest /opt/spacemacs /opt/spacemacs
#   ENV PATH=/opt/spacemacs/bin:$PATH
#
# The build context is the spacemacs/ directory (the config), not this folder:
#   docker build -t spacemacs-u24 -f docker/spacemacs-u24/Dockerfile .
ARG UBUNTU=24.04

# ---------------------------------------------------------------- build Emacs
FROM ubuntu:${UBUNTU} AS emacs-build
ARG EMACS_VERSION=30.2
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl xz-utils build-essential pkg-config texinfo patchelf \
      libgccjit-13-dev libgnutls28-dev libncurses-dev libtree-sitter-dev \
      libsqlite3-dev zlib1g-dev
RUN curl -fsSL https://ftpmirror.gnu.org/emacs/emacs-${EMACS_VERSION}.tar.xz | tar -xJ -C /tmp
WORKDIR /tmp/emacs-${EMACS_VERSION}
# Terminal only (no X, no image libraries, no libxml2: it drags in 35 MB of ICU
# and is only used by the built-in web browser). Native compilation is on; Lisp is
# compiled to native code at build time by bake.sh, into
# ~/.emacs.d/eln-cache.
RUN ./configure --prefix=/opt/spacemacs/emacs \
      --with-native-compilation --with-tree-sitter --with-gnutls --without-xml2 \
      --with-sqlite3 --with-modules --with-zlib \
      --without-x --without-sound --without-dbus --without-gsettings \
      --without-selinux --without-gpm --without-pop --without-mailutils \
      CFLAGS="-O2 -g0" \
 && make -j"$(nproc)" && make install-strip
# Make the tree self-contained: copy every non-glibc shared library Emacs links
# against next to it and point the binary there, so /opt/spacemacs/emacs runs in
# any Ubuntu 24.04 container without installing packages.
RUN set -eux; cd /opt/spacemacs/emacs; mkdir -p lib; \
    bin=$(readlink -f bin/emacs); \
    ldd "$bin" | awk '$3 ~ /^\// {print $3}' \
      | grep -Ev '/(libc|libm|libdl|libpthread|librt|libresolv|ld-linux[^/]*)\.so' \
      | xargs -I{} cp -L {} lib/; \
    for l in lib/libgccjit.so.0; do ldd "$l" | awk '$3 ~ /^\// {print $3}' \
      | grep -Ev '/(libc|libm|libdl|libpthread|librt|libresolv|ld-linux[^/]*)\.so' \
      | xargs -I{} cp -Ln {} lib/; done; \
    patchelf --set-rpath '$ORIGIN/../lib' "$bin"; \
    for l in lib/*.so*; do patchelf --set-rpath '$ORIGIN' "$l"; done; \
    g=/usr/lib/gcc/x86_64-linux-gnu/13; a=/usr/lib/x86_64-linux-gnu; [ -d "$g" ] || { g=/usr/lib/gcc/aarch64-linux-gnu/13; a=/usr/lib/aarch64-linux-gnu; }; \
    mkdir -p lib/gcc; cp -L "$g"/crtbeginS.o "$g"/crtendS.o "$g"/libgcc.a "$g"/libgcc_s.so "$a"/crti.o "$a"/crtn.o "$a"/libc_nonshared.a lib/gcc/; \
    sed "s#$a/libc_nonshared.a#/opt/spacemacs/emacs/lib/gcc/libc_nonshared.a#" "$a"/libc.so > lib/gcc/libc.so; cat lib/gcc/libc.so; \
    printf '%s\n' ';; The native compiler links each .eln with these GCC start files and libgcc,' \
      ';; bundled here so that only binutils (as, ld) is needed at run time.' \
      '(setq native-comp-driver-options (list "-B/opt/spacemacs/emacs/lib/gcc/"))' \
      > share/emacs/site-lisp/site-start.el; \
    rm -rf share/man share/info share/icons share/applications share/metainfo include; \
    find share/emacs -name '*.el.gz' -path '*/leim/*' -delete || true; \
    ./bin/emacs --batch --eval '(princ (format "%s native=%s json=%s treesit=%s\n" emacs-version (native-comp-available-p) (fboundp (quote json-parse-string)) (treesit-available-p)))'

# ---------------------------------------------------------------- bundle tools
# rg, fd, jq and aspell copied out of Ubuntu's packages into the folder, with
# their libraries, so the folder does not depend on apt packages elsewhere.
FROM ubuntu:${UBUNTU} AS tools-build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      ripgrep fd-find jq aspell aspell-en patchelf
COPY docker/spacemacs-u24/build/bundle-tools.sh /tmp/bundle-tools.sh
RUN bash /tmp/bundle-tools.sh /opt/spacemacs/tools

# ---------------------------------------------------------------- final image
FROM ubuntu:${UBUNTU}
ARG DEBIAN_FRONTEND=noninteractive
# For this stand-alone image only (none of it is needed inside /opt/spacemacs):
# git for Magit and the Spacemacs download, curl/gnupg for package downloads at
# build time, binutils for the native compiler, tmux/less/ssh for comfort.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates git curl gnupg openssh-client less tmux binutils \
 && rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/*

COPY --from=emacs-build /opt/spacemacs/emacs /opt/spacemacs/emacs
COPY --from=tools-build /opt/spacemacs/tools /opt/spacemacs/tools
COPY --chmod=755 docker/spacemacs-u24/build/emacs-launcher.sh /opt/spacemacs/bin/emacs
RUN ln -s ../emacs/bin/emacsclient /opt/spacemacs/bin/emacsclient

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color COLORTERM=truecolor \
    PATH=/opt/spacemacs/bin:$PATH
RUN printf 'export PATH=/opt/spacemacs/bin:$PATH\n' > /etc/profile.d/10-spacemacs.sh

# Language servers, pinned, installed by uv together with the standalone Python
# they run on. basedpyright brings its own node. uv itself and a python3 link go
# to tools/fallback, which the launcher puts last on PATH.
ARG UV_VERSION=0.13.8
ARG BASEDPYRIGHT_VERSION=1.40.2
ARG RUFF_VERSION=0.17.5
RUN set -eux; t=/opt/spacemacs/tools; mkdir -p $t/fallback; \
    export UV_UNMANAGED_INSTALL=$t/fallback; \
    curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh; \
    export PATH=$t/fallback:$t/bin:$PATH UV_TOOL_DIR=$t/uv UV_TOOL_BIN_DIR=$t/bin \
           UV_PYTHON_INSTALL_DIR=$t/python UV_NO_CACHE=1; \
    uv tool install basedpyright==${BASEDPYRIGHT_VERSION}; uv tool install ruff==${RUFF_VERSION}; \
    # the standalone Python only has to run basedpyright's small launcher: drop
    # its test suite, Tk, IDLE, headers and static libraries
    py=$(readlink -f $t/python/cpython-*-gnu | head -1); test -d "$py/lib"; \
    rm -rf "$py"/lib/python3*/test "$py"/lib/python3*/idlelib "$py"/lib/python3*/tkinter \
           "$py"/lib/python3*/turtledemo "$py"/lib/python3*/ensurepip "$py"/lib/python3*/config-* \
           "$py"/lib/tcl* "$py"/lib/tk* "$py"/lib/itcl* "$py"/lib/thread* "$py"/lib/*.a \
           "$py"/include "$py"/share; \
    find $t -name __pycache__ -prune -exec rm -rf {} +; \
    ln -s "$py/bin/python3" $t/fallback/python3; ln -s python3 $t/fallback/python; \
    basedpyright --version; ruff --version; $t/fallback/python3 --version; du -sh $t/*

# Spacemacs itself, pinned to the commit the config was developed against.
ARG SPACEMACS_REF=88393ec346620f8794348798ab28f8bdf562b767
RUN set -eux; git init -q /opt/spacemacs/emacs.d; cd /opt/spacemacs/emacs.d; \
    git remote add origin https://github.com/syl20bnr/spacemacs; \
    git fetch -q --depth 1 origin "$SPACEMACS_REF"; git checkout -q -B develop FETCH_HEAD; \
    git gc -q --prune=now

# The config, then everything it asks for: bake.sh installs all packages, checks
# a second start installs nothing, native-compiles the packages and checks the
# result. Logs stay in /opt/spacemacs/bake-log. The same script was developed by
# hand in a container.
COPY . /opt/spacemacs/spacemacs.d
RUN BAKE_LOG=/opt/spacemacs/bake-log bash /opt/spacemacs/spacemacs.d/docker/spacemacs-u24/build/bake.sh \
 && ln -s /opt/spacemacs/spacemacs.d /root/.spacemacs.d \
 && rm -rf /tmp/* /root/.cache

WORKDIR /work
CMD ["bash", "-l"]
