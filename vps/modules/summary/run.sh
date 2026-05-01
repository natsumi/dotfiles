#
# Setup Summary
#
# What it does:
#   - Writes ./vps-bootstrap-summary.txt (cwd) — human-readable summary
#   - Writes ./vps-bootstrap.stamp (cwd) — key=value, used by preflight's
#     prior-run detection on subsequent runs
#   - Prints the same content (colorized) to stdout
# Files written/touched:
#   - ./vps-bootstrap-summary.txt
#   - ./vps-bootstrap.stamp
# Idempotent: yes — files overwritten each run.
#

# shellcheck disable=SC2154
module_run() {
  local out_dir="${INVOKED_FROM:-$PWD}"
  local summary="$out_dir/vps-bootstrap-summary.txt"
  local stamp="$out_dir/vps-bootstrap.stamp"

  local reboot_needed="no"
  [[ -f /var/run/reboot-required ]] && reboot_needed="yes"

  # Per-module timing rows, built into a single string for the heredoc.
  local timings="" entry id
  for entry in "${SELECTED[@]}"; do
    id="${entry%%|*}"
    timings+=$(printf "  %-15s %s\n" "$id" "${STEP_TIMINGS[$id]:-?}")
    timings+=$'\n'
  done

  local reboot_hint=""
  if [[ "$reboot_needed" == "yes" ]]; then
    reboot_hint=$'\n  2. Reboot when convenient: sudo reboot'
  fi

  # ── Write the human-readable summary ─────────────────────────────
  cat >"$summary" <<EOF
vps-bootstrap summary
=====================
date:           $(date -Is)
hostname:       $(hostname)
Ubuntu:         $UBUNTU_VERSION_ID ($UBUNTU_CODENAME)
admin user:     ${USERNAME:-[none — root only]}
SSH port:       $SSH_PORT
timezone:       $TIMEZONE
Docker:         $INSTALL_DOCKER
reboot needed:  $reboot_needed
log file:       $LOG_FILE

Modules executed (id : seconds)
-------------------------------
${timings%$'\n'}

Important next steps
--------------------
  1. Open a NEW terminal and verify SSH works on the new port:
       ssh -p $SSH_PORT ${USERNAME:-root}@<host>
     Do NOT close this session until you've confirmed.${reboot_hint}
EOF

  # ── Write the stamp file (key=value) ─────────────────────────────
  cat >"$stamp" <<EOF
date=$(date -Is)
hostname=$(hostname)
version=$UBUNTU_VERSION_ID
ssh_port=$SSH_PORT
user=${USERNAME:-}
EOF

  # Echo the summary to the terminal, then announce the artifacts.
  printf "\n%s━━ Summary ━━%s\n" "$C_BOLD$C_CYAN" "$C_RESET"
  cat "$summary"
  printf "\n"

  success "Summary written: $summary"
  success "Stamp written:   $stamp"
  info "Log file:        $LOG_FILE"
}
