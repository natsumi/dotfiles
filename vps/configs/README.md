# VPS Configuration Files

This directory contains configuration templates and files used by the VPS setup script.

## Files

### ubuntu.sources
APT sources configuration for Ubuntu 24.04 using Pilot Fiber mirror.

### docker-daemon.json
Docker daemon configuration with security and performance optimizations.

### sshd_config.template
SSH server configuration template. Placeholders:
- `{{SSH_PORT}}` - Custom SSH port
- `{{USERNAME}}` - Username for SSH access

### jail.local.template
Fail2ban jail configuration template for Traefik. Placeholders:
- `{{SSH_PORT}}` - SSH port for SSH jails

### fail2ban-filters/
Directory containing custom Fail2ban filters for Traefik:
- `traefik-auth.conf` - Filter for 401/403 authentication failures
- `traefik-ratelimit.conf` - Filter for 429 rate limit responses
- `traefik-badbots.conf` - Filter for bad bots and scanners

### sshguard.conf.template
SSHGuard configuration template.

### sshguard-whitelist.template
SSHGuard whitelist template. Placeholders:
- `{{USER_IP}}` - Current user's IP address

### 50unattended-upgrades
Unattended upgrades configuration for automatic security updates.

### 20auto-upgrades
APT periodic update configuration.

## Usage

These files are automatically used by the VPS setup script. The script will:
1. Copy static configuration files directly
2. Process template files to replace placeholders with actual values
3. Install files to their appropriate system locations