# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    # Homebrew 6 refuses to load formulae, casks and external commands from
    # non-official taps until they are explicitly trusted. Trust has to be
    # granted before anything tries to install from those taps, so this runs
    # ahead of install_homebrew_packages.
    class TrustHomebrewTaps < Core::Step
      name "trust_homebrew_taps"
      description "Trust third-party Homebrew taps (required by Homebrew 6)"

      TAPS = %w[
        asmvik/formulae
      ].freeze

      private

      def should_skip?
        !brew_trust_available?
      end

      def perform_step
        trusted = []
        failed = []

        TAPS.each do |tap|
          puts "  Trusting #{tap}..."
          _, stderr, status = Open3.capture3("brew trust --tap #{tap}")

          if status.success?
            trusted << tap
          else
            failed << {name: tap, error: stderr.strip}
            puts "    ✗ Failed to trust #{tap}: #{stderr.lines.first&.strip}"
          end
        end

        build_result(trusted, failed)
      end

      # `brew trust` only exists on Homebrew 6+; on older versions there is
      # nothing to do and the step skips rather than failing the run.
      def brew_trust_available?
        _, _, status = Open3.capture3("brew trust --help")
        status.success?
      rescue
        false
      end

      def build_result(trusted, failed)
        if failed.empty?
          Core::StepResult.success(
            output: "Trusted #{trusted.size} taps:\n  #{trusted.join(", ")}",
            step_name: @name,
            context: {trusted: trusted}
          )
        else
          Core::StepResult.failure(
            error: failure_summary(failed),
            output: "Trusted: #{trusted.size}, Failed: #{failed.size}",
            step_name: @name,
            context: {trusted: trusted, failed: failed}
          )
        end
      end

      def failure_summary(failed)
        lines = ["Failed to trust #{failed.size} taps:"]
        failed.each do |failure|
          error_msg = failure[:error].lines.first&.strip || "Unknown error"
          lines << "  #{failure[:name]}: #{error_msg}"
        end
        lines.join("\n")
      end
    end
  end
end
