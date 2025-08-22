# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class InstallFonts < Core::Step
      name "install_fonts"
      description "Install fonts via Homebrew casks"

      private

      def perform_step
        start_time = Time.now
        fonts = fonts_to_install

        installed_fonts = {}
        failed_fonts = {}
        skipped_fonts = {}

        fonts.each do |category, font_list|
          puts "  Installing #{category} fonts..."

          installed_fonts[category] = []
          failed_fonts[category] = []
          skipped_fonts[category] = []

          font_list.each do |font|
            if font_installed?(font)
              skipped_fonts[category] << font
              next
            end

            puts "    Installing #{font}..."
            _, stderr, status = Open3.capture3("brew install --cask #{font}")

            if status.success?
              installed_fonts[category] << font
            else
              failed_fonts[category] << {font: font, error: stderr.strip}
              puts "      ✗ Failed to install #{font}: #{stderr.lines.first&.strip}"
            end
          end
        end

        duration = Time.now - start_time
        build_result(installed_fonts, failed_fonts, skipped_fonts, duration)
      end

      def fonts_to_install
        {
          "Powerline Fonts" => %w[
            font-cascadia-mono-pl
            font-consolas-for-powerline
            font-menlo-for-powerline
          ],
          "Nerd Fonts" => %w[
            font-anonymice-nerd-font
            font-blex-mono-nerd-font
            font-dejavu-sans-mono-nerd-font
            font-droid-sans-mono-nerd-font
            font-fantasque-sans-mono-nerd-font
            font-fira-code-nerd-font
            font-fira-mono-nerd-font
            font-go-mono-nerd-font
            font-iosevka-nerd-font
            font-jetbrains-mono-nerd-font
            font-liberation-nerd-font
            font-meslo-lg-nerd-font
            font-roboto-mono-nerd-font
            font-sauce-code-pro-nerd-font
            font-victor-mono-nerd-font
          ]
        }
      end

      def font_installed?(font)
        stdout, _, status = Open3.capture3("brew list --cask #{font}")
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
          output_lines << "Successfully installed #{total_installed} fonts:"
          installed.each do |category, fonts|
            next if fonts.empty?
            output_lines << "  #{category}: #{fonts.join(", ")}"
          end
        end

        if total_skipped > 0
          output_lines << "\nSkipped #{total_skipped} already installed fonts:"
          skipped.each do |category, fonts|
            next if fonts.empty?
            output_lines << "  #{category}: #{fonts.join(", ")}"
          end
        end

        output_lines.join("\n")
      end

      def build_error_output(failed, total_failed)
        output_lines = ["Failed to install #{total_failed} fonts:"]

        failed.each do |category, failures|
          next if failures.empty?
          output_lines << "  #{category}:"
          failures.each do |failure|
            error_msg = failure[:error].lines.first&.strip || "Unknown error"
            output_lines << "    #{failure[:font]}: #{error_msg}"
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

        "Font installation summary - #{output_parts.join(", ")}"
      end
    end
  end
end
