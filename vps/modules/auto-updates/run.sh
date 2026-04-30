#
# Unattended Upgrades
#
# What it does:
#   - Writes /etc/apt/apt.conf.d/99-vps-upgrades drop-in (security-only origins,
#     no auto-reboot, kernel/dependency cleanup on)
#   - Enables the unattended-upgrades systemd unit
# Files written/touched:
#   - /etc/apt/apt.conf.d/99-vps-upgrades (drop-in; stock 50unattended-upgrades
#     and 20auto-upgrades remain untouched)
# Idempotent: yes — drop-in overwritten each run.
#

module_run() {
  cat >/etc/apt/apt.conf.d/99-vps-upgrades <<'CONF'
// Managed by vps-bootstrap.
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
APT::Periodic::Download-Upgradeable-Packages "1";
CONF

  run_step "Enabling unattended-upgrades" systemctl enable unattended-upgrades
  success "Auto-updates configured (security-only, no auto-reboot)"
}
