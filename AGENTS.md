# Dotfiles

Modular dotfiles repo. Each tool has its own directory (e.g., `neovim/`, `zsh/`, `kitty/`).

Symlinks and machine setup are managed by `mise bootstrap`. The root `mise.toml` declares git repos, the `[dotfiles]` symlink map and the login shell. `auto_env` (`.miserc.toml`) also loads `mise.linux.toml` on Linux and `mise.macos.toml` (brew packages, casks, fonts, macOS defaults) on macOS. The global mise config (languages and cross-platform CLI tools) lives at `mise/.config/mise/config.toml` and is symlinked to `~/.config/mise/config.toml`.

Linux boxes add a **profile** (README.md, "Profiles"), chosen per machine in the untracked `.miserc.local.toml` (`env = ["workstation"]`, `env = ["server", "docker"]`):

- `mise.linux.toml` is the server-safe base every Linux box gets: admin tools and hardening, nothing that needs a compiler.
- `mise.workstation.toml` adds development packages (build libraries, ffmpeg, aria2, tmate, mosh and its firewall rule).
- `mise.server.toml` adds automatic reboots and no-root SSH, swaps in `mise/.config/mise/config.server.toml`, and turns off developer dotfiles with `enabled = false`.
- `mise.docker.toml` adds Docker Engine and its update pin.

Env files can only add packages, hooks and firewall rules, never remove them, so never put development-only things in `mise.linux.toml` or `mise.toml`'s packages. Dotfiles are the exception: `enabled = false` in a later file turns one off.

Adding a dotfile means putting the file under its `<package>/` directory and adding a `[dotfiles]` entry in `mise.toml` (development-only ones also get `enabled = false` in `mise.server.toml`). Host packages go in the platform file, or on Linux in `mise.workstation.toml` if a server should not have them, never with `os` selectors in `mise.toml`.

## Key Tools

- **Editor**: Neovim (LazyVim) in `neovim/.config/nvim/`
- **Terminal**: Wezterm (primary), Ghostty, Kitty, Alacritty
- **Shell**: Zsh + Prezto + Powerlevel10k
- **Window Mgmt**: AeroSpace (tiling), Yabai (tiling)
- **Runtimes**: mise (node, python, ruby)
