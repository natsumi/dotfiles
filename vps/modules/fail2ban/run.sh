#
# Fail2ban
#
# What it does:
#   - Renders the jail config to /etc/fail2ban/jail.d/vps.local from a
#     template (substitutes $SSH_PORT)
#   - Enables and restarts fail2ban
# Files written/touched:
#   - /etc/fail2ban/jail.d/vps.local (drop-in; OS keeps stock jail.conf)
# Idempotent: yes — file overwritten each run; service restart is fine.
#

module_run() {
  install -d -m 755 /etc/fail2ban/jail.d

  SSH_PORT="$SSH_PORT" envsubst \
    <"$MODULE_DIR/templates/vps.local.tmpl" \
    >/etc/fail2ban/jail.d/vps.local
  success "Wrote /etc/fail2ban/jail.d/vps.local"

  run_step "Enabling fail2ban" systemctl enable fail2ban
  run_step "Restarting fail2ban" systemctl restart fail2ban
  success "Fail2ban active with sshd + recidive jails"
}
