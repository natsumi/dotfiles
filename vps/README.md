# VPS Bootstrap

Modular Ubuntu 24.04 / 26.04 server bootstrap. Hardens SSH, configures the firewall, installs base packages, optionally installs Docker, and writes a setup summary.

## Quickstart

The bootstrap is interactive (prompts for username, hostname, timezone, etc.). On Ubuntu 22.04+, `sudo`'s default pty mode prevents user input from reaching the prompts when stdin is piped from `curl`, so the recommended pattern is **two-step**:

```bash
# 1) Download
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh -o /tmp/install.sh

# 2) Run as root (or via sudo)
sudo bash /tmp/install.sh
```

If you're already root (the `#` prompt), the one-line curl-pipe form works because no sudo is involved:

```bash
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh | bash
```

To test from a feature branch (use underscores; no slashes in branch names):

```bash
# Two-step from a branch
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/feat_vps_rewrite/vps/install.sh -o /tmp/install.sh
sudo BRANCH=feat_vps_rewrite bash /tmp/install.sh

# Or, if already root
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/feat_vps_rewrite/vps/install.sh \
  | BRANCH=feat_vps_rewrite bash
```

The bootstrap detects `curl | sudo bash` and aborts with these instructions before reaching any prompts.

## What it does

The bootstrap iterates an ordered manifest of modules. Each module is a self-contained folder under `modules/` that defines a single `module_run` function. Configuration goes into `/etc/<svc>.d/99-vps-*` drop-ins where the OS supports it; templates with `envsubst` where interpolation is needed; in-place edits only when there's no other choice (e.g. `/etc/hosts`).

## Modules

| ID | Display Name | What it does |
|---|---|---|
| `apt-mirror` | APT Mirror Configuration | **Disabled by default** (commented out in `manifest.sh`). Replaces `/etc/apt/sources.list.d/ubuntu.sources` with the Pilot Fiber mirror, codename-templated. |
| `system` | System Settings | Hostname (`hostnamectl` + `/etc/hosts`) and timezone (`timedatectl`). |
| `update` | System Update | `apt update` + `upgrade` + `autoremove`. |
| `packages` | Base Packages | Installs everything in `modules/packages/packages.list`. |
| `neovim` | Neovim | Adds `ppa:neovim-ppa/unstable`, installs neovim. |
| `user` | Admin User & Sudo | Creates `$USERNAME` with zsh, adds to sudo, sets password, installs SSH key. |
| `ssh` | SSH Hardening | Drop-in `/etc/ssh/sshd_config.d/99-vps-hardening.conf` (custom port, no password auth, modern crypto). Validates with `sshd -t`; rolls back on failure. |
| `firewall` | UFW Firewall | Default-deny incoming; allows the SSH port only. Open other ports (HTTP/HTTPS/etc.) manually with `ufw allow` when deploying services. |
| `fail2ban` | Fail2ban | Drop-in `/etc/fail2ban/jail.d/vps.local` with `sshd` (aggressive mode) and `recidive` jails. |
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

In the directory you invoked the bootstrap from (`install.sh` captures `$PWD` before any `cd`, exports it as `INVOKED_FROM`, and the runner writes all output paths there):

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
