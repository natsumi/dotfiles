#
# Admin User & Sudo
#
# What it does:
#   - If $USERNAME is empty, skips entirely
#   - Otherwise creates the user with zsh shell (or noop if user exists)
#   - Adds them to the sudo group
#   - Sets the password from $PASSWORD (trace bracketed off so it doesn't leak)
#   - Installs SSH key:
#       * If $SSH_PUBKEY is set, append it to /root/.ssh/authorized_keys
#       * Then copy /root/.ssh/authorized_keys to the new user
# Files written/touched:
#   - /etc/passwd, /etc/shadow, /etc/group (via useradd/usermod/chpasswd)
#   - /root/.ssh/authorized_keys (appended)
#   - /home/$USERNAME/.ssh/authorized_keys (copied from root)
# Idempotent: yes — safe to re-run; password is reset, root's key is
# appended only if not already present, user's file is overwritten with
# root's so it always reflects root's authorized_keys exactly.
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

  # ── SSH key install ──────────────────────────────────────────────
  # Strategy: ensure root's authorized_keys is up to date first (append
  # $SSH_PUBKEY if prompt_config queued one), then copy root's file to
  # the new admin user. One write path, easier to reason about.

  install -d -m 700 /root/.ssh
  if [[ -n "${SSH_PUBKEY:-}" ]]; then
    if ! grep -qF "$SSH_PUBKEY" /root/.ssh/authorized_keys 2>/dev/null; then
      printf "%s\n" "$SSH_PUBKEY" >>/root/.ssh/authorized_keys
      chmod 600 /root/.ssh/authorized_keys
      success "Installed SSH key for root"
    fi
  fi

  local user_home="/home/$USERNAME"
  local user_ssh="$user_home/.ssh"
  local user_keys="$user_ssh/authorized_keys"

  # Ensure /home/$USERNAME itself is owned by the user with safe perms.
  # 'useradd -m' does NOT chown a pre-existing home directory (e.g. one
  # created earlier by cloud-init, or because root cd'd there before
  # the script ran), and sshd's StrictModes will refuse pubkey auth if
  # any directory in the chain isn't owned by root or the user, or is
  # group/other-writable. 0750 satisfies StrictModes and matches the
  # Ubuntu HOME_MODE default.
  if [[ -d "$user_home" ]]; then
    chown "$USERNAME:$USERNAME" "$user_home"
    chmod 0750 "$user_home"
  fi

  install -d -m 700 -o "$USERNAME" -g "$USERNAME" "$user_ssh"

  if [[ -s /root/.ssh/authorized_keys ]]; then
    cp /root/.ssh/authorized_keys "$user_keys"
    chown "$USERNAME:$USERNAME" "$user_keys"
    chmod 600 "$user_keys"
    success "Installed SSH key for $USERNAME (copied from /root)"
  else
    warn "/root/.ssh/authorized_keys is empty — no key copied to $USERNAME"
  fi
}
