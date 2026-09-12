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

## Docker + UFW (important)

**Docker bypasses UFW by default.** When you publish a container port with `-p 80:80` (or via `ports:` in compose), Docker writes its own `iptables` rules into the `DOCKER` chain, which is matched *before* UFW's filter rules. The result is that published container ports are reachable from anywhere on the internet **regardless of what `ufw status` says**. This is a long-standing Docker design choice, not a bug; it has not changed on Ubuntu 26.04 or with recent Docker versions.

This means: if you set `ufw deny 80`, then `docker run -p 80:80 nginx`, port 80 IS reachable from outside.

The three common ways people deal with this:

1. **Bind containers to localhost and front them with a reverse proxy.** `-p 127.0.0.1:8080:8080` keeps the container off the internet; an nginx/traefik/caddy on the host (gated by UFW) proxies public traffic to it. This is the cleanest pattern and what most personal VPS setups end up doing.
2. **Use the `ufw-docker` workaround** — community recipe that adds rules to `/etc/ufw/after.rules` filtering Docker traffic through `DOCKER-USER`. Lets UFW actually gate published container ports. See <https://github.com/chaifeng/ufw-docker>.
3. **Set `"iptables": false` in `/etc/docker/daemon.json`** — tells Docker not to manage iptables at all. You then handle container networking entirely yourself. Heavy.

The bootstrap doesn't enable any of these — it just leaves Docker at its default. Pick the pattern that fits your deployment.

## Future: migrating to `mise bootstrap`

Workstation setup in this repo already runs on [`mise bootstrap`](https://mise.jdx.dev/bootstrap.html)
(see the root `mise.toml`). The VPS flow has not been migrated yet. This section
records how it would map, so it can be done later without re-deriving it.

### Suggested layout

Keep the server config in its own mise environment so it never applies to a
workstation:

```
mise.toml           # shared: dotfiles, tools (already exists)
mise.vps.toml       # server only: loaded with `-E vps` / MISE_ENV=vps
vps/files/...       # sources for [bootstrap.files] (sshd drop-in, sysctl, jail.d, daemon.json)
```

Run it either on the box after installing mise, or push it from a laptop over
SSH with mise's remote runner, which uploads mise and the config for you:

```bash
# on the server
curl https://mise.run | sh && mise -E vps bootstrap --dry-run

# from a laptop (needs an SSH host you can already reach)
mise -E vps bootstrap remote --host myvps --source . --install-mise --dry-run
```

Run `mise bootstrap` as the admin user, not root: mise elevates per command
with `sudo` where a step needs it (apt, `/etc` files, systemd, ufw). Dotfiles
and tools land in the invoking user's home.

### Module → mise mapping

| Module | mise equivalent | Notes |
|---|---|---|
| `packages` | `[bootstrap.packages]` `"apt:<name>" = "latest"` | Direct. `mise bootstrap packages import` does not exist for apt; copy `packages.list` by hand. |
| `update` | `mise bootstrap --update` / `mise bootstrap packages upgrade --manager apt` | Not a phase; run explicitly. |
| `neovim` (PPA) | `[bootstrap.files]` with `phase = "pre-packages"` for the `.sources` file + `apt:neovim` | Or drop the PPA and use `neovim` from `[tools]`. |
| `system` (hostname, tz) | `[bootstrap.hooks.pre-packages]` or `[tasks.bootstrap]` | No declarative hostname/timezone. `hostnamectl` / `timedatectl` are idempotent, so a hook is fine. |
| `user` | `[bootstrap.users.<name>]` with `group`, `groups = ["sudo"]`, `shell = "/usr/bin/zsh"` | No password support; set it by hand or via a hook. `authorized_keys` becomes a `[bootstrap.files]` entry owned by the user, mode `0600`, with the key from `[bootstrap.secrets]` or `[vars]`. |
| `ssh` | `[bootstrap.files."/etc/ssh/sshd_config.d/99-hardening.conf"]` + `[bootstrap.services.ssh] state = "running", enabled = true` | Port comes from `[vars]` with `template = true`. mise has no `sshd -t` validate-and-rollback; add `sshd -t` in a `post-packages` hook, or keep the console fallback in mind. |
| `firewall` | `[bootstrap.linux.firewall]` with `backend = "ufw"`, `default_incoming = "deny"`, `[[bootstrap.linux.firewall.rules]]` for the SSH port with `action = "limit"` | Direct. mise tags its ufw rules with `mise:<name>` comments and leaves other rules alone. Docker-bypasses-UFW caveat above still applies. |
| `fail2ban` | `apt:fail2ban` + `[bootstrap.files."/etc/fail2ban/jail.d/vps.local"]` + `[bootstrap.services.fail2ban]` | Direct. |
| `auto-updates` | `apt:unattended-upgrades` + `[bootstrap.files."/etc/apt/apt.conf.d/99-vps-upgrades"]` | Direct. |
| `sysctl` | `[bootstrap.files."/etc/sysctl.d/99-vps-hardening.conf"]` + hook `sysctl --system` | The file is declarative; the reload is a hook. |
| `swap` | hook or `[tasks.bootstrap]` guarded by `swapon --show` | No declarative swap. |
| `docker` | pre-packages `[bootstrap.files]` for Docker's apt keyring + `.sources`, `apt:docker-ce ...`, `[bootstrap.files."/etc/docker/daemon.json"]`, `[bootstrap.services.docker]`, user `groups = ["docker"]` | Long-running stacks then fit `[bootstrap.compose]`. Lazydocker can be a `[tools]` entry. |
| `apt-mirror` | `[bootstrap.files]` with `phase = "pre-packages"` and `template = true` | Currently disabled anyway. |
| `audit` | none | Keep as a script, or drop. |
| `summary` | `mise bootstrap status` / `mise bootstrap plan` | Built in; the stamp/summary files go away. |

### What changes in behaviour

- **Interactive prompts go away.** Username, hostname, timezone and SSH port
  become `[vars]` (or `-E`-specific values); passwords and keys come from
  `[bootstrap.secrets]` environment variables.
- **Idempotency is built in** for packages, files, users, services and the
  firewall: `mise bootstrap status --missing` reports drift, `mise bootstrap plan`
  shows exactly what would change. Hooks still run every time, so keep them
  guarded.
- **No rollback.** Bootstrap is a sequence, not a transaction. Test the sshd
  drop-in and firewall with `--dry-run` and keep the provider console handy.

### Suggested order

1. `packages`, `sysctl`, `auto-updates`, `fail2ban` — pure files + packages + services, lowest risk.
2. `firewall` — verify `mise bootstrap firewall status` shows the SSH rule before enabling.
3. `user`, `ssh` — last, since a mistake locks you out.
4. `docker` — optional; consider `[bootstrap.compose]` for the services that run on the box.
5. Delete `vps/modules/`, `main.sh`, `lib/` once every module has an equivalent; keep `install.sh` only as a thin "install mise and run it" wrapper.
