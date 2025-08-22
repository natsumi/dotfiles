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
        start_time = Time.now

        puts "  Installing Prezto framework..."

        # Install main Prezto repository
        _, stderr, status = Open3.capture3(prezto_install_command)
        unless status.success?
          duration = Time.now - start_time
          return Core::StepResult.failure(
            error: "Failed to install Prezto: #{stderr.strip}",
            output: "Prezto installation failed",
            step_name: @name,
            duration: duration,
            context: {
              status: :failed,
              error_details: stderr.strip
            }
          )
        end

        puts "  Installing Prezto contrib modules..."

        # Install Prezto contrib repository
        _, stderr, status = Open3.capture3(prezto_contrib_install_command)
        duration = Time.now - start_time

        if status.success?
          Core::StepResult.success(
            output: "Successfully installed Prezto framework with contrib modules",
            step_name: @name,
            duration: duration,
            context: {
              status: :installed,
              install_path: prezto_dir,
              contrib_path: prezto_contrib_dir
            }
          )
        else
          # Main Prezto installed but contrib failed - still consider it a success with warning
          Core::StepResult.success(
            output: "Prezto framework installed successfully, but contrib modules failed: #{stderr.strip}",
            step_name: @name,
            duration: duration,
            context: {
              status: :partial_install,
              install_path: prezto_dir,
              contrib_error: stderr.strip
            }
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
