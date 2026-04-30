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
