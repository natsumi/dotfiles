# vps/lib/ui.sh — colors, log helpers, prompts, run_step.
# Sourced by main.sh (and indirectly by every module). Do not execute directly.

# shellcheck disable=SC2034  # color vars are exported for module use

# ── Color setup ────────────────────────────────────────────────────
# Disabled when stdout is not a TTY or NO_COLOR is set (de-facto standard).
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[0;31m'
  C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[1;33m'
  C_BLUE=$'\033[0;34m'
  C_CYAN=$'\033[0;36m'
  C_GREY=$'\033[0;90m'
else
  C_RESET=''
  C_BOLD=''
  C_DIM=''
  C_RED=''
  C_GREEN=''
  C_YELLOW=''
  C_BLUE=''
  C_CYAN=''
  C_GREY=''
fi

# ── Message helpers ────────────────────────────────────────────────
info()    { printf "%sℹ%s %s\n" "$C_BLUE"   "$C_RESET" "$*"; }
success() { printf "%s✓%s %s\n" "$C_GREEN"  "$C_RESET" "$*"; }
warn()    { printf "%s⚠%s %s\n" "$C_YELLOW" "$C_RESET" "$*" >&2; }
error()   { printf "%s✗%s %s\n" "$C_RED"    "$C_RESET" "$*" >&2; }
die()     { error "$*"; exit 1; }
debug()   { [[ "${DEBUG:-0}" == "1" ]] && printf "%s· %s%s\n" "$C_GREY" "$*" "$C_RESET" >&2; return 0; }

# Section header — printed by the runner before each module.
section() {
  local n="$1" total="$2" name="$3"
  printf "\n%s━━ [%d/%d] %s ━━%s\n" "$C_BOLD$C_CYAN" "$n" "$total" "$name" "$C_RESET"
}
