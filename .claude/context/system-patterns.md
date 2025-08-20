---
created: 2025-08-20T18:10:34Z
last_updated: 2025-08-20T18:10:34Z
version: 1.0
author: Claude Code PM System
---

# System Patterns & Design Decisions

## Architectural Patterns

### Modular Configuration Architecture
- **Separation of Concerns:** Each tool/application has its own dedicated directory
- **Single Responsibility:** One directory per tool/application/platform
- **Loose Coupling:** Tools can be installed/configured independently
- **High Cohesion:** Related configurations are grouped together

### Configuration Management Pattern
- **Symlink Strategy:** Uses GNU Stow for creating symbolic links to home directory
- **Source of Truth:** All configurations stored in version control
- **Declarative Management:** Brewfile declares all package dependencies
- **Bootstrap Pattern:** Single entry point script (`bin/bootstrap.sh`) for setup

## Data Flow Patterns

### Setup & Installation Flow
1. **Bootstrap Script** → **Environment Setup** → **Package Installation** → **Configuration Linking**
2. **Dependency Declaration** (Brewfile) → **Package Manager** (Homebrew) → **Tool Installation**
3. **Configuration Files** → **Stow** → **Symlinked Home Directory**

### Platform-Specific Branching
- **Platform Detection:** Scripts adapt behavior based on operating system
- **Conditional Configuration:** Platform-specific directories (ubuntu/, windows/, vps/)
- **Fallback Strategies:** Alternative tools for different environments

## Design Principles Observed

### Unix Philosophy Adherence
- **Do One Thing Well:** Each configuration directory has a single purpose
- **Composability:** Tools work together through standard interfaces
- **Text-Based Configuration:** All configurations are human-readable text files

### DevOps & Infrastructure as Code
- **Version Controlled Infrastructure:** All configurations tracked in Git
- **Reproducible Environments:** Bootstrap script creates identical setups
- **Documentation as Code:** README files alongside configurations
- **Automated Provisioning:** Scripts handle complex setup procedures

### Developer Experience Optimization
- **Minimal Friction:** Single command setup (`sh bin/bootstrap.sh`)
- **Immediate Productivity:** Pre-configured development environments
- **Tool Integration:** Complementary tools that enhance each other
- **Customization Points:** Environment variables for personal preferences

## Configuration Patterns

### Layered Configuration Strategy
- **Base Configuration:** Core settings in main config files
- **Environment Overrides:** `~/.zshenv` for personal paths and variables
- **Tool-Specific Customization:** Individual tool directories for specialized settings

### Security & Safety Patterns
- **VPS Hardening:** Dedicated security configurations in vps/ directory
- **Credential Management:** External credential handling (not in repository)
- **Permission Management:** Appropriate file permissions for security-sensitive configs

### Multi-Platform Support Pattern
- **Platform Abstraction:** Common configurations with platform-specific overrides
- **Conditional Logic:** Scripts that adapt to different operating systems
- **Shared Core:** Maximum reuse of common configurations across platforms

## Code Organization Patterns

### Directory Naming Convention
- **Lowercase with Hyphens:** Consistent naming (e.g., `silver_searcher`, `yt-dlp`)
- **Tool Name Matching:** Directory names match actual tool names
- **Clear Categorization:** Logical grouping of related tools

### Documentation Pattern
- **README Driven:** Documentation at root and subdirectory levels where needed
- **Self-Documenting Code:** Clear script names and structure
- **Usage Examples:** Practical examples in documentation

### Dependency Management Pattern
- **Centralized Dependencies:** All Homebrew packages in single Brewfile
- **Explicit Dependencies:** Clear declaration of required tools
- **Optional Components:** Modular design allows selective installation

## Error Handling & Resilience
- **Graceful Degradation:** System continues to work if optional components fail
- **Idempotent Operations:** Scripts can be run multiple times safely
- **Validation Steps:** Checks for required dependencies before proceeding
- **User Feedback:** Clear status messages and error reporting