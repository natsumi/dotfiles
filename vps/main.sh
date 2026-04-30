#!/usr/bin/env bash
# vps/main.sh — the runner.
# Sources libs, parses flags, runs preflight, prompts, and the module loop.

set -Eeuo pipefail

VPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$VPS_DIR"

# shellcheck source=lib/ui.sh
source "$VPS_DIR/lib/ui.sh"
# shellcheck source=lib/log.sh
source "$VPS_DIR/lib/log.sh"
# shellcheck source=lib/preflight.sh
source "$VPS_DIR/lib/preflight.sh"
# shellcheck source=lib/config.sh
source "$VPS_DIR/lib/config.sh"
# shellcheck source=manifest.sh
source "$VPS_DIR/manifest.sh"

# ── Flag parsing ───────────────────────────────────────────────────
ONLY=""
SKIP=""
LIST_ONLY=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --only <ids>      Run only listed modules (comma-separated)
  --skip <ids>      Run all modules except listed (comma-separated)
  --verbose, -v     Stream all command output (no progress panel)
  --list            Print the module manifest and exit
  --branch <name>   (Bootstrap-only) sets BRANCH for install.sh
  --help, -h        Show this message

Environment:
  BRANCH      Branch to clone from (bootstrap, default: main)
  REPO        Repo URL (bootstrap, default: github.com/natsumi/dotfiles)
  NO_COLOR    Disable ANSI colors (also auto-disabled if not a TTY)
  VERBOSE=1   Same as --verbose
  DEBUG=1     Enable debug() output
EOF
}

_require_value() {
  # Usage: _require_value <flag-name> <value-or-empty>
  if [[ -z "${2:-}" ]]; then
    error "$1 requires a value"; usage >&2; exit 2
  fi
}

while (( $# > 0 )); do
  case "$1" in
    --only)    _require_value "--only"   "${2:-}"; ONLY="$2"; shift 2 ;;
    --skip)    _require_value "--skip"   "${2:-}"; SKIP="$2"; shift 2 ;;
    --verbose|-v) export VERBOSE=1; shift ;;  # consumed by run_step in lib/ui.sh
    --list)    LIST_ONLY=1; shift ;;
    --branch)  _require_value "--branch" "${2:-}"; shift 2 ;;  # consumed by install.sh
    --help|-h) usage; exit 0 ;;
    *) error "Unknown flag: $1"; usage >&2; exit 2 ;;
  esac
done

if (( LIST_ONLY )); then
  printf "%-15s  %s\n" "ID" "Display Name"
  printf "%-15s  %s\n" "──" "────────────"
  for entry in "${MODULES[@]}"; do
    printf "%-15s  %s\n" "${entry%%|*}" "${entry#*|}"
  done
  exit 0
fi

# ── Logging + traps ────────────────────────────────────────────────
setup_logging

cleanup() {
  local rc=$?
  [[ -d "${LOCKFILE:-}" ]] && rmdir "$LOCKFILE" 2>/dev/null || true
  # install.sh exports VPS_BOOTSTRAP_TMP for the temp clone path before
  # exec'ing us; clean it up on the way out (its own EXIT trap can't fire
  # because exec replaced its bash process).
  [[ -n "${VPS_BOOTSTRAP_TMP:-}" && -d "$VPS_BOOTSTRAP_TMP" ]] && \
    rm -rf "$VPS_BOOTSTRAP_TMP" 2>/dev/null || true
  exit "$rc"
}
on_error() {
  local lineno="$1" rc="$2" cmd="$3"
  printf "\n%s━━ ERROR ━━%s\n" "$C_BOLD$C_RED" "$C_RESET" >&2
  printf "  command: %s\n" "$cmd" >&2
  printf "  line:    %s\n" "$lineno" >&2
  printf "  rc:      %s\n" "$rc" >&2
  printf "  log:     %s\n" "$LOG_FILE" >&2
}
trap 'on_error "$LINENO" "$?" "$BASH_COMMAND"' ERR
trap cleanup EXIT

# ── Preflight + prompts ────────────────────────────────────────────
run_preflight
prompt_config

# ── Filter modules ─────────────────────────────────────────────────
SELECTED=()
for entry in "${MODULES[@]}"; do
  id="${entry%%|*}"
  if [[ -n "$ONLY"  && ! ",$ONLY,"  =~ ,$id, ]]; then continue; fi
  if [[ -n "$SKIP"  &&   ",$SKIP,"  =~ ,$id, ]]; then continue; fi
  SELECTED+=("$entry")
done

if (( ${#SELECTED[@]} == 0 )); then
  die "No modules selected (check --only/--skip)"
fi

# ── Module loop ────────────────────────────────────────────────────
# shellcheck disable=SC2034  # STEP_TIMINGS/STEP_STATUS used by summary module (Task 25)
declare -A STEP_TIMINGS=()
declare -a STEP_STATUS=()

total=${#SELECTED[@]}
n=0
for entry in "${SELECTED[@]}"; do
  ((n++))
  id="${entry%%|*}"
  name="${entry#*|}"
  MODULE_DIR="$VPS_DIR/modules/$id"
  export MODULE_DIR

  section "$n" "$total" "$name"

  if [[ ! -f "$MODULE_DIR/run.sh" ]]; then
    error "Module file missing: $MODULE_DIR/run.sh"
    exit 1
  fi

  start=$SECONDS
  # shellcheck source=/dev/null
  source "$MODULE_DIR/run.sh"
  if ! declare -F module_run >/dev/null; then
    die "Module $id did not define module_run()"
  fi
  module_run
  unset -f module_run

  # shellcheck disable=SC2034  # STEP_TIMINGS/STEP_STATUS consumed by summary module (Task 25)
  STEP_TIMINGS[$id]=$((SECONDS - start))
  STEP_STATUS+=("$id:ok")
done

success "All modules completed"
