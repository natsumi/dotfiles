#
# Swap File
#
# What it does:
#   - Skips if any swap is already active
#   - Sizes the swap as: min(2*RAM, 4096MB) when RAM < 2GB, else 4096MB
#   - Creates /swapfile, sets perms 600, mkswap, swapon
#   - Adds to /etc/fstab if not already present
# Files written/touched:
#   - /swapfile (created)
#   - /etc/fstab (line appended if missing)
# Idempotent: yes — checks before doing.
#

module_run() {
  if (( $(swapon --noheadings | wc -l) > 0 )); then
    info "Swap already active — skipping"
    return 0
  fi

  local total_mb size_mb
  total_mb=$(awk '/^MemTotal:/ {print int($2/1024)}' /proc/meminfo)
  if (( total_mb < 2048 )); then
    size_mb=$((total_mb * 2))
  else
    size_mb=4096
  fi

  info "Creating ${size_mb}MB swap (RAM: ${total_mb}MB)..."
  # fallocate fails on ZFS and some btrfs configs. Treat as best-effort:
  # warn and skip rather than aborting the whole bootstrap.
  if ! run_step "Allocating /swapfile" fallocate -l "${size_mb}M" /swapfile; then
    warn "fallocate failed (zfs/btrfs?) — skipping swap"
    rm -f /swapfile
    return 0
  fi
  chmod 600 /swapfile
  run_step "Formatting swap" mkswap /swapfile
  run_step "Activating swap" swapon /swapfile

  if ! grep -qE '^\s*/swapfile\b' /etc/fstab; then
    printf "/swapfile none swap sw 0 0\n" >>/etc/fstab
    info "Added /swapfile to /etc/fstab"
  fi

  success "Swap active (${size_mb}MB)"
}
