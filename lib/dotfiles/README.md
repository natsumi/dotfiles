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

### Basic Command Step

```ruby
class InstallPackageStep < Core::Step
  def initialize(package_name)
    super(
      name: "install_#{package_name}",
      description: "Install #{package_name} via Homebrew"
    )
    @package_name = package_name
  end

  private

  def should_skip?
    # Check if already installed
    _, _, status = Open3.capture3("brew list #{@package_name}")
    status.success?
  end

  def perform_step
    start_time = Time.now
    stdout, stderr, status = Open3.capture3("brew install #{@package_name}")
    duration = Time.now - start_time

    if status.success?
      Core::StepResult.success(
        output: stdout,
        step_name: @name,
        duration: duration
      )
    else
      Core::StepResult.failure(
        error: "Installation failed: #{stderr}",
        output: stdout,
        step_name: @name,
        duration: duration
      )
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

## Example Usage

```ruby
#!/usr/bin/env ruby

require_relative 'lib/dotfiles/menu_runner'

# Create steps
steps = [
  InstallPackageStep.new("git"),
  InstallPackageStep.new("node"),
  CreateSymlinkStep.new("~/.dotfiles/zsh/.zshrc", "~/.zshrc"),
  ConfigureGitStep.new,
  SetupDevelopmentStep.new
]

# Run interactively
runner = MenuRunner.new
runner.add_steps(steps)
runner.run_interactive
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