---
created: 2025-08-20T18:10:34Z
last_updated: 2025-08-20T18:10:34Z
version: 1.0
author: Claude Code PM System
---

# Technology Context

## Platform & Environment
- **Primary Platform:** macOS (Darwin 24.6.0)
- **Secondary Platforms:** Ubuntu/WSL, Windows, VPS deployments
- **Shell:** Zsh (extended Bourne shell)
- **Package Manager:** Homebrew + Homebrew Cask
- **Configuration Management:** GNU Stow (symlink farm manager)

## Development Tools & Utilities

### Core Development
- **Git:** Distributed version control with enhanced tooling
  - `diff-so-fancy` - Enhanced git diff output
  - `git-delta` - Syntax-highlighting pager
  - `difftastic` - Structural diff tool
  - `scmpuff` - Numeric shortcuts for git commands
  - `tig` - Text-mode interface for Git

### Text Editors & IDEs
- **Neovim:** Primary editor with plugin ecosystem
- **Helix:** Modern modal editor alternative
- **Visual Studio Code:** Popular editor with extensions
- **Cursor:** AI-first code editor
- **JetBrains IDEs:** Professional development environments

### Terminal & Shell Tools
- **Terminal Emulators:** Kitty (GPU-based), Alacritty
- **Terminal Multiplexer:** tmux with plugins and monitoring
- **Shell Enhancement:** Zsh with custom configurations
- **Search & Navigation:**
  - `ripgrep` - Extremely fast text search
  - `fd` - Modern find alternative
  - `fzf` - Command-line fuzzy finder
  - `broot` - Better directory navigation
  - `eza` - Modern ls replacement

### Language Environments
- **Mise:** Development environment manager (successor to asdf)
- **Ruby:** Ruby language runtime and configuration
- **Elixir:** Functional programming language setup
- **Node.js:** JavaScript runtime (referenced in README)

### Development Utilities
- **API Development:** Postman for testing
- **Database Management:** TablePlus, SQLite
- **Git Client:** Sublime Merge
- **JSON Processing:** jq, fx (terminal JSON viewer)
- **Process Management:** Overmind (Procfile-based)

## System Management & Productivity

### Window Management
- **Yabai:** Tiling window manager for macOS
- **SKHD:** Simple hotkey daemon
- **Aerospace:** Window management alternative

### File & System Tools
- **File Management:** ForkLift (dual pane manager)
- **System Monitoring:** Stats (menu bar), htop-osx
- **Disk Analysis:** ncdu (NCurses disk usage)
- **Archive Management:** The Unarchiver
- **Screenshot:** Shottr with annotation features

### Media & Communication
- **Media Player:** VLC (cross-platform multimedia)
- **Music:** Spotify with SpotMenu (menu bar integration)
- **Communication:** Discord, Slack, Telegram
- **File Sharing:** LocalSend (cross-device)

## Dependency Management

### Homebrew Packages (via Brewfile)
- **Core utilities:** awk, wget, tree, aria2
- **Development:** git, sqlite, ffmpeg
- **Enhancement:** bat (cat with syntax highlighting)
- **System:** terminal-notifier, mas (Mac App Store CLI)
- **Sharing:** tmate (instant terminal sharing)

### Desktop Applications
- **Productivity:** Alfred (Spotlight replacement), Itsycal (menu bar calendar)
- **Development:** Multiple editors and development tools
- **Utilities:** BetterDisplay, Ice (menu bar management), SaneSideButtons

## Hardware Specialization
- **Custom Keyboards:** Multiple mechanical keyboard configurations
  - QMK firmware support
  - Custom layouts and programming
  - Multiple keyboard models (DZ60, Magi65, Polaris, etc.)

## Platform-Specific Considerations
- **macOS:** Primary development environment with specialized tools
- **Ubuntu/WSL:** Linux development environment for cross-platform work
- **Windows:** PowerShell setup scripts
- **VPS:** Server deployment configurations with security hardening