# Dotfiles

Modular dotfiles repo using GNU Stow for symlink management. Each tool has its own directory (e.g., `neovim/`, `zsh/`, `kitty/`).

## Quick Reference

```bash
# Deploy symlinks
stow -v -R --target="$HOME" --dir="$DOTFILE_DIR" "<package>"

# Full setup
sh bin/bootstrap.sh

# Update Homebrew packages
brew bundle --file=homebrew/Brewfile
```

## Structure

- Each app config lives in its own directory mirroring `$HOME` structure
- `bin/apply_symlinks.sh` manages all 25 package configurations
- Platform configs: macOS (primary), Ubuntu/VPS, Windows

## Adding a New Tool

1. Create directory named after the tool
2. Add config files following the tool's expected paths relative to `$HOME`
3. Add package name to `packages` array in `bin/apply_symlinks.sh`
4. Test: `stow -v -R --target="$HOME" --dir="$DOTFILE_DIR" "new-tool"`

## Key Tools

- **Editor**: Neovim (LazyVim) in `neovim/.config/nvim/`
- **Terminal**: Ghostty (primary), Kitty, Alacritty
- **Shell**: Zsh + Prezto + Powerlevel10k
- **Window Mgmt**: AeroSpace (tiling)
- **Runtimes**: mise (node, python, ruby)
