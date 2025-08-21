# frozen_string_literal: true

require_relative "core/executor"
require_relative "core/logger"
require_relative "core/config"
require_relative "core/step_loader"
require_relative "ui/menu"
require_relative "ui/progress"
require_relative "ui/formatter"
require "json"
require "fileutils"

module Dotfiles
  class MenuRunner
    attr_reader :config, :logger, :formatter, :executor, :session_file

    def initialize
      @config = Core::Config.new
      @formatter = UI::Formatter.new(use_color: @config.use_color?)
      @logger = Core::Logger.new(level: @config.log_level, use_color: @config.use_color?)
      @executor = Core::Executor.new(dry_run: @config.dry_run?)
      @session_file = File.join(ENV["HOME"], ".dotfiles_session.json")
      @steps = []
    end

    def add_step(step)
      @steps << step
      @executor.add_step(step)
    end

    def add_steps(steps)
      steps.each { |step| add_step(step) }
    end

    def load_steps_from_config(config_path = nil)
      begin
        steps = Core::StepLoader.load_ordered_steps(config_path)
        add_steps(steps)
        steps.length
      rescue Core::StepLoader::MissingStepError => e
        puts @formatter.error("Missing step implementation: #{e.message}")
        raise
      rescue Core::StepLoader::InvalidConfigError => e
        puts @formatter.error("Invalid step configuration: #{e.message}")
        raise
      end
    end

    def list_available_steps
      puts @formatter.header("Available Steps")
      
      available = Core::StepLoader.available_steps
      
      if available.empty?
        puts @formatter.warning("No steps found in lib/dotfiles/steps/")
        return
      end

      available.each_with_index do |step_info, index|
        puts sprintf("  %2d. %-30s - %s", 
          index + 1, step_info[:name], step_info[:description])
      end
      puts
    end

    def run_interactive
      load_session if File.exist?(@session_file)

      loop do
        menu = UI::Menu.new(@steps, formatter: @formatter)
        selected_steps = menu.run

        break unless selected_steps

        if selected_steps.empty?
          puts @formatter.warning("No steps selected")
          sleep(1)
          next
        end

        save_session(selected_steps.map(&:name))
        execute_steps(selected_steps)

        unless prompt_continue?
          break
        end
      end

      cleanup_session
    end

    def run_all
      puts @formatter.header("Executing All Steps")
      execute_steps(@steps)
    end

    def run_steps(step_names)
      selected_steps = step_names.map do |name|
        @steps.find { |step| step.name == name }
      end.compact

      if selected_steps.empty?
        puts @formatter.error("No valid steps found for: #{step_names.join(", ")}")
        return false
      end

      execute_steps(selected_steps)
    end

    def list_steps
      puts @formatter.header("Available Steps")

      if @steps.empty?
        puts @formatter.warning("No steps registered")
        return
      end

      # Group steps by category if they have one
      categorized = group_steps_by_category

      categorized.each do |category, steps|
        puts @formatter.section(category)
        steps.each_with_index do |step, index|
          status_icon = @formatter.status_icon(step.status)
          deps = step.dependencies.any? ? " (deps: #{step.dependencies.join(", ")})" : ""
          puts sprintf("  %2d. %s %-30s - %s%s",
            index + 1, status_icon, step.name, step.description, deps)
        end
        puts
      end
    end

    def resume_session
      unless File.exist?(@session_file)
        puts @formatter.warning("No session to resume")
        return false
      end

      session_data = load_session
      pending_steps = session_data["pending_steps"] || []

      if pending_steps.empty?
        puts @formatter.info("No pending steps in session")
        cleanup_session
        return false
      end

      puts @formatter.info("Resuming session with #{pending_steps.length} pending steps")
      run_steps(pending_steps)
    end

    def show_status
      puts @formatter.header("Step Status Summary")

      status_counts = {
        pending: 0,
        running: 0,
        completed: 0,
        failed: 0,
        skipped: 0
      }

      @steps.each { |step| status_counts[step.status] += 1 }

      puts @formatter.table_header(["Status", "Count", "Steps"])

      status_counts.each do |status, count|
        next if count == 0

        status_steps = @steps.select { |s| s.status == status }.map(&:name).join(", ")
        status_steps = status_steps[0..50] + "..." if status_steps.length > 50

        puts @formatter.table_row([
          @formatter.status_icon(status) + " " + status.to_s.capitalize,
          count.to_s,
          status_steps
        ], status: status)
      end

      puts
    end

    private

    def execute_steps(steps)
      return if steps.empty?

      puts @formatter.header("Executing Selected Steps")
      puts

      progress = UI::Progress.new(total: steps.length)
      results = []

      steps.each_with_index do |step, index|
        progress.step_start(step.name, index + 1)

        result = @executor.execute_step(step.name)
        results << result

        case result.success?
        when true
          if result.skipped?
            progress.step_skipped(step.name)
          else
            progress.step_complete(step.name, result.duration)
          end
        when false
          progress.step_failed(step.name, result.error_message, result.duration)

          unless prompt_continue_on_error?(step, result)
            break
          end
        end

        progress.increment
        update_session_progress(step.name)
      end

      progress.complete
      progress.summary(results)

      results
    end

    def group_steps_by_category
      categories = {}

      @steps.each do |step|
        category = extract_category(step.name) || "General"
        categories[category] ||= []
        categories[category] << step
      end

      categories
    end

    def extract_category(step_name)
      case step_name
      when /^install_/
        "Package Installation"
      when /^symlink_/
        "Symlink Management"
      when /^setup_/
        "System Setup"
      when /^check_/
        "System Checks"
      end
    end

    def save_session(selected_step_names)
      session_data = {
        "timestamp" => Time.now.iso8601,
        "selected_steps" => selected_step_names,
        "pending_steps" => selected_step_names.dup,
        "completed_steps" => [],
        "failed_steps" => []
      }

      FileUtils.mkdir_p(File.dirname(@session_file))
      File.write(@session_file, JSON.pretty_generate(session_data))
    end

    def load_session
      return {} unless File.exist?(@session_file)

      JSON.parse(File.read(@session_file))
    rescue JSON::ParserError
      puts @formatter.warning("Invalid session file, starting fresh")
      {}
    end

    def update_session_progress(completed_step)
      return unless File.exist?(@session_file)

      session_data = load_session
      session_data["pending_steps"]&.delete(completed_step)
      session_data["completed_steps"] ||= []
      session_data["completed_steps"] << completed_step

      File.write(@session_file, JSON.pretty_generate(session_data))
    end

    def cleanup_session
      File.delete(@session_file) if File.exist?(@session_file)
    end

    def prompt_continue?
      print @formatter.prompt("Continue with menu? (y/N): ")
      response = $stdin.gets.chomp.downcase
      %w[y yes].include?(response)
    end

    def prompt_continue_on_error?(step, result)
      puts
      puts @formatter.error_with_suggestion(
        "Step '#{step.name}' failed: #{result.error_message}",
        "Check the error details above and decide whether to continue"
      )
      puts

      print @formatter.prompt("Continue with remaining steps? (y/N): ")
      response = $stdin.gets.chomp.downcase
      %w[y yes].include?(response)
    end
  end
end
