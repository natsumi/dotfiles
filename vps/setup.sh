#!/bin/bash

# Start with basic error handling
set -u

# Enable full strict mode after initialization
enable_strict_mode() {
    set -euo pipefail
}

# Enable debug mode if DEBUG environment variable is set
if [[ "${DEBUG:-}" == "1" ]]; then
    set -x
    # Also log all commands to the log file
    export PS4='+ $(date "+%Y-%m-%d %H:%M:%S") ${BASH_SOURCE}:${LINENO}: '
    exec 2>&1
fi

# VPS Ubuntu 24.04 Setup Script
# Enhanced with security hardening, interactive configuration, and best practices

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/configs"

# Error handler
handle_error() {
    local line_no=$1
    local bash_lineno=$2
    local last_command=$3
    local code=$4

    echo
    echo -e "\033[0;31mERROR: The script failed at line $line_no (bash line $bash_lineno)\033[0m"
    echo -e "\033[0;31mCommand: $last_command\033[0m"
    echo -e "\033[0;31mExit Code: $code\033[0m"
    echo
    echo "Check the log file for more details: $LOG_FILE"
    echo

    # If in the middle of installation, provide recovery instructions
    if [[ -f "$LOG_FILE" ]]; then
        echo "To debug, you can:"
        echo "1. Check the last 50 lines of the log: tail -50 $LOG_FILE"
        echo "2. Re-run with debug mode: DEBUG=1 bash $0"
        echo "3. Your original configs are backed up in: $BACKUP_DIR"
    fi

    exit $code
}

# Set up error handling
trap 'handle_error ${LINENO} ${BASH_LINENO} "$BASH_COMMAND" $?' ERR

# Color definitions for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration variables
EXECUTION_DIR="$(pwd)"
LOG_DIR="$EXECUTION_DIR"
LOG_FILE="$LOG_DIR/vps_setup.log"
BACKUP_DIR="$EXECUTION_DIR/vps-setup/backup/$(date +%Y%m%d-%H%M%S)"

# Ensure log file can be created (overwrite previous log)
if ! touch "$LOG_FILE" 2>/dev/null; then
    LOG_DIR="/tmp"
    LOG_FILE="$LOG_DIR/vps_setup.log"
    # Note: Can't use warning() here as it might not be defined yet
    echo -e "\033[1;33m⚠ Cannot write to current directory, using /tmp for logs\033[0m"
fi

# Set up logging to capture all output
setup_logging() {
    # Create a file descriptor for logging
    exec 3>&1 4>&2
    # Redirect stdout and stderr to tee, which writes to both log and screen
    # Overwrite previous log file on each run
    exec 1> >(tee "$LOG_FILE")
    exec 2> >(tee "$LOG_FILE" >&2)

    # Log script start
    echo "=== VPS Setup Script Started at $(date) ==="
    echo "=== Log file: $LOG_FILE ==="
    echo
}

# Default values
DEFAULT_SSH_PORT=22
DEFAULT_USERNAME=""
DEFAULT_HOSTNAME=""

# Logging function
log() {
    local message="${2:-}$1${NC}"
    echo -e "$message"
    # Try to append to log file, but don't fail if we can't
    echo -e "$message" >>"$LOG_FILE" 2>/dev/null || true
}

# Error handling
error_exit() {
    log "ERROR: $1" "$RED"
    exit 1
}

# Success message
success() {
    log "✓ $1" "$GREEN"
}

# Warning message
warning() {
    log "⚠ $1" "$YELLOW"
}

# Info message
info() {
    log "ℹ $1" "$BLUE"
}

# Run command with detailed logging
run_cmd() {
    local cmd="$1"
    local description="${2:-Running command}"

    echo ">>> $description"
    echo ">>> Command: $cmd"

    local exit_code
    if eval "$cmd"; then
        echo ">>> Success: $description"
        return 0
    else
        exit_code=$?
        echo ">>> FAILED: $description (exit code: $exit_code)"
        echo ">>> Failed command: $cmd"
        return $exit_code
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root"
    fi
}

# Check if config directory exists
check_config_dir() {
    if [[ ! -d "$CONFIG_DIR" ]]; then
        error_exit "Configuration directory not found: $CONFIG_DIR"
    fi
    success "Configuration directory found"
}

# Check Ubuntu version
check_ubuntu_version() {
    if [[ ! -f /etc/os-release ]]; then
        error_exit "Cannot determine OS version"
    fi

    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]] || [[ "$VERSION_ID" != "24.04" ]]; then
        error_exit "This script is designed for Ubuntu 24.04 only"
    fi
    success "Ubuntu 24.04 detected"
}

# Check internet connectivity
check_internet() {
    if ! ping -c 1 -q google.com &>/dev/null; then
        error_exit "No internet connection available"
    fi
    success "Internet connection verified"
}

# Create backup directory
create_backup() {
    if ! mkdir -p "$BACKUP_DIR" 2>/dev/null; then
        warning "Could not create backup directory: $BACKUP_DIR"
        BACKUP_DIR="/tmp/server-setup-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR" || error_exit "Failed to create backup directory"
    fi
    info "Backup directory created: $BACKUP_DIR"
}

# Interactive configuration
interactive_config() {
    echo
    info "=== Interactive Configuration ==="
    echo

    # Username
    read -p "Enter username for sudo access (leave empty to skip user creation): " username
    DEFAULT_USERNAME="$username"

    # Hostname
    current_hostname=$(hostname)
    read -p "Enter hostname (current: $current_hostname): " hostname
    DEFAULT_HOSTNAME="${hostname:-$current_hostname}"

    # SSH Port
    read -p "Enter SSH port (default: $DEFAULT_SSH_PORT): " ssh_port
    DEFAULT_SSH_PORT="${ssh_port:-$DEFAULT_SSH_PORT}"

    # Docker installation
    read -p "Install Docker? [y/N]: " install_docker_response
    INSTALL_DOCKER="$install_docker_response"

    # Display configuration summary
    echo
    info "=== Configuration Summary ==="
    echo "Username: ${DEFAULT_USERNAME:-[no new user]}"
    echo "Hostname: $DEFAULT_HOSTNAME"
    echo "SSH Port: $DEFAULT_SSH_PORT"
    echo "Install Docker: ${INSTALL_DOCKER:-N}"
    echo

    read -p "Proceed with this configuration? [Y/n]: " proceed
    [[ "$proceed" =~ ^[Nn]$ ]] && error_exit "Installation cancelled by user"
}

# Update system
update_system() {
    info "Configuring package mirror and updating system..."

    # Backup original sources file
    if [[ -f /etc/apt/sources.list.d/ubuntu.sources ]]; then
        cp /etc/apt/sources.list.d/ubuntu.sources "$BACKUP_DIR/ubuntu.sources.backup"
        info "Backed up original ubuntu.sources"
    fi

    # Configure Pilot Fiber mirror for Ubuntu 24.04
    if [[ -f "$CONFIG_DIR/apt/ubuntu.sources" ]]; then
        cp "$CONFIG_DIR/apt/ubuntu.sources" /etc/apt/sources.list.d/ubuntu.sources
    else
        error_exit "Ubuntu sources configuration file not found: $CONFIG_DIR/apt/ubuntu.sources"
    fi

    success "Configured Pilot Fiber mirror"

    # Update package lists
    if ! apt-get update -y >>"$LOG_FILE" 2>&1; then
        error_exit "Failed to update package lists. Check internet connection and repository settings."
    fi

    # Upgrade packages with error handling
    apt-get upgrade -y >>"$LOG_FILE" 2>&1 || warning "Some packages failed to upgrade"
    apt-get autoremove -y >>"$LOG_FILE" 2>&1 || true

    success "System updated"
}

# Install base packages
install_base_packages() {
    info "Installing base packages..."

    # Essential packages
    local packages=(
        # Build tools
        build-essential
        automake
        autoconf
        libreadline-dev
        libncurses-dev
        libssl-dev
        libyaml-dev
        libxslt-dev
        libffi-dev
        libtool
        unixodbc-dev
        openssl
        zlib1g-dev

        # System utilities
        software-properties-common
        apt-transport-https
        ca-certificates
        gnupg
        lsb-release

        # Security tools
        ufw
        fail2ban
        unattended-upgrades
        apt-listchanges

        # Development tools
        git
        curl
        wget
        unzip
        jq

        # Text processing
        ripgrep
        fd-find
        fzf
        bat

        # System monitoring
        btop
        htop
        ncdu
        iotop
        nethogs

        # Terminal tools
        tmux
        zsh
        stow
        tig
        tree

        # Network tools
        net-tools
        dnsutils
        traceroute
        mtr
        whois
    )

    # Install packages with error handling
    if ! apt-get install -y "${packages[@]}" >>"$LOG_FILE" 2>&1; then
        warning "Some packages failed to install. Check $LOG_FILE for details."
        # Try to install packages one by one to identify failures
        for pkg in "${packages[@]}"; do
            if ! dpkg -s "$pkg" &>/dev/null; then
                apt-get install -y "$pkg" >>"$LOG_FILE" 2>&1 || warning "Failed to install: $pkg"
            fi
        done
    fi
    success "Base packages installed"
}

# Install Neovim
install_neovim() {
    info "Installing Neovim..."
    add-apt-repository -y ppa:neovim-ppa/unstable >>"$LOG_FILE" 2>&1
    apt-get update -y >>"$LOG_FILE" 2>&1
    apt-get install -y neovim >>"$LOG_FILE" 2>&1
    success "Neovim installed"
}

# Install Docker
install_docker_engine() {
    info "Installing Docker..."

    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Set up the repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    # Install Docker Engine
    apt-get update -y >>"$LOG_FILE" 2>&1
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >>"$LOG_FILE" 2>&1

    # Enable and start Docker
    systemctl enable docker >>"$LOG_FILE" 2>&1
    systemctl start docker >>"$LOG_FILE" 2>&1

    # Add user to docker group if a user was created
    if [[ -n "$DEFAULT_USERNAME" ]]; then
        usermod -aG docker "$DEFAULT_USERNAME" >>"$LOG_FILE" 2>&1
        info "Added $DEFAULT_USERNAME to docker group"
    fi

    # Configure Docker to start on boot
    systemctl enable docker.service >>"$LOG_FILE" 2>&1
    systemctl enable containerd.service >>"$LOG_FILE" 2>&1

    # Optional: Configure Docker daemon for better security
    if [[ -f "$CONFIG_DIR/docker/daemon.json" ]]; then
        cp "$CONFIG_DIR/docker/daemon.json" /etc/docker/daemon.json
    else
        warning "Docker daemon configuration file not found: $CONFIG_DIR/docker/daemon.json"
    fi

    systemctl restart docker >>"$LOG_FILE" 2>&1
    success "Docker configuration applied"
}

# Install Lazydocker
install_lazydocker() {
    info "Installing Lazydocker..."

    # Use the official install script
    if curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash >>"$LOG_FILE" 2>&1; then
        # Move from user's local bin to system-wide location
        if [[ -f "$HOME/.local/bin/lazydocker" ]]; then
            mv "$HOME/.local/bin/lazydocker" /usr/local/bin/ >>"$LOG_FILE" 2>&1
            chmod +x /usr/local/bin/lazydocker >>"$LOG_FILE" 2>&1

            # Verify installation
            if command -v lazydocker &>/dev/null; then
                local version=$(lazydocker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
                success "Lazydocker installed successfully"
                LAZYDOCKER_INSTALLED="Installed (v${version})"
            else
                warning "Lazydocker moved but not found in PATH"
                LAZYDOCKER_INSTALLED="Installation attempted"
            fi
        else
            warning "Lazydocker binary not found at expected location"
            LAZYDOCKER_INSTALLED="Installation failed"
            return 1
        fi
    else
        warning "Failed to run Lazydocker install script"
        LAZYDOCKER_INSTALLED="Failed to install"
        return 1
    fi
}

# Create new user
create_user() {
    if [[ -z "$DEFAULT_USERNAME" ]]; then
        info "Skipping user creation"
        return
    fi

    # Check if user already exists
    if id "$DEFAULT_USERNAME" &>/dev/null; then
        warning "User '$DEFAULT_USERNAME' already exists, skipping user creation"
        info "Ensuring user is in sudo group..."
        usermod -aG sudo "$DEFAULT_USERNAME" >>"$LOG_FILE" 2>&1
        success "User '$DEFAULT_USERNAME' added to sudo group"
        return
    fi

    info "Creating user: $DEFAULT_USERNAME"

    # Create user with home directory
    useradd -m -s /bin/bash "$DEFAULT_USERNAME" >>"$LOG_FILE" 2>&1

    # Add to sudo group
    usermod -aG sudo "$DEFAULT_USERNAME" >>"$LOG_FILE" 2>&1

    # Set up SSH directory
    local user_home="/home/$DEFAULT_USERNAME"
    mkdir -p "$user_home/.ssh"

    # Copy root's authorized_keys if exists
    if [[ -f /root/.ssh/authorized_keys ]]; then
        cp /root/.ssh/authorized_keys "$user_home/.ssh/"
        chown -R "$DEFAULT_USERNAME:$DEFAULT_USERNAME" "$user_home/.ssh"
        chmod 700 "$user_home/.ssh"
        chmod 600 "$user_home/.ssh/authorized_keys"
        success "SSH keys copied to new user"
    fi

    # Set password
    info "Please set password for $DEFAULT_USERNAME"
    passwd "$DEFAULT_USERNAME"

    success "User created: $DEFAULT_USERNAME"
}

# Configure hostname
configure_hostname() {
    if [[ "$DEFAULT_HOSTNAME" != "$(hostname)" ]]; then
        info "Setting hostname to: $DEFAULT_HOSTNAME"
        hostnamectl set-hostname "$DEFAULT_HOSTNAME"

        # Update /etc/hosts
        sed -i "s/127.0.1.1.*/127.0.1.1\t$DEFAULT_HOSTNAME/" /etc/hosts

        success "Hostname configured"
    fi
}

# Configure timezone
configure_timezone() {
    info "Configuring timezone..."
    local current_tz=$(timedatectl show -p Timezone --value)

    echo "Current timezone: $current_tz"
    read -p "Enter timezone (default: America/Los_Angeles) or press Enter for default: " new_tz
    new_tz="${new_tz:-America/Los_Angeles}"

    if [[ "$new_tz" != "$current_tz" ]]; then
        timedatectl set-timezone "$new_tz" >>"$LOG_FILE" 2>&1
        success "Timezone set to: $new_tz"
    else
        success "Timezone unchanged: $current_tz"
    fi
}

# Configure SSH
configure_ssh() {
    info "Configuring SSH..."

    # Backup original sshd_config
    cp /etc/ssh/sshd_config "$BACKUP_DIR/sshd_config.backup"

    # Create new sshd_config from template
    if [[ -f "$CONFIG_DIR/ssh/sshd_config.template" ]]; then
        # Replace placeholders in template
        sed -e "s/{{SSH_PORT}}/$DEFAULT_SSH_PORT/g" \
            -e "s/{{USERNAME}}/${DEFAULT_USERNAME:-}/g" \
            "$CONFIG_DIR/ssh/sshd_config.template" > /etc/ssh/sshd_config
    else
        error_exit "SSH configuration template not found: $CONFIG_DIR/ssh/sshd_config.template"
    fi

    # Test SSH configuration and restart
    if sshd -t; then
        systemctl restart sshd >>"$LOG_FILE" 2>&1
        success "SSH configured and restarted on port $DEFAULT_SSH_PORT"
        warning "Remember to update your SSH connection to use port $DEFAULT_SSH_PORT"
    else
        error_exit "SSH configuration error - check $LOG_FILE"
    fi
}

# Configure firewall
configure_firewall() {
    info "Configuring UFW firewall..."

    # Reset UFW to defaults
    ufw --force reset >>"$LOG_FILE" 2>&1

    # Default policies
    ufw default deny incoming >>"$LOG_FILE" 2>&1
    ufw default allow outgoing >>"$LOG_FILE" 2>&1

    # Allow SSH on custom port
    ufw allow "$DEFAULT_SSH_PORT/tcp" comment 'SSH' >>"$LOG_FILE" 2>&1

    # Allow HTTP/HTTPS
    ufw allow 80/tcp comment 'HTTP' >>"$LOG_FILE" 2>&1
    ufw allow 443/tcp comment 'HTTPS' >>"$LOG_FILE" 2>&1

    # Enable UFW
    echo "y" | ufw enable >>"$LOG_FILE" 2>&1

    success "Firewall configured"
}

# Configure fail2ban
configure_fail2ban() {
    info "Configuring fail2ban..."

    # Backup original config
    cp /etc/fail2ban/jail.conf "$BACKUP_DIR/jail.conf.backup" 2>/dev/null || true

    # Create jail.local from template
    if [[ -f "$CONFIG_DIR/fail2ban/jail.local.template" ]]; then
        # Replace placeholders in template
        sed -e "s/{{SSH_PORT}}/$DEFAULT_SSH_PORT/g" \
            "$CONFIG_DIR/fail2ban/jail.local.template" > /etc/fail2ban/jail.local
    else
        error_exit "Fail2ban configuration template not found: $CONFIG_DIR/fail2ban/jail.local.template"
    fi

    # Copy Traefik filter files
    if [[ -d "$CONFIG_DIR/fail2ban/filters" ]]; then
        for filter in "$CONFIG_DIR/fail2ban/filters"/*.conf; do
            if [[ -f "$filter" ]]; then
                cp "$filter" /etc/fail2ban/filter.d/
                info "Copied filter: $(basename "$filter")"
            fi
        done
    else
        warning "Fail2ban filter directory not found: $CONFIG_DIR/fail2ban/filters"
    fi

    # Start and enable fail2ban
    systemctl enable fail2ban >>"$LOG_FILE" 2>&1
    systemctl restart fail2ban >>"$LOG_FILE" 2>&1

    success "Fail2ban configured"
}

# Configure automatic updates
configure_auto_updates() {
    info "Configuring automatic security updates..."

    # Configure unattended-upgrades
    if [[ -f "$CONFIG_DIR/apt/unattended-upgrades/50unattended-upgrades" ]]; then
        cp "$CONFIG_DIR/apt/unattended-upgrades/50unattended-upgrades" /etc/apt/apt.conf.d/50unattended-upgrades
    else
        error_exit "Unattended upgrades configuration not found: $CONFIG_DIR/apt/unattended-upgrades/50unattended-upgrades"
    fi

    # Enable automatic updates
    if [[ -f "$CONFIG_DIR/apt/unattended-upgrades/20auto-upgrades" ]]; then
        cp "$CONFIG_DIR/apt/unattended-upgrades/20auto-upgrades" /etc/apt/apt.conf.d/20auto-upgrades
    else
        error_exit "Auto upgrades configuration not found: $CONFIG_DIR/apt/unattended-upgrades/20auto-upgrades"
    fi

    systemctl enable unattended-upgrades >>"$LOG_FILE" 2>&1

    success "Automatic updates configured"
}

# Create swap file
create_swap() {
    info "Checking swap configuration..."

    if [[ $(swapon -s | wc -l) -gt 1 ]]; then
        info "Swap already configured, skipping"
        return
    fi

    local total_mem=$(free -m | awk '/^Mem:/{print $2}')
    local swap_size=$((total_mem < 2048 ? total_mem * 2 : 4096))

    info "Creating ${swap_size}MB swap file..."

    fallocate -l "${swap_size}M" /swapfile >>"$LOG_FILE" 2>&1
    chmod 600 /swapfile
    mkswap /swapfile >>"$LOG_FILE" 2>&1
    swapon /swapfile >>"$LOG_FILE" 2>&1

    # Make permanent (idempotent)
    if ! grep -q '/swapfile' /etc/fstab; then
        echo "/swapfile none swap sw 0 0" >>/etc/fstab
    fi

    # Optimize swappiness (idempotent)
    if ! grep -q 'vm.swappiness' /etc/sysctl.conf; then
        echo "vm.swappiness=10" >>/etc/sysctl.conf
    fi
    sysctl -p >>"$LOG_FILE" 2>&1

    success "Swap file created: ${swap_size}MB"
}

# Security audit
perform_security_audit() {
    info "Performing security audit..."

    # Check for default users
    for user in pi ubuntu debian; do
        if id "$user" &>/dev/null; then
            warning "Default user '$user' exists - consider removing"
        fi
    done

    # Check SSH key strength
    while IFS= read -r key; do
        if [[ "$key" =~ ssh-rsa ]] && [[ $(echo "$key" | awk '{print $2}' | base64 -d | wc -c) -lt 256 ]]; then
            warning "Weak RSA key found in authorized_keys"
        fi
    done <"${target_home:-/root}/.ssh/authorized_keys" 2>/dev/null || true

    # Check for running unnecessary services
    local unnecessary_services=(
        "telnet"
        "rsh-server"
        "rlogin"
        "vsftpd"
    )

    for service in "${unnecessary_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            warning "Unnecessary service running: $service"
        fi
    done

    success "Security audit complete"
}

# Generate summary report
generate_summary() {
    local summary_file="/root/vps-setup-summary.txt"

    cat >"$summary_file" <<EOF
VPS Setup Summary
Generated: $(date)
================

System Information:
- Hostname: $DEFAULT_HOSTNAME
- Ubuntu Version: 24.04 LTS

User Configuration:
- Admin User: ${DEFAULT_USERNAME:-root}
- SSH Port: $DEFAULT_SSH_PORT

Security Features:
- Firewall: UFW (enabled)
- Fail2ban: Configured for SSH and Traefik protection
- Automatic Updates: Enabled for security patches

Optional Features:
- Swap: Configured
- Docker: ${DOCKER_INSTALLED:-Not installed}
- Lazydocker: ${LAZYDOCKER_INSTALLED:-Not installed}

Important Notes:
1. SSH is now on port $DEFAULT_SSH_PORT (not 22)
2. Password authentication is disabled - use SSH keys only
3. Root login is allowed with SSH keys only (no password)
4. Firewall is active - only SSH, HTTP, and HTTPS are allowed

Next Steps:
1. Test SSH connection on new port before closing current session
2. Configure your domain DNS to point to this server
3. Install your applications
4. Regularly review /var/log/auth.log for security events
5. Keep the system updated with: apt update && apt upgrade

Logs and Backups:
- Setup Log: $LOG_FILE
- Configuration Backup: $BACKUP_DIR
EOF

    info "Setup summary saved to: $summary_file"
    cat "$summary_file"
}

# Main installation flow
main() {
    clear
    echo "========================================"
    echo "     VPS Ubuntu 24.04 Setup Script      "
    echo "        Enhanced Security Edition       "
    echo "========================================"
    echo

    # Set up comprehensive logging first
    setup_logging

    # Pre-flight checks
    check_root
    check_config_dir
    check_ubuntu_version
    check_internet
    create_backup

    # Interactive configuration
    interactive_config

    # Enable strict mode after initialization
    enable_strict_mode

    # System setup
    configure_timezone
    configure_hostname
    update_system

    # Package installation
    install_base_packages
    install_neovim

    # User and security setup
    create_user
    configure_ssh
    # Docker installation (optional)
    if [[ "$INSTALL_DOCKER" =~ ^[Yy]$ ]]; then
        install_docker_engine
        DOCKER_INSTALLED="Installed"
        # Install Lazydocker after Docker
        install_lazydocker
    else
        info "Skipping Docker installation"
        DOCKER_INSTALLED="Not installed"
        LAZYDOCKER_INSTALLED="Not installed (requires Docker)"
    fi
    configure_firewall
    configure_fail2ban
    configure_auto_updates

    # System optimization
    create_swap

    # Final steps
    perform_security_audit
    generate_summary

    echo
    echo "========================================"
    success "VPS setup completed successfully!"
    echo
    warning "IMPORTANT: Test SSH on port $DEFAULT_SSH_PORT before closing this session!"
    echo
    info "Review the setup summary above and in: /root/vps-setup-summary.txt"
    echo
    warning "RECOMMENDED: Reboot the server to ensure all changes take effect"
    info "To reboot now, run: sudo reboot"
    echo "========================================"
    echo
}

# Run main function
main "$@"
