# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class InstallDesktopApps < Core::Step
      name "install_desktop_apps"
      description "Install desktop applications via Homebrew casks"

      private

      def perform_step
        start_time = Time.now
        apps = apps_to_install

        installed_apps = {}
        failed_apps = {}
        skipped_apps = {}

        apps.each do |category, app_list|
          puts "  Installing #{category} applications..."

          installed_apps[category] = []
          failed_apps[category] = []
          skipped_apps[category] = []

          app_list.each do |app|
            if app_installed?(app)
              skipped_apps[category] << app
              next
            end

            puts "    Installing #{app}..."
            _, stderr, status = Open3.capture3("brew install --cask #{app}")

            if status.success?
              installed_apps[category] << app
            else
              failed_apps[category] << {app: app, error: stderr.strip}
              puts "      ✗ Failed to install #{app}: #{stderr.lines.first&.strip}"
            end
          end
        end

        duration = Time.now - start_time
        build_result(installed_apps, failed_apps, skipped_apps, duration)
      end

      def apps_to_install
        {
          "Productivity" => %w[
            alfred
            forklift
            google-chrome
            homebrew/cask-versions/firefox-developer-edition
            itsycal
            shottr
          ],
          "Development" => %w[
            cursor
            ghostty
            kitty
            postman
            sublime-merge
            tableplus
            visual-studio-code
          ],
          "Media" => %w[
            spotify
            spotmenu
            vlc
          ],
          "Social" => %w[
            discord
            slack
            telegram
          ],
          "Utilities" => %w[
            betterdisplay
            localsend
            jordanbaird-ice
            mounty
            sanesidebuttons
            stats
            qlvideo
            the-unarchiver
            trex
          ]
        }
      end

      def app_installed?(app)
        stdout, _, status = Open3.capture3("brew list --cask #{app}")
        status.success? && !stdout.strip.empty?
      rescue
        false
      end

      def build_result(installed, failed, skipped, duration)
        total_installed = installed.values.flatten.size
        total_failed = failed.values.sum { |failures| failures.size }
        total_skipped = skipped.values.flatten.size

        if total_failed == 0
          Core::StepResult.success(
            output: build_success_output(installed, skipped, total_installed, total_skipped),
            step_name: @name,
            duration: duration,
            context: {
              installed: installed,
              skipped: skipped,
              categories: installed.keys + skipped.keys
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
          output_lines << "Successfully installed #{total_installed} applications:"
          installed.each do |category, apps|
            next if apps.empty?
            output_lines << "  #{category}: #{apps.join(", ")}"
          end
        end

        if total_skipped > 0
          output_lines << "\nSkipped #{total_skipped} already installed applications:"
          skipped.each do |category, apps|
            next if apps.empty?
            output_lines << "  #{category}: #{apps.join(", ")}"
          end
        end

        output_lines.join("\n")
      end

      def build_error_output(failed, total_failed)
        output_lines = ["Failed to install #{total_failed} applications:"]

        failed.each do |category, failures|
          next if failures.empty?
          output_lines << "  #{category}:"
          failures.each do |failure|
            error_msg = failure[:error].lines.first&.strip || "Unknown error"
            output_lines << "    #{failure[:app]}: #{error_msg}"
          end
        end

        output_lines.join("\n")
      end

      def build_partial_output(installed, failed, skipped)
        output_parts = []

        total_installed = installed.values.flatten.size
        total_failed = failed.values.sum { |failures| failures.size }
        total_skipped = skipped.values.flatten.size

        output_parts << "Installed: #{total_installed}" if total_installed > 0
        output_parts << "Failed: #{total_failed}" if total_failed > 0
        output_parts << "Skipped: #{total_skipped}" if total_skipped > 0

        "Application installation summary - #{output_parts.join(", ")}"
      end
    end
  end
end
