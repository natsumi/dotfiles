#!/usr/bin/env bash
# vps/install.sh — bootstrap entrypoint.
# Designed for `curl ... | sudo bash` invocation.
# Verifies prerequisites, sparse-clones the repo, and execs main.sh.

set -euo pipefail

REPO_DEFAULT="https://github.com/natsumi/dotfiles"
BRANCH_DEFAULT="main"

REPO="${REPO:-$REPO_DEFAULT}"
BRANCH="${BRANCH:-$BRANCH_DEFAULT}"

# ── Parse --branch from args (env var still wins if both set) ──────
ARGS=()
while (( $# > 0 )); do
  case "$1" in
    --branch) BRANCH="$2"; ARGS+=("--branch" "$2"); shift 2 ;;
    *)        ARGS+=("$1"); shift ;;
  esac
done

# ── Inline color setup (lib/ui.sh isn't available yet) ─────────────
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'; C_RED=$'\033[0;31m'; C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[1;33m'; C_BLUE=$'\033[0;34m'
else
  C_RESET=''; C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''
fi
log_info()  { printf "%sℹ%s %s\n" "$C_BLUE" "$C_RESET" "$*"; }
log_ok()    { printf "%s✓%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
log_warn()  { printf "%s⚠%s %s\n" "$C_YELLOW" "$C_RESET" "$*" >&2; }
log_die()   { printf "%s✗%s %s\n" "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# ── Prereqs ────────────────────────────────────────────────────────
(( EUID == 0 )) || log_die "Run as root (try: sudo bash)"

if [[ ! -r /etc/os-release ]]; then
  log_die "Cannot read /etc/os-release — unsupported OS"
fi
# shellcheck source=/dev/null
. /etc/os-release
case "${ID:-}:${VERSION_ID:-}" in
  ubuntu:24.04|ubuntu:26.04) ;;
  *) log_die "Only Ubuntu 24.04 and 26.04 are supported (found ${ID:-?}:${VERSION_ID:-?})" ;;
esac

if ! curl -fsS --max-time 5 https://github.com >/dev/null 2>&1; then
  log_die "Cannot reach github.com — check network/DNS"
fi

# ── Install minimal deps if missing ────────────────────────────────
need=()
for cmd in git curl envsubst; do
  command -v "$cmd" >/dev/null 2>&1 || need+=("$cmd")
done
if (( ${#need[@]} > 0 )); then
  log_info "Installing missing dependencies: ${need[*]}"
  apt-get update -qq
  # envsubst lives in gettext-base
  local_pkgs=()
  for c in "${need[@]}"; do
    case "$c" in
      envsubst) local_pkgs+=("gettext-base") ;;
      *)        local_pkgs+=("$c") ;;
    esac
  done
  apt-get install -y -q "${local_pkgs[@]}"
fi

# ── Clone repo (sparse, just vps/) ─────────────────────────────────
TMP=$(mktemp -d /tmp/vps-bootstrap-XXXXXX)
trap 'rm -rf "$TMP"' EXIT

log_info "Cloning $REPO @ $BRANCH (sparse: vps/)"
(
  cd "$TMP"
  git clone --quiet --depth 1 --branch "$BRANCH" --filter=blob:none --sparse "$REPO" .
  git sparse-checkout set vps
) || log_die "Clone failed — check BRANCH=$BRANCH and REPO=$REPO"

if [[ ! -x "$TMP/vps/main.sh" ]]; then
  log_die "main.sh not found at $TMP/vps/main.sh — wrong branch?"
fi

log_ok "Sources fetched; handing off to main.sh"
echo

# ── Hand off ───────────────────────────────────────────────────────
cd "$TMP"
exec ./vps/main.sh "${ARGS[@]}"
