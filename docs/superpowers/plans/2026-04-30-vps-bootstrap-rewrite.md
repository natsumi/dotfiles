# VPS Bootstrap Rewrite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the existing 944-line monolithic `vps/setup.sh` with a modular, manifest-driven bootstrap toolkit for Ubuntu 24.04/26.04 servers.

**Architecture:** A thin `install.sh` bootstrap that sparse-clones the repo and execs `main.sh`. The runner sources four library files (`lib/ui.sh`, `lib/log.sh`, `lib/preflight.sh`, `lib/config.sh`), reads a manifest of `id|Display Name` entries, and iterates each module by sourcing its `run.sh` and calling its `module_run` function. Configuration goes into `/etc/<svc>.d/99-vps-*` drop-ins wherever the OS supports them; `envsubst` templates are used when interpolation is needed; in-place edits are last resort. Long-running commands display a 6-line live panel (header + 5-line scrolling tail).

**Tech Stack:** Bash 5+, `gettext-base` (for `envsubst`), `shellcheck` (for linting). No other runtime dependencies beyond the standard Ubuntu base.

**Reference:** Spec at `docs/superpowers/specs/2026-04-30-vps-bootstrap-rewrite-design.md`.

---

## File Structure

After this plan completes, `vps/` looks like:

```
vps/
├── install.sh                              # bootstrap (curl-piped)
├── main.sh                                 # runner — flags, preflight, prompts, module loop
├── manifest.sh                             # ordered MODULES array
├── README.md                               # quickstart, module table, flags, troubleshooting
├── lib/
│   ├── ui.sh                               # colors, message helpers, prompts, run_step
│   ├── log.sh                              # log file setup with ANSI strip + xtrace
│   ├── config.sh                           # prompt_config()
│   └── preflight.sh                        # OS / root / internet / safety checks
└── modules/
    ├── apt-mirror/run.sh
    ├── apt-mirror/templates/ubuntu.sources.tmpl
    ├── system/run.sh
    ├── update/run.sh
    ├── packages/run.sh
    ├── packages/packages.list
    ├── neovim/run.sh
    ├── user/run.sh
    ├── ssh/run.sh
    ├── ssh/files/99-hardening.conf
    ├── firewall/run.sh
    ├── fail2ban/run.sh
    ├── fail2ban/templates/vps.local.tmpl
    ├── fail2ban/filters/traefik-auth.conf
    ├── fail2ban/filters/traefik-badbots.conf
    ├── fail2ban/filters/traefik-ratelimit.conf
    ├── auto-updates/run.sh
    ├── sysctl/run.sh
    ├── sysctl/files/99-vps-hardening.conf
    ├── swap/run.sh
    ├── docker/run.sh
    ├── docker/files/daemon.json
    ├── audit/run.sh
    └── summary/run.sh
```

The existing `vps/install.sh`, `vps/setup.sh`, `vps/README.md`, and `vps/configs/` are deleted. History remains on the `main` branch.

**Conventions across all bash files:**
- First line `#!/usr/bin/env bash` only on executables (`install.sh`, `main.sh`); library and module files have no shebang because they are sourced.
- All files pass `bash -n` and `shellcheck` (with the shellcheck disables documented per-file when needed).
- Every file ends with a single trailing newline.
- **shellcheck note:** Sourced files (libraries, manifest, module `run.sh`) have no shebang, so invoke shellcheck with `-s bash` for those (e.g. `shellcheck -s bash vps/lib/ui.sh`). Files with shebangs (`install.sh`, `main.sh`) don't need the flag. Per-task lint commands below omit `-s bash` for brevity; add it when running against sourced files if shellcheck reports unsupported-shell warnings.

---

## Task 1: Scaffold the new directory layout

**Files:**
- Delete: `vps/install.sh`, `vps/setup.sh`, `vps/README.md`, `vps/configs/` (entire tree)
- Create: empty directory tree for the new `vps/`

- [ ] **Step 1: Verify the working branch**

```bash
git rev-parse --abbrev-ref HEAD
```

Expected output: `feat_vps_rewrite`. If you see `main`, stop and switch to the feature branch.

- [ ] **Step 2: Delete the existing vps/ tree**

```bash
git rm -r vps/
```

Expected: `rm 'vps/README.md'`, `rm 'vps/install.sh'`, `rm 'vps/setup.sh'`, plus all files under `vps/configs/`.

- [ ] **Step 3: Create the new directory skeleton**

```bash
mkdir -p vps/lib
mkdir -p vps/modules/apt-mirror/templates
mkdir -p vps/modules/system
mkdir -p vps/modules/update
mkdir -p vps/modules/packages
mkdir -p vps/modules/neovim
mkdir -p vps/modules/user
mkdir -p vps/modules/ssh/files
mkdir -p vps/modules/firewall
mkdir -p vps/modules/fail2ban/templates
mkdir -p vps/modules/fail2ban/filters
mkdir -p vps/modules/auto-updates
mkdir -p vps/modules/sysctl/files
mkdir -p vps/modules/swap
mkdir -p vps/modules/docker/files
mkdir -p vps/modules/audit
mkdir -p vps/modules/summary
```

- [ ] **Step 4: Add a `.gitkeep` only where needed (none here — every dir gets a real file later)**

No action.

- [ ] **Step 5: Verify the structure**

```bash
find vps -type d | sort
```

Expected output (relative to the repo root):
```
vps
vps/lib
vps/modules
vps/modules/apt-mirror
vps/modules/apt-mirror/templates
vps/modules/audit
vps/modules/auto-updates
vps/modules/docker
vps/modules/docker/files
vps/modules/fail2ban
vps/modules/fail2ban/filters
vps/modules/fail2ban/templates
vps/modules/firewall
vps/modules/neovim
vps/modules/packages
vps/modules/ssh
vps/modules/ssh/files
vps/modules/summary
vps/modules/swap
vps/modules/sysctl
vps/modules/sysctl/files
vps/modules/system
vps/modules/update
vps/modules/user
```

- [ ] **Step 6: Commit the deletion**

(Empty directories aren't tracked by git, so this commit only contains the deletes.)

```bash
git commit -m "Remove existing vps/ in preparation for rewrite"
```

---

## Task 2: lib/ui.sh — colors and message helpers

**Files:**
- Create: `vps/lib/ui.sh`

- [ ] **Step 1: Write the initial `lib/ui.sh` with colors and message helpers**

Create `vps/lib/ui.sh` with this content:

```bash
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
```

- [ ] **Step 2: Syntax-check the file**

```bash
bash -n vps/lib/ui.sh
```

Expected: no output, exit 0.

- [ ] **Step 3: Lint with shellcheck (skip if shellcheck is not installed)**

```bash
command -v shellcheck && shellcheck vps/lib/ui.sh
```

Expected: no output, exit 0. (If `shellcheck` isn't installed, skip. The CI / final review will catch it.)

- [ ] **Step 4: Visually verify the helpers work**

```bash
bash -c 'source vps/lib/ui.sh; info "info"; success "success"; warn "warn"; error "error"; DEBUG=1 debug "debug"; section 3 15 "Example Section"'
```

Expected: each line prints with its symbol and color (when the terminal is a TTY).

- [ ] **Step 5: Commit**

```bash
git add vps/lib/ui.sh
git commit -m "Add lib/ui.sh with colors and message helpers"
```

---

## Task 3: lib/ui.sh — interactive prompts

**Files:**
- Modify: `vps/lib/ui.sh` (append)

- [ ] **Step 1: Append prompt helpers to `vps/lib/ui.sh`**

Append the following to the end of the file:

```bash

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
```

- [ ] **Step 2: Syntax-check**

```bash
bash -n vps/lib/ui.sh
```

Expected: no output, exit 0.

- [ ] **Step 3: Lint**

```bash
command -v shellcheck && shellcheck vps/lib/ui.sh
```

Expected: no output, exit 0.

- [ ] **Step 4: Verify `ask` and `ask_yn` interactively**

```bash
bash -c 'source vps/lib/ui.sh; v=$(ask "Hostname" "default-host"); echo "got: $v"'
```

Press Enter at the prompt; expect output `got: default-host`. Re-run, type `myhost`, expect `got: myhost`.

```bash
bash -c 'source vps/lib/ui.sh; ask_yn "Continue?" && echo yes || echo no'
```

Type `y`, expect `yes`. Type anything else, expect `no`.

- [ ] **Step 5: Commit**

```bash
git add vps/lib/ui.sh
git commit -m "Add interactive prompt helpers to lib/ui.sh"
```

---

## Task 4: lib/ui.sh — run_step (live tail panel)

**Files:**
- Modify: `vps/lib/ui.sh` (append)

- [ ] **Step 1: Append `run_step` to `vps/lib/ui.sh`**

Append the following to the end of the file:

```bash

# ── run_step: long-running command UX ──────────────────────────────
# Usage: run_step "Description" command arg1 arg2 ...
# Returns the command's exit code.
TAIL_LINES=5
SPIN='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

run_step() {
  local desc="$1"; shift
  local start=$SECONDS rc

  # Non-TTY or VERBOSE: stream everything plainly.
  if [[ ! -t 1 ]] || [[ "${VERBOSE:-0}" == "1" ]]; then
    printf "  ▸ %s\n" "$desc"
    "$@" 2>&1 | tee -a "$LOG_FILE"
    rc=${PIPESTATUS[0]}
    local elapsed=$((SECONDS - start))
    if (( rc == 0 )); then
      printf "  %s✓%s %s (%ss)\n" "$C_GREEN" "$C_RESET" "$desc" "$elapsed"
    else
      printf "  %s✗%s %s (failed after %ss)\n" "$C_RED" "$C_RESET" "$desc" "$elapsed" >&2
    fi
    return "$rc"
  fi

  # Reserve a 6-line panel: 1 header + TAIL_LINES tail.
  printf "  ⠋ %s — 0s\n" "$desc"
  local _i
  for ((_i = 0; _i < TAIL_LINES; _i++)); do
    printf "  │\n"
  done

  # Run command in background, output to log only.
  "$@" >>"$LOG_FILE" 2>&1 &
  local pid=$! i=0

  while kill -0 "$pid" 2>/dev/null; do
    # Rewind to top of panel.
    printf "\033[%dA" $((TAIL_LINES + 1))

    # Header: spinner, desc, elapsed.
    local elapsed=$((SECONDS - start))
    printf "\r\033[K  %s %s — %ss\n" \
      "${SPIN:i++%10:1}" "$desc" "$elapsed"

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

    sleep 0.2
  done
  wait "$pid"; rc=$?
  local elapsed=$((SECONDS - start))

  # Collapse 6-line panel into a single result line.
  printf "\033[%dA" $((TAIL_LINES + 1))
  local _k
  for ((_k = 0; _k < TAIL_LINES + 1; _k++)); do
    printf "\r\033[K\n"
  done
  printf "\033[%dA" $((TAIL_LINES + 1))

  if (( rc == 0 )); then
    printf "  %s✓%s %s (%ss)\n" "$C_GREEN" "$C_RESET" "$desc" "$elapsed"
  else
    printf "  %s✗%s %s (failed after %ss)\n" "$C_RED" "$C_RESET" "$desc" "$elapsed" >&2
    printf "    ── last 20 lines of log ──\n" >&2
    tail -20 "$LOG_FILE" 2>/dev/null | sed 's/^/    │ /' >&2
  fi
  return "$rc"
}
```

- [ ] **Step 2: Syntax-check**

```bash
bash -n vps/lib/ui.sh
```

Expected: no output, exit 0.

- [ ] **Step 3: Lint**

```bash
command -v shellcheck && shellcheck vps/lib/ui.sh
```

Expected: no output. If shellcheck flags `SC2086` on the `printf "\033[%dA"` lines, ignore — the integer expansion is intentional.

- [ ] **Step 4: Visually verify run_step**

```bash
bash -c '
  set -euo pipefail
  source vps/lib/ui.sh
  LOG_FILE=$(mktemp)
  run_step "Counting to 5" bash -c "for i in 1 2 3 4 5; do echo line \$i; sleep 0.5; done"
  rm -f "$LOG_FILE"
'
```

Expected: a 6-line panel updates with a spinner and the last lines of output. After ~2.5 seconds, collapses to `✓ Counting to 5 (2s)` (or similar).

```bash
bash -c '
  set -euo pipefail
  source vps/lib/ui.sh
  LOG_FILE=$(mktemp)
  run_step "Failing command" bash -c "echo about to fail; exit 7" || echo "got rc=$?"
  rm -f "$LOG_FILE"
'
```

Expected: panel collapses to `✗ Failing command (...)`, last 20 lines of log are reproduced inline with `│` prefix, then `got rc=7`.

- [ ] **Step 5: Commit**

```bash
git add vps/lib/ui.sh
git commit -m "Add run_step live-tail UX helper to lib/ui.sh"
```

---

## Task 5: lib/log.sh

**Files:**
- Create: `vps/lib/log.sh`

- [ ] **Step 1: Write `vps/lib/log.sh`**

```bash
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
```

- [ ] **Step 2: Syntax-check**

```bash
bash -n vps/lib/log.sh
```

Expected: no output.

- [ ] **Step 3: Lint**

```bash
command -v shellcheck && shellcheck vps/lib/log.sh
```

Expected: no output. (If it warns that `LOG_FILE` is unused, ignore — it's read by other files.)

- [ ] **Step 4: Verify the redirect works**

```bash
bash -c '
  set -euo pipefail
  cd "$(mktemp -d)"
  source ~/dev/dotfiles/vps/lib/ui.sh
  source ~/dev/dotfiles/vps/lib/log.sh
  setup_logging
  info "this should be in the log"
  warn "this too"
  printf "log file: %s\n" "$LOG_FILE"
  cat "$LOG_FILE"
'
```

Replace `~/dev/dotfiles` with the actual repo path if different. Expected: the log file contains `info`/`warn` lines without ANSI escapes plus the bash trace lines.

- [ ] **Step 5: Commit**

```bash
git add vps/lib/log.sh
git commit -m "Add lib/log.sh with timestamped log and xtrace fd"
```

---

## Task 6: lib/preflight.sh

**Files:**
- Create: `vps/lib/preflight.sh`

- [ ] **Step 1: Write `vps/lib/preflight.sh`**

```bash
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
  local stamp="${PWD}/vps-bootstrap.stamp"
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
```

- [ ] **Step 2: Syntax-check**

```bash
bash -n vps/lib/preflight.sh
```

Expected: no output.

- [ ] **Step 3: Lint**

```bash
command -v shellcheck && shellcheck vps/lib/preflight.sh
```

Expected: no output. The `# shellcheck source=/dev/null` directive suppresses the warning about sourcing `/etc/os-release`.

- [ ] **Step 4: Verify it can source without error**

```bash
bash -c 'source vps/lib/ui.sh; source vps/lib/preflight.sh; type run_preflight | head -1'
```

Expected: `run_preflight is a function`.

- [ ] **Step 5: Commit**

```bash
git add vps/lib/preflight.sh
git commit -m "Add lib/preflight.sh with OS/root/internet/disk/lock checks"
```

---

## Task 7: lib/config.sh

**Files:**
- Create: `vps/lib/config.sh`

- [ ] **Step 1: Write `vps/lib/config.sh`**

```bash
# vps/lib/config.sh — interactive prompts collected upfront.
# Sourced by main.sh after lib/ui.sh and lib/preflight.sh.
#
# Public function:
#   prompt_config — collects all interactive values, validates them,
#                   prints a summary, asks for confirmation.
#
# Sets shell vars (used by modules):
#   USERNAME, PASSWORD, HOSTNAME, SSH_PORT, TIMEZONE,
#   SSH_PUBKEY, INSTALL_DOCKER

_validate_username() {
  [[ "$1" =~ ^[a-z][-a-z0-9_]*$ ]]
}

_validate_hostname() {
  # RFC-1123: 1–63 chars per label, letters/digits/hyphens, can't start/end with hyphen.
  [[ "$1" =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]]
}

_validate_port() {
  [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 ))
}

_validate_timezone() {
  [[ -f "/usr/share/zoneinfo/$1" ]]
}

_validate_pubkey() {
  printf "%s" "$1" | ssh-keygen -l -f - >/dev/null 2>&1
}

prompt_config() {
  printf "\n%s━━ Interactive configuration ━━%s\n\n" "$C_BOLD$C_CYAN" "$C_RESET"

  # ── Username ─────────────────────────────────────────────────────
  while true; do
    USERNAME=$(ask "Username for sudo access (empty to skip user creation)")
    [[ -z "$USERNAME" ]] && break
    if _validate_username "$USERNAME"; then break; fi
    warn "Invalid username — must match ^[a-z][-a-z0-9_]*\$"
  done

  # ── Password (only if username given) ────────────────────────────
  PASSWORD=""
  if [[ -n "$USERNAME" ]]; then
    { set +x; } 2>/dev/null
    PASSWORD=$(ask_password "Password for $USERNAME")
    set -x
  fi

  # ── Hostname ─────────────────────────────────────────────────────
  local cur_host
  cur_host=$(hostname)
  while true; do
    HOSTNAME=$(ask "Hostname" "$cur_host")
    if _validate_hostname "$HOSTNAME"; then break; fi
    warn "Invalid hostname (RFC-1123)"
  done

  # ── SSH port ─────────────────────────────────────────────────────
  while true; do
    SSH_PORT=$(ask "SSH port" "22")
    if _validate_port "$SSH_PORT"; then break; fi
    warn "Invalid port — must be 1–65535"
  done

  # ── Timezone ─────────────────────────────────────────────────────
  while true; do
    TIMEZONE=$(ask "Timezone" "America/Los_Angeles")
    if _validate_timezone "$TIMEZONE"; then break; fi
    warn "Unknown timezone — must exist in /usr/share/zoneinfo"
  done

  # ── SSH key (only if root has none) ──────────────────────────────
  SSH_PUBKEY=""
  if [[ ! -s /root/.ssh/authorized_keys ]]; then
    warn "Root has no authorized_keys — a public key is required"
    while true; do
      printf "  Paste your SSH public key (e.g. from ~/.ssh/id_ed25519.pub): "
      read -r SSH_PUBKEY
      if _validate_pubkey "$SSH_PUBKEY"; then break; fi
      warn "Invalid public key — try again"
    done
  fi

  # ── Docker (optional) ────────────────────────────────────────────
  if ask_yn "Install Docker?" "N"; then
    INSTALL_DOCKER="yes"
  else
    INSTALL_DOCKER="no"
  fi

  # ── Summary + final confirm ──────────────────────────────────────
  printf "\n%s━━ Configuration summary ━━%s\n" "$C_BOLD$C_CYAN" "$C_RESET"
  printf "  Username:        %s\n" "${USERNAME:-[skip]}"
  printf "  Password:        %s\n" "${PASSWORD:+[set]}${PASSWORD:-[skip]}"
  printf "  Hostname:        %s\n" "$HOSTNAME"
  printf "  SSH port:        %s\n" "$SSH_PORT"
  printf "  Timezone:        %s\n" "$TIMEZONE"
  printf "  SSH public key:  %s\n" "${SSH_PUBKEY:+to be installed}${SSH_PUBKEY:-already present}"
  printf "  Install Docker:  %s\n\n" "$INSTALL_DOCKER"

  if ! ask_yn "Proceed with this configuration?" "Y"; then
    die "Aborted by user"
  fi
}
```

- [ ] **Step 2: Syntax-check**

```bash
bash -n vps/lib/config.sh
```

Expected: no output.

- [ ] **Step 3: Lint**

```bash
command -v shellcheck && shellcheck vps/lib/config.sh
```

Expected: no output. (Several variables look unused — they're consumed by modules. shellcheck is fine here because they have `_` prefix or are uppercase globals.)

- [ ] **Step 4: Quick verification**

```bash
bash -c 'source vps/lib/ui.sh; source vps/lib/config.sh; type prompt_config | head -1'
```

Expected: `prompt_config is a function`.

- [ ] **Step 5: Commit**

```bash
git add vps/lib/config.sh
git commit -m "Add lib/config.sh with prompt_config()"
```

---

## Task 8: manifest.sh

**Files:**
- Create: `vps/manifest.sh`

- [ ] **Step 1: Write `vps/manifest.sh`**

```bash
# vps/manifest.sh — ordered list of modules.
# Each entry: "<id>|<Display Name>". Order is the array order.
# Sourced by main.sh.

MODULES=(
  "apt-mirror|APT Mirror Configuration"
  "system|System Settings (hostname, timezone)"
  "update|System Update"
  "packages|Base Packages"
  "neovim|Neovim (latest unstable)"
  "user|Admin User & Sudo"
  "ssh|SSH Hardening"
  "firewall|UFW Firewall"
  "fail2ban|Fail2ban"
  "auto-updates|Unattended Upgrades"
  "sysctl|Kernel & Network Hardening"
  "swap|Swap File"
  "docker|Docker Engine"
  "audit|Security Audit"
  "summary|Setup Summary"
)
```

- [ ] **Step 2: Syntax-check**

```bash
bash -n vps/manifest.sh
```

Expected: no output.

- [ ] **Step 3: Lint**

```bash
command -v shellcheck && shellcheck vps/manifest.sh
```

Expected: no output. If shellcheck warns `MODULES appears unused`, ignore — it's read by `main.sh`.

- [ ] **Step 4: Commit**

```bash
git add vps/manifest.sh
git commit -m "Add manifest.sh with the ordered module list"
```

---

## Task 9: main.sh

**Files:**
- Create: `vps/main.sh`

- [ ] **Step 1: Write `vps/main.sh`**

```bash
#!/usr/bin/env bash
# vps/main.sh — the runner.
# Sources libs, parses flags, runs preflight, prompts, and the module loop.

set -euo pipefail

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

while (( $# > 0 )); do
  case "$1" in
    --only)    ONLY="$2"; shift 2 ;;
    --skip)    SKIP="$2"; shift 2 ;;
    --verbose|-v) VERBOSE=1; shift ;;
    --list)    LIST_ONLY=1; shift ;;
    --branch)  shift 2 ;;   # consumed by install.sh, ignored here
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
  [[ -d "$LOCKFILE" ]] && rmdir "$LOCKFILE" 2>/dev/null || true
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

  STEP_TIMINGS[$id]=$((SECONDS - start))
  STEP_STATUS+=("$id:ok")
done

success "All modules completed"
```

- [ ] **Step 2: Make it executable and syntax-check**

```bash
chmod +x vps/main.sh
bash -n vps/main.sh
```

Expected: no output.

- [ ] **Step 3: Lint**

```bash
command -v shellcheck && shellcheck -x vps/main.sh
```

Expected: no output. (`-x` follows the source directives.)

- [ ] **Step 4: Verify the `--help` and `--list` flags**

```bash
vps/main.sh --help
```

Expected: usage text printed, exit 0.

```bash
vps/main.sh --list
```

Expected: the manifest table prints (no log file created because LIST_ONLY exits before `setup_logging`).

- [ ] **Step 5: Commit**

```bash
git add vps/main.sh
git commit -m "Add main.sh runner with flag parsing and module loop"
```

---

## Task 10: install.sh (bootstrap)

**Files:**
- Create: `vps/install.sh`

- [ ] **Step 1: Write `vps/install.sh`**

```bash
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
```

- [ ] **Step 2: Make executable, syntax-check, lint**

```bash
chmod +x vps/install.sh
bash -n vps/install.sh
command -v shellcheck && shellcheck vps/install.sh
```

Expected: no output from any command.

- [ ] **Step 3: Verify the script can be parsed via curl-like piping (no execution since we're not on a VPS)**

```bash
bash -n < vps/install.sh
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add vps/install.sh
git commit -m "Add install.sh bootstrap (sparse-clone + exec main.sh)"
```

---

## Task 11: Module — apt-mirror

**Files:**
- Create: `vps/modules/apt-mirror/run.sh`
- Create: `vps/modules/apt-mirror/templates/ubuntu.sources.tmpl`

- [ ] **Step 1: Write the template `vps/modules/apt-mirror/templates/ubuntu.sources.tmpl`**

```
Types: deb
URIs: https://mirror.pilotfiber.com/ubuntu/
Suites: ${UBUNTU_CODENAME} ${UBUNTU_CODENAME}-updates ${UBUNTU_CODENAME}-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirror.pilotfiber.com/ubuntu/
Suites: ${UBUNTU_CODENAME}-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb-src
URIs: https://mirror.pilotfiber.com/ubuntu/
Suites: ${UBUNTU_CODENAME} ${UBUNTU_CODENAME}-updates ${UBUNTU_CODENAME}-backports ${UBUNTU_CODENAME}-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

- [ ] **Step 2: Write `vps/modules/apt-mirror/run.sh`**

```bash
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
```

- [ ] **Step 3: Syntax-check and lint**

```bash
bash -n vps/modules/apt-mirror/run.sh
command -v shellcheck && shellcheck vps/modules/apt-mirror/run.sh
```

Expected: no output. (The module file relies on globals like `MODULE_DIR` and `UBUNTU_CODENAME` set by the runner; shellcheck may need a directive — if it warns, add `# shellcheck disable=SC2154` on the line above the offending reference.)

- [ ] **Step 4: Commit**

```bash
git add vps/modules/apt-mirror/
git commit -m "Add apt-mirror module (Pilot Fiber, codename-templated)"
```

---

## Task 12: Module — system (hostname + timezone)

**Files:**
- Create: `vps/modules/system/run.sh`

- [ ] **Step 1: Write `vps/modules/system/run.sh`**

```bash
#
# System Settings — hostname and timezone
#
# What it does:
#   - Sets hostname via hostnamectl
#   - Updates /etc/hosts so 127.0.1.1 resolves to the new hostname
#   - Sets timezone via timedatectl
# Files written/touched:
#   - /etc/hostname (via hostnamectl)
#   - /etc/hosts (in-place edit; original backed up)
#   - /etc/timezone, /etc/localtime (via timedatectl)
# Idempotent: yes — skips if already at desired values.
#

module_run() {
  local backup_dir="${PWD}/vps-bootstrap-backup"
  mkdir -p "$backup_dir"

  # ── Hostname ─────────────────────────────────────────────────────
  local cur_host
  cur_host=$(hostname)
  if [[ "$HOSTNAME" != "$cur_host" ]]; then
    info "Setting hostname: $cur_host → $HOSTNAME"
    cp /etc/hosts "$backup_dir/hosts.$(date +%H%M%S)"
    hostnamectl set-hostname "$HOSTNAME"
    if grep -qE '^127\.0\.1\.1\b' /etc/hosts; then
      sed -i -E "s/^127\.0\.1\.1\b.*/127.0.1.1\t$HOSTNAME/" /etc/hosts
    else
      printf "127.0.1.1\t%s\n" "$HOSTNAME" >>/etc/hosts
    fi
    success "Hostname is now $HOSTNAME"
  else
    success "Hostname unchanged ($cur_host)"
  fi

  # ── Timezone ─────────────────────────────────────────────────────
  local cur_tz
  cur_tz=$(timedatectl show -p Timezone --value 2>/dev/null || echo UTC)
  if [[ "$TIMEZONE" != "$cur_tz" ]]; then
    info "Setting timezone: $cur_tz → $TIMEZONE"
    timedatectl set-timezone "$TIMEZONE"
    success "Timezone is now $TIMEZONE"
  else
    success "Timezone unchanged ($cur_tz)"
  fi
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/system/run.sh
command -v shellcheck && shellcheck vps/modules/system/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/system/
git commit -m "Add system module (hostname + timezone)"
```

---

## Task 13: Module — update (apt update + upgrade)

**Files:**
- Create: `vps/modules/update/run.sh`

- [ ] **Step 1: Write `vps/modules/update/run.sh`**

```bash
#
# System Update
#
# What it does:
#   - apt-get update
#   - apt-get upgrade (best-effort: warn on failure, don't abort)
#   - apt-get autoremove (best-effort)
# Files written/touched:
#   - none directly (apt does the work)
# Idempotent: yes (re-running is safe and a no-op if already up to date)
#

module_run() {
  export DEBIAN_FRONTEND=noninteractive

  run_step "Updating package lists" apt-get update -y -q
  run_step "Upgrading installed packages" apt-get upgrade -y -q || \
    warn "Some packages failed to upgrade (continuing — see log for details)"
  run_step "Removing unused packages" apt-get autoremove -y -q || true
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/update/run.sh
command -v shellcheck && shellcheck vps/modules/update/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/update/
git commit -m "Add update module (apt update/upgrade/autoremove)"
```

---

## Task 14: Module — packages

**Files:**
- Create: `vps/modules/packages/packages.list`
- Create: `vps/modules/packages/run.sh`

- [ ] **Step 1: Write `vps/modules/packages/packages.list`**

```
# vps/modules/packages/packages.list
# One package per line. Lines beginning with # and blank lines are ignored.

# ── Build tools ────────────────────────────────────────────────
build-essential
automake
autoconf
libreadline-dev
libncurses-dev
libssl-dev
libyaml-dev
libxslt-dev
libffi-dev
libtool
unixodbc-dev
openssl
zlib1g-dev

# ── System utilities ───────────────────────────────────────────
software-properties-common
apt-transport-https
ca-certificates
gnupg
lsb-release

# ── Security tools ─────────────────────────────────────────────
ufw
fail2ban
unattended-upgrades
apt-listchanges

# ── Dev tools ──────────────────────────────────────────────────
git
curl
wget
unzip
jq

# ── Text processing ────────────────────────────────────────────
ripgrep
fd-find
fzf
bat

# ── Monitoring ─────────────────────────────────────────────────
btop
htop
ncdu
iotop
nethogs

# ── Terminal tools ─────────────────────────────────────────────
tmux
zsh
stow
tig
tree

# ── Network tools ──────────────────────────────────────────────
net-tools
dnsutils
traceroute
mtr
whois
```

- [ ] **Step 2: Write `vps/modules/packages/run.sh`**

```bash
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
```

- [ ] **Step 3: Syntax-check and lint**

```bash
bash -n vps/modules/packages/run.sh
command -v shellcheck && shellcheck vps/modules/packages/run.sh
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add vps/modules/packages/
git commit -m "Add packages module + packages.list"
```

---

## Task 15: Module — neovim

**Files:**
- Create: `vps/modules/neovim/run.sh`

- [ ] **Step 1: Write `vps/modules/neovim/run.sh`**

```bash
#
# Neovim (latest unstable from PPA)
#
# What it does:
#   - Adds the official ppa:neovim-ppa/unstable
#   - Installs neovim from that PPA
# Files written/touched:
#   - /etc/apt/sources.list.d/neovim-ppa-ubuntu-unstable-*.list
# Idempotent: yes (add-apt-repository is idempotent; apt-get install is idempotent)
#

module_run() {
  export DEBIAN_FRONTEND=noninteractive

  run_step "Adding neovim PPA" add-apt-repository -y ppa:neovim-ppa/unstable
  run_step "Refreshing apt after PPA add" apt-get update -y -q
  run_step "Installing neovim" apt-get install -y -q neovim
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/neovim/run.sh
command -v shellcheck && shellcheck vps/modules/neovim/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/neovim/
git commit -m "Add neovim module (PPA install)"
```

---

## Task 16: Module — user

**Files:**
- Create: `vps/modules/user/run.sh`

- [ ] **Step 1: Write `vps/modules/user/run.sh`**

```bash
#
# Admin User & Sudo
#
# What it does:
#   - If $USERNAME is empty, skips entirely
#   - Otherwise creates the user with zsh shell (or noop if user exists)
#   - Adds them to the sudo group
#   - Sets the password from $PASSWORD (trace bracketed off so it doesn't leak)
#   - Installs SSH key:
#       * Copies /root/.ssh/authorized_keys to the new user (if root has any)
#       * Or installs $SSH_PUBKEY if it was queued by prompt_config
# Files written/touched:
#   - /etc/passwd, /etc/shadow, /etc/group (via useradd/usermod/chpasswd)
#   - /home/$USERNAME/.ssh/authorized_keys
# Idempotent: yes — safe to re-run; password is reset, key is appended once.
#

module_run() {
  if [[ -z "$USERNAME" ]]; then
    info "No username configured — skipping user creation"
    return 0
  fi

  if id "$USERNAME" >/dev/null 2>&1; then
    info "User $USERNAME already exists — ensuring sudo group membership"
    usermod -aG sudo "$USERNAME"
  else
    info "Creating user $USERNAME with /usr/bin/zsh shell"
    useradd -m -s /usr/bin/zsh "$USERNAME"
    usermod -aG sudo "$USERNAME"
    success "Created $USERNAME"
  fi

  if [[ -n "$PASSWORD" ]]; then
    { set +x; } 2>/dev/null
    printf "%s:%s\n" "$USERNAME" "$PASSWORD" | chpasswd
    set -x
    success "Password set for $USERNAME"
  fi

  # ── SSH key for the new user ─────────────────────────────────────
  local user_home="/home/$USERNAME"
  local user_ssh="$user_home/.ssh"
  local user_keys="$user_ssh/authorized_keys"

  install -d -m 700 -o "$USERNAME" -g "$USERNAME" "$user_ssh"

  # Source 1: copy root's authorized_keys if present
  if [[ -s /root/.ssh/authorized_keys ]] && [[ ! -s "$user_keys" ]]; then
    cp /root/.ssh/authorized_keys "$user_keys"
    chown "$USERNAME:$USERNAME" "$user_keys"
    chmod 600 "$user_keys"
    success "Copied root's authorized_keys to $USERNAME"
  fi

  # Source 2: install $SSH_PUBKEY if it was queued
  if [[ -n "${SSH_PUBKEY:-}" ]]; then
    if ! grep -qF "$SSH_PUBKEY" "$user_keys" 2>/dev/null; then
      printf "%s\n" "$SSH_PUBKEY" >>"$user_keys"
      chown "$USERNAME:$USERNAME" "$user_keys"
      chmod 600 "$user_keys"
      success "Installed SSH key for $USERNAME"
    fi
    # Also install for root, in case prompt_config queued the key because
    # /root/.ssh/authorized_keys was empty.
    install -d -m 700 /root/.ssh
    if ! grep -qF "$SSH_PUBKEY" /root/.ssh/authorized_keys 2>/dev/null; then
      printf "%s\n" "$SSH_PUBKEY" >>/root/.ssh/authorized_keys
      chmod 600 /root/.ssh/authorized_keys
      success "Installed SSH key for root"
    fi
  fi
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/user/run.sh
command -v shellcheck && shellcheck vps/modules/user/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/user/
git commit -m "Add user module (admin user, sudo, SSH key)"
```

---

## Task 17: Module — ssh

**Files:**
- Create: `vps/modules/ssh/files/99-hardening.conf`
- Create: `vps/modules/ssh/run.sh`

- [ ] **Step 1: Write `vps/modules/ssh/files/99-hardening.conf`**

This is a template (rendered with envsubst). It supports `${SSH_PORT}` and `${ALLOW_USERS}`.

```
# /etc/ssh/sshd_config.d/99-vps-hardening.conf — managed by vps-bootstrap
Port ${SSH_PORT}
PasswordAuthentication no
PermitRootLogin prohibit-password
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 3
X11Forwarding no
PrintMotd no
GSSAPIAuthentication no
KbdInteractiveAuthentication no
AllowUsers ${ALLOW_USERS}
ClientAliveInterval 300
ClientAliveCountMax 2
Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
```

- [ ] **Step 2: Write `vps/modules/ssh/run.sh`**

```bash
#
# SSH Hardening
#
# What it does:
#   - Refuses to run if no authorized_keys exist anywhere (key safety gate)
#   - Disables /etc/ssh/sshd_config.d/50-cloud-init.conf if present (it
#     re-enables PasswordAuthentication on cloud images)
#   - Renders /etc/ssh/sshd_config.d/99-vps-hardening.conf from
#     $MODULE_DIR/files/99-hardening.conf (template; uses envsubst)
#   - Validates with `sshd -t`. On failure: removes the drop-in, restores
#     the cloud-init drop-in, dies.
#   - Restarts ssh.
# Files written/touched:
#   - /etc/ssh/sshd_config.d/99-vps-hardening.conf (drop-in)
#   - /etc/ssh/sshd_config.d/50-cloud-init.conf (renamed to .disabled if present)
# Idempotent: yes — drop-in is overwritten each run.
#

module_run() {
  # ── Safety gate: don't disable password auth without keys ────────
  local have_keys=0
  [[ -s /root/.ssh/authorized_keys ]] && have_keys=1
  if [[ -n "$USERNAME" ]] && [[ -s "/home/$USERNAME/.ssh/authorized_keys" ]]; then
    have_keys=1
  fi
  if (( have_keys == 0 )); then
    die "SSH key safety: no authorized_keys found. Refusing to disable password auth."
  fi

  # ── Disable cloud-init drop-in if present ────────────────────────
  if [[ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]]; then
    mv /etc/ssh/sshd_config.d/50-cloud-init.conf \
       /etc/ssh/sshd_config.d/50-cloud-init.conf.disabled
    info "Disabled /etc/ssh/sshd_config.d/50-cloud-init.conf"
  fi

  # ── Render the hardening drop-in ─────────────────────────────────
  local drop_in=/etc/ssh/sshd_config.d/99-vps-hardening.conf
  local allow_users="root"
  if [[ -n "$USERNAME" ]]; then
    allow_users="root $USERNAME"
  fi

  SSH_PORT="$SSH_PORT" ALLOW_USERS="$allow_users" \
    envsubst <"$MODULE_DIR/files/99-hardening.conf" >"$drop_in"

  # ── Validate, then restart (rollback on failure) ─────────────────
  if ! sshd -t 2>>"$LOG_FILE"; then
    rm -f "$drop_in"
    if [[ -f /etc/ssh/sshd_config.d/50-cloud-init.conf.disabled ]]; then
      mv /etc/ssh/sshd_config.d/50-cloud-init.conf.disabled \
         /etc/ssh/sshd_config.d/50-cloud-init.conf
    fi
    die "sshd config validation failed — drop-in removed, cloud-init drop-in restored"
  fi

  run_step "Restarting ssh" systemctl restart ssh
  success "SSH hardened on port $SSH_PORT (users: $allow_users)"
  warn "Reconnect with: ssh -p $SSH_PORT ${USERNAME:-root}@<host>"
}
```

- [ ] **Step 3: Syntax-check and lint**

```bash
bash -n vps/modules/ssh/run.sh
command -v shellcheck && shellcheck vps/modules/ssh/run.sh
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add vps/modules/ssh/
git commit -m "Add ssh module (drop-in hardening with key-safety gate)"
```

---

## Task 18: Module — firewall

**Files:**
- Create: `vps/modules/firewall/run.sh`

- [ ] **Step 1: Write `vps/modules/firewall/run.sh`**

```bash
#
# UFW Firewall
#
# What it does:
#   - Resets UFW to defaults (force)
#   - Default-deny incoming, default-allow outgoing
#   - Allows $SSH_PORT/tcp, 80/tcp, 443/tcp
#   - Enables UFW
# Files written/touched:
#   - /etc/ufw/* (managed by ufw)
# Idempotent: yes — reset + reconfigure on each run.
#

module_run() {
  run_step "Resetting UFW" ufw --force reset
  run_step "Default deny incoming" ufw default deny incoming
  run_step "Default allow outgoing" ufw default allow outgoing
  run_step "Allowing SSH ($SSH_PORT/tcp)" ufw allow "$SSH_PORT/tcp" comment 'SSH (vps-bootstrap)'
  run_step "Allowing HTTP (80/tcp)"  ufw allow 80/tcp  comment 'HTTP (vps-bootstrap)'
  run_step "Allowing HTTPS (443/tcp)" ufw allow 443/tcp comment 'HTTPS (vps-bootstrap)'
  # `ufw enable` reads from stdin; pipe "y" to confirm.
  run_step "Enabling UFW" bash -c 'echo y | ufw enable'
  success "Firewall enabled with SSH on $SSH_PORT, plus 80 and 443"
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/firewall/run.sh
command -v shellcheck && shellcheck vps/modules/firewall/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/firewall/
git commit -m "Add firewall module (UFW: deny incoming, allow ssh/80/443)"
```

---

## Task 19: Module — fail2ban

**Files:**
- Create: `vps/modules/fail2ban/templates/vps.local.tmpl`
- Create: `vps/modules/fail2ban/filters/traefik-auth.conf`
- Create: `vps/modules/fail2ban/filters/traefik-badbots.conf`
- Create: `vps/modules/fail2ban/filters/traefik-ratelimit.conf`
- Create: `vps/modules/fail2ban/run.sh`

- [ ] **Step 1: Write `vps/modules/fail2ban/templates/vps.local.tmpl`**

```
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = root@localhost
sendername = Fail2Ban
action = %(action_mwl)s
backend = systemd

[sshd]
enabled = true
port = ${SSH_PORT}
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[sshd-ddos]
enabled = true
port = ${SSH_PORT}
filter = sshd-ddos
logpath = /var/log/auth.log
maxretry = 10
findtime = 60
bantime = 600

[recidive]
enabled = true
filter = recidive
logpath = /var/log/fail2ban.log
action = %(action_mwl)s
bantime = 86400
findtime = 86400
maxretry = 2

[traefik-auth]
enabled = true
port = http,https
filter = traefik-auth
logpath = /var/log/traefik/access.log
maxretry = 5
bantime = 3600

[traefik-ratelimit]
enabled = true
port = http,https
filter = traefik-ratelimit
logpath = /var/log/traefik/access.log
maxretry = 100
findtime = 60
bantime = 600

[traefik-badbots]
enabled = true
port = http,https
filter = traefik-badbots
logpath = /var/log/traefik/access.log
maxretry = 2
bantime = 86400
```

- [ ] **Step 2: Write `vps/modules/fail2ban/filters/traefik-auth.conf`**

```
# Fail2Ban filter for Traefik unauthorized access attempts
[Definition]
failregex = ^<HOST> \- \S+ \[.*\] "[^"]*" 401
            ^<HOST> \- \S+ \[.*\] "[^"]*" 403
ignoreregex =
```

- [ ] **Step 3: Write `vps/modules/fail2ban/filters/traefik-badbots.conf`**

```
# Fail2Ban filter for Traefik bad bots and scanners
[Definition]
badbots = Googlebot|bingbot|Baiduspider|yandex|facebookexternalhit|twitterbot|rogerbot|linkedinbot|embedly|quora link preview|showyoubot|outbrain|pinterest|slackbot|vkShare|W3C_Validator|whatsapp|Mediatoolkitbot|ahrefsbot|semrushbot|dotbot|applebot|duckduckbot
failregex = ^<HOST> \- \S+ \[.*\] "(?:GET|POST|HEAD) [^"]+" [0-9]{3} [0-9]+ "[^"]*" "(?i)(?:%(badbots)s)[^"]*"$
            ^<HOST> \- \S+ \[.*\] "(?:GET|POST|HEAD) (?:/\.git|/\.env|/wp-admin|/phpMyAdmin|/phpmyadmin|/pma|/admin|/\.aws|/config\.json|/\.svn|/\.hg)[^"]*" [0-9]{3}
ignoreregex =
```

- [ ] **Step 4: Write `vps/modules/fail2ban/filters/traefik-ratelimit.conf`**

```
# Fail2Ban filter for Traefik rate limiting
[Definition]
failregex = ^<HOST> \- \S+ \[.*\] "[^"]*" 429
ignoreregex =
```

- [ ] **Step 5: Write `vps/modules/fail2ban/run.sh`**

```bash
#
# Fail2ban
#
# What it does:
#   - Renders the jail config to /etc/fail2ban/jail.d/vps.local from a
#     template (substitutes $SSH_PORT)
#   - Copies the traefik-* filters to /etc/fail2ban/filter.d/
#   - Enables and restarts fail2ban
# Files written/touched:
#   - /etc/fail2ban/jail.d/vps.local (drop-in; OS keeps stock jail.conf)
#   - /etc/fail2ban/filter.d/traefik-auth.conf
#   - /etc/fail2ban/filter.d/traefik-badbots.conf
#   - /etc/fail2ban/filter.d/traefik-ratelimit.conf
# Idempotent: yes — files overwritten each run; service restart is fine.
#

module_run() {
  install -d -m 755 /etc/fail2ban/jail.d /etc/fail2ban/filter.d

  SSH_PORT="$SSH_PORT" envsubst \
    <"$MODULE_DIR/templates/vps.local.tmpl" \
    >/etc/fail2ban/jail.d/vps.local
  success "Wrote /etc/fail2ban/jail.d/vps.local"

  for f in "$MODULE_DIR"/filters/*.conf; do
    cp "$f" /etc/fail2ban/filter.d/
    info "Installed filter $(basename "$f")"
  done

  run_step "Enabling fail2ban" systemctl enable fail2ban
  run_step "Restarting fail2ban" systemctl restart fail2ban
  success "Fail2ban active with SSH and Traefik jails"
}
```

- [ ] **Step 6: Syntax-check and lint**

```bash
bash -n vps/modules/fail2ban/run.sh
command -v shellcheck && shellcheck vps/modules/fail2ban/run.sh
```

Expected: no output.

- [ ] **Step 7: Commit**

```bash
git add vps/modules/fail2ban/
git commit -m "Add fail2ban module (jail.d drop-in + traefik filters)"
```

---

## Task 20: Module — auto-updates

**Files:**
- Create: `vps/modules/auto-updates/run.sh`

- [ ] **Step 1: Write `vps/modules/auto-updates/run.sh`**

```bash
#
# Unattended Upgrades
#
# What it does:
#   - Writes /etc/apt/apt.conf.d/99-vps-upgrades drop-in (security-only origins,
#     no auto-reboot, kernel/dependency cleanup on)
#   - Enables the unattended-upgrades systemd unit
# Files written/touched:
#   - /etc/apt/apt.conf.d/99-vps-upgrades (drop-in; stock 50unattended-upgrades
#     and 20auto-upgrades remain untouched)
# Idempotent: yes — drop-in overwritten each run.
#

module_run() {
  cat >/etc/apt/apt.conf.d/99-vps-upgrades <<'CONF'
// Managed by vps-bootstrap.
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
APT::Periodic::Download-Upgradeable-Packages "1";
CONF

  run_step "Enabling unattended-upgrades" systemctl enable unattended-upgrades
  success "Auto-updates configured (security-only, no auto-reboot)"
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/auto-updates/run.sh
command -v shellcheck && shellcheck vps/modules/auto-updates/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/auto-updates/
git commit -m "Add auto-updates module (security-only drop-in)"
```

---

## Task 21: Module — sysctl

**Files:**
- Create: `vps/modules/sysctl/files/99-vps-hardening.conf`
- Create: `vps/modules/sysctl/run.sh`

- [ ] **Step 1: Write `vps/modules/sysctl/files/99-vps-hardening.conf`**

```
# /etc/sysctl.d/99-vps-hardening.conf — managed by vps-bootstrap

# Swap
vm.swappiness = 10

# Network — reverse path, ICMP, redirects, source routing, syncookies
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
```

- [ ] **Step 2: Write `vps/modules/sysctl/run.sh`**

```bash
#
# Kernel & Network Hardening (sysctl)
#
# What it does:
#   - Installs /etc/sysctl.d/99-vps-hardening.conf
#   - Reloads sysctl from drop-ins
# Files written/touched:
#   - /etc/sysctl.d/99-vps-hardening.conf (drop-in)
# Idempotent: yes — file overwritten each run.
#

module_run() {
  install -m 644 "$MODULE_DIR/files/99-vps-hardening.conf" \
    /etc/sysctl.d/99-vps-hardening.conf

  run_step "Applying sysctl drop-ins" sysctl --system
  success "Kernel/network hardening applied"
}
```

- [ ] **Step 3: Syntax-check and lint**

```bash
bash -n vps/modules/sysctl/run.sh
command -v shellcheck && shellcheck vps/modules/sysctl/run.sh
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add vps/modules/sysctl/
git commit -m "Add sysctl module (network/kernel hardening drop-in)"
```

---

## Task 22: Module — swap

**Files:**
- Create: `vps/modules/swap/run.sh`

- [ ] **Step 1: Write `vps/modules/swap/run.sh`**

```bash
#
# Swap File
#
# What it does:
#   - Skips if any swap is already active
#   - Sizes the swap as: min(2*RAM, 4096MB) when RAM < 2GB, else 4096MB
#   - Creates /swapfile, sets perms 600, mkswap, swapon
#   - Adds to /etc/fstab if not already present
# Files written/touched:
#   - /swapfile (created)
#   - /etc/fstab (line appended if missing)
# Idempotent: yes — checks before doing.
#

module_run() {
  if (( $(swapon --noheadings | wc -l) > 0 )); then
    info "Swap already active — skipping"
    return 0
  fi

  local total_mb size_mb
  total_mb=$(awk '/^MemTotal:/ {print int($2/1024)}' /proc/meminfo)
  if (( total_mb < 2048 )); then
    size_mb=$((total_mb * 2))
  else
    size_mb=4096
  fi

  info "Creating ${size_mb}MB swap (RAM: ${total_mb}MB)..."
  run_step "Allocating /swapfile" fallocate -l "${size_mb}M" /swapfile
  chmod 600 /swapfile
  run_step "Formatting swap" mkswap /swapfile
  run_step "Activating swap" swapon /swapfile

  if ! grep -qE '^\s*/swapfile\b' /etc/fstab; then
    printf "/swapfile none swap sw 0 0\n" >>/etc/fstab
    info "Added /swapfile to /etc/fstab"
  fi

  success "Swap active (${size_mb}MB)"
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/swap/run.sh
command -v shellcheck && shellcheck vps/modules/swap/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/swap/
git commit -m "Add swap module (size-aware /swapfile + fstab)"
```

---

## Task 23: Module — docker

**Files:**
- Create: `vps/modules/docker/files/daemon.json`
- Create: `vps/modules/docker/run.sh`

- [ ] **Step 1: Write `vps/modules/docker/files/daemon.json`**

```json
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "live-restore": true,
    "userland-proxy": false
}
```

- [ ] **Step 2: Write `vps/modules/docker/run.sh`**

```bash
#
# Docker Engine (optional)
#
# What it does:
#   - Skips if $INSTALL_DOCKER is not "yes"
#   - Adds Docker's apt repo (using the version codename)
#   - Installs docker-ce + plugins
#   - Copies daemon.json
#   - Adds the admin user to the docker group (if any)
#   - Installs Lazydocker (best-effort)
# Files written/touched:
#   - /etc/apt/keyrings/docker.asc
#   - /etc/apt/sources.list.d/docker.list
#   - /etc/docker/daemon.json
#   - /usr/local/bin/lazydocker (if Lazydocker installs)
# Idempotent: yes — apt operations and copy are idempotent.
#

module_run() {
  if [[ "${INSTALL_DOCKER:-no}" != "yes" ]]; then
    info "Docker not requested — skipping"
    return 0
  fi

  export DEBIAN_FRONTEND=noninteractive

  install -d -m 0755 /etc/apt/keyrings
  run_step "Fetching Docker GPG key" \
    bash -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc'
  chmod a+r /etc/apt/keyrings/docker.asc

  local arch
  arch=$(dpkg --print-architecture)
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu %s stable\n' \
    "$arch" "$UBUNTU_CODENAME" >/etc/apt/sources.list.d/docker.list

  run_step "Refreshing apt for Docker repo" apt-get update -y -q
  run_step "Installing Docker engine + plugins" \
    apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  install -d -m 755 /etc/docker
  install -m 644 "$MODULE_DIR/files/daemon.json" /etc/docker/daemon.json

  run_step "Enabling docker"     systemctl enable docker
  run_step "Enabling containerd" systemctl enable containerd
  run_step "Restarting docker"   systemctl restart docker

  if [[ -n "$USERNAME" ]]; then
    usermod -aG docker "$USERNAME"
    info "Added $USERNAME to docker group (logout/login required to take effect)"
  fi

  # ── Lazydocker (best-effort) ─────────────────────────────────────
  info "Installing Lazydocker..."
  if curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh \
       | bash >>"$LOG_FILE" 2>&1; then
    if [[ -f "$HOME/.local/bin/lazydocker" ]]; then
      mv "$HOME/.local/bin/lazydocker" /usr/local/bin/
      chmod +x /usr/local/bin/lazydocker
      success "Lazydocker installed to /usr/local/bin/lazydocker"
    else
      warn "Lazydocker installer ran but binary not found"
    fi
  else
    warn "Lazydocker install failed — see log"
  fi

  success "Docker installed and configured"
}
```

- [ ] **Step 3: Syntax-check and lint**

```bash
bash -n vps/modules/docker/run.sh
command -v shellcheck && shellcheck vps/modules/docker/run.sh
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add vps/modules/docker/
git commit -m "Add docker module (engine + daemon.json + lazydocker)"
```

---

## Task 24: Module — audit

**Files:**
- Create: `vps/modules/audit/run.sh`

- [ ] **Step 1: Write `vps/modules/audit/run.sh`**

```bash
#
# Security Audit (read-only)
#
# What it does:
#   - Warns about default users (pi, ubuntu, debian) if present
#   - Warns about weak SSH keys (RSA < 2048 bits)
#   - Warns about unnecessary services running (telnet, rsh, etc.)
# Files written/touched:
#   - none
# Idempotent: yes — read-only.
#

module_run() {
  # ── Default users ────────────────────────────────────────────────
  for u in pi ubuntu debian; do
    if id "$u" >/dev/null 2>&1; then
      warn "Default user '$u' exists — consider removing"
    fi
  done

  # ── Weak SSH keys (root + admin user) ────────────────────────────
  local homes=(/root)
  [[ -n "$USERNAME" ]] && homes+=("/home/$USERNAME")
  for home in "${homes[@]}"; do
    local auth="$home/.ssh/authorized_keys"
    [[ -s "$auth" ]] || continue
    while IFS= read -r key; do
      [[ "$key" =~ ssh-rsa ]] || continue
      local bits
      bits=$(printf "%s" "$key" | ssh-keygen -l -f - 2>/dev/null | awk '{print $1}') || continue
      if [[ "$bits" =~ ^[0-9]+$ ]] && (( bits < 2048 )); then
        warn "Weak RSA key ($bits bits) in $auth"
      fi
    done <"$auth"
  done

  # ── Unnecessary services ─────────────────────────────────────────
  local svcs=(telnet rsh-server rlogin vsftpd)
  for svc in "${svcs[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
      warn "Unnecessary service running: $svc"
    fi
  done

  success "Audit complete"
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/audit/run.sh
command -v shellcheck && shellcheck vps/modules/audit/run.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add vps/modules/audit/
git commit -m "Add audit module (read-only security checks)"
```

---

## Task 25: Module — summary

**Files:**
- Create: `vps/modules/summary/run.sh`

- [ ] **Step 1: Write `vps/modules/summary/run.sh`**

```bash
#
# Setup Summary
#
# What it does:
#   - Writes ./vps-bootstrap-summary.txt (cwd) — human-readable summary
#   - Writes ./vps-bootstrap.stamp (cwd) — key=value, used by preflight's
#     prior-run detection on subsequent runs
#   - Prints the same content (colorized) to stdout
# Files written/touched:
#   - ./vps-bootstrap-summary.txt
#   - ./vps-bootstrap.stamp
# Idempotent: yes — files overwritten each run.
#

module_run() {
  local summary="${PWD}/vps-bootstrap-summary.txt"
  local stamp="${PWD}/vps-bootstrap.stamp"

  local reboot_needed="no"
  [[ -f /var/run/reboot-required ]] && reboot_needed="yes"

  # ── Build human-readable summary ─────────────────────────────────
  {
    printf "vps-bootstrap summary\n"
    printf "=====================\n"
    printf "date:           %s\n" "$(date -Is)"
    printf "hostname:       %s\n" "$(hostname)"
    printf "Ubuntu:         %s (%s)\n" "$UBUNTU_VERSION_ID" "$UBUNTU_CODENAME"
    printf "admin user:     %s\n" "${USERNAME:-[none — root only]}"
    printf "SSH port:       %s\n" "$SSH_PORT"
    printf "timezone:       %s\n" "$TIMEZONE"
    printf "Docker:         %s\n" "$INSTALL_DOCKER"
    printf "reboot needed:  %s\n" "$reboot_needed"
    printf "log file:       %s\n" "$LOG_FILE"
    printf "\n"
    printf "Modules executed (id : seconds)\n"
    printf "-------------------------------\n"
    for entry in "${SELECTED[@]}"; do
      local id="${entry%%|*}"
      printf "  %-15s %s\n" "$id" "${STEP_TIMINGS[$id]:-?}"
    done
    printf "\n"
    printf "Important next steps\n"
    printf "--------------------\n"
    printf "  1. Open a NEW terminal and verify SSH works on the new port:\n"
    printf "       ssh -p %s %s@<host>\n" "$SSH_PORT" "${USERNAME:-root}"
    printf "     Do NOT close this session until you've confirmed.\n"
    if [[ "$reboot_needed" == "yes" ]]; then
      printf "  2. Reboot when convenient: sudo reboot\n"
    fi
  } | tee "$summary" >/dev/null

  # ── Stamp file ───────────────────────────────────────────────────
  {
    printf "date=%s\n" "$(date -Is)"
    printf "hostname=%s\n" "$(hostname)"
    printf "version=%s\n" "$UBUNTU_VERSION_ID"
    printf "ssh_port=%s\n" "$SSH_PORT"
    printf "user=%s\n" "${USERNAME:-}"
  } >"$stamp"

  success "Summary written: $summary"
  success "Stamp written:   $stamp"
  info "Log file:        $LOG_FILE"

  # Echo summary to stdout colorized.
  printf "\n%s━━ Summary ━━%s\n" "$C_BOLD$C_CYAN" "$C_RESET"
  cat "$summary"
}
```

- [ ] **Step 2: Syntax-check and lint**

```bash
bash -n vps/modules/summary/run.sh
command -v shellcheck && shellcheck vps/modules/summary/run.sh
```

Expected: no output. (`SELECTED` and `STEP_TIMINGS` are runner-set globals; if shellcheck warns, add `# shellcheck disable=SC2154` above the offending references.)

- [ ] **Step 3: Commit**

```bash
git add vps/modules/summary/
git commit -m "Add summary module (writes summary.txt and stamp)"
```

---

## Task 26: README.md

**Files:**
- Create: `vps/README.md`

- [ ] **Step 1: Write `vps/README.md`**

```markdown
# VPS Bootstrap

Modular Ubuntu 24.04 / 26.04 server bootstrap. Hardens SSH, configures the firewall, installs base packages, optionally installs Docker, and writes a setup summary.

## Quickstart

```bash
# Production (main branch)
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh | sudo bash

# Test from a feature branch (branch name in env var, no slashes)
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/feat_vps_rewrite/vps/install.sh \
  | sudo BRANCH=feat_vps_rewrite bash

# Same, with --branch arg form
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/feat_vps_rewrite/vps/install.sh \
  | sudo bash -s -- --branch feat_vps_rewrite
```

## What it does

The bootstrap iterates an ordered manifest of modules. Each module is a self-contained folder under `modules/` that defines a single `module_run` function. Configuration goes into `/etc/<svc>.d/99-vps-*` drop-ins where the OS supports it; templates with `envsubst` where interpolation is needed; in-place edits only when there's no other choice (e.g. `/etc/hosts`).

## Modules

| ID | Display Name | What it does |
|---|---|---|
| `apt-mirror` | APT Mirror Configuration | Replaces `/etc/apt/sources.list.d/ubuntu.sources` with the Pilot Fiber mirror, codename-templated. |
| `system` | System Settings | Hostname (`hostnamectl` + `/etc/hosts`) and timezone (`timedatectl`). |
| `update` | System Update | `apt update` + `upgrade` + `autoremove`. |
| `packages` | Base Packages | Installs everything in `modules/packages/packages.list`. |
| `neovim` | Neovim | Adds `ppa:neovim-ppa/unstable`, installs neovim. |
| `user` | Admin User & Sudo | Creates `$USERNAME` with zsh, adds to sudo, sets password, installs SSH key. |
| `ssh` | SSH Hardening | Drop-in `/etc/ssh/sshd_config.d/99-vps-hardening.conf` (custom port, no password auth, modern crypto). Validates with `sshd -t`; rolls back on failure. |
| `firewall` | UFW Firewall | Default-deny incoming; allows the SSH port plus 80/443. |
| `fail2ban` | Fail2ban | Drop-in `/etc/fail2ban/jail.d/vps.local` plus traefik filters. |
| `auto-updates` | Unattended Upgrades | Drop-in `/etc/apt/apt.conf.d/99-vps-upgrades` (security-only, no auto-reboot). |
| `sysctl` | Kernel & Network Hardening | Drop-in `/etc/sysctl.d/99-vps-hardening.conf` (swappiness, rp_filter, syncookies, etc.). |
| `swap` | Swap File | `/swapfile` sized by RAM (skipped if any swap already active). |
| `docker` | Docker Engine | Optional. Adds Docker's apt repo, installs engine + plugins, writes `/etc/docker/daemon.json`, adds the admin user to `docker` group. Installs Lazydocker. |
| `audit` | Security Audit | Read-only checks for default users, weak SSH keys, unnecessary services. |
| `summary` | Setup Summary | Writes `./vps-bootstrap-summary.txt` and `./vps-bootstrap.stamp`. |

## Flags

| Flag | Description |
|---|---|
| `--only ssh,firewall` | Run only listed modules (comma-separated ids) |
| `--skip docker,neovim` | Run all modules except listed |
| `--verbose`, `-v` | Stream all command output (no progress panel) |
| `--list` | Print the manifest and exit |
| `--branch <name>` | Bootstrap-only; equivalent to `BRANCH=<name>` |
| `--help`, `-h` | Print usage |

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `BRANCH` | `main` | Branch to clone in `install.sh` |
| `REPO` | `https://github.com/natsumi/dotfiles` | Repo URL in `install.sh` |
| `NO_COLOR` | unset | Set to disable ANSI colors |
| `VERBOSE` | `0` | Set to `1` for `--verbose` |
| `DEBUG` | `0` | Set to `1` to enable `debug()` output |

## Files produced

In your current working directory (where `main.sh` runs from — typically `/root` after a sudo + curl-pipe):

- `vps-bootstrap-YYYYMMDD-HHMMSS.log` — full log (ANSI-stripped, includes bash trace)
- `vps-bootstrap-summary.txt` — readable summary printed at the end
- `vps-bootstrap.stamp` — key=value record used by preflight's prior-run detection
- `vps-bootstrap-backup/` — originals of any in-place-edited files

## Adding a new module

1. `mkdir vps/modules/<id>`
2. Create `vps/modules/<id>/run.sh`:
   ```bash
   #
   # <Display Name>
   # What it does: …
   # Files written/touched: …
   # Idempotent: yes/no (notes)
   #
   module_run() {
     # use info / success / warn / error / die
     # use run_step "Description" cmd args... for long-running steps
     # $MODULE_DIR points to this directory
   }
   ```
3. Add an entry to `vps/manifest.sh`: `"<id>|<Display Name>"` at the right position.
4. Add a row to the table above.

## Troubleshooting

- **Locked out of SSH** — Use the VPS provider's console. The ssh module backs up the cloud-init drop-in to `…/50-cloud-init.conf.disabled`; restore it and `systemctl restart ssh` if needed. `ufw status` shows whether the new port is allowed.
- **A module failed** — The runner prints the last 20 lines of log inline. The full log is at `./vps-bootstrap-YYYYMMDD-HHMMSS.log`. Re-run with `--only <id>` after fixing.
- **Re-run safety** — Modules are idempotent. Re-running the whole script on the same server is supported.
- **Want to test changes from a branch** — `BRANCH=my_branch` (with underscores; the script expects no slashes).

## Spec

Design rationale lives in `docs/superpowers/specs/2026-04-30-vps-bootstrap-rewrite-design.md`.
```

- [ ] **Step 2: Verify markdown renders sanely (visual scan)**

```bash
head -40 vps/README.md
```

Expected: the front-matter, quickstart code block, and the start of the modules table.

- [ ] **Step 3: Commit**

```bash
git add vps/README.md
git commit -m "Add README for vps-bootstrap"
```

---

## Task 27: Final shellcheck pass and end-to-end syntax check

**Files:**
- Touch nothing — verification only.

- [ ] **Step 1: Syntax-check every shell file in the project**

```bash
find vps -type f -name '*.sh' -print0 \
  | xargs -0 -I{} bash -n {}
```

Expected: no output.

- [ ] **Step 2: Run shellcheck across every shell file (skip if not installed)**

```bash
if command -v shellcheck >/dev/null 2>&1; then
  # Files with shebangs
  shellcheck -x -e SC1091 vps/install.sh vps/main.sh
  # Sourced files (no shebang) — pass -s bash so shellcheck doesn't fall back to sh
  find vps/lib vps/modules vps/manifest.sh -type f -name '*.sh' -print0 \
    | xargs -0 shellcheck -s bash -x -e SC1091
else
  echo "shellcheck not installed — skipping (recommend: brew install shellcheck)"
fi
```

`-e SC1091` suppresses "file not found" warnings on dynamic source paths. Expected: no other warnings.

- [ ] **Step 3: Verify all manifest ids correspond to existing modules**

```bash
bash -c '
  source vps/manifest.sh
  for entry in "${MODULES[@]}"; do
    id="${entry%%|*}"
    if [[ ! -f "vps/modules/$id/run.sh" ]]; then
      echo "MISSING: vps/modules/$id/run.sh"
      exit 1
    fi
  done
  echo "all 15 modules present"
'
```

Expected: `all 15 modules present`.

- [ ] **Step 4: Verify every module run.sh defines `module_run`**

```bash
for f in vps/modules/*/run.sh; do
  if ! grep -qE '^module_run\(\)' "$f"; then
    echo "$f: missing module_run() definition"
    exit 1
  fi
done
echo "all modules define module_run()"
```

Expected: `all modules define module_run()`.

- [ ] **Step 5: Verify `--list` produces the expected manifest**

```bash
vps/main.sh --list
```

Expected: 15 rows + header. Compare against `vps/manifest.sh` for sanity.

- [ ] **Step 6: Verify `--help` works**

```bash
vps/main.sh --help
```

Expected: usage text, exit 0.

- [ ] **Step 7: Commit any cosmetic fixes that came out of this pass**

If any shellcheck warnings or syntax issues required edits, commit them now. Otherwise:

```bash
echo "Nothing to commit — verification only"
```

- [ ] **Step 8: Print the manual VPS smoke-test checklist for the user**

This is for the human, not the agent. Include in your task report:

> **Manual VPS smoke test (user runs after merging to main, or pushes the branch first):**
>
> 1. Spin up a fresh Ubuntu 24.04 (and 26.04) VM you can reset.
> 2. Push `feat_vps_rewrite` to GitHub: `git push origin feat_vps_rewrite`.
> 3. From the VM:
>    ```
>    curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/feat_vps_rewrite/vps/install.sh \
>      | sudo BRANCH=feat_vps_rewrite bash
>    ```
> 4. Watch for:
>    - All 15 modules show `✓` with timing
>    - The summary at the end lists timings, log path, reboot status
>    - SSH on the new port works from a second terminal **before** closing the first
>    - `cat vps-bootstrap-summary.txt` and `cat vps-bootstrap.stamp` look right
> 5. Repeat with `--only ssh` and `--skip docker,neovim` to verify filtering.
> 6. Repeat the whole thing on Ubuntu 26.04.
> 7. After validation, merge `feat_vps_rewrite` → `main`.

---

## Verification checklist (use after all tasks complete)

- [ ] `git log feat_vps_rewrite ^main --oneline` shows ~26 commits, one per task
- [ ] `find vps -type f` shows the file structure from the top of this plan
- [ ] `vps/main.sh --list` prints all 15 modules
- [ ] `vps/main.sh --help` prints usage
- [ ] `bash -n` succeeds on every `.sh` file in `vps/`
- [ ] `shellcheck` passes (or the warnings are documented)
- [ ] `vps/README.md` describes every module and every flag
- [ ] The spec at `docs/superpowers/specs/2026-04-30-vps-bootstrap-rewrite-design.md` is unchanged
