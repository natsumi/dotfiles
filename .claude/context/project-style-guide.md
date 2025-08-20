---
created: 2025-08-20T18:10:34Z
last_updated: 2025-08-20T18:10:34Z
version: 1.0
author: Claude Code PM System
---

# Project Style Guide

## Directory & File Naming Conventions

### Directory Naming
- **Lowercase with Underscores:** Use snake_case for multi-word directory names
  - ✅ `silver_searcher/`, `yt-dlp/`
  - ❌ `SilverSearcher/`, `YT-DLP/`
- **Tool Name Matching:** Directory names should match the actual tool name
  - ✅ `neovim/` (matches `nvim` command)
  - ✅ `tmux/` (matches `tmux` command)
- **Platform Specificity:** Use platform names for platform-specific directories
  - ✅ `ubuntu/`, `windows/`, `vps/`

### File Naming
- **Configuration Files:** Preserve original tool naming conventions
  - ✅ `.zshrc`, `init.vim`, `tmux.conf`
- **Scripts:** Use descriptive names with clear purpose
  - ✅ `bootstrap.sh`, `install_desktop_apps`
- **Documentation:** Use `README.md` for directory-specific documentation

## Code Organization Patterns

### Configuration File Structure
```
tool-name/
├── README.md           # Tool-specific documentation
├── .config-file        # Primary configuration
├── additional-configs/ # Supporting configuration files
└── scripts/           # Tool-specific scripts
```

### Script Organization
- **Executable Scripts:** Store in `bin/` directory at project root
- **Tool-Specific Scripts:** Include in respective tool directories
- **Platform Scripts:** Group in platform-specific directories

## Documentation Standards

### README.md Structure
```markdown
# Tool Name

Brief description of the tool and its purpose.

## Installation
Steps for installation and setup.

## Configuration
Description of configuration files and customizations.

## Usage
Common usage patterns and examples.
```

### Code Comments
- **Minimal Comments:** Prefer self-documenting code and clear variable names
- **Configuration Comments:** Comment complex or non-obvious configuration settings
- **Script Headers:** Include purpose and usage in script headers

```bash
#!/bin/bash
# Purpose: Bootstrap complete development environment
# Usage: sh bin/bootstrap.sh
```

## Shell Scripting Conventions

### Script Structure
```bash
#!/bin/bash
set -euo pipefail  # Strict error handling

# Constants and configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions
function main() {
    # Main script logic
}

# Script execution
main "$@"
```

### Error Handling
- **Strict Mode:** Always use `set -euo pipefail` for shell scripts
- **Meaningful Errors:** Provide clear error messages with context
- **Graceful Degradation:** Handle optional dependencies gracefully

### Variable Naming
- **Constants:** UPPERCASE with underscores (`DOTFILE_DIR`)
- **Local Variables:** lowercase with underscores (`config_dir`)
- **Environment Variables:** UPPERCASE with underscores (`$DEV_DIR`)

## Configuration File Conventions

### Zsh Configuration
- **Modular Organization:** Separate concerns into different files
- **Environment Variables:** Define in `~/.zshenv` for global access
- **Aliases:** Group related aliases logically
- **Functions:** Prefer functions over complex aliases

### Tool Configuration Patterns
- **Idiomatic Configuration:** Follow each tool's recommended patterns
- **Minimal Configuration:** Only configure what differs from sensible defaults
- **Commented Customizations:** Explain why custom settings are chosen

## Version Control Practices

### Commit Message Format
```
type(scope): description

- feat: new feature
- fix: bug fix
- docs: documentation changes
- refactor: code refactoring
- config: configuration updates
```

Examples:
- `feat(neovim): add new plugin configuration`
- `fix(zsh): correct alias definition`
- `docs(readme): update installation instructions`

### Branch Management
- **Main Branch:** `main` for stable configurations
- **Feature Branches:** Use descriptive names for new features
- **Pull Requests:** Use for significant changes and reviews

## Security & Privacy Guidelines

### Credential Management
- **No Credentials in Repository:** Never commit secrets, tokens, or passwords
- **Environment Variables:** Use environment variables for sensitive configuration
- **Template Files:** Provide `.template` files for configurations requiring secrets

### File Permissions
- **Executable Scripts:** Set appropriate execute permissions
- **Configuration Files:** Use restrictive permissions for sensitive configs
- **SSH Configurations:** Ensure proper permissions (600 for private files)

## Platform-Specific Considerations

### macOS Conventions
- **Homebrew Integration:** Use Brewfile for package management
- **LaunchAgents:** Follow macOS service patterns for background processes
- **Preferences:** Use `defaults write` for system preference modifications

### Linux/Ubuntu Conventions
- **Package Management:** Use appropriate package managers (apt, snap)
- **Systemd Integration:** Follow systemd patterns for services
- **XDG Compliance:** Respect XDG base directory specifications

### Windows Conventions
- **PowerShell Scripts:** Use `.ps1` extension and proper PowerShell syntax
- **Registry Modifications:** Document registry changes clearly
- **Path Separators:** Handle Windows path conventions properly

## Performance Guidelines

### Script Optimization
- **Avoid Unnecessary Processes:** Minimize external command calls
- **Parallel Operations:** Use background processes where appropriate
- **Caching:** Cache expensive operations when possible

### Configuration Optimization
- **Startup Time:** Optimize shell and editor startup times
- **Resource Usage:** Monitor memory and CPU usage of configured tools
- **Loading Strategies:** Use lazy loading for non-essential features

## Maintenance Standards

### Regular Updates
- **Dependency Updates:** Keep Brewfile and package lists current
- **Configuration Reviews:** Periodically review and clean configurations
- **Documentation Updates:** Keep documentation synchronized with changes

### Testing Procedures
- **Fresh Install Testing:** Test bootstrap script on clean systems
- **Cross-Platform Validation:** Verify configurations on all supported platforms
- **Regression Testing:** Ensure changes don't break existing functionality