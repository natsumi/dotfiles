#!/bin/bash

# New Mac setup
# Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/bin/bootstrap.sh)"

set -euo pipefail

# Cleanup temp files on exit
trap 'rm -f /tmp/dotfiles.tar.gz' EXIT

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly REPO_URL="https://github.com/natsumi/dotfiles"
readonly REPO_BRANCH="${REPO_BRANCH:-main}"
readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/dotfiles}"

# Functions
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

verify_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error_exit "This script is designed for macOS only. Current OS: $OSTYPE"
    fi
    success "Verified running on macOS"
}

clone_repository() {
    info "Setting up dotfiles repository..."

    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        success "Dotfiles repo already cloned at $DOTFILES_DIR"
        return 0
    fi

    if [[ -d "$DOTFILES_DIR" ]] && [[ -n "$(ls -A "$DOTFILES_DIR" 2>/dev/null)" ]]; then
        warning "Directory $DOTFILES_DIR already exists and is not empty (but is not a git repo)"
        info "Skipping clone to avoid overwriting existing files"
        return 0
    fi

    mkdir -p "$(dirname "$DOTFILES_DIR")" || error_exit "Failed to create parent directory"

    info "Cloning dotfiles repository..."
    git clone -b "$REPO_BRANCH" "$REPO_URL" "$DOTFILES_DIR" || error_exit "Failed to clone repository"
    success "Cloned dotfiles repository to $DOTFILES_DIR"
}

install_homebrew() {
    if command -v brew &> /dev/null; then
        success "Homebrew is already installed"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "Failed to install Homebrew"

    # Add Homebrew to PATH (only if not already present)
    if ! grep -qF '/opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"

    success "Homebrew installed successfully"
}

install_mise() {
    if command -v mise &> /dev/null; then
        success "mise is already installed"
        return 0
    fi

    info "Installing mise..."
    brew install mise || error_exit "Failed to install mise"

    # Initialize mise for current session
    eval "$(mise activate bash)"

    success "mise installed successfully"
}

install_ruby() {
    if mise ls --installed ruby 2>/dev/null | grep -q ruby; then
        success "Ruby is already installed via mise"
        return 0
    fi

    info "Installing latest Ruby via mise..."

    info "Installing build libraries..."
    brew install jemalloc libffi libtool libxslt libyaml openssl readline unixodbc xz zlib

    info "Installing Ruby..."
    mise install ruby@latest || error_exit "Failed to install Ruby"
    mise use -g ruby@latest || error_exit "Failed to set global Ruby version"

    success "Ruby installed and set as global version"
}

main() {
    info "Starting macOS bootstrap process..."

    verify_macos
    clone_repository
    install_homebrew
    install_mise
    install_ruby

    success "Bootstrap completed successfully!"

    cd "$DOTFILES_DIR" || error_exit "Failed to cd to $DOTFILES_DIR"
    ruby bin/setup_system.rb
}

# Run main function
main
