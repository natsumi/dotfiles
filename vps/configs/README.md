# VPS Configuration Files

This directory contains configuration templates and files used by the VPS setup script, organized by service.

## Directory Structure

```
configs/
├── apt/                         # APT package manager configurations
│   ├── ubuntu.sources          # APT sources for Ubuntu 24.04
│   └── unattended-upgrades/    # Automatic security updates
│       ├── 20auto-upgrades     # APT periodic update configuration
│       └── 50unattended-upgrades # Unattended upgrades configuration
├── docker/                      # Docker configurations
│   └── daemon.json             # Docker daemon settings
└── fail2ban/                    # Fail2ban intrusion prevention
    ├── jail.local.template     # Jail configuration (with placeholders)
    └── filters/                # Custom filter definitions
        ├── traefik-auth.conf   # Filter for 401/403 auth failures
        ├── traefik-badbots.conf # Filter for bad bots and scanners
        └── traefik-ratelimit.conf # Filter for 429 rate limit responses
```

## Service Configurations

### APT (`apt/`)
- **ubuntu.sources**: Configures APT to use Pilot Fiber mirror for better performance
- **unattended-upgrades/**: Automatic security updates configuration
  - `50unattended-upgrades`: Defines which updates to install automatically
  - `20auto-upgrades`: Enables periodic package list updates and upgrades

### Docker (`docker/`)
- **daemon.json**: Docker daemon configuration with:
  - Log rotation settings
  - Storage driver optimization
  - Live restore for container uptime
  - Disabled userland proxy for performance

### Fail2ban (`fail2ban/`)
- **jail.local.template**: Main jail configuration for SSH and Traefik services
  - Placeholder: `{{SSH_PORT}}` - Custom SSH port
- **filters/**: Custom Traefik-specific filters
  - `traefik-auth.conf`: Detects authentication failures (401/403)
  - `traefik-ratelimit.conf`: Detects rate limiting (429)
  - `traefik-badbots.conf`: Detects malicious bots and vulnerability scanners

### SSH

SSH hardening is not managed via config files in this directory. Instead, the setup script writes a drop-in override to `/etc/ssh/sshd_config.d/99-hardening.conf`, preserving the system's default `sshd_config` and only overriding security-relevant directives.

## Template Processing

The fail2ban `jail.local.template` contains a placeholder that is replaced during setup:
- `{{SSH_PORT}}` - Replaced with the configured SSH port

The setup script uses `sed` to process this template and generate the final configuration file.

## Usage

These files are automatically used by the VPS setup script (`vps/setup.sh`). The script will:
1. Check for the existence of the configuration directory
2. Copy static configuration files directly to system locations
3. Process template files to replace placeholders with actual values
4. Install processed files to their appropriate system locations
5. Set proper permissions and ownership

## Customization

To customize configurations for your environment:
1. Edit the configuration files in their respective service directories
2. For template files, you can modify the base configuration while keeping placeholders
3. Run the setup script to apply your customized configurations