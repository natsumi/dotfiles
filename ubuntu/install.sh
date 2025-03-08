#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for better readability
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'

# Log levels
log_info() { printf "${GREEN}%s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}%s${NC}\n" "$*" >&2; }

# Function to check for required commands
check_required_commands() {
  local commands=("$@")
  for cmd in "${commands[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || {
      log_error "Error: $cmd is required but not installed."
      log_info "Installing $cmd..."
      sudo apt-get update && sudo apt-get install -y "$cmd"
    }
  done
}

# List of required commands
required_commands=("curl" "unzip")

# Check for required commands
check_required_commands "${required_commands[@]}"

# Set install directory
INSTALL_DIR="$HOME/dev/dotfiles"
TEMP_ZIP="/tmp/dotfiles.zip"

# Remove existing zip if present
rm -f "$TEMP_ZIP"

# Check if directory already exists
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${BLUE}Removing existing dotfiles installation...${NC}"
  rm -rf "$INSTALL_DIR"
fi

echo -e "${BLUE}Downloading dotfiles...${NC}"
curl -L "https://github.com/natsumi/dotfiles/archive/refs/heads/main.zip" -o "$TEMP_ZIP"

echo -e "${BLUE}Extracting files...${NC}"
mkdir -p "$INSTALL_DIR"
unzip -q "$TEMP_ZIP" -d "/tmp"
mv "/tmp/dotfiles-main/"* "$INSTALL_DIR"
rm -f "$TEMP_ZIP"
rm -rf "/tmp/dotfiles-main"

cd "$INSTALL_DIR"

# Make setup script executable
# chmod +x setup.sh

echo -e "\n${GREEN}✓ Download complete!${NC}"
echo -e "${BLUE}Starting setup...${NC}\n"

# Run setup script
# ./setup.sh
