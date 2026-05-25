#!/usr/bin/env bash
set -euo pipefail

# Dotfiles deploy script
# Usage: ./install.sh [package...]
#   ./install.sh          # deploy all packages
#   ./install.sh common    # deploy only common

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME"
PACKAGES="${*:-$DOTFILES_DIR}"

echo "=== Dotfiles Deploy ==="
echo "Dotfiles: $DOTFILES_DIR"
echo "Target:   $TARGET_DIR"
echo "Packages: $PACKAGES"
echo ""

for pkg in $PACKAGES; do
  pkg_path="$DOTFILES_DIR/$pkg"
  if [[ ! -d "$pkg_path" ]]; then
    echo "WARNING: $pkg/ not found, skipping"
    continue
  fi
  echo ">>> stowing $pkg ..."
  stow -t "$TARGET_DIR" -d "$DOTFILES_DIR" "$pkg"
done

echo ""
echo "=== Done ==="
echo "Symlinks created. Restart your shell or source ~/.bashrc to apply."
