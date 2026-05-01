# vps/lib/preflight.sh — checks that must pass before prompts and modules run.
# Sourced by main.sh.
#
# Public function:
#   run_preflight — runs every check; calls die() on the first failure.
#
# Side effects on success:
#   - Creates /run/vps-bootstrap.lock (removed by main.sh's EXIT trap)
#   - Sets UBUNTU_VERSION_ID and UBUNTU_CODENAME shell vars

SUPPORTED_UBUNTU=("24.04" "26.04")
LOCKFILE="/run/vps-bootstrap.lock"

_check_root() {
  info "Checking for root..."
  if (( EUID != 0 )); then
    die "This script must be run as root (try: sudo bash ...)"
  fi
  success "Running as root"
}

_check_bash() {
  info "Checking bash version..."
  if (( BASH_VERSINFO[0] < 4 )); then
    die "Bash 4+ required (found $BASH_VERSION)"
  fi
  success "Bash $BASH_VERSION"
}

_check_os() {
  info "Checking OS..."
  if [[ ! -r /etc/os-release ]]; then
    die "Cannot read /etc/os-release — unsupported OS"
  fi
  # shellcheck source=/dev/null
  . /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    die "Only Ubuntu is supported (found ID=${ID:-unknown})"
  fi
  local supported=0 v
  for v in "${SUPPORTED_UBUNTU[@]}"; do
    if [[ "${VERSION_ID:-}" == "$v" ]]; then
      supported=1
      break
    fi
  done
  if (( supported == 0 )); then
    die "Unsupported Ubuntu version ${VERSION_ID:-unknown} (supported: ${SUPPORTED_UBUNTU[*]})"
  fi
  UBUNTU_VERSION_ID="$VERSION_ID"
  UBUNTU_CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  export UBUNTU_VERSION_ID UBUNTU_CODENAME
  success "Ubuntu ${UBUNTU_VERSION_ID} (${UBUNTU_CODENAME})"
}

_check_internet() {
  info "Checking internet..."
  if ! curl -fsS --max-time 5 https://github.com >/dev/null 2>&1; then
    die "Cannot reach github.com — check network/DNS/firewall"
  fi
  success "Internet reachable"
}

_check_disk() {
  info "Checking disk space..."
  local mb
  mb=$(df -m --output=avail /var | tail -1 | tr -d ' ')
  if (( mb < 2048 )); then
    die "Need at least 2GB free on /var (found ${mb}MB)"
  fi
  success "/var has ${mb}MB free"
}

_check_lockfile() {
  info "Checking for concurrent runs..."
  if ! mkdir "$LOCKFILE" 2>/dev/null; then
    die "Lockfile $LOCKFILE exists — another bootstrap may be running. \
Remove the directory if you're sure no other instance is active."
  fi
  success "Acquired lock $LOCKFILE"
}

_check_prior_run() {
  local stamp="${INVOKED_FROM:-$PWD}/vps-bootstrap.stamp"
  if [[ -f "$stamp" ]]; then
    warn "Found prior run record: $stamp"
    grep -E '^(date|hostname|version)=' "$stamp" 2>/dev/null | sed 's/^/    /'
    if ! ask_yn "Re-running will reapply all configuration. Continue?" "N"; then
      die "Aborted by user"
    fi
  fi
}

run_preflight() {
  info "Running preflight checks..."
  _check_root
  _check_bash
  _check_os
  _check_internet
  _check_disk
  _check_lockfile
  _check_prior_run
  success "Preflight passed"
}
