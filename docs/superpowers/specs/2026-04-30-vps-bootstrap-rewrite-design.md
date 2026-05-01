# VPS Bootstrap Rewrite — Design

**Date:** 2026-04-30
**Status:** Approved (brainstorm), pending implementation plan

## Overview

Replace the existing `vps/` directory in `dotfiles` with a redesigned, modular bootstrap toolkit for Ubuntu 24.04 and 26.04 servers. The current implementation is a single 944-line `setup.sh` plus a 169-line `install.sh`; it works but is hard to extend and read.

The rewrite keeps the feature set, splits it into self-contained modules, formalizes a single UI/logging library, and standardizes the file-write strategy across modules. Functionality stays roughly equivalent; the change is structural.

## Goals

1. **Code organization is the top priority.** A new module is a folder you drop in. A module file is a header comment plus one function.
2. **Bootable from a fresh server with a single `curl ... | sudo bash` invocation**, with branch override for testing.
3. **Pretty, informative TTY output** — colorized log helpers, a live 5-line scrolling tail of long-running commands, elapsed time per step.
4. **Robust logging.** Every command run is captured to a timestamped log file in cwd, ANSI-stripped, with bash trace.
5. **Failures are visible inline.** When a step fails, the last 20 log lines are reproduced where the user is looking.
6. **Drop-ins, not edits.** Where the OS supports it, configuration goes in `/etc/<svc>.d/99-vps-*` files so we don't track Ubuntu's stock configs.

## Non-goals

- Auto-reboot.
- Rollback / undo command (manual restore from backup dir if needed).
- Plugin system or external module loading. Fork the repo to extend.
- Dry-run mode.
- Per-prompt env-var overrides for unattended runs (always interactive).
- State-file-based skip-completed-modules. Modules are individually idempotent; re-running everything is the supported way.

## Constraints

- **Bash 4+** (Ubuntu 24.04 ships 5.x).
- **Ubuntu 24.04 LTS and Ubuntu 26.04 LTS** are the supported targets. Other distros are explicitly unsupported and the script aborts in preflight.
- Lives in `dotfiles/vps/` on a feature branch (`feat_vps_rewrite`); replaces the existing directory at merge time.
- All artifacts (logs, backups, summary, stamp file) go in cwd, not the user's home or `/etc`.

---

## Project layout

```
vps/
├── install.sh              # bootstrap — sparse-clones repo, exec main.sh
├── main.sh                 # runner — flags, preflight, prompts, module loop
├── manifest.sh             # ordered list of modules + display names
├── README.md               # quickstart, module table, flags, troubleshooting
├── lib/
│   ├── ui.sh               # colors, log helpers, prompts, run_step
│   ├── log.sh              # log file setup (tee + ANSI strip)
│   ├── config.sh           # interactive prompts for upfront values
│   └── preflight.sh        # OS / root / internet / safety checks
└── modules/
    ├── apt-mirror/
    │   ├── run.sh
    │   └── templates/ubuntu.sources.tmpl
    ├── system/             # hostname + timezone
    │   └── run.sh
    ├── update/             # apt update + upgrade
    │   └── run.sh
    ├── packages/
    │   ├── run.sh
    │   └── packages.list
    ├── neovim/
    │   └── run.sh
    ├── user/
    │   └── run.sh
    ├── ssh/
    │   ├── run.sh
    │   └── files/99-hardening.conf
    ├── firewall/
    │   └── run.sh
    ├── fail2ban/
    │   ├── run.sh
    │   ├── templates/vps.local.tmpl
    │   └── filters/        # traefik filters carried over from existing setup
    ├── auto-updates/
    │   └── run.sh
    ├── sysctl/
    │   ├── run.sh
    │   └── files/99-vps-hardening.conf
    ├── swap/
    │   └── run.sh
    ├── docker/
    │   ├── run.sh
    │   └── files/daemon.json
    ├── audit/
    │   └── run.sh
    └── summary/
        └── run.sh
```

### Notes on the layout

- **`packages/packages.list`** — newline-delimited package names, comments allowed. Adding a package = one line edit.
- **`apt-mirror`, `update`, `neovim` are separate modules** rather than sub-functions, so `--skip apt-mirror` / `--only update` / etc. work.
- **`system` covers hostname + timezone together** (both quick `*ctl` calls).

---

## Module manifest

`manifest.sh` is sourced by the runner. Each entry is a single string `id|Display Name`. Order is the array order.

```bash
MODULES=(
  # "apt-mirror|APT Mirror Configuration"  # disabled by default; uncomment to use the Pilot Fiber mirror
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

### Why this order

- `user` runs before `ssh` so the new user's `authorized_keys` exists before password auth is disabled.
- `ssh` runs before `firewall` so UFW knows the new SSH port (UFW reads `$SSH_PORT`).
- `apt-mirror` runs before `update` so updates pull from the configured mirror.
- `audit` and `summary` run last and are read-only.

---

## Module conventions

Every `modules/<id>/run.sh`:

```bash
#
# <Display Name>
#
# What it does:
#   - bullet
#   - bullet
# Files written/touched:
#   - /etc/.../foo.conf
# Idempotent: yes (or notes on what isn't)
#

module_run() {
  # body — uses info, warn, run_step, $MODULE_DIR, env vars from prompts
}
```

The runner pre-sets `$MODULE_DIR` to the module's directory so the module can reference its `files/`, `templates/`, etc. without hardcoding paths. The runner also sources `lib/ui.sh` once before the loop; modules don't re-source helpers, don't set `set -e`, and don't define globals.

The header comment is the contract. The README's module table is hand-written from these.

---

## Bootstrap flow — `install.sh`

The thin entrypoint behind `curl ... | sudo bash`. Responsibilities, in order:

1. Verify root, supported Ubuntu version, internet connectivity.
2. Install minimal deps if missing: `git`, `curl`, `ca-certificates`, `gettext-base` (for `envsubst`).
3. Decide branch: `BRANCH` env var first, then `--branch X` after `bash -s --`, default `main`.
4. Decide repo: `REPO` env var (default `https://github.com/natsumi/dotfiles`).
5. Sparse-clone the `vps/` subtree from that branch into `/tmp/vps-bootstrap-$$`.
6. `cd` into the clone, `exec ./main.sh "$@"` so flags pass through.
7. Cleanup on exit via trap.

### README invocation forms

```bash
# Production
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh \
  | sudo bash

# Test branch via env var (note underscores, no slashes)
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/feat_vps_rewrite/vps/install.sh \
  | sudo BRANCH=feat_vps_rewrite bash

# Test branch via args
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/feat_vps_rewrite/vps/install.sh \
  | sudo bash -s -- --branch feat_vps_rewrite
```

---

## Runner — `main.sh`

After sourcing libraries:

1. Parse flags (`--only`, `--skip`, `--verbose`, `--list`, `--branch`, `--help`).
2. Set up logging (cwd, timestamped).
3. Run `lib/preflight.sh` checks.
4. Run `lib/config.sh::prompt_config` — collect everything upfront.
5. Filter manifest by `--only` / `--skip`.
6. Loop:
   ```bash
   for entry in "${MODULES[@]}"; do
     id="${entry%%|*}"; name="${entry#*|}"
     [[ -n "$ONLY" && ! ",$ONLY," =~ ,"$id", ]] && continue
     [[ -n "$SKIP" && ",$SKIP," =~ ,"$id", ]] && continue
     MODULE_DIR="modules/$id"
     section "$n" "$total" "$name"
     source "$MODULE_DIR/run.sh"
     module_run
     unset -f module_run
     STEP_TIMINGS+=("$id:$elapsed")
   done
   ```
7. Print final summary.

---

## CLI flags & env vars

| Flag | Purpose |
|---|---|
| `--only ssh,firewall` | Run only listed modules (comma-separated ids) |
| `--skip docker,neovim` | Run all modules except listed |
| `--verbose` / `-v` | Disable progress panel; stream all command output |
| `--list` | Print manifest (id + display name) and exit |
| `--branch X` | (Bootstrap-only) Equivalent to `BRANCH=X` |
| `--help` / `-h` | Print usage and exit |

**Env vars:**

- `BRANCH` — branch to clone (default `main`)
- `REPO` — repo URL (default `https://github.com/natsumi/dotfiles`)
- `NO_COLOR` — set to any non-empty value to disable ANSI colors (also auto-disabled on non-TTY)
- `VERBOSE` — set to `1` to bypass the progress panel
- `DEBUG` — set to `1` to enable `debug` log helper output

No per-prompt env-var overrides. Every interactive value is collected via `prompt_config()`.

---

## UI library — `lib/ui.sh`

Exports the only set of functions modules call for output and command execution.

### Colors

Auto-disabled when `[[ ! -t 1 ]]` or `NO_COLOR` is set. Otherwise: `C_RESET`, `C_BOLD`, `C_DIM`, `C_RED`, `C_GREEN`, `C_YELLOW`, `C_BLUE`, `C_CYAN`, `C_GREY`.

### Message helpers

```bash
info "..."       # blue ℹ
success "..."    # green ✓
warn "..."       # yellow ⚠   (stderr)
error "..."      # red ✗      (stderr)
die "..."        # error + exit 1
debug "..."      # grey · (only if DEBUG=1, stderr)
section N TOTAL NAME   # bold cyan section header — printed by runner per module
```

### Prompts

```bash
ask "Hostname" "$default"            # echoes the answer
ask_yn "Install Docker?" "N"         # exit code: 0 if yes
ask_password "Password for $u"       # twice, hidden, must match
```

### `run_step` — long-running command UX

```bash
run_step "Upgrading packages" apt-get upgrade -y
```

While running, prints a 6-line panel: header line with spinner + description + elapsed seconds, plus 5 lines showing the live tail of the log (stripped of ANSI, truncated to terminal width). On completion the entire panel is replaced with `✓ <desc> (Ns)` (or `✗ ...` plus the last 20 lines of log indented inline).

Auto-fallback paths:

- Non-TTY (`[[ ! -t 1 ]]`): plain streaming with `tee`, no panel.
- `VERBOSE=1`: same plain-streaming path.
- Output that needs ANSI stripping: `sed 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r//g'`.

The function uses `${PIPESTATUS[0]}` / wait on a backgrounded pid to capture the real exit code. Returns that exit code unchanged so the caller can `||` for soft-fail.

---

## Logging — `lib/log.sh`

- Log file: `./vps-bootstrap-YYYYMMDD-HHMMSS.log`. Cwd, timestamped per run, never clobbered.
- `tee` redirects on fd 1 and 2 with inline ANSI stripping so the screen is colorized but the file is plain text:
  ```bash
  exec 1> >(tee >(sed -u 's/\x1b\[[0-9;]*[a-zA-Z]//g' >>"$LOG_FILE"))
  exec 2> >(tee >(sed -u 's/\x1b\[[0-9;]*[a-zA-Z]//g' >>"$LOG_FILE") >&2)
  ```
- Bash command tracing on a separate fd so the log captures every command actually executed:
  ```bash
  exec 9>>"$LOG_FILE"
  BASH_XTRACEFD=9
  PS4='+ ${BASH_SOURCE}:${LINENO}: '
  set -x
  ```
- The log path is announced at startup, repeated in the final summary, and reproduced if a module dies.

---

## File-write strategy

Three-tier policy, codified here and used across modules:

1. **Drop-ins first.** Write `/etc/<svc>.d/99-vps-<module>.conf`; never touch the OS-managed file. Used for: ssh, sysctl, apt unattended-upgrades, fail2ban jails. Rollback = `rm`. We don't track upstream defaults because we only ship deltas.
2. **Templates with `envsubst` second.** When interpolation is needed. Template lives in `modules/<id>/templates/foo.conf.tmpl`, rendered at runtime to its install path. Used for: apt mirror (`${UBUNTU_CODENAME}`), fail2ban jail (`${SSH_PORT}`).
3. **In-place edits last.** Only when 1 and 2 are impossible — realistic case: `/etc/hosts` for hostname. When unavoidable: backup the original to `./vps-bootstrap-YYYYMMDD-HHMMSS-backup/` first, then edit.

For `docker/files/daemon.json`: Ubuntu doesn't ship a stock `daemon.json` so we own the whole file. This is acknowledged and not a violation of the policy.

---

## Failure handling

- Runner sets `set -euo pipefail` and `trap 'on_error $LINENO $? "$BASH_COMMAND"' ERR`. Hard fail by default.
- `run_step` already captures output and prints the last 20 log lines inline on failure — the user sees what broke without leaving the terminal.
- Modules that want best-effort behavior do `run_step "..." cmd || warn "non-fatal: ..."`. Soft-fails are explicit, never magic.
- The `ERR` trap re-prints the failed command, line number, log path, and exits non-zero.
- The `EXIT` trap removes the lockfile and any `/tmp` clones.

---

## Preflight — `lib/preflight.sh`

Runs before prompts and modules. Each check uses `info` → `success` or `die`.

- **Root** — `[[ $EUID -eq 0 ]]` or die.
- **OS** — `/etc/os-release`: ID = ubuntu, VERSION_ID in supported set. Supported set is one bash array (`SUPPORTED_UBUNTU=("24.04" "26.04")`) so adding a version is one line.
- **Bash** — `(( BASH_VERSINFO[0] >= 4 ))`.
- **Internet** — `curl -fsS --max-time 5 https://github.com >/dev/null`.
- **Disk** — at least 2GB free on `/var`.
- **Lockfile** — `mkdir /run/vps-bootstrap.lock` to fail-fast on concurrent runs; trap removes it on exit.
- **Prior run** — if `./vps-bootstrap.stamp` exists, print the previous run date and prompt "another run will reapply all configuration. Continue? [y/N]".

---

## Safety gates

Two non-negotiables:

### SSH key gate
The `ssh` module disables password auth. If no SSH keys are present at that moment, that locks the user out. Prevention is layered:

1. During `prompt_config`, if `/root/.ssh/authorized_keys` is empty, ask for a public key, validate with `ssh-keygen -l -f -`, and queue it for installation.
2. The `user` module installs the queued key into the new user's `~/.ssh/authorized_keys` (and root's, if missing).
3. The `ssh` module dies with a clear message if **both** root's and the new user's `authorized_keys` are empty when it runs. Better to abort than lock out.

### Manifest ordering
- `user` before `ssh` (key in place before password auth is disabled).
- `ssh` before `firewall` (UFW gets the new port).
- `firewall` enables UFW *after* the new SSH port is allowed.

---

## Interactive config — `lib/config.sh`

Single function `prompt_config()` collects everything upfront and sets shell variables (in the runner's shell, since modules are sourced) for modules to consume. Tracing (`set -x`) is bracketed off around password handling so the password doesn't leak into the trace log.

| Variable | Prompt | Default | Validation |
|---|---|---|---|
| `USERNAME` | "Username for sudo access (empty = skip)" | empty | `^[a-z][-a-z0-9_]*$` if non-empty |
| `PASSWORD` | "Password for $USERNAME" (twice, hidden) | — | non-empty, must match |
| `HOSTNAME` | "Hostname" | current hostname | RFC-1123 |
| `SSH_PORT` | "SSH port" | `22` | 1–65535 |
| `TIMEZONE` | "Timezone" | `America/Los_Angeles` | exists in `/usr/share/zoneinfo` |
| `SSH_PUBKEY` | "SSH public key" (only if no keys present) | — | passes `ssh-keygen -l -f -` |
| `INSTALL_DOCKER` | "Install Docker?" | `N` | y/N |

After collection, prints a summary block and asks one final "proceed?" yes/no.

---

## Summary module

Last in the manifest. Writes:

- `./vps-bootstrap-summary.txt` — human-readable summary
- `./vps-bootstrap.stamp` — key=value, used by preflight's prior-run detection

Content of the summary:

- Run timestamp, hostname, Ubuntu version
- Admin user, SSH port
- Modules executed and their elapsed times
- Modules that warned/failed (if any)
- Reboot needed? (`[[ -f /var/run/reboot-required ]]`)
- Important post-install reminders ("test SSH on the new port from another shell BEFORE closing this one", etc.)

The same content is printed to stdout in color, and the log path is reproduced as the final line.

---

## Default module set

| ID | Display Name | What it does |
|---|---|---|
| `apt-mirror` | APT Mirror Configuration | Replaces `/etc/apt/sources.list.d/ubuntu.sources` with mirror config (Pilot Fiber). Codename templated via `envsubst`. |
| `system` | System Settings | Sets hostname (`hostnamectl` + `/etc/hosts` edit) and timezone (`timedatectl`). |
| `update` | System Update | `apt-get update && apt-get upgrade && apt-get autoremove`. |
| `packages` | Base Packages | Installs every package listed in `packages.list` (build tools, monitoring, network tools, shell tools). Filters unavailable packages with a warning before bulk install. |
| `neovim` | Neovim | Adds `ppa:neovim-ppa/unstable`, installs `neovim`. |
| `user` | Admin User & Sudo | Creates `$USERNAME` with zsh shell, adds to sudo group, sets password, installs SSH key. Idempotent if user already exists. |
| `ssh` | SSH Hardening | Writes `/etc/ssh/sshd_config.d/99-vps-hardening.conf` (custom port, no password auth, restricted users, modern crypto). Disables `50-cloud-init.conf` if present. Validates with `sshd -t` and rolls back on failure. |
| `firewall` | UFW Firewall | Resets UFW, default-deny incoming, allows `$SSH_PORT/tcp`, `80/tcp`, `443/tcp`. Enables UFW. |
| `fail2ban` | Fail2ban | Installs `jail.local` from template (with `$SSH_PORT`), copies traefik filters to `filter.d/`, enables and restarts. |
| `auto-updates` | Unattended Upgrades | Writes `/etc/apt/apt.conf.d/99-vps-upgrades` with security-only origins, no auto-reboot, kernel cleanup on. |
| `sysctl` | Kernel & Network Hardening | Writes `/etc/sysctl.d/99-vps-hardening.conf` (swappiness, rp_filter, syncookies, redirect/source-route hardening). |
| `swap` | Swap File | Creates `/swapfile` sized by available RAM, adds to fstab. Skips if any swap is already active. |
| `docker` | Docker Engine | Optional. Adds Docker apt repo, installs `docker-ce`, copies `daemon.json`, adds the admin user to `docker` group. Installs Lazydocker. |
| `audit` | Security Audit | Read-only checks: default users (`pi`, `ubuntu`, `debian`), weak SSH keys, unnecessary services running. Warns; does not modify. |
| `summary` | Setup Summary | Writes summary file and stamp; prints to stdout. |

---

## Out of scope (revisit later)

- Auto-reboot after kernel updates.
- Rollback / undo command.
- Plugin / external module loading.
- Dry-run mode.
- Migration from existing `vps/` setups (the rewrite is a fresh install path; existing servers can be left as-is or re-bootstrapped on a fresh OS).
