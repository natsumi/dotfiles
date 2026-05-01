# shellcheck disable=SC2154
#
# SSH Hardening
#
# What it does:
#   - Refuses to run if no authorized_keys exist anywhere (key safety gate)
#   - Disables /etc/ssh/sshd_config.d/50-cloud-init.conf if present (it
#     re-enables PasswordAuthentication on cloud images)
#   - Renders /etc/ssh/sshd_config.d/99-vps-hardening.conf from
#     $MODULE_DIR/files/99-hardening.conf (template; uses envsubst)
#   - Validates with `sshd -t`. On failure: removes the drop-in, restores
#     the cloud-init drop-in, dies.
#   - Restarts ssh.
# Files written/touched:
#   - /etc/ssh/sshd_config.d/99-vps-hardening.conf (drop-in)
#   - /etc/ssh/sshd_config.d/50-cloud-init.conf (renamed to .disabled if present)
#   - /etc/issue.net (pre-login banner referenced by the drop-in)
# Idempotent: yes — drop-in is overwritten each run.
#

module_run() {
  # ── Safety gate: don't disable password auth without keys ────────
  local have_keys=0
  [[ -s /root/.ssh/authorized_keys ]] && have_keys=1
  if [[ -n "$USERNAME" ]] && [[ -s "/home/$USERNAME/.ssh/authorized_keys" ]]; then
    have_keys=1
  fi
  if (( have_keys == 0 )); then
    die "SSH key safety: no authorized_keys found. Refusing to disable password auth."
  fi

  # ── Disable cloud-init drop-in if present (track per-run so rollback
  # only resurrects what THIS run disabled) ────────────────────────
  local disabled_this_run=0
  if [[ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]]; then
    mv /etc/ssh/sshd_config.d/50-cloud-init.conf \
       /etc/ssh/sshd_config.d/50-cloud-init.conf.disabled
    disabled_this_run=1
    info "Disabled /etc/ssh/sshd_config.d/50-cloud-init.conf"
  fi

  # ── Render the hardening drop-in ─────────────────────────────────
  local drop_in=/etc/ssh/sshd_config.d/99-vps-hardening.conf
  local allow_users="root"
  if [[ -n "$USERNAME" ]]; then
    allow_users="root $USERNAME"
  fi

  SSH_PORT="$SSH_PORT" ALLOW_USERS="$allow_users" \
    envsubst <"$MODULE_DIR/files/99-hardening.conf" >"$drop_in"

  # ── Write the pre-login banner referenced by the drop-in ─────────
  # Short legal/contact notice. Empty file would be treated as no
  # banner; this gives mass-scanners a clear "go away" page.
  cat >/etc/issue.net <<'BANNER'
**********************************************************************
This system is for authorized use only. Activity may be monitored and
recorded. Disconnect now if you are not an authorized user.
**********************************************************************
BANNER

  # ── Validate, then restart (rollback on failure) ─────────────────
  if ! sshd -t 2>>"$LOG_FILE"; then
    rm -f "$drop_in"
    if (( disabled_this_run )); then
      mv /etc/ssh/sshd_config.d/50-cloud-init.conf.disabled \
         /etc/ssh/sshd_config.d/50-cloud-init.conf
      die "sshd config validation failed — drop-in removed, cloud-init drop-in restored"
    fi
    die "sshd config validation failed — drop-in removed"
  fi

  run_step "Restarting ssh" systemctl restart ssh
  success "SSH hardened on port $SSH_PORT (users: $allow_users)"

  # Resolve the server's public IPv4 by asking the kernel which source
  # address it would use to reach 1.1.1.1. Works on any VPS with a
  # default route. Falls back to "<host>" if anything goes wrong.
  local server_ip
  server_ip=$(ip route get 1.1.1.1 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
  warn "Reconnect with: ssh -p $SSH_PORT ${USERNAME:-root}@${server_ip:-<host>}"
}
