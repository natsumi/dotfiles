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

# ── Prompt helpers ─────────────────────────────────────────────────
# ask <prompt> [default] — prints the answer to stdout
ask() {
  local prompt="$1" default="${2:-}" reply
  if [[ -n "$default" ]]; then
    read -rp "$(printf "%s?%s %s [%s%s%s]: " \
      "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "$default" "$C_RESET")" reply
    printf "%s\n" "${reply:-$default}"
  else
    read -rp "$(printf "%s?%s %s: " "$C_CYAN" "$C_RESET" "$prompt")" reply
    printf "%s\n" "$reply"
  fi
}

# ask_yn <prompt> [default(Y|N)] — exit 0 if yes
ask_yn() {
  local prompt="$1" default="${2:-N}" reply
  read -rp "$(printf "%s?%s %s [y/N]: " "$C_CYAN" "$C_RESET" "$prompt")" reply
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ask_password <prompt> — twice, hidden, must match. Echoes the password.
# Caller is responsible for bracketing trace (set +x / set -x) when calling.
ask_password() {
  local prompt="$1" pw1 pw2
  while true; do
    read -rsp "$(printf "%s?%s %s: " "$C_CYAN" "$C_RESET" "$prompt")" pw1
    printf "\n" >&2
    read -rsp "$(printf "%s?%s confirm: " "$C_CYAN" "$C_RESET")" pw2
    printf "\n" >&2
    if [[ "$pw1" == "$pw2" && -n "$pw1" ]]; then
      printf "%s" "$pw1"
      return 0
    fi
    printf "%s⚠%s passwords do not match (or empty), try again\n" \
      "$C_YELLOW" "$C_RESET" >&2
  done
}
