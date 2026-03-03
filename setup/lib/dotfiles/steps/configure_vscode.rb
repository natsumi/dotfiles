# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class ConfigureVscode < Core::Step
      name "configure_vscode"
      description "Configure VS Code settings and key repeat"
      depends_on "install_desktop_apps"

      private

      def perform_step
        puts "  Enabling VS Code key repeat..."
        _, stderr, status = Open3.capture3(enable_keyrepeat_command)

        if status.success?
          Core::StepResult.success(
            output: "Successfully enabled VS Code key repeat",
            step_name: @name,
            context: {
              setting: "ApplePressAndHoldEnabled",
              value: false,
              application: "com.microsoft.VSCode"
            }
          )
        else
          Core::StepResult.failure(
            error: "Failed to configure VS Code: #{stderr.strip}",
            step_name: @name,
            context: {command: enable_keyrepeat_command, error_details: stderr.strip}
          )
        end
      end

      def enable_keyrepeat_command
        "defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false"
      end
    end
  end
end
