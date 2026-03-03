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

        build_result(successful_packages, failed_packages)
      end

      def packages_to_symlink
        %w[
          aerospace bat claude ccstatusline elixir eslint ghostty helix jetbrains
          kitty mise neovim prettier ripgrep ruby tig
          tmux wezterm yt-dlp yabai zsh
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

      def build_result(successful, failed)
        if failed.empty?
          Core::StepResult.success(
            output: success_summary(successful),
            step_name: @name,
            context: {
              symlinked_packages: successful,
              total_packages: packages_to_symlink.size,
              dotfile_dir: dotfile_dir,
              target_dir: target_dir
            }
          )
        else
          Core::StepResult.failure(
            error: failure_summary(failed),
            output: partial_summary(successful, failed),
            step_name: @name,
            context: {
              symlinked_packages: successful,
              failed_packages: failed,
              dotfile_dir: dotfile_dir,
              target_dir: target_dir
            }
          )
        end
      end

      def success_summary(successful)
        lines = []
        lines << "Successfully symlinked #{successful.size} packages:"
        lines << "  Packages: #{successful.join(", ")}"
        lines << "\nDotfiles symlinked from #{dotfile_dir} to #{target_dir}"
        lines.join("\n")
      end

      def failure_summary(failed)
        lines = ["Failed to symlink #{failed.size} packages:"]
        failed.each do |failure|
          error_msg = failure[:error].lines.first&.strip || "Unknown error"
          lines << "  #{failure[:package]}: #{error_msg}"
        end
        lines.join("\n")
      end

      def partial_summary(successful, failed)
        parts = []
        parts << "Symlinked: #{successful.size}" if successful.any?
        parts << "Failed: #{failed.size}" if failed.any?
        "Symlink creation summary - #{parts.join(", ")}"
      end
    end
  end
end
