# vps/manifest.sh — ordered list of modules.
# Each entry: "<id>|<Display Name>". Order is the array order.
# Sourced by main.sh.

# shellcheck disable=SC2034
MODULES=(
  # "apt-mirror|APT Mirror Configuration"  # disabled — re-enable if you want the Pilot Fiber mirror
  "system|System Settings (hostname, timezone)"
  "update|System Update"
  "packages|Base Packages"
  # "neovim|Neovim (stable PPA)" # disabled
  "user|Admin User & Sudo"
  "ssh|SSH Hardening"
  "firewall|UFW Firewall"
  "fail2ban|Fail2ban"
  "auto-updates|Unattended Upgrades"
  "sysctl|Kernel & Network Hardening"
  "swap|Swap File"
  "docker|Docker Engine"
  "audit|Security Audit"
  "summary|Setup Summary"
)
