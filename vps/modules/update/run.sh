#
# System Update
#
# What it does:
#   - apt-get update
#   - apt-get upgrade (best-effort: warn on failure, don't abort)
#   - apt-get autoremove (best-effort)
# Files written/touched:
#   - none directly (apt does the work)
# Idempotent: yes (re-running is safe and a no-op if already up to date)
#

module_run() {
  export DEBIAN_FRONTEND=noninteractive

  run_step "Updating package lists" apt-get update -y -q
  run_step "Upgrading installed packages" apt-get upgrade -y -q || \
    warn "Some packages failed to upgrade (continuing — see log for details)"
  run_step "Removing unused packages" apt-get autoremove -y -q || true
}
