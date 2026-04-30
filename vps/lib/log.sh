# vps/lib/log.sh — log file setup and tee redirection.
# Sourced by main.sh after lib/ui.sh.
#
# Sets:
#   LOG_FILE — absolute path to the timestamped log file in cwd
# Side effects:
#   - Creates the log file in cwd
#   - Redirects fd 1 and 2 through tee with ANSI stripping
#   - Sets BASH_XTRACEFD to a separate fd so set -x output goes to the log,
#     not the screen.
#
# Call setup_logging() from main.sh BEFORE running preflight or modules,
# but after sourcing lib/ui.sh.

setup_logging() {
  local stamp
  stamp=$(date +%Y%m%d-%H%M%S)
  LOG_FILE="${PWD}/vps-bootstrap-${stamp}.log"

  : >"$LOG_FILE" || die "Cannot write to $LOG_FILE"

  # Mirror stdout and stderr to the log file, stripping ANSI escapes from
  # the file copy so logs are plain-text and grep-friendly.
  exec 1> >(tee >(sed -u 's/\x1b\[[0-9;]*[a-zA-Z]//g' >>"$LOG_FILE"))
  exec 2> >(tee >(sed -u 's/\x1b\[[0-9;]*[a-zA-Z]//g' >>"$LOG_FILE") >&2)

  # Bash trace on a separate fd so xtrace lines go to the log only.
  exec 9>>"$LOG_FILE"
  BASH_XTRACEFD=9
  PS4='+ ${BASH_SOURCE}:${LINENO}: '
  set -x

  # Header in the log file (and on screen).
  printf "=== vps-bootstrap started %s ===\n" "$(date -Is)"
  printf "=== log: %s ===\n" "$LOG_FILE"
}
