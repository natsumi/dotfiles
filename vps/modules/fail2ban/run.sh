#
# Fail2ban
#
# What it does:
#   - Renders the jail config to /etc/fail2ban/jail.d/vps.local from a
#     template (substitutes $SSH_PORT)
#   - Copies the traefik-* filters to /etc/fail2ban/filter.d/
#   - Enables and restarts fail2ban
# Files written/touched:
#   - /etc/fail2ban/jail.d/vps.local (drop-in; OS keeps stock jail.conf)
#   - /etc/fail2ban/filter.d/traefik-auth.conf
#   - /etc/fail2ban/filter.d/traefik-badbots.conf
#   - /etc/fail2ban/filter.d/traefik-ratelimit.conf
# Idempotent: yes — files overwritten each run; service restart is fine.
#

module_run() {
  local filter
  install -d -m 755 /etc/fail2ban/jail.d /etc/fail2ban/filter.d

  SSH_PORT="$SSH_PORT" envsubst \
    <"$MODULE_DIR/templates/vps.local.tmpl" \
    >/etc/fail2ban/jail.d/vps.local
  success "Wrote /etc/fail2ban/jail.d/vps.local"

  for filter in "$MODULE_DIR"/filters/*.conf; do
    cp "$filter" /etc/fail2ban/filter.d/
    info "Installed filter $(basename "$filter")"
  done

  run_step "Enabling fail2ban" systemctl enable fail2ban
  run_step "Restarting fail2ban" systemctl restart fail2ban
  success "Fail2ban active with SSH and Traefik jails"
}
