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

  # ── Build human-readable summary ─────────────────────────────────
  {
    printf "vps-bootstrap summary\n"
    printf "=====================\n"
    printf "date:           %s\n" "$(date -Is)"
    printf "hostname:       %s\n" "$(hostname)"
    printf "Ubuntu:         %s (%s)\n" "$UBUNTU_VERSION_ID" "$UBUNTU_CODENAME"
    printf "admin user:     %s\n" "${USERNAME:-[none — root only]}"
    printf "SSH port:       %s\n" "$SSH_PORT"
    printf "timezone:       %s\n" "$TIMEZONE"
    printf "Docker:         %s\n" "$INSTALL_DOCKER"
    printf "reboot needed:  %s\n" "$reboot_needed"
    printf "log file:       %s\n" "$LOG_FILE"
    printf "\n"
    printf "Modules executed (id : seconds)\n"
    # %s form avoids printf parsing a leading '-' as an option flag.
    printf "%s\n" "-------------------------------"
    for entry in "${SELECTED[@]}"; do
      local id="${entry%%|*}"
      printf "  %-15s %s\n" "$id" "${STEP_TIMINGS[$id]:-?}"
    done
    printf "\n"
    printf "Important next steps\n"
    printf "%s\n" "--------------------"
    printf "  1. Open a NEW terminal and verify SSH works on the new port:\n"
    printf "       ssh -p %s %s@<host>\n" "$SSH_PORT" "${USERNAME:-root}"
    printf "     Do NOT close this session until you've confirmed.\n"
    if [[ "$reboot_needed" == "yes" ]]; then
      printf "  2. Reboot when convenient: sudo reboot\n"
    fi
  } | tee "$summary" >/dev/null

  # ── Stamp file ───────────────────────────────────────────────────
  {
    printf "date=%s\n" "$(date -Is)"
    printf "hostname=%s\n" "$(hostname)"
    printf "version=%s\n" "$UBUNTU_VERSION_ID"
    printf "ssh_port=%s\n" "$SSH_PORT"
    printf "user=%s\n" "${USERNAME:-}"
  } >"$stamp"

  success "Summary written: $summary"
  success "Stamp written:   $stamp"
  info "Log file:        $LOG_FILE"

  # Echo summary to stdout colorized.
  printf "\n%s━━ Summary ━━%s\n" "$C_BOLD$C_CYAN" "$C_RESET"
  cat "$summary"
}
