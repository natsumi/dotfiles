#
# APT Mirror Configuration
#
# What it does:
#   - Replaces /etc/apt/sources.list.d/ubuntu.sources with the Pilot Fiber
#     mirror, templated by the Ubuntu codename ($UBUNTU_CODENAME).
# Files written/touched:
#   - /etc/apt/sources.list.d/ubuntu.sources (replaced; original backed up)
# Idempotent: yes — overwrites the file on every run.
#
# shellcheck disable=SC2154

module_run() {
  local target=/etc/apt/sources.list.d/ubuntu.sources
  local backup_dir="${PWD}/vps-bootstrap-backup"
  mkdir -p "$backup_dir"

  if [[ -f "$target" ]]; then
    cp "$target" "$backup_dir/ubuntu.sources.$(date +%H%M%S)"
    info "Backed up existing $target"
  fi

  envsubst <"$MODULE_DIR/templates/ubuntu.sources.tmpl" >"$target"
  success "Configured Pilot Fiber mirror for $UBUNTU_CODENAME"
}
