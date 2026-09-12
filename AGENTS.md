# Dotfiles

Modular dotfiles repo. Each tool has its own directory (e.g., `neovim/`, `zsh/`, `kitty/`).

Symlinks and machine setup are managed by `mise bootstrap`. The root `mise.toml` declares git repos, the `[dotfiles]` symlink map and the login shell. `auto_env` (`.miserc.toml`) also loads `mise.linux.toml` (apt packages, SSH/firewall/fail2ban hardening, sources under `linux/etc/`) on Linux and `mise.macos.toml` (brew packages, casks, fonts, macOS defaults) on macOS. `mise.docker.toml` is an opt-in env (`mise -E docker bootstrap`). The global mise config (languages and cross-platform CLI tools) lives at `mise/.config/mise/config.toml` and is symlinked to `~/.config/mise/config.toml`.

Adding a dotfile means putting the file under its `<package>/` directory and adding a `[dotfiles]` entry in `mise.toml`. Host packages go in the platform file, never with `os` selectors in `mise.toml`.

## Key Tools

- **Editor**: Neovim (LazyVim) in `neovim/.config/nvim/`
- **Terminal**: Wezterm (primary), Ghostty, Kitty, Alacritty
- **Shell**: Zsh + Prezto + Powerlevel10k
- **Window Mgmt**: AeroSpace (tiling), Yabai (tiling)
- **Runtimes**: mise (node, python, ruby)
