# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class InstallDevEnv < Core::Step
      name "install_dev_env"
      description "Install development environments using mise"

      private

      def should_skip?
        mise_not_available? || all_languages_installed?
      end

      def perform_step
        start_time = Time.now

        installed_languages = []
        failed_languages = []
        skipped_languages = []

        languages_to_install.each do |language|
          if language_installed?(language)
            skipped_languages << language
            puts "  #{language} is already installed, skipping..."
            next
          end

          puts "  Installing #{language}..."
          _, stderr, status = Open3.capture3("mise use --global #{language}")

          if status.success?
            installed_languages << language
            puts "    ✓ Successfully installed #{language}"
          else
            failed_languages << {language: language, error: stderr.strip}
            puts "    ✗ Failed to install #{language}: #{stderr.lines.first&.strip}"
          end
        end

        duration = Time.now - start_time
        build_result(installed_languages, failed_languages, skipped_languages, duration)
      end

      def languages_to_install
        %w[node python ruby]
      end

      def mise_not_available?
        stdout, _, status = Open3.capture3("command -v mise")
        !status.success? || stdout.strip.empty?
      rescue
        true
      end

      def all_languages_installed?
        languages_to_install.all? { |lang| language_installed?(lang) }
      end

      def language_installed?(language)
        stdout, _, status = Open3.capture3("mise list #{language}")
        return false unless status.success?

        # If stdout contains "missing", the language is not installed
        return false if stdout.downcase.include?("missing")

        # If stdout is empty or only whitespace, no versions are installed
        !stdout.strip.empty?
      rescue
        false
      end

      def build_result(installed, failed, skipped, duration)
        total_installed = installed.size
        total_failed = failed.size
        total_skipped = skipped.size

        if total_failed == 0
          Core::StepResult.success(
            output: build_success_output(installed, skipped, total_installed, total_skipped),
            step_name: @name,
            duration: duration,
            context: {
              installed: installed,
              skipped: skipped,
              languages: languages_to_install
            }
          )
        else
          Core::StepResult.failure(
            error: build_error_output(failed, total_failed),
            output: build_partial_output(installed, failed, skipped),
            step_name: @name,
            duration: duration,
            context: {
              installed: installed,
              failed: failed,
              skipped: skipped
            }
          )
        end
      end

      def build_success_output(installed, skipped, total_installed, total_skipped)
        output_lines = []

        if total_installed > 0
          output_lines << "Successfully installed #{total_installed} development environments:"
          output_lines << "  Languages: #{installed.join(", ")}"
        end

        if total_skipped > 0
          output_lines << "\nSkipped #{total_skipped} already installed languages:"
          output_lines << "  Languages: #{skipped.join(", ")}"
        end

        output_lines << "\nRestart your terminal to use the new environments."
        output_lines.join("\n")
      end

      def build_error_output(failed, total_failed)
        output_lines = ["Failed to install #{total_failed} languages:"]

        failed.each do |failure|
          error_msg = failure[:error].lines.first&.strip || "Unknown error"
          output_lines << "  #{failure[:language]}: #{error_msg}"
        end

        output_lines.join("\n")
      end

      def build_partial_output(installed, failed, skipped)
        output_parts = []

        output_parts << "Installed: #{installed.size}" if installed.size > 0
        output_parts << "Failed: #{failed.size}" if failed.size > 0
        output_parts << "Skipped: #{skipped.size}" if skipped.size > 0

        "Development environment installation summary - #{output_parts.join(", ")}"
      end
    end
  end
end
