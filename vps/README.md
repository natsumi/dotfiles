# VPS Ubuntu 24.04 Setup Script

A comprehensive, security-focused setup script for Ubuntu 24.04 VPS servers with interactive configuration, automated hardening, and development environment setup.

## Quick Start

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh)"
```

## Features

### Security Hardening
- **SSH Hardening**: Custom port, key-only authentication, root login with key only (via drop-in at `/etc/ssh/sshd_config.d/99-hardening.conf`)
- **SSH Key Safety Gate**: Verifies authorized_keys exist before disabling password auth; prompts for public key if missing
- **Firewall**: UFW with strict default-deny incoming rules
- **Intrusion Prevention**: Fail2ban with SSH and Traefik jails
- **Automatic Updates**: Unattended security patches (via drop-in at `/etc/apt/apt.conf.d/99-vps-upgrades`)
- **Kernel Hardening**: sysctl network security settings (via drop-in at `/etc/sysctl.d/99-vps-hardening.conf`)
- **Security Audit**: Post-installation check for weak keys, default users, unnecessary services

### Development Environment
- **Shell**: Zsh
- **Editor**: Neovim (latest unstable)
- **Tools**: ripgrep, fd, fzf, bat, tig, tmux, btop, htop, and more
- **Version Control**: Git

### System Optimization
- **Swap File**: Automatic creation based on available RAM
- **Monitoring**: btop, htop, iotop, nethogs
- **Performance**: Optimized sysctl settings (swappiness, network security)

### User Experience
- **Interactive Setup**: All prompts collected upfront, then the entire setup runs unattended
- **Logging**: Full command traces always written to `~/vps_setup.log`
- **Backup**: Automatic backup of original configurations
- **Visible Progress**: Package installs show status lines on screen
- **Summary Report**: Post-installation summary with important notes

## Prerequisites

- Fresh Ubuntu 24.04 LTS installation
- Root access to the server
- SSH public key (script will prompt if not already on the server)

## Installation

### Method 1: One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh | sudo bash
```

### Method 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/natsumi/dotfiles.git
cd dotfiles/vps

# Run the setup script
sudo bash setup.sh
```

## Interactive Configuration

All prompts are collected upfront so the rest of the setup runs unattended:

1. **Admin Username** - Create a non-root sudo user (optional)
2. **Password** - Password for the new user (if creating one)
3. **Hostname** - Set server hostname
4. **SSH Port** - Custom SSH port (default: 22, validated 1-65535)
5. **Timezone** - Server timezone (default: America/Los_Angeles)
6. **SSH Public Key** - Prompted only if root has no authorized_keys (validated with ssh-keygen)
7. **Docker** - Optional Docker and Lazydocker installation

## Post-Installation

### Important First Steps

1. **Test SSH Connection**
   ```bash
   # From your local machine (not the server!)
   ssh -p YOUR_PORT username@your-server-ip
   ```

2. **Review Security Settings**
   ```bash
   # Check the setup summary
   cat /root/vps-setup-summary.txt

   # Monitor auth logs
   tail -f /var/log/auth.log
   ```

3. **Configure Your Domain**
   - Point your domain's A record to the server IP
   - Consider setting up reverse DNS

### File Locations

- **Setup Log**: `~/vps_setup.log` (includes full command traces)
- **Configuration Backup**: `~/vps-setup/backup/TIMESTAMP/`
- **Setup Summary**: `/root/vps-setup-summary.txt`

### Service Management

```bash
# Check firewall status
sudo ufw status verbose

# Check fail2ban status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# View blocked IPs
sudo iptables -L -n -v
```

## Customization

### Modifying Security Settings

#### Change SSH Port After Installation
```bash
# Edit the hardening drop-in
sudo nano /etc/ssh/sshd_config.d/99-hardening.conf
# Update UFW rules
sudo ufw delete allow OLD_PORT/tcp
sudo ufw allow NEW_PORT/tcp
# Restart SSH
sudo systemctl restart ssh
```

#### Whitelist IP Addresses
```bash
# For Fail2ban
sudo fail2ban-client set sshd addignoreip YOUR_IP_ADDRESS
```

### Adding Custom Software

The script is modular. To add custom software:

1. Edit `setup.sh`
2. Add your packages to the `install_base_packages()` function
3. Or create a new function and call it from `main()`

## Troubleshooting

### Locked Out of SSH

If you're locked out:

1. Use your VPS provider's console access
2. Check fail2ban: `fail2ban-client set sshd unbanip YOUR_IP`
3. Review `/var/log/auth.log` for issues

### Script Fails During Installation

1. Check the log file: `~/vps_setup.log` (includes full command traces for debugging)
2. Original configs are backed up in `~/vps-setup/backup/*/`
3. Re-run the script - it's designed to be idempotent
4. Check the last few lines of the log:
   ```bash
   tail -50 ~/vps_setup.log
   ```

### High Memory Usage

- Check if swap is enabled: `free -h`
- Adjust swappiness: `sysctl vm.swappiness=10`
- Consider upgrading your VPS plan

## Security Best Practices

1. **Regular Updates**
   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. **Monitor Logs**
   ```bash
   # Check for failed login attempts
   grep "Failed password" /var/log/auth.log

   # Check fail2ban activity
   grep "Ban" /var/log/fail2ban.log
   ```

3. **Backup Your Data**
   - Set up regular backups of important data
   - Test restore procedures

4. **Use Strong SSH Keys**
   - Minimum 4096-bit RSA or Ed25519
   - Use passphrase protection
   - Rotate keys periodically

5. **Principle of Least Privilege**
   - Don't run services as root
   - Use sudo instead of root login
   - Limit user permissions
