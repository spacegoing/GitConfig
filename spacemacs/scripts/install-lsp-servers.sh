#!/usr/bin/env bash
# Install the language servers that ~/.spacemacs.d/init.el expects.
#
#   basedpyright  -> basedpyright-langserver  Python IDE features
#   ruff          -> ruff server              Python lint / format / imports
#   rust-analyzer -> via rustup               Rust
#
# Nothing is installed into a conda env: Python tools go into a private
# venv under ~/.local/share/lsp-servers and are symlinked into ~/.local/bin,
# which init.el puts at the front of exec-path. Re-run to upgrade.
#
# Works on macOS and Linux (incl. the dev container); needs python3 >= 3.8
# and network access (pip honours HTTPS_PROXY).
set -euo pipefail

PREFIX="${LSP_PREFIX:-$HOME/.local/share/lsp-servers}"
BIN="${LSP_BIN:-$HOME/.local/bin}"
PY="${PYTHON:-$(command -v python3 || command -v python)}"

mkdir -p "$BIN"
echo "==> Python servers: venv $PREFIX (using $PY)"
if [ ! -x "$PREFIX/bin/python" ]; then
    "$PY" -m venv "$PREFIX"
fi
"$PREFIX/bin/python" -m pip install --quiet --disable-pip-version-check \
    --upgrade pip basedpyright ruff
for exe in basedpyright basedpyright-langserver ruff; do
    ln -sfn "$PREFIX/bin/$exe" "$BIN/$exe"
done
echo "    $("$BIN/ruff" --version)"
echo "    basedpyright $("$PREFIX/bin/python" -m pip show basedpyright | awk '/^Version/ {print $2}')"

echo "==> rust-analyzer"
if command -v rustup >/dev/null 2>&1; then
    if ! rustup component list --installed 2>/dev/null | grep -q '^rust-analyzer'; then
        rustup component add rust-analyzer
    fi
    echo "    $("$HOME/.cargo/bin/rust-analyzer" --version)"
else
    echo "    rustup not found; install it from https://rustup.rs and re-run this script."
fi

echo "==> Done. Restart Emacs, or run 'SPC m b r' in an open Python/Rust buffer."
