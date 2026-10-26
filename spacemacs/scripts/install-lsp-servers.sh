#!/usr/bin/env bash
# Install the language servers used by ~/.spacemacs.d (layers/sdev):
#
#   basedpyright   Python IDE features (pyright fork, node bundled)   via uv
#   ruff           Python lint + format, has its own language server  via uv
#   rust-analyzer  Rust                                               via rustup
#
# All Python tooling goes through uv: `uv tool install` gives each tool its
# own isolated venv under ~/.local/share/uv/tools and links the executables
# into ~/.local/bin, which layers/sdev/config.el puts first on PATH inside
# Emacs. Nothing is written into your conda/project environments.
#
# Re-run any time to upgrade (uv tool upgrade --all).
#
# Env:
#   UV_INSTALL_DIR  where to put uv itself if it is missing   (default ~/.local/bin)
#   NO_RUST=1       skip rust-analyzer
set -euo pipefail

bin=${UV_INSTALL_DIR:-$HOME/.local/bin}
export PATH="$bin:$HOME/.cargo/bin:$PATH"

say() { printf '\033[1m==> %s\033[0m\n' "$*"; }

# ---- uv ---------------------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  say "installing uv into $bin"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$bin" UV_NO_MODIFY_PATH=1 sh
fi
say "uv $(uv --version | awk '{print $2}')"

# ---- basedpyright + ruff ----------------------------------------------------
for tool in basedpyright ruff; do
  if uv tool list 2>/dev/null | grep -q "^$tool "; then
    say "upgrading $tool"
    uv tool upgrade "$tool"
  else
    say "installing $tool"
    uv tool install "$tool"
  fi
done
say "basedpyright $(basedpyright --version | head -1 | awk '{print $2}')  ($(command -v basedpyright-langserver))"
say "ruff $(ruff --version | awk '{print $2}')  ($(command -v ruff))"

# ---- rust-analyzer ----------------------------------------------------------
if [[ -z ${NO_RUST:-} ]]; then
  if ! command -v rustup >/dev/null 2>&1; then
    say "installing rustup (stable, minimal profile)"
    curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
  fi
  if ! rustup component list --installed 2>/dev/null | grep -q '^rust-analyzer'; then
    say "adding rust-analyzer component"
    rustup component add rust-analyzer rustfmt clippy
  fi
  say "rust-analyzer $(rust-analyzer --version | awk '{print $2}')  ($(command -v rust-analyzer))"
fi

# ---- PATH check -------------------------------------------------------------
case ":$PATH:" in
  *":$bin:"*) ;;
  *) say "NOTE: add $bin to PATH in your shell rc (Emacs already finds it)";;
esac
say "done"
