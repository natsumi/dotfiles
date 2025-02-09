#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for better readability
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color
readonly RED='\033[0;31m'

# Log levels
log_info() { printf "${GREEN}%s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}%s${NC}\n" "$*" >&2; }

# Helper function to prompt user for yes/no
prompt_user() {
  local message=$1
  local choice

  read -r -p "${GREEN}$message [Y/n]:${NC} " choice
  choice=${choice:-Y} # Default to Y if no input
  [[ $choice =~ ^[Yy]$ ]]
}

# Helper function to run a step if user agrees
run_step() {
  local step_name=$1
  shift # Remove first argument, leaving remaining args as commands

  if prompt_user "Do you want to $step_name?"; then
    log_info "Running: $step_name..."

    local cmd
    for cmd in "$@"; do
      log_info "Executing: $cmd"
      if ! eval "$cmd"; then
        log_error "Failed to execute: $cmd"
        return 1
      fi
    done

    log_info "Completed: $step_name"
  else
    log_info "Skipping: $step_name"
  fi
}

# Cleanup function
cleanup() {
  # Add cleanup tasks here if needed
  log_info "Cleaning up..."
}

# Trap errors and interrupts
trap cleanup EXIT
trap 'log_error "Error occurred on line $LINENO. Exiting..."; exit 1' ERR

main() {
  log_info "Starting system bootstrap..."

  # Define installation steps
  local -ra INSTALL_STEPS=(
    "Install Homebrew|bash -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"
    "Change hostname / computer name|${SCRIPT_DIR}/set_hostname.sh"
    "Install Desktop Apps|${SCRIPT_DIR}/install_desktop_apps.sh"
    "Install Brew packages|brew bundle --file=homebrew/Brewfile"
    "Configure git|${SCRIPT_DIR}/set_git_config.sh"
    "Install Zplug|curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh"
    "Install Prezto|git clone --recursive --depth 1 https://github.com/sorin-ionescu/prezto.git \"${ZDOTDIR:-$HOME}/.zprezto\" && git clone --recursive --depth 1 https://github.com/belak/prezto-contrib \"${ZDOTDIR:-$HOME}/.zprezto/contrib\""
    "Apply symlinks|${SCRIPT_DIR}/apply_symlinks.sh"
    "Install dev environment|${SCRIPT_DIR}/install_dev_env.sh"
  )

  # Execute installation steps
  local step
  for step in "${INSTALL_STEPS[@]}"; do
    IFS='|' read -r description command <<<"$step"
    run_step "$description" "$command"
  done

  log_info "Bootstrap complete!"
}

# Only execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
