#!/bin/bash

# New Mac setup
# Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/bin/bootstrap.sh)"

set -euo pipefail

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

setup_dotfiles_dir() {
    info "Setting up dotfiles directory: $DOTFILES_DIR"

    if [[ -d "$DOTFILES_DIR" ]]; then
        warning "Directory $DOTFILES_DIR already exists"
        return 0
    fi

    mkdir -p "$(dirname "$DOTFILES_DIR")" || error_exit "Failed to create parent directory"
    success "Created dotfiles directory structure"
}

download_repository() {
    info "Downloading dotfiles repository..."

    if [[ -d "$DOTFILES_DIR" ]] && [[ -n "$(ls -A "$DOTFILES_DIR" 2>/dev/null)" ]]; then
        warning "Directory $DOTFILES_DIR already exists and is not empty"
        info "Skipping download to avoid overwriting existing files"
        return 0
    fi

    info "Downloading repository as archive..."
    local temp_file="/tmp/dotfiles.tar.gz"
    curl -fsSL "$REPO_URL/archive/refs/heads/$REPO_BRANCH.tar.gz" -o "$temp_file" || error_exit "Failed to download repository"

    mkdir -p "$DOTFILES_DIR" || error_exit "Failed to create dotfiles directory"
    tar -xzf "$temp_file" -C "$DOTFILES_DIR" --strip-components=1 || error_exit "Failed to extract repository"
    rm -f "$temp_file"
    success "Downloaded and extracted dotfiles repository"
}

install_homebrew() {
    if command -v brew &> /dev/null; then
        success "Homebrew is already installed"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "Failed to install Homebrew"

    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
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
    info "Installing latest Ruby via mise..."

    info "Installing buil libraries...."
    brew install jemalloc libffi libtool libxslt libyaml openssl readline unixodbc xz zlib

    info "Installing Ruby...."
    mise install ruby@latest || error_exit "Failed to install Ruby"
    mise use -g ruby@latest || error_exit "Failed to set global Ruby version"

    # Add mise to PATH for current session
    eval "$(mise activate bash)"

    success "Ruby installed and set as global version"
}

main() {
    info "Starting macOS bootstrap process..."

    verify_macos
    setup_dotfiles_dir
    download_repository
    install_homebrew
    install_mise
    install_ruby

    success "Bootstrap completed successfully!"
    info "Next steps:"
    info "ruby $DOTFILES_DIR/bin/dotfiles_menu.rb"
}

# Run main function
main "$@"
