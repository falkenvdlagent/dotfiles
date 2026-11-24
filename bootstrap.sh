#!/usr/bin/env bash
# Takes a fresh Linux box (non-NixOS) from nothing to a built Home Manager config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
fi
if ! command -v nix >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: check the configured username"
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is configured for \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  echo "    Edit the single \"user = \" line in flake.nix, then re-run."
  exit 1
fi

echo "==> Step 4: first home-manager switch"
# home-manager isn't installed yet, so run it from the flake this once.
# -b backup renames pre-existing files (e.g. ~/.zshrc) to *.backup instead of failing.
nix run home-manager/release-26.05 -- switch --flake "$DIR#$REAL_USER" -b backup

echo "==> Done. Use ./rebuild.sh for future changes."
echo "    To make zsh your login shell: chsh -s /usr/bin/zsh"
