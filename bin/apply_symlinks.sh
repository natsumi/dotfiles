#!/usr/bin/env bash

# DESCRIPTION
# Applies symlinks using stow

# This line sets shell options for safer script execution:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of
#              the last command to exit with a non-zero status,
#              or zero if no command exited with a non-zero status.
set -euo pipefail

DOTFILE_DIR="${DOTFILE_DIR:-$HOME/dev/dotfiles}"
TARGET_DIR="$HOME"

apply_symlink() {
  stow -v -R --target="$TARGET_DIR" --dir="$DOTFILE_DIR" "$1"
}

# List of packages to symlink
packages=(
  mise alacritty aerospace bat elixir eslint helix jetbrains
  kitty neovim prettier ripgrep ruby silver_searcher tig
  tmux yt-dlp yabai zsh
)

# Apply symlinks for each package
for package in "${packages[@]}"; do
  apply_symlink "$package"
done
