# Dotfiles

Modular dotfiles repo. Each tool has its own directory (e.g., `neovim/`, `zsh/`, `kitty/`).

Symlinks and machine setup are managed by `mise bootstrap` from the root `mise.toml`: it declares host packages, git repos, the `[dotfiles]` symlink map, macOS defaults and the login shell. The global mise config (languages and cross-platform CLI tools) lives at `mise/.config/mise/config.toml` and is symlinked to `~/.config/mise/config.toml`.

Adding a dotfile means putting the file under its `<package>/` directory and adding a `[dotfiles]` entry in `mise.toml`.

## Key Tools

- **Editor**: Neovim (LazyVim) in `neovim/.config/nvim/`
- **Terminal**: Wezterm (primary), Ghostty, Kitty, Alacritty
- **Shell**: Zsh + Prezto + Powerlevel10k
- **Window Mgmt**: AeroSpace (tiling), Yabai (tiling)
- **Runtimes**: mise (node, python, ruby)
