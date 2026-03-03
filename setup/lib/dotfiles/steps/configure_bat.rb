# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class ConfigureBat < Core::Step
      name "configure_bat"
      description "Refresh bat theme cache"

      private

      def should_skip?
        bat_not_available?
      end

      def perform_step
        start_time = Time.now

        puts "  Refreshing bat theme cache..."
        stdout, stderr, status = Open3.capture3(bat_cache_command)

        duration = Time.now - start_time

        if status.success?
          Core::StepResult.success(
            output: "Successfully refreshed bat theme cache",
            step_name: @name,
            duration: duration,
            context: {
              command: bat_cache_command,
              output: stdout.strip
            }
          )
        else
          Core::StepResult.failure(
            error: "Failed to refresh bat cache: #{stderr.strip}",
            output: "bat cache refresh failed",
            step_name: @name,
            duration: duration,
            context: {
              command: bat_cache_command,
              error_details: stderr.strip
            }
          )
        end
      end

      def bat_not_available?
        stdout, _, status = Open3.capture3("command -v bat")
        !status.success? || stdout.strip.empty?
      rescue
        true
      end

      def bat_cache_command
        "bat cache --build"
      end
    end
  end
end
