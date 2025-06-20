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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTION_DIR="$(pwd)"
LOG_DIR="$EXECUTION_DIR"
LOG_FILE="$LOG_DIR/vps-setup-$(date +%Y%m%d-%H%M%S).log"
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="/root/server-setup-backup-$(date +%Y%m%d-%H%M%S)"

# Ensure log file can be created
if ! touch "$LOG_FILE" 2>/dev/null; then
    LOG_DIR="/tmp"
    LOG_FILE="$LOG_DIR/vps-setup-$(date +%Y%m%d-%H%M%S).log"
    # Note: Can't use warning() here as it might not be defined yet
    echo -e "\033[1;33m⚠ Cannot write to current directory, using /tmp for logs\033[0m"
fi

# Set up logging to capture all output
setup_logging() {
    # Create a file descriptor for logging
    exec 3>&1 4>&2
    # Redirect stdout and stderr to tee, which writes to both log and screen
    exec 1> >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$LOG_FILE" >&2)

    # Log script start
    echo "=== VPS Setup Script Started at $(date) ==="
    echo "=== Log file: $LOG_FILE ==="
    echo
}

# Default values
DEFAULT_SSH_PORT=2222
DEFAULT_USERNAME=""
DEFAULT_HOSTNAME=""
SECURITY_LEVEL="enhanced"
ENABLE_MONITORING="yes"

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

    if eval "$cmd"; then
        echo ">>> Success: $description"
        return 0
    else
        local exit_code=$?
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

    # Optional features
    echo
    read -p "Enable system monitoring tools? [Y/n]: " monitoring_choice
    [[ "$monitoring_choice" =~ ^[Nn]$ ]] && ENABLE_MONITORING="no"


    # Display configuration summary
    echo
    info "=== Configuration Summary ==="
    echo "Username: ${DEFAULT_USERNAME:-[no new user]}"
    echo "Hostname: $DEFAULT_HOSTNAME"
    echo "SSH Port: $DEFAULT_SSH_PORT"
    echo "Security Level: $SECURITY_LEVEL"
    echo "Monitoring: $ENABLE_MONITORING"
    echo

    read -p "Proceed with this configuration? [Y/n]: " proceed
    [[ "$proceed" =~ ^[Nn]$ ]] && error_exit "Installation cancelled by user"
}

# Update system
update_system() {
    info "Updating system packages..."

    # Update package lists
    if ! apt-get update -y >>"$LOG_FILE" 2>&1; then
        error_exit "Failed to update package lists. Check internet connection and repository settings."
    fi

    # Upgrade packages with error handling
    apt-get upgrade -y >>"$LOG_FILE" 2>&1 || warning "Some packages failed to upgrade"
    apt-get dist-upgrade -y >>"$LOG_FILE" 2>&1 || warning "Some packages failed to dist-upgrade"
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
        sshguard
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
        htop
        ncdu
        iotop
        nethogs

        # Terminal tools
        tmux
        zsh
        stow
        tig

        # Network tools
        net-tools
        dnsutils
        traceroute
        mtr
        whois
    )

    # Add monitoring tools if enabled
    if [[ "$ENABLE_MONITORING" == "yes" ]]; then
        # btop might not be available in all repos
        if apt-cache show btop &>/dev/null; then
            packages+=(btop)
        fi
    fi

    # Install packages with error handling
    if ! apt-get install -y "${packages[@]}" >>"$LOG_FILE" 2>&1; then
        warning "Some packages failed to install. Check $LOG_FILE for details."
        # Try to install packages one by one to identify failures
        for pkg in "${packages[@]}"; do
            if ! dpkg -l "$pkg" &>/dev/null; then
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

# Create new user
create_user() {
    if [[ -z "$DEFAULT_USERNAME" ]]; then
        info "Skipping user creation"
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
    read -p "Enter timezone (e.g., America/New_York) or press Enter to keep current: " new_tz

    if [[ -n "$new_tz" ]]; then
        timedatectl set-timezone "$new_tz" >>"$LOG_FILE" 2>&1
        success "Timezone set to: $new_tz"
    fi
}

# Configure SSH
configure_ssh() {
    info "Configuring SSH..."

    # Backup original sshd_config
    cp /etc/ssh/sshd_config "$BACKUP_DIR/sshd_config.backup"

    # Create new sshd_config
    cat >/etc/ssh/sshd_config <<EOF
# SSH Server Configuration - Hardened
# Generated by VPS Setup Script

# Port and Protocol
Port $DEFAULT_SSH_PORT
Protocol 2

# Host Keys
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication
LoginGraceTime 30
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
MaxSessions 3

# Public key authentication
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Password authentication (disabled for security)
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Other authentication methods (disabled)
GSSAPIAuthentication no
HostbasedAuthentication no

# Security settings
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
Compression delayed
ClientAliveInterval 300
ClientAliveCountMax 2
UseDNS no

# Restrict users and groups
AllowUsers ${DEFAULT_USERNAME:-root}
AllowGroups sudo ssh

# Crypto settings (strong only)
Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# SFTP
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

    # Additional paranoid settings
    if [[ "$SECURITY_LEVEL" == "paranoid" ]]; then
        cat >>/etc/ssh/sshd_config <<EOF

# Paranoid mode additions
MaxStartups 2:30:5
PermitUserEnvironment no
Banner /etc/issue.net
EOF

        # Create banner
        cat >/etc/issue.net <<EOF
***************************************************************************
                            AUTHORIZED ACCESS ONLY
Unauthorized access to this system is forbidden and will be prosecuted
by law. By accessing this system, you consent to monitoring and recording.
***************************************************************************
EOF
    fi

    # Test SSH configuration
    if sshd -t; then
        systemctl restart sshd
        success "SSH configured on port $DEFAULT_SSH_PORT"
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

    # Additional rules based on security level
    if [[ "$SECURITY_LEVEL" != "basic" ]]; then
        # Rate limiting for SSH
        ufw limit "$DEFAULT_SSH_PORT/tcp" >>"$LOG_FILE" 2>&1
    fi

    # Enable UFW
    echo "y" | ufw enable >>"$LOG_FILE" 2>&1

    success "Firewall configured"
}

# Configure fail2ban
configure_fail2ban() {
    info "Configuring fail2ban..."

    # Backup original config
    cp /etc/fail2ban/jail.conf "$BACKUP_DIR/jail.conf.backup" 2>/dev/null || true

    # Create jail.local
    cat >/etc/fail2ban/jail.local <<EOF
[DEFAULT]
# Ban time and retry settings
bantime = 3600
findtime = 600
maxretry = 3
destemail = root@localhost
sendername = Fail2Ban
action = %(action_mwl)s

# Backend
backend = systemd

[sshd]
enabled = true
port = $DEFAULT_SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[sshd-ddos]
enabled = true
port = $DEFAULT_SSH_PORT
filter = sshd-ddos
logpath = /var/log/auth.log
maxretry = 10
findtime = 60
bantime = 600
EOF

    # Enhanced/Paranoid additions
    if [[ "$SECURITY_LEVEL" != "basic" ]]; then
        cat >>/etc/fail2ban/jail.local <<EOF

[recidive]
enabled = true
filter = recidive
logpath = /var/log/fail2ban.log
action = %(action_mwl)s
bantime = 86400
findtime = 86400
maxretry = 2

[nginx-http-auth]
enabled = false
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log

[nginx-noscript]
enabled = false
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 6

[nginx-badbots]
enabled = false
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 2

[nginx-noproxy]
enabled = false
port = http,https
filter = nginx-noproxy
logpath = /var/log/nginx/access.log
maxretry = 2
EOF
    fi

    # Start and enable fail2ban
    systemctl enable fail2ban >>"$LOG_FILE" 2>&1
    systemctl restart fail2ban >>"$LOG_FILE" 2>&1

    success "Fail2ban configured"
}

# Configure SSHGuard
configure_sshguard() {
    info "Configuring SSHGuard..."

    # Create SSHGuard configuration
    cat >/etc/sshguard/sshguard.conf <<EOF
# SSHGuard Configuration
# Generated by VPS Setup Script

# Backend
BACKEND="/usr/lib/sshguard/sshg-fw-ufw"

# Log files to monitor
FILES="/var/log/auth.log"

# Whitelist file
WHITELIST_FILE=/etc/sshguard/whitelist

# Danger threshold
THRESHOLD=30

# Block time (seconds)
BLOCK_TIME=1800

# Detection time (seconds)
DETECTION_TIME=1800

# IPv6 support
IPV6_SUBNET=128
IPV4_SUBNET=32

# Blacklist threshold
BLACKLIST_FILE=/var/lib/sshguard/blacklist.db
BLACKLIST_THRESHOLD=120
EOF

    # Create whitelist
    cat >/etc/sshguard/whitelist <<EOF
# SSHGuard whitelist
# Add trusted IP addresses here
127.0.0.0/8
::1/128
EOF

    # Add user's current IP to whitelist if available
    if [[ -n "${SSH_CLIENT:-}" ]]; then
        local user_ip=$(echo "$SSH_CLIENT" | awk '{print $1}')
        echo "# Current user IP" >>/etc/sshguard/whitelist
        echo "$user_ip" >>/etc/sshguard/whitelist
        info "Added your current IP ($user_ip) to SSHGuard whitelist"
    fi

    # Enable and start SSHGuard
    systemctl enable sshguard >>"$LOG_FILE" 2>&1
    systemctl restart sshguard >>"$LOG_FILE" 2>&1

    success "SSHGuard configured"
}

# Configure automatic updates
configure_auto_updates() {
    info "Configuring automatic security updates..."

    # Configure unattended-upgrades
    cat >/etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::DevRelease "false";
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::InstallOnShutdown "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF

    # Enable automatic updates
    cat >/etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF

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

    # Make permanent
    echo "/swapfile none swap sw 0 0" >>/etc/fstab

    # Optimize swappiness
    echo "vm.swappiness=10" >>/etc/sysctl.conf
    sysctl -p >>"$LOG_FILE" 2>&1

    success "Swap file created: ${swap_size}MB"
}


# Setup monitoring
setup_monitoring() {
    if [[ "$ENABLE_MONITORING" != "yes" ]]; then
        info "Skipping monitoring setup"
        return
    fi

    info "Setting up monitoring..."

    # Install netdata (optional)
    read -p "Install Netdata for real-time monitoring? [y/N]: " install_netdata
    if [[ "$install_netdata" =~ ^[Yy]$ ]]; then
        wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh >>"$LOG_FILE" 2>&1
        sh /tmp/netdata-kickstart.sh --dont-wait >>"$LOG_FILE" 2>&1

        # Configure netdata to bind only to localhost
        sed -i 's/# bind to = \*/bind to = 127.0.0.1/g' /etc/netdata/netdata.conf
        systemctl restart netdata >>"$LOG_FILE" 2>&1

        success "Netdata installed (accessible via SSH tunnel on port 19999)"
    fi
}

# Setup dotfiles
setup_dotfiles() {
    local target_user="${DEFAULT_USERNAME:-root}"
    local target_home="/home/$target_user"
    [[ "$target_user" == "root" ]] && target_home="/root"

    info "Setting up dotfiles for user: $target_user"

    # Clone dotfiles
    if [[ ! -d "$target_home/dotfiles" ]]; then
        sudo -u "$target_user" git clone https://github.com/natsumi/dotfiles.git "$target_home/dotfiles" >>"$LOG_FILE" 2>&1
    fi

    # Apply symlinks
    sudo -u "$target_user" bash "$target_home/dotfiles/bin/apply_symlinks" >>"$LOG_FILE" 2>&1

    # Install Prezto
    if [[ ! -d "$target_home/.zprezto" ]]; then
        sudo -u "$target_user" git clone --recursive https://github.com/sorin-ionescu/prezto.git "$target_home/.zprezto" >>"$LOG_FILE" 2>&1
        sudo -u "$target_user" git clone --recursive https://github.com/belak/prezto-contrib "$target_home/.zprezto/contrib" >>"$LOG_FILE" 2>&1
    fi

    # Install Zplug
    if [[ ! -d "$target_home/.zplug" ]]; then
        export ZPLUG_HOME="$target_home/.zplug"
        git clone https://github.com/zplug/zplug "$ZPLUG_HOME" >>"$LOG_FILE" 2>&1
        chown -R "$target_user:$target_user" "$ZPLUG_HOME"
    fi

    # Change shell to zsh
    chsh -s $(which zsh) "$target_user" >>"$LOG_FILE" 2>&1

    success "Dotfiles configured"
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
- Security Level: $SECURITY_LEVEL

User Configuration:
- Admin User: ${DEFAULT_USERNAME:-root}
- SSH Port: $DEFAULT_SSH_PORT

Security Features:
- Firewall: UFW (enabled)
- Fail2ban: Configured for SSH protection
- SSHGuard: Additional brute-force protection
- Automatic Updates: Enabled for security patches

Optional Features:
- Monitoring: $ENABLE_MONITORING
- Swap: Configured

Important Notes:
1. SSH is now on port $DEFAULT_SSH_PORT (not 22)
2. Password authentication is disabled - use SSH keys only
3. Root login is disabled
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
    configure_firewall
    configure_fail2ban
    configure_sshguard
    configure_auto_updates

    # System optimization
    create_swap

    # Optional features
    setup_monitoring

    # Development environment
    setup_dotfiles

    # Final steps
    perform_security_audit
    generate_summary

    echo
    success "VPS setup completed successfully!"
    echo
    warning "IMPORTANT: Test SSH on port $DEFAULT_SSH_PORT before closing this session!"
    echo
    info "Review the setup summary above and in: /root/vps-setup-summary.txt"
    echo
}

# Run main function
main "$@"
