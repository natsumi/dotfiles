#!/bin/bash

# VPS Setup Installer
# This script downloads and runs the main VPS setup script
# Usage: curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh | bash

set -euo pipefail

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly REPO_URL="https://github.com/natsumi/dotfiles"
readonly REPO_BRANCH="main"
readonly SETUP_SCRIPT="vps/setup.sh"
readonly TEMP_DIR="/tmp/vps-setup-$$"

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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This installer must be run as root. Try: sudo bash"
    fi
}

# Check OS compatibility
check_os() {
    if [[ ! -f /etc/os-release ]]; then
        error_exit "Cannot determine OS version"
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]] || [[ "$VERSION_ID" != "24.04" ]]; then
        error_exit "This installer is designed for Ubuntu 24.04 only (detected: $ID $VERSION_ID)"
    fi
}

# Check internet connectivity
check_internet() {
    if ! ping -c 1 -q google.com &> /dev/null; then
        error_exit "No internet connection available"
    fi
}

# Check required commands
check_dependencies() {
    local deps=(git curl wget)
    local missing=()
    
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        info "Installing missing dependencies: ${missing[*]}"
        apt-get update -qq
        apt-get install -y "${missing[@]}" || error_exit "Failed to install dependencies"
    fi
}

# Download setup files
download_setup() {
    info "Downloading setup files..."
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Clone repository (sparse checkout for efficiency)
    git clone --depth 1 --branch "$REPO_BRANCH" --sparse "$REPO_URL" . &> /dev/null || \
        error_exit "Failed to download setup files"
    
    git sparse-checkout init --cone &> /dev/null
    git sparse-checkout set vps &> /dev/null
    
    # Verify main script exists
    if [[ ! -f "$SETUP_SCRIPT" ]]; then
        error_exit "Setup script not found: $SETUP_SCRIPT"
    fi
    
    # Make executable
    chmod +x "$SETUP_SCRIPT"
    
    success "Setup files downloaded"
}

# Pre-installation warning
show_warning() {
    echo
    warning "This script will:"
    echo "  • Install and configure various system packages"
    echo "  • Modify SSH configuration (custom port)"
    echo "  • Enable firewall with strict rules"
    echo "  • Configure security tools (fail2ban, sshguard)"
    echo "  • Potentially create a new admin user"
    echo "  • Apply various security hardening measures"
    echo
    echo "The script will guide you through interactive configuration."
    echo
    read -p "Do you want to continue? [y/N]: " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error_exit "Installation cancelled by user"
    fi
}

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Main execution
main() {
    clear
    echo "========================================"
    echo "   VPS Ubuntu 24.04 Setup Installer     "
    echo "========================================"
    echo
    
    # Checks
    check_root
    check_os
    check_internet
    check_dependencies
    
    # Show warning and get confirmation
    show_warning
    
    # Download and run setup
    download_setup
    
    info "Starting VPS setup..."
    echo
    
    # Run the main setup script
    cd "$TEMP_DIR"
    bash "$SETUP_SCRIPT"
}

# Run main
main "$@"