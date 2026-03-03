# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class BrewInstallStep < Core::Step
      private

      def perform_step
        installed = {}
        failed = {}
        skipped = {}

        items_to_install.each do |category, item_list|
          puts "  Installing #{category} #{item_noun}..."

          installed[category] = []
          failed[category] = []
          skipped[category] = []

          item_list.each do |item|
            if item_installed?(item)
              skipped[category] << item
              next
            end

            puts "    Installing #{item}..."
            _, stderr, status = Open3.capture3("brew install #{cask_flag} #{item}".strip)

            if status.success?
              installed[category] << item
            else
              failed[category] << {name: item, error: stderr.strip}
              puts "      ✗ Failed to install #{item}: #{stderr.lines.first&.strip}"
            end
          end
        end

        build_result(installed, failed, skipped)
      end

      def items_to_install
        raise NotImplementedError, "#{self.class} must implement #items_to_install"
      end

      def item_noun
        "items"
      end

      def cask?
        false
      end

      def cask_flag
        cask? ? "--cask" : ""
      end

      def item_installed?(item)
        stdout, _, status = Open3.capture3("brew list #{cask_flag} #{item}".strip)
        status.success? && !stdout.strip.empty?
      rescue
        false
      end

      def build_result(installed, failed, skipped)
        total_installed = installed.values.flatten.size
        total_failed = failed.values.sum { |f| f.size }
        total_skipped = skipped.values.flatten.size

        if total_failed == 0
          Core::StepResult.success(
            output: success_summary(installed, skipped, total_installed, total_skipped),
            step_name: @name,
            context: {installed: installed, skipped: skipped}
          )
        else
          Core::StepResult.failure(
            error: failure_summary(failed, total_failed),
            output: partial_summary(total_installed, total_failed, total_skipped),
            step_name: @name,
            context: {installed: installed, failed: failed, skipped: skipped}
          )
        end
      end

      def success_summary(installed, skipped, total_installed, total_skipped)
        lines = []

        if total_installed > 0
          lines << "Successfully installed #{total_installed} #{item_noun}:"
          installed.each do |category, items|
            next if items.empty?
            lines << "  #{category}: #{items.join(", ")}"
          end
        end

        if total_skipped > 0
          lines << "\nSkipped #{total_skipped} already installed #{item_noun}:"
          skipped.each do |category, items|
            next if items.empty?
            lines << "  #{category}: #{items.join(", ")}"
          end
        end

        lines.join("\n")
      end

      def failure_summary(failed, total_failed)
        lines = ["Failed to install #{total_failed} #{item_noun}:"]

        failed.each do |category, failures|
          next if failures.empty?
          lines << "  #{category}:"
          failures.each do |failure|
            error_msg = failure[:error].lines.first&.strip || "Unknown error"
            lines << "    #{failure[:name]}: #{error_msg}"
          end
        end

        lines.join("\n")
      end

      def partial_summary(total_installed, total_failed, total_skipped)
        parts = []
        parts << "Installed: #{total_installed}" if total_installed > 0
        parts << "Failed: #{total_failed}" if total_failed > 0
        parts << "Skipped: #{total_skipped}" if total_skipped > 0

        "#{item_noun.capitalize} installation summary - #{parts.join(", ")}"
      end
    end
  end
end
