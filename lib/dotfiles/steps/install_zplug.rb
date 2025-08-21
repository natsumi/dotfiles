# frozen_string_literal: true

require_relative '../core/step'
require_relative '../core/step_result'
require 'open3'

module Dotfiles
  module Steps
    class InstallZplug < Core::Step
      name "install_zplug"
      description "Install Zplug plugin manager for Zsh"

      private

      def should_skip?
        zplug_installed?
      end

      def perform_step
        start_time = Time.now

        puts "  Installing Zplug..."
        stdout, stderr, status = Open3.capture3(zplug_install_command)

        duration = Time.now - start_time

        if status.success?
          Core::StepResult.success(
            output: "Successfully installed Zplug plugin manager",
            step_name: @name,
            duration: duration,
            context: {
              status: :installed,
              install_path: zplug_path
            }
          )
        else
          Core::StepResult.failure(
            error: "Failed to install Zplug: #{stderr.strip}",
            output: "Zplug installation failed",
            step_name: @name,
            duration: duration,
            context: {
              status: :failed,
              error_details: stderr.strip
            }
          )
        end
      end

      def zplug_installed?
        File.directory?(zplug_path)
      end

      def zplug_path
        "#{ENV['HOME']}/.zplug"
      end

      def zplug_install_command
        "curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh"
      end
    end
  end
end
