# Dotfiles Ruby Library

A robust, interactive framework for automating system setup and configuration tasks. This library provides a step-based architecture with dependency resolution, progress tracking, and an intuitive menu-driven interface.

## Architecture Overview

The library is organized into three main modules:

- **`Core`** - Essential framework components (Step, Executor, Logger, Config)
- **`UI`** - User interface components (Menu, Progress, Formatter)
- **`Steps`** - Concrete step implementations

## Core Components

### Step (`Core::Step`)

The base class for all automation steps. Uses the template method pattern to provide a consistent execution lifecycle.

```ruby
class MyStep < Dotfiles::Core::Step
  def initialize
    super(
      name: "my_step",
      description: "Does something useful",
      dependencies: ["prerequisite_step"]
    )
  end

  private

  def should_skip?
    # Return true if step should be skipped (idempotency check)
    false
  end

  def pre_execute
    # Setup and validation before execution
  end

  def perform_step
    # Main step implementation - must return StepResult
    Core::StepResult.success(
      output: "Step completed successfully",
      step_name: @name
    )
  end

  def post_execute(result)
    # Cleanup and verification after execution
  end
end
```

#### Step Lifecycle

1. `should_skip?` - Check if step should be skipped
2. `pre_execute` - Setup and validation
3. `perform_step` - Main execution (must be implemented)
4. `post_execute` - Cleanup and verification

#### Step Status

Steps track their execution status:
- `:pending` - Not yet executed
- `:running` - Currently executing
- `:completed` - Successfully completed
- `:failed` - Execution failed
- `:skipped` - Skipped due to idempotency

### StepResult (`Core::StepResult`)

Represents the result of step execution with detailed context.

```ruby
# Success result
result = Core::StepResult.success(
  output: "Command output",
  step_name: "my_step",
  duration: 1.5,
  context: { command: "ls -la" }
)

# Failure result
result = Core::StepResult.failure(
  error: "Command failed",
  output: "Error output",
  step_name: "my_step",
  context: { exit_code: 1 }
)

# Skipped result
result = Core::StepResult.skipped(step_name: "my_step")
```

### Executor (`Core::Executor`)

Orchestrates step execution with dependency resolution and error handling.

```ruby
executor = Core::Executor.new(dry_run: false)

# Add steps
executor.add_step(step1)
executor.add_step(step2)

# Execute all steps (with dependency resolution)
results = executor.execute_all

# Execute specific step (with dependencies)
result = executor.execute_step("step_name")
```

### Logger (`Core::Logger`)

Structured logging with multiple verbosity levels and colored output.

```ruby
logger = Core::Logger.new(level: :info, use_color: true)

logger.info("Information message")
logger.success("Operation completed")
logger.error("Something went wrong")
logger.debug("Debug information")

# Step-specific logging
logger.step_start("Installing package")
logger.step_complete("Installing package", duration: 2.5)
logger.step_failed("Installing package", "Package not found")
```

### Config (`Core::Config`)

Simple configuration management with sensible defaults.

```ruby
config = Core::Config.new

config.log_level      # :info
config.use_color?     # true
config.dry_run?       # false
config.dotfiles_dir   # "/Users/username/dev/dotfiles"
config.target_dir     # "/Users/username"
```

## UI Components

### Menu (`UI::Menu`)

Interactive menu system for step selection and execution.

```ruby
menu = UI::Menu.new(steps, formatter: formatter)
selected_steps = menu.run

# Controls:
# ↑/↓    - Navigate
# Space  - Select/deselect
# Enter  - Execute selected
# a      - Select all
# c      - Clear selection
# h      - Toggle help
# q      - Quit
```

### Progress (`UI::Progress`)

Real-time progress tracking with ETAs and summaries.

```ruby
progress = UI::Progress.new(total: 5)

progress.step_start("Installing packages", 1)
progress.step_complete("Installing packages", duration: 2.1)
progress.increment

progress.complete("All steps finished!")
progress.summary(results)
```

### Formatter (`UI::Formatter`)

Consistent output formatting with colors and icons.

```ruby
formatter = UI::Formatter.new(use_color: true)

formatter.success("✓ Operation completed")
formatter.error("✗ Operation failed")
formatter.warning("⚠ Warning message")
formatter.info("ℹ Information")

# Specialized formatting
formatter.header("Section Title")
formatter.command("$ brew install git")
formatter.file_path("/path/to/file")
```

## MenuRunner

High-level interface that combines all components for easy use.

```ruby
runner = MenuRunner.new
runner.add_steps([step1, step2, step3])

# Interactive menu
runner.run_interactive

# Execute all steps
runner.run_all

# Execute specific steps
runner.run_steps(["step1", "step2"])

# List available steps
runner.list_steps

# Show status summary
runner.show_status

# Resume interrupted session
runner.resume_session
```

## Writing Custom Steps

Steps are now defined as self-contained classes using a declarative DSL. Each step should be placed in `lib/dotfiles/steps/` and will be automatically discovered.

### Step Architecture

Steps use class-level methods to declare their properties and implement their logic in `perform_step`:

```ruby
# lib/dotfiles/steps/install_package.rb
module Dotfiles
  module Steps
    class InstallPackage < Core::Step
      name "install_package"
      description "Install a package via Homebrew"
      depends_on InstallHomebrew

      private

      def should_skip?
        # Check if already installed
        system("brew list #{package_name} > /dev/null 2>&1")
      end

      def perform_step
        stdout, stderr, status = Open3.capture3("brew install #{package_name}")

        if status.success?
          Core::StepResult.success(
            output: stdout,
            step_name: @name
          )
        else
          Core::StepResult.failure(
            error: "Installation failed: #{stderr}",
            output: stdout,
            step_name: @name
          )
        end
      end

      def package_name
        "git" # Override in subclasses or make configurable
      end
    end
  end
end
```

### Step Auto-Discovery

Steps are automatically discovered and loaded. The system:

1. **Loads all step files** from `lib/dotfiles/steps/*.rb`
2. **Finds all Step subclasses** using `Step.subclasses`
3. **Orders steps** based on `config/step_order.yml`
4. **Validates dependencies** and reports missing implementations

### Step Ordering Configuration

Create `config/step_order.yml` to define categories and execution order:

```yaml
categories:
  - name: "System Setup"
    steps:
      - install_homebrew
      - install_git
      
  - name: "Applications"
    steps:
      - install_desktop_apps
      
  - name: "Configuration"
    steps:
      - setup_symlinks
```

### Complex Step Example

```ruby
# lib/dotfiles/steps/install_desktop_apps.rb
module Dotfiles
  module Steps
    class InstallDesktopApps < Core::Step
      name "install_desktop_apps"
      description "Install desktop applications via Homebrew"
      depends_on InstallHomebrew

      private

      def should_skip?
        apps_to_install.all? { |app| app_installed?(app) }
      end

      def perform_step
        installed_apps = []
        failed_apps = []

        apps_to_install.each do |app|
          next if app_installed?(app)

          stdout, stderr, status = Open3.capture3("brew install --cask #{app}")

          if status.success?
            installed_apps << app
          else
            failed_apps << { app: app, error: stderr.strip }
          end
        end

        if failed_apps.empty?
          Core::StepResult.success(
            output: "Installed #{installed_apps.length} applications",
            step_name: @name,
            context: { installed: installed_apps }
          )
        else
          Core::StepResult.failure(
            error: "Failed to install #{failed_apps.length} applications",
            step_name: @name,
            context: { installed: installed_apps, failed: failed_apps }
          )
        end
      end

      def apps_to_install
        %w[
          alfred
          visual-studio-code
          kitty
          google-chrome
          discord
        ]
      end

      def app_installed?(app)
        system("brew list --cask #{app} > /dev/null 2>&1")
      end
    end
  end
end
```

### File System Step

```ruby
class CreateSymlinkStep < Core::Step
  def initialize(source, target)
    super(
      name: "symlink_#{File.basename(source)}",
      description: "Create symlink: #{source} -> #{target}"
    )
    @source = File.expand_path(source)
    @target = File.expand_path(target)
  end

  private

  def should_skip?
    File.symlink?(@target) && File.readlink(@target) == @source
  end

  def pre_execute
    unless File.exist?(@source)
      raise ArgumentError, "Source file does not exist: #{@source}"
    end
  end

  def perform_step
    begin
      # Backup existing file if needed
      if File.exist?(@target) && !File.symlink?(@target)
        FileUtils.mv(@target, "#{@target}.backup")
      end

      # Remove existing symlink
      File.unlink(@target) if File.symlink?(@target)

      # Create symlink
      File.symlink(@source, @target)

      Core::StepResult.success(
        output: "Symlink created: #{@source} -> #{@target}",
        step_name: @name
      )
    rescue => e
      Core::StepResult.failure(
        error: e.message,
        step_name: @name
      )
    end
  end
end
```

### Multi-Command Step

```ruby
class SetupDevelopmentStep < Core::Step
  def initialize
    super(
      name: "setup_development",
      description: "Setup development environment",
      dependencies: ["install_homebrew"]
    )
  end

  private

  def perform_step
    commands = [
      "brew install git node ruby python",
      "npm install -g yarn",
      "gem install bundler"
    ]

    results = []
    total_duration = 0

    commands.each_with_index do |cmd, index|
      puts "  [#{index + 1}/#{commands.size}] #{cmd}"
      
      start_time = Time.now
      stdout, stderr, status = Open3.capture3(cmd)
      duration = Time.now - start_time
      total_duration += duration

      unless status.success?
        return Core::StepResult.failure(
          error: "Command failed: #{cmd}\n#{stderr}",
          output: results.join("\n"),
          step_name: @name,
          duration: total_duration
        )
      end

      results << stdout
    end

    Core::StepResult.success(
      output: results.join("\n"),
      step_name: @name,
      duration: total_duration
    )
  end
end
```

### Step with Optional Behavior

```ruby
class ConfigureGitStep < Core::Step
  def initialize(optional: true)
    super(
      name: "configure_git",
      description: "Configure Git user settings"
    )
    @optional = optional
  end

  def optional?
    @optional
  end

  private

  def should_skip?
    # Skip if already configured
    name = `git config --global user.name`.strip
    email = `git config --global user.email`.strip
    !name.empty? && !email.empty?
  end

  def perform_step
    print "Enter Git user name: "
    name = $stdin.gets.chomp

    print "Enter Git email: "
    email = $stdin.gets.chomp

    if name.empty? || email.empty?
      return Core::StepResult.failure(
        error: "Name and email are required",
        step_name: @name
      )
    end

    commands = [
      "git config --global user.name '#{name}'",
      "git config --global user.email '#{email}'"
    ]

    commands.each do |cmd|
      _, _, status = Open3.capture3(cmd)
      unless status.success?
        return Core::StepResult.failure(
          error: "Failed to configure git: #{cmd}",
          step_name: @name
        )
      end
    end

    Core::StepResult.success(
      output: "Git configured: #{name} <#{email}>",
      step_name: @name
    )
  end
end
```

## Usage

### Running the Menu System

```bash
# Interactive menu with auto-loaded steps
bin/dotfiles_menu.rb

# List all loaded steps
bin/dotfiles_menu.rb list

# List all available step implementations
bin/dotfiles_menu.rb available

# Execute all steps
bin/dotfiles_menu.rb all

# Execute specific steps
bin/dotfiles_menu.rb steps install_homebrew install_desktop_apps
```

### Programmatic Usage

```ruby
#!/usr/bin/env ruby

require_relative 'lib/dotfiles/menu_runner'

runner = Dotfiles::MenuRunner.new

# Auto-load steps from config
runner.load_steps_from_config

# Run interactively
runner.run_interactive

# Or run specific functionality
runner.run_all
runner.list_available_steps
```

### Creating New Steps

1. **Create the step file**: `lib/dotfiles/steps/my_new_step.rb`
2. **Add to config**: Include step name in `config/step_order.yml`
3. **Steps are auto-discovered** - no manual registration needed

```ruby
# lib/dotfiles/steps/my_new_step.rb
module Dotfiles
  module Steps
    class MyNewStep < Core::Step
      name "my_new_step"
      description "Does something useful"
      depends_on SomeOtherStep

      private

      def perform_step
        # Your implementation here
        Core::StepResult.success(
          output: "Step completed",
          step_name: @name
        )
      end
    end
  end
end
```

## Best Practices

### Step Design
- Keep steps focused on a single responsibility
- Use descriptive names and descriptions
- Implement proper idempotency checks
- Handle errors gracefully with meaningful messages
- Include relevant context in results

### Dependencies
- Declare dependencies explicitly
- Avoid circular dependencies
- Consider making steps optional when appropriate
- Use dependency injection for testability

### Error Handling
- Provide clear error messages
- Include suggested remediation steps
- Use appropriate result types (success/failure/skipped)
- Log errors with sufficient context

### Performance
- Implement proper `should_skip?` checks
- Avoid unnecessary work in already-completed steps
- Use timeouts for long-running commands
- Provide progress feedback for slow operations