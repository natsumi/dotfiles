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
