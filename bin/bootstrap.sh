#!/bin/bash

# New Mac / Linux setup
# Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/bin/bootstrap.sh)"
#
# Installs the few things mise cannot install for itself (git and mise), clones
# this repo, and hands the rest over to `mise bootstrap`. Run it as the user
# who will own the machine, never as root: on a fresh Linux box create the
# admin user first (see README.md). Extra arguments are passed straight
# through, e.g.:
#
#   bootstrap.sh --dry-run
#   bootstrap.sh --only dotfiles
#
# Environment:
#
#   DOTFILES_ENV   profile for this machine, comma-separated, written once to
#                  .miserc.local.toml in the clone (e.g. "server,docker" or
#                  "workstation"; README.md, "Profiles")
#   REPO_BRANCH    branch or tag to clone (default: main). Servers use a tag,
#                  and fetch this script from the same tag.
#   MISE_VERSION   mise release to install, e.g. v2026.11.5 (default: latest)

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

readonly REPO_URL="https://github.com/natsumi/dotfiles"
readonly REPO_BRANCH="${REPO_BRANCH:-main}"
readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/dotfiles}"
readonly DOTFILES_ENV="${DOTFILES_ENV:-}"
readonly MISE_BIN="$HOME/.local/bin/mise"
# Optional pin, read by the mise.run installer.
if [[ -n "${MISE_VERSION:-}" ]]; then export MISE_VERSION; fi

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

verify_not_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        error_exit "Do not run this as root. Create the admin user first (see README.md) and run it as that user."
    fi
}

ensure_git_macos() {
    if xcode-select -p &> /dev/null; then
        success "Xcode command line tools are installed"
        return 0
    fi

    info "Installing Xcode command line tools..."
    xcode-select --install || true

    warning "Finish the Xcode command line tools installer, this will continue automatically"
    until xcode-select -p &> /dev/null; do
        sleep 10
    done
    success "Xcode command line tools installed"
}

ensure_git_linux() {
    if command -v git &> /dev/null && command -v curl &> /dev/null; then
        success "git and curl are installed"
        return 0
    fi

    command -v apt-get &> /dev/null \
        || error_exit "git and curl are required. Install them with your package manager and re-run."

    info "Installing git and curl..."
    sudo apt-get update || error_exit "Failed to update apt metadata"
    sudo apt-get install -y git curl || error_exit "Failed to install git and curl"
    success "git and curl installed"
}

ensure_git() {
    case "$OSTYPE" in
        darwin*) ensure_git_macos ;;
        linux*) ensure_git_linux ;;
        *) error_exit "Unsupported OS: $OSTYPE" ;;
    esac
}

install_mise() {
    if [[ -x "$MISE_BIN" ]]; then
        success "mise is already installed"
        return 0
    fi

    info "Installing mise ${MISE_VERSION:-(latest)}..."
    # mise.run checks the release's SHA256 checksum before installing.
    curl -fsSL https://mise.run | sh || error_exit "Failed to install mise"
    success "mise installed"
}

# mise sets the login shell with `chsh`, which asks for the user's password.
# Users created by cloud-init have no password (locked) and passwordless sudo,
# so set it here with usermod instead; mise then finds it already done. With a
# password-protected sudo this does nothing and mise's chsh prompts as usual.
ensure_login_shell_linux() {
    [[ "$OSTYPE" == linux* ]] || return 0
    [[ "$(getent passwd "$USER" | cut -d: -f7)" == /bin/zsh ]] && return 0
    sudo -n true 2> /dev/null || return 0

    if [[ ! -x /bin/zsh ]]; then
        info "Installing zsh..."
        sudo apt-get update || error_exit "Failed to update apt metadata"
        sudo apt-get install -y zsh || error_exit "Failed to install zsh"
    fi

    sudo usermod -s /bin/zsh "$USER" || error_exit "Failed to set the login shell"
    success "Login shell set to /bin/zsh"
}

# Record this machine's profile once, so later plain `mise bootstrap` runs keep
# loading the same env files. An existing file is never overwritten.
write_profile() {
    [[ -n "$DOTFILES_ENV" ]] || return 0

    local file="$DOTFILES_DIR/.miserc.local.toml"
    local list
    list=$(printf '%s' "$DOTFILES_ENV" | tr -d ' ' | sed -e 's/,/", "/g')
    local wanted="env = [\"$list\"]"

    if [[ -f "$file" ]]; then
        if grep -qxF "$wanted" "$file"; then
            success "Profile already set: $wanted"
        else
            warning "$file exists and does not say $wanted - leaving it alone"
        fi
        return 0
    fi

    printf '# This machine'"'"'s profile (README.md, "Profiles"). Not tracked.\n%s\n' "$wanted" > "$file" \
        || error_exit "Failed to write $file"
    success "Profile set: $wanted"
}

clone_repository() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        success "Dotfiles repo already cloned at $DOTFILES_DIR"
        return 0
    fi

    if [[ -d "$DOTFILES_DIR" ]] && [[ -n "$(ls -A "$DOTFILES_DIR" 2>/dev/null)" ]]; then
        error_exit "$DOTFILES_DIR exists, is not empty and is not a git repo"
    fi

    mkdir -p "$(dirname "$DOTFILES_DIR")" || error_exit "Failed to create parent directory"

    info "Cloning dotfiles repository..."
    git clone -b "$REPO_BRANCH" "$REPO_URL" "$DOTFILES_DIR" || error_exit "Failed to clone repository"
    success "Cloned dotfiles repository to $DOTFILES_DIR"
}

main() {
    info "Starting bootstrap..."

    verify_not_root
    ensure_git
    install_mise

    export PATH="$HOME/.local/bin:$PATH"

    clone_repository

    cd "$DOTFILES_DIR" || error_exit "Failed to cd to $DOTFILES_DIR"

    write_profile
    ensure_login_shell_linux

    # On Linux, refresh apt metadata so packages from repositories added in
    # this run (Docker's) can be found.
    local update=()
    [[ "$OSTYPE" == linux* ]] && update=(--update)

    "$MISE_BIN" trust || error_exit "Failed to trust $DOTFILES_DIR/mise.toml"
    "$MISE_BIN" bootstrap --yes ${update[@]+"${update[@]}"} "$@" || error_exit "mise bootstrap failed"

    success "Bootstrap completed. Open a new shell to pick up the new environment."
}

main "$@"
