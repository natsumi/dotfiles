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
# All prompts read from and write to /dev/tty directly, bypassing the
# tee'd fd 1/fd 2 set up by setup_logging. Writing a prompt without a
# trailing newline through tee would buffer it (tee block-buffers when
# its input has no newline), leaving the user staring at an empty
# screen. Reading from /dev/tty also makes prompts work under
# `curl ... | sudo bash`, where main.sh's fd 0 is the curl pipe.

# ask <prompt> [default] — prints the answer to stdout
ask() {
  local prompt="$1" default="${2:-}" reply
  if [[ -n "$default" ]]; then
    printf "%s?%s %s [%s%s%s]: " \
      "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "$default" "$C_RESET" >/dev/tty
  else
    printf "%s?%s %s: " "$C_CYAN" "$C_RESET" "$prompt" >/dev/tty
  fi
  IFS= read -r reply </dev/tty
  printf "%s\n" "${reply:-$default}"
}

# ask_yn <prompt> [default(Y|N)] — exit 0 if yes
ask_yn() {
  local prompt="$1" default="${2:-N}" reply hint
  if [[ "$default" =~ ^[Yy]$ ]]; then
    hint="[Y/n]"
  else
    hint="[y/N]"
  fi
  printf "%s?%s %s %s: " "$C_CYAN" "$C_RESET" "$prompt" "$hint" >/dev/tty
  IFS= read -r reply </dev/tty
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ask_password <prompt> — twice, hidden, must match. Echoes the password
# on fd 1 (so the caller can capture it via "$()"); prompts on /dev/tty.
# Caller is responsible for bracketing trace (set +x / set -x) when calling.
ask_password() {
  local prompt="$1" pw1 pw2
  while true; do
    printf "%s?%s %s: " "$C_CYAN" "$C_RESET" "$prompt" >/dev/tty
    IFS= read -rs pw1 </dev/tty
    printf "\n" >/dev/tty
    printf "%s?%s confirm: " "$C_CYAN" "$C_RESET" >/dev/tty
    IFS= read -rs pw2 </dev/tty
    printf "\n" >/dev/tty
    if [[ "$pw1" == "$pw2" && -n "$pw1" ]]; then
      printf "%s" "$pw1"
      return 0
    fi
    printf "%s⚠%s passwords do not match (or empty), try again\n" \
      "$C_YELLOW" "$C_RESET" >/dev/tty
  done
}

# ── run_step: long-running command UX ──────────────────────────────
# Usage: run_step "Description" command arg1 arg2 ...
# Returns the command's exit code.
TAIL_LINES=5
# SPIN is an array of glyphs (not a string). Bash substring indexing on a
# string counts bytes, not codepoints — Braille glyphs are 3 bytes each in
# UTF-8, so string indexing prints garbage. An array indexes by glyph.
SPIN=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

run_step() {
  local desc="$1"; shift
  local cmd_str="$*"
  local start=$SECONDS
  local rc=0

  # Suppress bash xtrace inside run_step. Otherwise our own panel-loop
  # commands trace into BASH_XTRACEFD (= LOG_FILE), and the panel — which
  # reads `tail -n 5 LOG_FILE` — picks up its own trace lines instead of
  # the wrapped command's output. Restore at the end (and on every
  # return path) so module code keeps its trace.
  local _saved_xtrace=0
  [[ $- == *x* ]] && _saved_xtrace=1
  { set +x; } 2>/dev/null

  _restore_xtrace() { (( _saved_xtrace )) && { set -x; } 2>/dev/null; return 0; }

  # Detect a usable terminal via /dev/tty rather than `[[ -t 1 ]]`,
  # because main.sh's setup_logging redirects fd 1 through tee so the
  # fd-1 test always fails inside the runner.
  local have_tty=0
  if [[ -e /dev/tty ]] && [[ -w /dev/tty ]] && [[ "${VERBOSE:-0}" != "1" ]]; then
    have_tty=1
  fi

  # ── Streaming branch: VERBOSE=1 or no /dev/tty ───────────────────
  # Output streams via fd 1 (already tee'd to LOG_FILE by setup_logging).
  if (( have_tty == 0 )); then
    printf "  ▸ %s\n" "$desc"
    "$@" || rc=$?
    local elapsed=$((SECONDS - start))
    if (( rc == 0 )); then
      printf "  %s✓%s %s (%ss)\n" "$C_GREEN" "$C_RESET" "$desc" "$elapsed"
    else
      printf "  %s✗%s %s (rc=%s after %ss)\n" "$C_RED" "$C_RESET" "$desc" "$rc" "$elapsed" >&2
      printf "    command: %s\n" "$cmd_str" >&2
      printf "    log:     %s\n" "${LOG_FILE:-?}" >&2
    fi
    _restore_xtrace
    return "$rc"
  fi

  # ── Panel branch ─────────────────────────────────────────────────
  # The 6-line live panel (header + 5-line scrolling tail of LOG_FILE)
  # is drawn directly on /dev/tty so cursor escapes don't get buffered
  # by tee and don't end up scrubbed in the log file. The command's own
  # output is written to LOG_FILE directly (NOT through fd 1) so the
  # streaming text doesn't fight the panel for screen real estate.

  # Reserve the panel: 1 header line + TAIL_LINES tail lines.
  {
    printf "  ⠋ %s — 0s\n" "$desc"
    local _i
    for ((_i = 0; _i < TAIL_LINES; _i++)); do
      printf "  │\n"
    done
  } >/dev/tty

  "$@" >>"$LOG_FILE" 2>&1 &
  local pid=$! i=0

  while kill -0 "$pid" 2>/dev/null; do
    {
      # Rewind to top of panel.
      printf "\033[%dA" $((TAIL_LINES + 1))

      # Header.
      local elapsed=$((SECONDS - start))
      printf "\r\033[K  %s %s — %ss\n" \
        "${SPIN[i++ % 10]}" "$desc" "$elapsed"

      # Tail box.
      local width=$((${COLUMNS:-80} - 6))
      local lines=()
      mapfile -t lines < <(
        tail -n "$TAIL_LINES" "$LOG_FILE" 2>/dev/null \
          | sed -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' -e 's/\r//g' \
          | cut -c1-"$width"
      )
      local j
      for ((j = 0; j < TAIL_LINES; j++)); do
        printf "\r\033[K  │ %s\n" "${lines[j]:-}"
      done
    } >/dev/tty
    sleep 0.2
  done
  wait "$pid"; rc=$?
  local elapsed=$((SECONDS - start))

  # Clear the 6-line panel (cursor back at the top of where it was).
  {
    printf "\033[%dA" $((TAIL_LINES + 1))
    local _k
    for ((_k = 0; _k < TAIL_LINES + 1; _k++)); do
      printf "\r\033[K\n"
    done
    printf "\033[%dA" $((TAIL_LINES + 1))
  } >/dev/tty

  # Result line goes via fd 1/fd 2 so it lands in the log too.
  if (( rc == 0 )); then
    printf "  %s✓%s %s (%ss)\n" "$C_GREEN" "$C_RESET" "$desc" "$elapsed"
  else
    printf "  %s✗%s %s (rc=%s after %ss)\n" "$C_RED" "$C_RESET" "$desc" "$rc" "$elapsed" >&2
    printf "    command: %s\n" "$cmd_str" >&2
    printf "    log:     %s\n" "${LOG_FILE:-?}" >&2
    printf "    ── last 20 lines of log ──\n" >&2
    tail -20 "$LOG_FILE" 2>/dev/null | sed 's/^/    │ /' >&2
  fi
  _restore_xtrace
  return "$rc"
}
