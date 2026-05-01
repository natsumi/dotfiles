#!/usr/bin/env bash
# vps/install.sh — bootstrap entrypoint.
# Designed for `curl ... | sudo bash` invocation.
# Verifies prerequisites, sparse-clones the repo, and execs main.sh.

set -Eeuo pipefail

# Capture the user's invocation cwd before we cd anywhere. Logs, summary
# files, and backups will be written here so they don't end up in the
# tmpdir (which the EXIT trap removes).
export INVOKED_FROM="$PWD"

REPO_DEFAULT="https://github.com/natsumi/dotfiles"
BRANCH_DEFAULT="main"

REPO="${REPO:-$REPO_DEFAULT}"
BRANCH="${BRANCH:-$BRANCH_DEFAULT}"

# ── Parse --branch from args (env var still wins if both set) ──────
ARGS=()
while (( $# > 0 )); do
  case "$1" in
    --branch)
      if [[ -z "${2:-}" ]]; then
        printf "✗ --branch requires a value\n" >&2; exit 2
      fi
      BRANCH="$2"; ARGS+=("--branch" "$2"); shift 2
      ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

# ── Inline color setup (lib/ui.sh isn't available yet) ─────────────
# This block intentionally mirrors the start of vps/lib/ui.sh. Keep names
# (info/success/warn/die) identical so muscle memory is consistent.
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'; C_RED=$'\033[0;31m'; C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[1;33m'; C_BLUE=$'\033[0;34m'
else
  C_RESET=''; C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''
fi
info()    { printf "%sℹ%s %s\n" "$C_BLUE"   "$C_RESET" "$*"; }
success() { printf "%s✓%s %s\n" "$C_GREEN"  "$C_RESET" "$*"; }
warn()    { printf "%s⚠%s %s\n" "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()     { printf "%s✗%s %s\n" "$C_RED"    "$C_RESET" "$*" >&2; exit 1; }

# ── Prereqs ────────────────────────────────────────────────────────
# Note: 'curl ... | sudo bash' breaks on Ubuntu 22.04+ because sudo's
# default use_pty mode proxies its stdin to the script's pty, and here
# sudo's stdin is the curl pipe — so prompts hang waiting for input that
# can't get through. The README's quickstart shows the two viable
# patterns (two-step download, or no-sudo when already root). We don't
# try to detect the broken case here; the EUID check below is enough.
(( EUID == 0 )) || die "Run as root (try: sudo bash)"

if [[ ! -r /etc/os-release ]]; then
  die "Cannot read /etc/os-release — unsupported OS"
fi
# shellcheck source=/dev/null
. /etc/os-release
case "${ID:-}:${VERSION_ID:-}" in
  ubuntu:24.04|ubuntu:26.04) ;;
  *) die "Only Ubuntu 24.04 and 26.04 are supported (found ${ID:-?}:${VERSION_ID:-?})" ;;
esac

# ── Install minimal deps if missing (BEFORE the internet probe — the
# probe uses curl, which itself might be missing on a barebones image) ─
declare -a apt_pkgs=()
for cmd in git curl envsubst; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    case "$cmd" in
      envsubst) apt_pkgs+=("gettext-base") ;;
      *)        apt_pkgs+=("$cmd") ;;
    esac
  fi
done
# ca-certificates isn't a binary, so command -v can't find it; check via dpkg.
if ! dpkg -s ca-certificates >/dev/null 2>&1; then
  apt_pkgs+=("ca-certificates")
fi
if (( ${#apt_pkgs[@]} > 0 )); then
  info "Installing missing dependencies: ${apt_pkgs[*]}"
  apt-get update -qq
  apt-get install -y -q "${apt_pkgs[@]}"
fi

# ── Internet check (after deps so curl is available) ───────────────
if ! curl -fsS --max-time 5 https://github.com >/dev/null 2>&1; then
  die "Cannot reach github.com — check network/DNS"
fi

# ── Clone repo (sparse, just vps/) ─────────────────────────────────
# We export VPS_BOOTSTRAP_TMP so main.sh's cleanup() can rm -rf it on the
# way out — this script's own EXIT trap cannot fire because exec replaces
# our bash process.
VPS_BOOTSTRAP_TMP=$(mktemp -d /tmp/vps-bootstrap-XXXXXX)
export VPS_BOOTSTRAP_TMP
# Fallback cleanup if exec is never reached (e.g., clone failure below).
trap 'rm -rf "$VPS_BOOTSTRAP_TMP"' EXIT

info "Cloning $REPO @ $BRANCH (sparse: vps/)"
(
  cd "$VPS_BOOTSTRAP_TMP"
  git clone --quiet --depth 1 --branch "$BRANCH" --filter=blob:none --sparse "$REPO" .
  git sparse-checkout set vps
) || die "Clone failed — check BRANCH=$BRANCH and REPO=$REPO"

if [[ ! -x "$VPS_BOOTSTRAP_TMP/vps/main.sh" ]]; then
  die "main.sh not found at $VPS_BOOTSTRAP_TMP/vps/main.sh — wrong branch?"
fi

success "Sources fetched; handing off to main.sh"
echo

# ── Hand off ───────────────────────────────────────────────────────
# When invoked via `curl ... | sudo bash`, our stdin is the pipe (closed
# the moment install.sh has been read), so any `read` in main.sh / lib/*
# hits EOF immediately. Re-attach stdin to /dev/tty so the prompts work.
cd "$VPS_BOOTSTRAP_TMP"

if [[ -t 0 ]]; then
  exec ./vps/main.sh "${ARGS[@]}"
elif [[ -r /dev/tty ]]; then
  exec ./vps/main.sh "${ARGS[@]}" </dev/tty
else
  die "No TTY available for interactive prompts. Run from an interactive shell, \
or save install.sh locally and execute it directly (e.g. 'sudo bash ./install.sh')."
fi
