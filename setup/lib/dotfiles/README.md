# Dotfiles Ruby Library

A modern, interactive framework for automating macOS system setup and configuration tasks. This library provides a step-based architecture with auto-discovery, progress tracking, and an intuitive menu-driven interface.

## Architecture Overview

The library is organized into four main modules:

- **`Core`** - Essential framework components (Step, StepResult, StepLoader, Config, Executor, Logger)
- **`UI`** - User interface components (Menu, Progress, Formatter)
- **`Steps`** - Concrete step implementations (auto-discovered)
- **`MenuRunner`** - High-level orchestration and session management

## Core Components

### Step (`Core::Step`)

The base class for all automation steps using a declarative DSL approach. Steps are defined as self-contained classes with class-level metadata.

```ruby
module Dotfiles
  module Steps
    class InstallPackage < Core::Step
      name "install_package"
      description "Install a package via Homebrew"
      depends_on SomeOtherStep

      private

      def should_skip?
        # Check if already installed (idempotency)
        system("brew list #{package_name} > /dev/null 2>&1")
      end

      def perform_step
        stdout, stderr, status = Open3.capture3("brew install #{package_name}")

        if status.success?
          Core::StepResult.success(
            output: stdout,
            step_name: @name,
            duration: Time.now - start_time
          )
        else
          Core::StepResult.failure(
            error: "Installation failed: #{stderr}",
            step_name: @name
          )
        end
      end

      def package_name
        "git"
      end
    end
  end
end
```

#### Step DSL Methods

- `name(value)` - Set the step identifier
- `description(value)` - Set human-readable description  
- `depends_on(*deps)` - Declare dependencies (class references or strings)

#### Step Lifecycle

1. `should_skip?` - Return true if step should be skipped (idempotency check)
2. `perform_step` - Main implementation (must return StepResult)

#### Step Status

Steps automatically track their execution status:
- `:pending` - Not yet executed
- `:running` - Currently executing  
- `:completed` - Successfully completed
- `:failed` - Execution failed
- `:skipped` - Skipped due to idempotency

### StepResult (`Core::StepResult`)

Represents execution results with detailed context and timing information.

```ruby
# Success result
Core::StepResult.success(
  output: "Operation completed successfully",
  step_name: "install_git",
  duration: 2.5,
  context: { packages_installed: ["git", "git-delta"] }
)

# Failure result  
Core::StepResult.failure(
  error: "Command failed with exit code 1",
  output: "stderr output here",
  step_name: "install_git",
  duration: 1.2,
  context: { command: "brew install git" }
)

# Skipped result (built-in method)
Core::StepResult.skipped(
  step_name: "install_git",
  context: { reason: "already_installed" }
)
```

### StepLoader (`Core::StepLoader`)

Handles automatic step discovery and ordering based on configuration.

```ruby
# Auto-discover all step classes
all_steps = Core::StepLoader.load_all_steps

# Load steps in configured order
ordered_steps = Core::StepLoader.load_ordered_steps("config/step_order.yml")

# List available step implementations
available = Core::StepLoader.available_steps
```

**Auto-Discovery Process:**
1. Loads all `.rb` files from `lib/dotfiles/steps/`
2. Finds all `Core::Step` subclasses
3. Orders based on `config/step_order.yml` categories
4. Validates that configured steps exist
5. Creates instances using `create_instance`

### Config (`Core::Config`)

Simple, static configuration with sensible defaults.

```ruby
config = Core::Config.new

config.log_level      # :info
config.use_color?     # true  
config.dry_run?       # false
config.dotfiles_dir   # File.expand_path("~/dev/dotfiles")
config.target_dir     # File.expand_path("~")
```

### Executor (`Core::Executor`)

Orchestrates step execution with dependency resolution and error handling.

```ruby
executor = Core::Executor.new(dry_run: false)

# Add individual step
executor.add_step(step_instance)

# Execute all registered steps
results = executor.execute_all

# Execute specific step by name
result = executor.execute_step("install_homebrew")
```

## UI Components

### Menu (`UI::Menu`)

Interactive terminal menu with keyboard navigation and multi-selection.

```ruby
menu = UI::Menu.new(steps, formatter: formatter)
selected_steps = menu.run

# Navigation Controls:
# ↑/↓     - Navigate up/down
# Space   - Toggle step selection  
# Enter   - Execute selected steps
# a       - Select all steps
# c       - Clear all selections
# h       - Toggle help display
# q/Esc   - Quit menu
# 1-9     - Quick select by number
```

### Progress (`UI::Progress`)

Real-time progress tracking with step timing and completion estimates.

```ruby
progress = UI::Progress.new(total: 5)

progress.step_start("Installing Homebrew packages", 1)
progress.step_complete("Installing Homebrew packages", duration: 3.2)
progress.step_skipped("Installing fonts")
progress.step_failed("Installing prezto", error: "Git clone failed", duration: 1.1)

progress.increment
progress.complete("Setup completed!")
progress.summary(results)
```

### Formatter (`UI::Formatter`)

Consistent terminal output formatting with colors, icons, and semantic styling.

```ruby
formatter = UI::Formatter.new(use_color: true)

# Status messages
formatter.success("✓ Package installed successfully") 
formatter.error("✗ Installation failed")
formatter.warning("⚠ Version mismatch detected")
formatter.info("ℹ Using cached download")

# Structured output  
formatter.header("=== System Setup ===")
formatter.section("Package Installation") 
formatter.status_icon(:completed)  # Returns colored icon
formatter.table_row(["git", "2.42.0", "✓"])
```

## MenuRunner

High-level orchestrator that combines all components and provides session management.

```ruby
runner = Dotfiles::MenuRunner.new

# Load steps from config/step_order.yml
step_count = runner.load_steps_from_config

# Interactive menu workflow  
runner.run_interactive

# Non-interactive execution
runner.run_all
runner.run_steps(["install_homebrew", "install_fonts"])

# Information and status
runner.list_steps           # Show configured steps with status
runner.list_available_steps # Show all discoverable steps  
runner.show_status         # Summary of step states
runner.resume_session      # Resume interrupted session
```

**Session Management:**
- Automatically saves progress to `~/.dotfiles_session.json`
- Tracks selected, completed, and failed steps
- Supports resuming interrupted sessions
- Prompts to continue on step failures

## Step Implementations

The library includes several production-ready step implementations:

### Package Installation Steps

```ruby
# Install Homebrew packages by category
class InstallHomebrewPackages < Core::Step
  name "install_homebrew_packages"
  description "Install Homebrew packages from Brewfile"
  
  def packages_to_install
    {
      "Development Tools" => %w[git ripgrep jq mise],
      "Build Tools" => %w[autoconf automake coreutils], 
      "Utilities" => %w[bat fzf tree stow]
    }
  end
end

# Install desktop applications via cask
class InstallDesktopApps < Core::Step
  name "install_desktop_apps"
  description "Install desktop applications via Homebrew casks"
  
  def apps_to_install
    {
      "Productivity" => %w[alfred google-chrome],
      "Development" => %w[cursor kitty visual-studio-code],
      "Media" => %w[spotify vlc]
    }
  end
end

# Install fonts via cask
class InstallFonts < Core::Step
  name "install_fonts" 
  description "Install fonts via Homebrew casks"
  
  def fonts_to_install
    {
      "Powerline Fonts" => %w[font-menlo-for-powerline],
      "Nerd Fonts" => %w[font-fira-code-nerd-font font-jetbrains-mono-nerd-font]
    }
  end
end
```

### Development Environment Steps

```ruby
# Install development languages via mise
class InstallDevEnv < Core::Step
  name "install_dev_env"
  description "Install development environments using mise"
  
  def should_skip?
    mise_not_available? || all_languages_installed?
  end
  
  def languages_to_install
    %w[node python ruby]
  end
  
  def language_installed?(language)
    stdout, _, status = Open3.capture3("mise list #{language}")
    return false unless status.success?
    return false if stdout.downcase.include?("missing")
    !stdout.strip.empty?
  end
end
```

### Shell Tool Steps

```ruby
# Install Zplug plugin manager
class InstallZplug < Core::Step
  name "install_zplug"
  description "Install Zplug plugin manager for Zsh"
  
  def should_skip?
    File.directory?("#{ENV['HOME']}/.zplug")
  end
  
  def zplug_install_command
    "curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh"
  end
end

# Install Prezto Zsh framework  
class InstallPrezto < Core::Step
  name "install_prezto"
  description "Install Prezto Zsh framework"
  
  def should_skip?
    File.directory?(prezto_dir)
  end
  
  def prezto_dir
    zdotdir = ENV['ZDOTDIR'] || ENV['HOME']
    "#{zdotdir}/.zprezto"
  end
end
```

### Configuration Steps

```ruby
# Apply dotfile symlinks using GNU Stow
class SymlinkDotfiles < Core::Step
  name "symlink_dotfiles"
  description "Apply dotfile symlinks using GNU Stow"
  
  def should_skip?
    !command_available?("stow")
  end
  
  def packages_to_symlink
    %w[alacritty bat kitty neovim tmux zsh]
  end
  
  def stow_command(package)
    "stow -v -R --target=\"#{target_dir}\" --dir=\"#{dotfile_dir}\" \"#{package}\""
  end
end

# Configure Git user settings
class ConfigureGit < Core::Step
  name "configure_git"
  description "Configure Git user information and settings"
  
  def should_skip?
    git_already_configured?
  end
  
  def perform_step
    git_name = prompt_for_git_name
    git_email = prompt_for_git_email
    
    # Apply user configuration + additional Git settings
    apply_git_settings(git_name, git_email)
  end
end
```

## Step Order Configuration

Define execution order and categories in `config/step_order.yml`:

```yaml
categories:
  - name: "Package Management"
    steps:
      - install_homebrew_packages

  - name: "Desktop Applications"  
    steps:
      - install_desktop_apps

  - name: "Fonts"
    steps:
      - install_fonts

  - name: "Shell Tools"
    steps:
      - install_zplug
      - install_prezto

  - name: "Configuration Files"
    steps:
      - symlink_dotfiles

  - name: "Development Environment"
    steps:
      - install_dev_env

  - name: "Configuration"  
    steps:
      - configure_git
```

## Usage

### Command Line Interface

```bash
# Interactive menu (default)
bin/dotfiles_menu.rb

# List configured steps with status
bin/dotfiles_menu.rb list

# List all discoverable step implementations  
bin/dotfiles_menu.rb available

# Execute all configured steps
bin/dotfiles_menu.rb all

# Execute specific steps by name
bin/dotfiles_menu.rb steps install_homebrew configure_git

# Resume interrupted session
bin/dotfiles_menu.rb resume

# Show step execution status summary
bin/dotfiles_menu.rb status

# Dry run mode (show what would execute)
bin/dotfiles_menu.rb --dry-run menu
```

### Programmatic Usage

```ruby
#!/usr/bin/env ruby

require_relative 'lib/dotfiles/menu_runner'

# Initialize runner
runner = Dotfiles::MenuRunner.new

# Load steps from configuration
runner.load_steps_from_config

# Interactive workflow
runner.run_interactive

# Or programmatic execution
runner.run_all
results = runner.run_steps(["install_homebrew", "symlink_dotfiles"])

# Status and information
runner.show_status
runner.list_available_steps
```

## Writing Custom Steps

### Basic Step Pattern

```ruby
# lib/dotfiles/steps/my_custom_step.rb
module Dotfiles
  module Steps
    class MyCustomStep < Core::Step
      name "my_custom_step"
      description "Performs custom system configuration"
      
      private
      
      def should_skip?
        # Return true if step should be skipped
        already_configured?
      end
      
      def perform_step
        start_time = Time.now
        
        # Your implementation here
        result = execute_custom_logic
        
        if result.success?
          Core::StepResult.success(
            output: "Custom configuration applied successfully",
            step_name: @name,
            duration: Time.now - start_time,
            context: { configured_items: result.items }
          )
        else
          Core::StepResult.failure(
            error: "Configuration failed: #{result.error}",
            step_name: @name,
            duration: Time.now - start_time
          )
        end
      end
      
      def already_configured?
        # Implementation-specific logic
        false
      end
      
      def execute_custom_logic
        # Your custom implementation
      end
    end
  end
end
```

### Step with Categories and Batch Processing

```ruby
module Dotfiles
  module Steps  
    class InstallCliTools < Core::Step
      name "install_cli_tools"
      description "Install command-line development tools"
      
      private
      
      def perform_step
        start_time = Time.now
        
        installed_tools = {}
        failed_tools = {}
        skipped_tools = {}
        
        tools_to_install.each do |category, tool_list|
          puts "  Installing #{category}..."
          
          installed_tools[category] = []
          failed_tools[category] = []  
          skipped_tools[category] = []
          
          tool_list.each do |tool|
            if tool_installed?(tool)
              skipped_tools[category] << tool
              next
            end
            
            puts "    Installing #{tool}..."
            _, stderr, status = Open3.capture3("brew install #{tool}")
            
            if status.success?
              installed_tools[category] << tool
            else
              failed_tools[category] << { tool: tool, error: stderr.strip }
            end
          end
        end
        
        duration = Time.now - start_time
        build_result(installed_tools, failed_tools, skipped_tools, duration)
      end
      
      def tools_to_install
        {
          "Version Control" => %w[git git-delta tig],
          "Text Processing" => %w[ripgrep fd bat jq],
          "Development" => %w[mise overmind]
        }
      end
      
      def tool_installed?(tool)
        stdout, _, status = Open3.capture3("brew list #{tool}")
        status.success? && !stdout.strip.empty?
      rescue
        false
      end
      
      def build_result(installed, failed, skipped, duration)
        total_failed = failed.values.sum { |failures| failures.size }
        
        if total_failed == 0
          Core::StepResult.success(
            output: build_success_output(installed, skipped),
            step_name: @name,
            duration: duration,
            context: { installed: installed, skipped: skipped }
          )
        else
          Core::StepResult.failure(
            error: build_error_output(failed, total_failed),
            step_name: @name,
            duration: duration,
            context: { installed: installed, failed: failed, skipped: skipped }
          )
        end
      end
      
      def build_success_output(installed, skipped)
        output_lines = []
        
        installed.each do |category, tools|
          next if tools.empty?
          output_lines << "#{category}: #{tools.join(', ')}"
        end
        
        "Successfully installed CLI tools:\n#{output_lines.join("\n")}"
      end
      
      def build_error_output(failed, total_failed)
        "Failed to install #{total_failed} tools. Check logs for details."
      end
    end
  end
end
```

### Adding Steps to Configuration

1. **Create step file**: `lib/dotfiles/steps/your_step.rb`
2. **Add to configuration**: Update `config/step_order.yml`
3. **Auto-discovery**: Step is automatically loaded and available

```yaml
# Add to config/step_order.yml
categories:
  - name: "Custom Tools"
    steps:
      - install_cli_tools
      - my_custom_step
```

## Best Practices

### Step Design
- **Single Responsibility**: Each step should have one clear purpose
- **Idempotency**: Always implement `should_skip?` to avoid duplicate work
- **Error Handling**: Provide clear error messages with context
- **Progress Feedback**: Use `puts` for intermediate status updates
- **Timing**: Track and report execution duration for performance monitoring

### Configuration Pattern  
- **Static Data**: Store configuration as class methods returning hashes/arrays
- **Categorization**: Group related items (packages, apps, etc.) by logical categories
- **Flexibility**: Use environment variables for paths and system-specific settings

### Dependencies
- **Explicit Declaration**: Use `depends_on` to declare step dependencies
- **Avoid Circles**: Ensure no circular dependency chains
- **System Dependencies**: Check for required tools (brew, git, etc.) in `should_skip?`

### Error Recovery
- **Graceful Failures**: Continue processing other items when individual items fail
- **Detailed Context**: Include failed items and error details in result context
- **User Guidance**: Provide actionable error messages with suggested fixes