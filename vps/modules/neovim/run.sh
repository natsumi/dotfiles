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
