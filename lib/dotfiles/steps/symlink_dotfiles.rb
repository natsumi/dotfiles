# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class SymlinkDotfiles < Core::Step
      name "symlink_dotfiles"
      description "Apply dotfile symlinks using GNU Stow"

      private

      def should_skip?
        stow_not_available?
      end

      def perform_step
        start_time = Time.now

        successful_packages = []
        failed_packages = []

        packages_to_symlink.each do |package|
          puts "  Symlinking #{package}..."

          _, stderr, status = Open3.capture3(stow_command(package))

          if status.success?
            successful_packages << package
            puts "    ✓ Successfully symlinked #{package}"
          else
            failed_packages << {package: package, error: stderr.strip}
            puts "    ✗ Failed to symlink #{package}: #{stderr.lines.first&.strip}"
          end
        end

        duration = Time.now - start_time
        build_result(successful_packages, failed_packages, duration)
      end

      def packages_to_symlink
        %w[
          alacritty aerospace bat elixir eslint helix jetbrains
          kitty mise neovim prettier ripgrep ruby tig
          tmux yt-dlp yabai zsh
        ]
      end

      def stow_not_available?
        stdout, _, status = Open3.capture3("which stow")
        !status.success? || stdout.strip.empty?
      rescue
        true
      end

      def dotfile_dir
        ENV["DOTFILE_DIR"] || "#{ENV["HOME"]}/dev/dotfiles"
      end

      def target_dir
        ENV["HOME"]
      end

      def stow_command(package)
        "stow -v -R --target=\"#{target_dir}\" --dir=\"#{dotfile_dir}\" \"#{package}\""
      end

      def build_result(successful, failed, duration)
        total_successful = successful.size
        total_failed = failed.size

        if total_failed == 0
          Core::StepResult.success(
            output: build_success_output(successful, total_successful),
            step_name: @name,
            duration: duration,
            context: {
              symlinked_packages: successful,
              total_packages: packages_to_symlink.size,
              dotfile_dir: dotfile_dir,
              target_dir: target_dir
            }
          )
        else
          Core::StepResult.failure(
            error: build_error_output(failed, total_failed),
            output: build_partial_output(successful, failed),
            step_name: @name,
            duration: duration,
            context: {
              symlinked_packages: successful,
              failed_packages: failed,
              dotfile_dir: dotfile_dir,
              target_dir: target_dir
            }
          )
        end
      end

      def build_success_output(successful, total_successful)
        output_lines = []
        output_lines << "Successfully symlinked #{total_successful} packages:"
        output_lines << "  Packages: #{successful.join(", ")}"
        output_lines << "\nDotfiles symlinked from #{dotfile_dir} to #{target_dir}"
        output_lines.join("\n")
      end

      def build_error_output(failed, total_failed)
        output_lines = ["Failed to symlink #{total_failed} packages:"]

        failed.each do |failure|
          error_msg = failure[:error].lines.first&.strip || "Unknown error"
          output_lines << "  #{failure[:package]}: #{error_msg}"
        end

        output_lines.join("\n")
      end

      def build_partial_output(successful, failed)
        output_parts = []
        output_parts << "Symlinked: #{successful.size}" if successful.size > 0
        output_parts << "Failed: #{failed.size}" if failed.size > 0

        "Symlink creation summary - #{output_parts.join(", ")}"
      end
    end
  end
end
