# frozen_string_literal: true

require_relative '../core/step'
require_relative '../core/step_result'
require 'open3'

module Dotfiles
  module Steps
    class InstallDesktopApps < Core::Step
      name "install_desktop_apps"
      description "Install desktop applications via Homebrew"
      depends_on InstallHomebrew

      private

      def should_skip?
        # Check if all apps are already installed
        apps_to_install.all? { |app| app_installed?(app) }
      end

      def perform_step
        start_time = Time.now
        installed_apps = []
        failed_apps = []

        apps_to_install.each do |app|
          next if app_installed?(app)

          puts "  Installing #{app}..."
          stdout, stderr, status = Open3.capture3("brew install --cask #{app}")

          if status.success?
            installed_apps << app
          else
            failed_apps << { app: app, error: stderr.strip }
          end
        end

        duration = Time.now - start_time

        if failed_apps.empty?
          Core::StepResult.success(
            output: build_success_output(installed_apps),
            step_name: @name,
            duration: duration,
            context: { installed: installed_apps }
          )
        else
          Core::StepResult.failure(
            error: build_error_output(failed_apps),
            output: build_partial_output(installed_apps, failed_apps),
            step_name: @name,
            duration: duration,
            context: { installed: installed_apps, failed: failed_apps }
          )
        end
      end

      def apps_to_install
        [
          # Productivity
          'alfred',
          'forklift',
          'google-chrome',
          'firefox-developer-edition',
          'itsycal',
          'shottr',

          # Development
          'cursor',
          'kitty',
          'postman',
          'sublime-merge',
          'tableplus',
          'visual-studio-code',

          # Media
          'spotify',
          'spotmenu',
          'vlc',

          # Social
          'discord',
          'slack',
          'telegram',

          # Utilities
          'betterdisplay',
          'localsend',
          'jordanbaird-ice',
          'mounty',
          'sanesidebuttons',
          'stats',
          'qlvideo',
          'the-unarchiver',
          'trex'
        ]
      end

      def app_installed?(app)
        stdout, _, status = Open3.capture3("brew list --cask #{app}")
        status.success? && !stdout.strip.empty?
      rescue
        false
      end

      def build_success_output(installed_apps)
        if installed_apps.empty?
          "All applications already installed"
        else
          "Successfully installed #{installed_apps.length} applications:\n#{installed_apps.join("\n")}"
        end
      end

      def build_error_output(failed_apps)
        error_details = failed_apps.map { |failure| "#{failure[:app]}: #{failure[:error]}" }
        "Failed to install #{failed_apps.length} applications:\n#{error_details.join("\n")}"
      end

      def build_partial_output(installed_apps, failed_apps)
        output_parts = []
        
        unless installed_apps.empty?
          output_parts << "Successfully installed: #{installed_apps.join(', ')}"
        end
        
        unless failed_apps.empty?
          output_parts << "Failed to install: #{failed_apps.map { |f| f[:app] }.join(', ')}"
        end
        
        output_parts.join("\n")
      end
    end

    # Placeholder for dependency - we'll create this later
    class InstallHomebrew < Core::Step
      name "install_homebrew"
      description "Install Homebrew package manager"

      private

      def should_skip?
        system('which brew > /dev/null 2>&1')
      end

      def perform_step
        puts "  Installing Homebrew..."
        stdout, stderr, status = Open3.capture3('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
        
        if status.success?
          Core::StepResult.success(
            output: "Homebrew installed successfully",
            step_name: @name,
            context: { stdout: stdout }
          )
        else
          Core::StepResult.failure(
            error: "Failed to install Homebrew: #{stderr}",
            output: stdout,
            step_name: @name,
            context: { stderr: stderr }
          )
        end
      end
    end
  end
end