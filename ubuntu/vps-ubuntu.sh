#!/bin/bash
###############################################################################
# ERROR Exit on error, undefined variables, and pipe failures
###############################################################################

set -euo pipefail

# Exit handler - runs if script fails
trap 'if [ $? -ne 0 ]; then
  log_error "Setup failed"
  exit $?
fi' EXIT

###############################################################################
# Constants
###############################################################################

# Colors for better readability
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'

DOTFILES_DIR="$HOME/dotfiles"
ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"
ZPLUG_DIR="$HOME/.zplug"
SYMLINKS_PATH="$DOTFILES_DIR/bin/apply_symlinks.sh"

###############################################################################
# Utility functions
###############################################################################
# Log levels
log_info() { printf "${GREEN}%s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}%s${NC}\n" "$*" >&2; }

###############################################################################
# Main
###############################################################################

# For Neovim
log_info "Installing Neovim"
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable

log_info "Updating packages"
sudo apt update
sudo apt upgrade

# Build tools
log_info "Installing build tools"
sudo apt install -y \
  automake autoconf libreadline-dev \
  libncurses-dev libssl-dev libyaml-dev \
  libxslt-dev libffi-dev libtool unixodbc-dev \
  build-essential openssl \
  zlib1g-dev

# Utils
log_info "Installing utils"
sudo apt install -y \
  htop btop ncdu jq fd-find fzf stow \
  tig tmux \
  wget unzip curl neovim \
  zsh git fail2ban ripgrep bat

log_info "Installing Prezto"
if [ -d "$ZPREZTO_DIR" ]; then
  log_info "Removing existing Prezto installation..."
  rm -rf "$ZPREZTO_DIR"
  rm -rf "$ZPLUG_DIR"
fi

git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"
git clone --recursive https://github.com/belak/prezto-contrib "$ZPREZTO_DIR/contrib"

log_info "Installing Zplug"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

log_info "Applying symlinks"
. "$SYMLINKS_PATH"

log_info "Setting default shell"
chsh -s $(which zsh)

log_info "Setup complete"
log_info "Restart Terminal"
