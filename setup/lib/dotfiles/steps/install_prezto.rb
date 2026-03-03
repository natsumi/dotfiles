# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class InstallPrezto < Core::Step
      name "install_prezto"
      description "Install Prezto Zsh framework"

      private

      def should_skip?
        prezto_installed?
      end

      def perform_step
        puts "  Installing Prezto framework..."

        _, stderr, status = Open3.capture3(prezto_install_command)
        unless status.success?
          return Core::StepResult.failure(
            error: "Failed to install Prezto: #{stderr.strip}",
            step_name: @name,
            context: {error_details: stderr.strip}
          )
        end

        puts "  Installing Prezto contrib modules..."

        _, stderr, status = Open3.capture3(prezto_contrib_install_command)

        if status.success?
          Core::StepResult.success(
            output: "Successfully installed Prezto framework with contrib modules",
            step_name: @name,
            context: {install_path: prezto_dir, contrib_path: prezto_contrib_dir}
          )
        else
          Core::StepResult.success(
            output: "Prezto framework installed successfully, but contrib modules failed: #{stderr.strip}",
            step_name: @name,
            context: {install_path: prezto_dir, contrib_error: stderr.strip}
          )
        end
      end

      def prezto_installed?
        File.directory?(prezto_dir)
      end

      def prezto_dir
        zdotdir = ENV["ZDOTDIR"] || ENV["HOME"]
        "#{zdotdir}/.zprezto"
      end

      def prezto_contrib_dir
        "#{prezto_dir}/contrib"
      end

      def prezto_install_command
        "git clone --recursive --depth 1 https://github.com/sorin-ionescu/prezto.git \"#{prezto_dir}\""
      end

      def prezto_contrib_install_command
        "git clone --recursive --depth 1 https://github.com/belak/prezto-contrib \"#{prezto_contrib_dir}\""
      end
    end
  end
end
