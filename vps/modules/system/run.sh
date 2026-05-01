#
# System Settings — hostname and timezone
#
# What it does:
#   - Sets hostname via hostnamectl
#   - Updates /etc/hosts so 127.0.1.1 resolves to the new hostname
#   - Sets timezone via timedatectl
# Files written/touched:
#   - /etc/hostname (via hostnamectl)
#   - /etc/hosts (in-place edit; original backed up)
#   - /etc/timezone, /etc/localtime (via timedatectl)
# Idempotent: yes — skips if already at desired values.
#

module_run() {
  local backup_dir="${INVOKED_FROM:-$PWD}/vps-bootstrap-backup"
  mkdir -p "$backup_dir"

  # ── Hostname ─────────────────────────────────────────────────────
  local cur_host
  cur_host=$(hostname)
  if [[ "$HOSTNAME" != "$cur_host" ]]; then
    info "Setting hostname: $cur_host → $HOSTNAME"
    cp /etc/hosts "$backup_dir/hosts.$(date +%H%M%S)"
    hostnamectl set-hostname "$HOSTNAME"
    if grep -qE '^127\.0\.1\.1\b' /etc/hosts; then
      sed -i -E "s/^127\.0\.1\.1\b.*/127.0.1.1\t$HOSTNAME/" /etc/hosts
    else
      printf "127.0.1.1\t%s\n" "$HOSTNAME" >>/etc/hosts
    fi
    success "Hostname is now $HOSTNAME"
  else
    success "Hostname unchanged ($cur_host)"
  fi

  # ── Timezone ─────────────────────────────────────────────────────
  local cur_tz
  cur_tz=$(timedatectl show -p Timezone --value 2>/dev/null || echo UTC)
  if [[ "$TIMEZONE" != "$cur_tz" ]]; then
    info "Setting timezone: $cur_tz → $TIMEZONE"
    timedatectl set-timezone "$TIMEZONE"
    success "Timezone is now $TIMEZONE"
  else
    success "Timezone unchanged ($cur_tz)"
  fi
}
