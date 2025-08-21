# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class ExampleStep < Core::Step
      def initialize(command:, name: nil, description: nil, expected_output: nil, optional: false, timeout: 30, dependencies: [])
        step_name = name || "example_#{command.gsub(/\s+/, "_")}"
        step_description = description || "Execute command: #{command}"
        
        super(
          name: step_name,
          description: step_description,
          dependencies: dependencies
        )
        @command = command
        @expected_output = expected_output
        @optional = optional
        @timeout = timeout
      end

      def optional?
        @optional
      end

      private

      def should_skip?
        # Example: Skip if command has already been run successfully
        # This could check for a marker file, process, or other condition
        false
      end

      def pre_execute
        # Validation before execution
        if @command.nil? || @command.strip.empty?
          raise ArgumentError, "Command cannot be empty"
        end
      end

      def perform_step
        start_time = Time.now

        begin
          stdout, stderr, status = Open3.capture3(@command, timeout: @timeout)
          duration = Time.now - start_time

          if status.success?
            if @expected_output && !stdout.include?(@expected_output)
              return Core::StepResult.failure(
                error: "Command succeeded but output didn't match expected: '#{@expected_output}'",
                output: stdout,
                step_name: @name,
                duration: duration,
                context: {
                  command: @command,
                  stderr: stderr,
                  exit_code: status.exitstatus
                }
              )
            end

            Core::StepResult.success(
              output: stdout,
              step_name: @name,
              duration: duration,
              context: {
                command: @command,
                exit_code: status.exitstatus
              }
            )
          else
            Core::StepResult.failure(
              error: "Command failed with exit code #{status.exitstatus}",
              output: stdout,
              step_name: @name,
              duration: duration,
              context: {
                command: @command,
                stderr: stderr,
                exit_code: status.exitstatus
              }
            )
          end
        rescue Timeout::Error
          duration = Time.now - start_time
          Core::StepResult.failure(
            error: "Command timed out after #{@timeout} seconds",
            step_name: @name,
            duration: duration,
            context: {
              command: @command,
              timeout: @timeout
            }
          )
        end
      end

      def post_execute(result)
        # Optional cleanup or verification after execution
        if result.success?
          # Could write a marker file to indicate successful completion
          # File.write(marker_file_path, Time.now.to_s)
        end
      end

      private

      def marker_file_path
        File.join(ENV["HOME"], ".dotfiles_markers", "#{@name}.completed")
      end
    end

    # Convenience subclasses for common step types
    class SystemCheckStep < ExampleStep
      def initialize(check_command:, name: nil, description: nil)
        step_name = name || "check_#{check_command.gsub(/\s+/, "_")}"
        step_description = description || "System check: #{check_command}"
        
        super(
          command: check_command,
          name: step_name,
          description: step_description,
          optional: false
        )
      end

      private

      def should_skip?
        # System checks might not need to be skipped
        false
      end
    end

    class PackageInstallStep < ExampleStep
      def initialize(package_name:, install_command: nil, check_command: nil)
        @package_name = package_name
        @check_command = check_command || "which #{package_name}"

        install_cmd = install_command || "brew install #{package_name}"

        super(
          command: install_cmd,
          name: "install_#{package_name}",
          description: "Install package: #{package_name}",
          optional: true
        )
      end

      private

      def should_skip?
        # Skip if package is already installed
        stdout, _, status = Open3.capture3(@check_command)
        status.success? && !stdout.strip.empty?
      rescue
        false
      end
    end
  end
end
