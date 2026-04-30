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
