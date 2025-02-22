#!/usr/bin/env bash

# =============================================================================
# System Bootstrap Script
# =============================================================================
# This script automates the setup of a new macOS system by installing and
# configuring essential software and development tools.
#
# Requirements:
# - macOS operating system
# - Administrative privileges
#
# Usage: ./bootstrap.sh
# =============================================================================

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

  read -r -p "$(printf "${GREEN}%s [Y/n]:${NC} " "$message")" choice
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
      # log_info "Executing: $cmd"
      log_info "Executing:"
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

# Installation step functions
# Since homebrew executs based on a curl file download, it doens't work well with run_step
# define and execute it within its own function
install_homebrew() {
  if prompt_user "Install Homebrew?"; then
    log_info "Running: Install Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_info "Completed: Install Homebrew"
  else
    log_info "Skipping: Install Homebrew"
  fi
}

set_hostname() {
  run_step "Change hostname / computer name" \
    "${SCRIPT_DIR}/set_hostname.sh"
}

install_desktop_apps() {
  run_step "Install Desktop Apps" \
    "${SCRIPT_DIR}/install_desktop_apps.sh"
}

install_brew_packages() {
  run_step "Install Brew packages" \
    "brew bundle --file=homebrew/Brewfile"
}

configure_git() {
  run_step "Configure git" \
    "${SCRIPT_DIR}/set_git_config.sh"
}

install_zplug() {
  if prompt_user "Install Zplug?"; then
    log_info "Running: Install Zplug..."
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    log_info "Completed: Install Zplug"
  else
    log_info "Skipping: Install Zplug"
  fi
}

install_prezto() {
  local prezto_dir="${ZDOTDIR:-$HOME}/.zprezto"
  if prompt_user "Install Prezto?"; then
    log_info "Running: Install Prezto..."
    git clone --recursive --depth 1 https://github.com/sorin-ionescu/prezto.git "${prezto_dir}"
    git clone --recursive --depth 1 https://github.com/belak/prezto-contrib "${prezto_dir}/contrib"
    log_info "Completed: Install Prezto"
  else
    log_info "Skipping: Install Prezto"
  fi
}

apply_symlinks() {
  run_step "Apply symlinks" \
    "${SCRIPT_DIR}/apply_symlinks.sh"
}

install_dev_env() {
  run_step "Install dev environment" \
    "${SCRIPT_DIR}/install_dev_env.sh"
}

# Generate SSH key for the user
generate_ssh_key() {
  if prompt_user "Generate SSH key?"; then
    log_info "Running: Generate SSH key..."

    # Prompt for email
    read -r -p "Enter your email for SSH key: " email

    # Generate SSH key with provided email
    ssh-keygen -t ed25519 -C "$email"

    # Start ssh-agent and add key
    # eval "$(ssh-agent -s)"
    # ssh-add ~/.ssh/id_ed25519

    log_info "Completed: Generate SSH key"
  else
    log_info "Skipping: Generate SSH key"
  fi
}

# Helper function to check system requirements
check_system_requirements() {
  if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is designed for macOS only"
    exit 1
  fi

  if ! command -v curl &>/dev/null; then
    log_error "curl is required but not installed"
    exit 1
  fi
}

show_menu() {
  clear
  echo "==================================================="
  echo "               System Bootstrap Menu                 "
  echo "==================================================="
  echo "1)  Install Homebrew"
  echo "2)  Set Hostname"
  echo "3)  Install Desktop Apps"
  echo "4)  Install Brew Packages"
  echo "5)  Configure Git"
  echo "6)  Generate SSH Key"
  echo "7)  Install Zplug"
  echo "8)  Install Prezto"
  echo "9)  Apply Symlinks"
  echo "10) Install Dev Environment"
  echo "---------------------------------------------------"
  echo "A)  Run All Steps"
  echo "Q)  Quit"
  echo "==================================================="
  echo -n "Please select an option: "
}

main() {
  log_info "Starting system bootstrap..."

  check_system_requirements

  local choice
  while true; do
    show_menu
    read -r choice

    case $choice in
    1) install_homebrew ;;
    2) set_hostname ;;
    3) install_desktop_apps ;;
    4) install_brew_packages ;;
    5) configure_git ;;
    6) generate_ssh_key ;;
    7) install_zplug ;;
    8) install_prezto ;;
    9) apply_symlinks ;;
    10) install_dev_env ;;
    [Aa])
      install_homebrew
      set_hostname
      install_desktop_apps
      install_brew_packages
      configure_git
      generate_ssh_key
      install_zplug
      install_prezto
      apply_symlinks
      install_dev_env
      ;;
    [Qq])
      log_info "Exiting bootstrap script..."
      break
      ;;
    *)
      log_error "Invalid option. Please try again."
      sleep 2
      ;;
    esac

    if [[ $choice != [Qq] ]]; then
      echo
      read -n 1 -s -r -p "Press any key to continue..."
    fi
  done

  log_info "Bootstrap complete!"
}

# Only execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
