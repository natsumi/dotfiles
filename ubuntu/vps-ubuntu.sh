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

log_info "Updating packages"
sudo apt update

# For Neovim
log_info "Installing Neovim"
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable

sudo apt upgrade -y

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

# log_info "Setting default shell"
# chsh -s $(which zsh) $(whoami)

log_info "Install Docker"
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_info "Setting hostname"
# Get the current hostname
CURRENT_HOSTNAME=$(hostname)

# Prompt for new hostname
read -r -p "Enter new hostname (current: $CURRENT_HOSTNAME): " NEW_HOSTNAME

if [ ! -z "$NEW_HOSTNAME" ]; then
  # Update hostname
  sudo hostnamectl set-hostname "$NEW_HOSTNAME"

  # Update /etc/hosts
  sudo sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts

  log_info "Hostname updated to $NEW_HOSTNAME"
else
  log_info "Hostname unchanged"
fi

log_info "Setting timezone to Los Angeles"
sudo timedatectl set-timezone America/Los_Angeles

log_info "Hardening SSH configuration"

# Change SSH port to 2222
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
# Disable root login
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
# Disable password authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Disable empty passwords
sudo sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
# Disable X11 forwarding
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
# Set maximum auth tries
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
# Enable public key authentication
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# Disable challenge-response authentication
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
# Set login grace time
sudo sed -i 's/#LoginGraceTime 2m/LoginGraceTime 1m/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
# this doesn't seem to work
# sudo systemctl restart ssh

# Add section for settings up docker firewall
# log_info "Configuring UFW firewall"
# sudo apt install -y ufw
# Default policies
# sudo ufw default deny incoming
# sudo ufw default allow outgoing
# Allow SSH on custom port
# sudo ufw allow 2222/tcp
# Allow HTTP/HTTPS if needed
# sudo ufw allow 80/tcp
# sudo ufw allow 443/tcp
# Enable UFW
# sudo ufw enable

log_info "Setting up automatic security updates"
# TODO: see if I can do this without a prompt
# sudo apt install -y unattended-upgrades
# sudo dpkg-reconfigure -plow unattended-upgrades

# Disable IPv6 if not needed
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

log_info "Configuring Docker security"
# Add current user to docker group
sudo usermod -aG docker $USER
# Configure Docker daemon to use more secure options
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "20m",
    "max-file": "5"
  },
  "no-new-privileges": true,
  "userns-remap": "default"
}
EOF

log_info "Copy over your SSH key"
log_info "ssh-copy-id -i ~/.ssh/mykey user@host"
log_info "Setup complete"
log_info "Reboot your server: sudo reboot now"
