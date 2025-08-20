---
created: 2025-08-20T18:10:34Z
last_updated: 2025-08-20T18:10:34Z
version: 1.0
author: Claude Code PM System
---

# Project Structure

## Overview
This is a personal dotfiles repository organized by application/tool with a modular structure that allows for selective deployment and management.

## Root Directory Structure
```
dotfiles/
├── .claude/                 # Claude Code PM integration
├── bin/                     # Setup and utility scripts
├── homebrew/               # Package management
│   └── Brewfile            # Homebrew dependencies
├── README.md               # Project documentation
└── [application directories]
```

## Application-Specific Directories
The project follows a clear pattern where each tool/application has its own dedicated directory:

### Development Tools
- `neovim/` - Neovim editor configuration
- `helix/` - Helix editor configuration  
- `tmux/` - Terminal multiplexer configuration
- `kitty/` - Terminal emulator configuration
- `alacritty/` - Alternative terminal emulator
- `zsh/` - Shell configuration and customizations
- `mise/` - Development environment manager
- `git/` - Version control configuration (implied from README)

### Development Languages & Frameworks
- `elixir/` - Elixir language configuration
- `ruby/` - Ruby language configuration
- `eslint/` - JavaScript linting configuration
- `prettier/` - Code formatting configuration

### Productivity & System Tools
- `aerospace/` - Window management
- `yabai/` - Tiling window manager for macOS
- `bat/` - Enhanced cat command
- `ripgrep/` - Fast text search tool
- `silver_searcher/` - Text search utility
- `tig/` - Git text interface
- `yt-dlp/` - YouTube downloader configuration

### Platform-Specific
- `ubuntu/` - Ubuntu/WSL specific configurations
- `windows/` - Windows-specific setup
- `vps/` - VPS server configuration and setup
- `computer/` - General computer setup files

### Specialized Hardware
- `keyboards/` - Custom keyboard configurations and layouts
  - `dz60-drifter/`, `magi65/`, `pok3r-layouts/`, `polaris/`, `rainy75/`, `zoom65/`
- `jetbrains/` - JetBrains IDE configurations

## File Organization Patterns
- Each directory contains configuration files specific to that tool
- Setup scripts are centralized in `bin/` directory
- Documentation (README.md) exists at both root and subdirectory levels where needed
- Binary files and manuals are kept within their respective tool directories

## Configuration Management
- Uses GNU Stow for symlink management (mentioned in README tools)
- Homebrew Brewfile for package dependency management
- Bootstrap script for automated setup
- Modular design allows for selective tool installation