#
# Kernel & Network Hardening (sysctl)
#
# What it does:
#   - Installs /etc/sysctl.d/99-vps-hardening.conf
#   - Reloads sysctl from drop-ins
# Files written/touched:
#   - /etc/sysctl.d/99-vps-hardening.conf (drop-in)
# Idempotent: yes — file overwritten each run.
#

module_run() {
  install -m 644 "$MODULE_DIR/files/99-vps-hardening.conf" \
    /etc/sysctl.d/99-vps-hardening.conf

  run_step "Applying sysctl drop-ins" sysctl --system
  success "Kernel/network hardening applied"
}
