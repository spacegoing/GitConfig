# syntax=docker/dockerfile:1
#
# spacemacs-u24: a small, portable Spacemacs image on Ubuntu 24.04.
#
# Same Ubuntu as verlai/verl:uv.cu130.dev5 (nvidia/cuda 13.0.2 on ubuntu24.04),
# so the same glibc: project venvs built in that image resolve here, and the
# two directories this image produces can be mounted into that image as is.
#
#   /opt/spacemacs/emacs   Emacs 30 (terminal build, native compilation), with
#                          the shared libraries it needs bundled in lib/
#   /opt/spacemacs/tools   uv, basedpyright, ruff and the Python they run on
#   /root/.emacs.d         Spacemacs (develop), packages install here on first start
#
# Not in the image: your config. Mount it at /root/.spacemacs.d (see run.sh).
#
#   docker build -t spacemacs-u24 docker/ubuntu24
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
# compiled to native code the first time it is loaded and cached in
# ~/.emacs.d/eln-cache, which keeps the image small.
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

# ---------------------------------------------------------------- final image
FROM ubuntu:${UBUNTU}
ARG DEBIAN_FRONTEND=noninteractive
# git/curl/gnupg: Spacemacs and package downloads.  ripgrep/fd: SPC / and SPC p f.
# jq: JSON syntax check (flycheck).  aspell: spell-checking layer.
# binutils: the assembler and linker libgccjit calls to turn Lisp into native
# code at run time. Everything else it needs is bundled in /opt/spacemacs/emacs.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates git curl gnupg openssh-client less tmux \
      ripgrep fd-find jq aspell aspell-en \
      binutils \
 && ln -s /usr/bin/fdfind /usr/local/bin/fd \
 && rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/*

COPY --from=emacs-build /opt/spacemacs/emacs /opt/spacemacs/emacs

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color COLORTERM=truecolor \
    PATH=/opt/spacemacs/emacs/bin:/opt/spacemacs/tools/bin:/root/.local/bin:/root/.cargo/bin:$PATH
RUN printf 'export PATH=/opt/spacemacs/emacs/bin:/opt/spacemacs/tools/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH\n' \
      > /etc/profile.d/10-spacemacs.sh

# uv installs the language servers into /opt/spacemacs/tools, together with the
# standalone Python they run on. basedpyright brings its own node.
RUN set -eux; export UV_UNMANAGED_INSTALL=/opt/spacemacs/tools/bin; \
    curl -LsSf https://astral.sh/uv/install.sh | sh; \
    export UV_TOOL_DIR=/opt/spacemacs/tools/uv UV_TOOL_BIN_DIR=/opt/spacemacs/tools/bin \
           UV_PYTHON_INSTALL_DIR=/opt/spacemacs/tools/python UV_NO_CACHE=1; \
    uv tool install basedpyright; uv tool install ruff; \
    # the standalone Python only has to run basedpyright's small launcher: drop
    # its test suite, Tk, IDLE, headers and static libraries (about 70 MB)
    py=$(echo /opt/spacemacs/tools/python/cpython-*); \
    rm -rf "$py"/lib/python3*/test "$py"/lib/python3*/idlelib "$py"/lib/python3*/tkinter \
           "$py"/lib/python3*/turtledemo "$py"/lib/python3*/ensurepip "$py"/lib/python3*/config-* \
           "$py"/lib/tcl* "$py"/lib/tk* "$py"/lib/itcl* "$py"/lib/thread* "$py"/lib/*.a \
           "$py"/include "$py"/share; \
    find /opt/spacemacs/tools -name __pycache__ -prune -exec rm -rf {} +; \
    basedpyright --version; ruff --version; du -sh /opt/spacemacs/tools/*

# Spacemacs itself, pinned to the commit the config was developed against.
ARG SPACEMACS_REF=88393ec346620f8794348798ab28f8bdf562b767
RUN set -eux; git init -q /root/.emacs.d; cd /root/.emacs.d; \
    git remote add origin https://github.com/syl20bnr/spacemacs; \
    git fetch -q --depth 1 origin "$SPACEMACS_REF"; git checkout -q -B develop FETCH_HEAD; \
    git gc -q --prune=now

# Prove native compilation works with only the runtime pieces above.
RUN emacs --batch --eval '(progn (require (quote comp)) (let ((f "/tmp/t.el")) (with-temp-file f (insert ";;; -*- lexical-binding: t -*-\n(defun t-add (a b) (+ a b))\n")) (princ (format "native-compiled: %s\n" (native-compile f)))))' \
 && rm -rf /tmp/* /root/.emacs.d/eln-cache

WORKDIR /work
CMD ["bash", "-l"]
