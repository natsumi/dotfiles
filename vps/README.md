# VPS Ubuntu 24.04 Setup Script

A comprehensive, security-focused setup script for Ubuntu 24.04 VPS servers with interactive configuration, automated hardening, and development environment setup.

## Quick Start

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh)"

```

## Features

### 🔒 Security Hardening
- **SSH Hardening**: Custom port, key-only authentication, disable root login
- **Firewall**: UFW with strict rules and rate limiting
- **Intrusion Prevention**: Fail2ban + SSHGuard dual protection
- **Automatic Updates**: Unattended security patches
- **Security Audit**: Post-installation security check

### 🛠️ Development Environment
- **Shell**: Zsh with Prezto and Zplug
- **Editor**: Neovim (latest unstable)
- **Tools**: ripgrep, fd, fzf, bat, tig, tmux, htop, and more
- **Version Control**: Git with diff-so-fancy and scmpuff
- **Dotfiles**: Automatic setup from this repository

### 📊 System Optimization
- **Swap File**: Automatic creation based on available RAM
- **Monitoring**: Optional btop and Netdata installation
- **Performance**: Optimized sysctl settings

### 🎯 User Experience
- **Interactive Setup**: Guided configuration with sensible defaults
- **Logging**: Comprehensive setup logs for troubleshooting
- **Backup**: Automatic backup of original configurations
- **Summary Report**: Post-installation summary with important notes

## Prerequisites

- Fresh Ubuntu 24.04 LTS installation
- Root access to the server
- SSH key authentication configured (recommended)
- Basic understanding of Linux administration

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

During installation, you'll be prompted for:

1. **Admin Username** - Create a non-root sudo user (optional)
2. **Hostname** - Set server hostname
3. **SSH Port** - Custom SSH port (default: 2222)
4. **System Monitoring** - Enable additional monitoring tools (default: yes)

The script automatically uses **Enhanced** security settings with optimal security configurations.

## Security Features

The script automatically configures **Enhanced** security settings that include:

- **SSH Hardening**: Custom port, key-only authentication, disabled root login
- **UFW Firewall**: Strict rules with rate limiting for SSH connections
- **Fail2ban**: SSH protection with automatic IP banning
- **SSHGuard**: Additional brute-force protection layer
- **Automatic Updates**: Unattended security patches
- **Extended Fail2ban Jails**: Protection against various attack types

## Post-Installation

### Important First Steps

1. **Test SSH Connection**
   ```bash
   # From your local machine (not the server!)
   ssh -p 2222 username@your-server-ip
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

- **Setup Log**: `./vps-setup-TIMESTAMP.log` (in current directory, or `/tmp/` if not writable)
- **Configuration Backup**: `/root/server-setup-backup-TIMESTAMP/`
- **Setup Summary**: `/root/vps-setup-summary.txt`
- **Dotfiles**: `~/dotfiles/`

### Service Management

```bash
# Check firewall status
sudo ufw status verbose

# Check fail2ban status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Check SSHGuard status
sudo systemctl status sshguard

# View blocked IPs
sudo iptables -L -n -v
```

## Customization

### Modifying Security Settings

#### Change SSH Port After Installation
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
# Update UFW rules
sudo ufw delete allow 2222/tcp
sudo ufw allow NEW_PORT/tcp
# Restart SSH
sudo systemctl restart sshd
```

#### Whitelist IP Addresses
```bash
# For SSHGuard
echo "YOUR_IP_ADDRESS" | sudo tee -a /etc/sshguard/whitelist
sudo systemctl restart sshguard

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
3. Check SSHGuard: `iptables -D sshguard -s YOUR_IP -j DROP`
4. Review `/var/log/auth.log` for issues

### Script Fails During Installation

1. Check the log file: `./vps-setup-*.log` (in the directory where you ran the script)
2. Original configs are backed up in `/root/server-setup-backup-*/`
3. Re-run the script - it's designed to be idempotent
4. Run with debug mode for more details:
   ```bash
   # Show all commands being executed
   DEBUG=1 sudo bash /path/to/setup.sh

   # Or run without strict error checking to see exactly where it fails
   sudo bash -c 'set +e; bash /path/to/setup.sh'

   # Check the last few lines of the log
   tail -50 ./vps-setup-*.log
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

## Contributing

Feel free to submit issues and enhancement requests!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Ubuntu security guides and best practices
- Fail2ban and SSHGuard communities
- The broader open-source security community

## Support

For issues specific to this script:
- Open an issue on GitHub
- Check existing issues for solutions

For general Ubuntu/VPS help:
- [Ubuntu Forums](https://ubuntuforums.org/)
- [Ask Ubuntu](https://askubuntu.com/)
- Your VPS provider's documentation
