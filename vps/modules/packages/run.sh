#
# Base Packages
#
# What it does:
#   - Reads $MODULE_DIR/packages.list (one package per line; # comments ignored)
#   - Filters out unavailable packages with a warning
#   - Bulk-installs the rest with apt-get install
# Files written/touched:
#   - /var/lib/dpkg, /var/cache/apt (managed by apt)
# Idempotent: yes (apt skips already-installed packages)
#

module_run() {
  export DEBIAN_FRONTEND=noninteractive

  local list="$MODULE_DIR/packages.list"
  if [[ ! -f "$list" ]]; then
    die "Package list not found: $list"
  fi

  local requested=() available=()
  while IFS= read -r line; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -n "$line" ]] && requested+=("$line")
  done <"$list"

  info "Filtering ${#requested[@]} requested packages by availability..."
  for pkg in "${requested[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      available+=("$pkg")
    else
      warn "Package not available: $pkg (skipping)"
    fi
  done

  if (( ${#available[@]} == 0 )); then
    die "No installable packages found"
  fi

  run_step "Installing ${#available[@]} packages" \
    apt-get install -y -q "${available[@]}"
}
