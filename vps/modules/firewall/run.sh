#
# UFW Firewall
#
# What it does:
#   - Resets UFW to defaults (force)
#   - Default-deny incoming, default-allow outgoing
#   - Allows $SSH_PORT/tcp, 80/tcp, 443/tcp
#   - Enables UFW
# Files written/touched:
#   - /etc/ufw/* (managed by ufw)
# Idempotent: yes — reset + reconfigure on each run.
#

module_run() {
  run_step "Resetting UFW" ufw --force reset
  run_step "Default deny incoming" ufw default deny incoming
  run_step "Default allow outgoing" ufw default allow outgoing
  run_step "Allowing SSH ($SSH_PORT/tcp)" ufw allow "$SSH_PORT/tcp" comment 'SSH (vps-bootstrap)'
  run_step "Allowing HTTP (80/tcp)"  ufw allow 80/tcp  comment 'HTTP (vps-bootstrap)'
  run_step "Allowing HTTPS (443/tcp)" ufw allow 443/tcp comment 'HTTPS (vps-bootstrap)'
  run_step "Enabling UFW" ufw --force enable
  success "Firewall enabled with SSH on $SSH_PORT, plus 80 and 443"
}
