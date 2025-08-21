#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

# Add lib directory to load path
lib_path = Pathname.new(__FILE__).dirname.parent.join('lib')
$LOAD_PATH.unshift(lib_path.to_s)

require 'dotfiles/menu_runner'
require 'dotfiles/steps/example_step'

def create_sample_steps
  steps = []
  
  # System check steps
  steps << Dotfiles::Steps::SystemCheckStep.new(
    check_command: "uname -s",
    description: "Check operating system type"
  )
  
  steps << Dotfiles::Steps::SystemCheckStep.new(
    check_command: "whoami",
    description: "Verify current user"
  )
  
  # File system steps
  steps << Dotfiles::Steps::ExampleStep.new(
    command: "ls -la ~/.zshrc",
    name: "check_zshrc",
    description: "Check if .zshrc exists",
    optional: true
  )
  
  steps << Dotfiles::Steps::ExampleStep.new(
    command: "ls -la ~/.gitconfig",
    name: "check_gitconfig", 
    description: "Check if .gitconfig exists",
    optional: true
  )
  
  # Package checks
  steps << Dotfiles::Steps::PackageInstallStep.new(
    package_name: "git",
    check_command: "git --version"
  )
  
  steps << Dotfiles::Steps::PackageInstallStep.new(
    package_name: "ruby",
    check_command: "ruby --version"
  )
  
  steps << Dotfiles::Steps::PackageInstallStep.new(
    package_name: "node",
    check_command: "node --version"
  )
  
  # Demonstration steps
  steps << Dotfiles::Steps::ExampleStep.new(
    command: "date",
    name: "show_date",
    description: "Display current date",
    expected_output: "2025"
  )
  
  steps << Dotfiles::Steps::ExampleStep.new(
    command: "echo 'Hello from Dotfiles Ruby Framework!'",
    name: "hello_world",
    description: "Display greeting message",
    expected_output: "Hello from Dotfiles Ruby Framework!"
  )
  
  # Slow step for progress demonstration
  steps << Dotfiles::Steps::ExampleStep.new(
    command: "sleep 3 && echo 'Slow operation completed'",
    name: "slow_demo",
    description: "Demonstrate slow operation with progress",
    expected_output: "Slow operation completed"
  )
  
  # Step with dependency
  steps << Dotfiles::Steps::ExampleStep.new(
    command: "git status 2>/dev/null || echo 'Not a git repository'",
    name: "git_status",
    description: "Check git repository status",
    optional: true,
    dependencies: ["install_git"]
  )
  
  # Failing step for error handling demonstration
  steps << Dotfiles::Steps::ExampleStep.new(
    command: "exit 1",
    name: "demo_failure",
    description: "Demonstrate error handling",
    optional: true
  )
  
  steps
end

def show_help
  puts <<~HELP
    Dotfiles Ruby Framework - Interactive Menu Demo
    
    USAGE:
      #{$0} [command] [options]
    
    COMMANDS:
      menu          Show interactive menu (default)
      list          List all available steps
      status        Show step status summary
      all           Execute all steps
      resume        Resume interrupted session
      steps NAMES   Execute specific steps by name
    
    OPTIONS:
      --dry-run     Show what would be executed without running
      --help        Show this help message
    
    EXAMPLES:
      #{$0}                           # Show interactive menu
      #{$0} list                      # List all steps
      #{$0} all                       # Execute all steps
      #{$0} steps hello_world         # Execute specific step
      #{$0} steps install_git show_date # Execute multiple steps
      #{$0} --dry-run menu            # Dry run with menu
    
    INTERACTIVE MENU CONTROLS:
      ↑/↓         Navigate steps
      Space       Toggle step selection
      Enter       Execute selected steps
      a           Select all steps
      c           Clear selection
      h           Toggle help
      q           Quit
  HELP
end

def main
  # Parse command line arguments
  dry_run = ARGV.include?('--dry-run')
  help = ARGV.include?('--help') || ARGV.include?('-h')
  
  if help
    show_help
    exit 0
  end
  
  # Set dry run environment variable if specified
  ENV['DOTFILES_DRY_RUN'] = 'true' if dry_run
  
  # Initialize menu runner
  runner = Dotfiles::MenuRunner.new
  
  # Add sample steps
  steps = create_sample_steps
  runner.add_steps(steps)
  
  # Parse command
  command = ARGV.find { |arg| !arg.start_with?('--') } || 'menu'
  
  puts runner.formatter.header("Dotfiles Ruby Framework Demo")
  puts runner.formatter.info("Dry run mode enabled") if dry_run
  puts
  
  case command
  when 'menu'
    runner.run_interactive
    
  when 'list'
    runner.list_steps
    
  when 'status'
    runner.show_status
    
  when 'all'
    runner.run_all
    
  when 'resume'
    success = runner.resume_session
    exit(success ? 0 : 1)
    
  when 'steps'
    step_names = ARGV.drop_while { |arg| arg != 'steps' }[1..-1]
    if step_names.empty?
      puts runner.formatter.error("No step names provided")
      puts "Available steps:"
      runner.list_steps
      exit 1
    end
    
    runner.run_steps(step_names)
    
  else
    puts runner.formatter.error("Unknown command: #{command}")
    puts
    show_help
    exit 1
  end

rescue Interrupt
  puts
  puts runner.formatter.warning("Interrupted by user")
  exit 130
rescue => e
  puts runner.formatter.error("Error: #{e.message}")
  puts e.backtrace.join("\n") if ENV['DEBUG']
  exit 1
end

main if __FILE__ == $0