# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands and Development Workflow

### Primary Setup Commands
```bash
# Complete macOS system setup (interactive menu-driven)
sh bin/bootstrap.sh

# Apply configuration symlinks using GNU Stow
bin/apply_symlinks.sh

# Install desktop applications
bin/install_desktop_apps.sh

# Update Homebrew packages
brew bundle --file=homebrew/Brewfile
```

### Platform-Specific Setup
```bash
# Ubuntu/VPS one-line setup
curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/vps/install.sh | sudo bash

# Windows setup (PowerShell)
windows/setup.ps1
```

### Configuration Management
```bash
# Rebuild bat theme cache
bat cache --build

# Install tmux plugins (run tmux first, then Ctrl-s Shift-i)
mkdir -p ~/.tmux/plugins

# Update development environments
mise use --global node python ruby

# Enable VS Code key repeat
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
```

### Custom Environment Variables
Edit `~/.zshenv` to set personal paths:
- `$DEV_DIR` - Development projects directory
- `$DOTFILE_DIR` - Dotfiles repository location

## Architecture Overview

This is a modular dotfiles repository using GNU Stow for symlink management across multiple platforms.

### Core Architecture Principles
- **Modular Design**: Each tool has its own directory (e.g., `neovim/`, `zsh/`, `kitty/`)
- **GNU Stow Integration**: Configurations symlinked to `$HOME` without cluttering
- **Platform Isolation**: Separate configs for macOS, Ubuntu/WSL, Windows, VPS
- **Security-First**: Comprehensive VPS hardening with SSH, firewall, intrusion prevention

### Key Components
- **Bootstrap System**: Interactive menu-driven setup with user confirmation
- **Package Management**: Homebrew with comprehensive Brewfile (98 packages)
- **Symlink Management**: GNU Stow handles all configuration deployment
- **Multi-Platform**: Supports macOS (primary), Ubuntu, Windows, VPS environments

### Configuration Deployment Pattern
1. Each application config lives in its own directory
2. `bin/apply_symlinks.sh` manages 25 package configurations
3. Symlinks created via: `stow -v -R --target="$HOME" --dir="$DOTFILE_DIR" "$package"`
4. Packages: alacritty, aerospace, bat, claude, elixir, eslint, ghostty, helix, jetbrains, kitty, mise, neovim, prettier, ripgrep, ruby, silver_searcher, tig, tmux, yt-dlp, yabai, zsh

### Development Tools Stack
- **Editors**: Neovim (primary), Helix, VS Code, Cursor
- **Terminals**: Ghostty (primary), Kitty, Alacritty with tmux multiplexing
- **Shell**: Zsh with Prezto framework and Powerlevel10k theme
- **Version Control**: Git with diff-so-fancy, git-delta, tig, scmpuff
- **Runtime Management**: mise (replaces asdf/rbenv/nvm)
- **Window Management**: Yabai + skhd for macOS tiling

### Security Architecture (VPS)
- SSH hardening (custom port, key-only auth, disable root)
- UFW firewall with strict rules and rate limiting
- Fail2ban + SSHGuard for intrusion prevention
- Automatic security updates via unattended-upgrades
- Comprehensive logging and monitoring

### Custom Hardware Support
Extensive mechanical keyboard configurations in `keyboards/` directory:
- 6 different keyboard models with QMK firmware support
- Custom layouts and programming for DZ60, Magi65, Polaris, Rainy75, Zoom65
- VIA programming support with layer management
- Detailed documentation with visual layout diagrams

## Working with This Repository

### Adding New Tool Configurations
1. Create new directory named after the tool
2. Add configuration files following tool conventions
3. Update `packages` array in `bin/apply_symlinks.sh`
4. Test symlink deployment: `stow -v -R --target="$HOME" --dir="$DOTFILE_DIR" "new-tool"`

### Modifying Existing Configurations
1. Edit files in appropriate tool directory
2. Re-run `bin/apply_symlinks.sh` to update symlinks
3. Test configuration changes before committing

### Platform-Specific Modifications
- **macOS**: Modify `bin/bootstrap.sh` and `homebrew/Brewfile`
- **Ubuntu/VPS**: Update `vps/setup.sh` and security configurations
- **Windows**: Modify `windows/setup.ps1` and Chocolatey packages

### Package Management
- Homebrew packages declared in `homebrew/Brewfile`
- Desktop applications managed via `bin/install_desktop_apps.sh`
- Development runtimes managed via mise
- Platform-specific package managers (apt, chocolatey) in respective directories

### Environment Customization
Personal customizations should be made in `~/.zshenv` rather than modifying repository files:
```bash
export DEV_DIR="$HOME/custom/dev"
export DOTFILE_DIR="$HOME/custom/dotfiles"
```

This ensures personal preferences don't interfere with the shared configuration system.