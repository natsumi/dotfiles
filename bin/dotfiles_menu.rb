#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

# Add lib directory to load path
lib_path = Pathname.new(__FILE__).dirname.parent.join('lib')
$LOAD_PATH.unshift(lib_path.to_s)

require 'dotfiles/menu_runner'

def show_help
  puts <<~HELP
    Dotfiles Ruby Framework - Interactive Menu Demo
    
    USAGE:
      #{$0} [command] [options]
    
    COMMANDS:
      menu          Show interactive menu (default)
      list          List loaded steps with status
      available     List all available steps in lib/steps/
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
  
  # Load steps from configuration
  begin
    step_count = runner.load_steps_from_config
    puts runner.formatter.success("Loaded #{step_count} steps from configuration")
  rescue => e
    puts runner.formatter.error("Failed to load steps: #{e.message}")
    puts runner.formatter.info("Use 'available' command to see all available steps")
    puts
  end
  
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
    
  when 'available'
    runner.list_available_steps
    
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