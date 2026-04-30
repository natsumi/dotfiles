# shellcheck disable=SC2154
#
# Security Audit (read-only)
#
# What it does:
#   - Warns about default users (pi, ubuntu, debian) if present
#   - Warns about weak SSH keys (RSA < 2048 bits)
#   - Warns about unnecessary services running (telnet, rsh, etc.)
# Files written/touched:
#   - none
# Idempotent: yes — read-only.
#

module_run() {
  local u home auth key bits svc
  local homes=(/root)
  local svcs=(telnet rsh-server rlogin vsftpd)

  # ── Default users ────────────────────────────────────────────────
  for u in pi ubuntu debian; do
    if id "$u" >/dev/null 2>&1; then
      warn "Default user '$u' exists — consider removing"
    fi
  done

  # ── Weak SSH keys (root + admin user) ────────────────────────────
  [[ -n "$USERNAME" ]] && homes+=("/home/$USERNAME")
  for home in "${homes[@]}"; do
    auth="$home/.ssh/authorized_keys"
    [[ -s "$auth" ]] || continue
    while IFS= read -r key; do
      [[ "$key" =~ ssh-rsa ]] || continue
      bits=$(printf "%s" "$key" | ssh-keygen -l -f - 2>/dev/null | awk '{print $1}') || continue
      if [[ "$bits" =~ ^[0-9]+$ ]] && (( bits < 2048 )); then
        warn "Weak RSA key ($bits bits) in $auth"
      fi
    done <"$auth"
  done

  # ── Unnecessary services ─────────────────────────────────────────
  for svc in "${svcs[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
      warn "Unnecessary service running: $svc"
    fi
  done

  success "Audit complete"
}
