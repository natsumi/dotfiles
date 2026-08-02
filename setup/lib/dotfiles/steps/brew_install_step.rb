# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"
require "set"

module Dotfiles
  module Steps
    # Shared base for the steps that install Homebrew formulae and casks.
    # Subclasses only supply #items_to_install (a category => names hash).
    #
    # Homebrew is invoked in as few processes as possible:
    #
    #   1. One `brew list` to learn everything that is already installed,
    #      rather than probing each package separately.
    #   2. One `brew install` for everything still missing. Handing Homebrew
    #      the whole set at once lets it resolve dependencies and fetch all the
    #      downloads together, which is far quicker than a package at a time.
    #   3. Only when that batch fails, a second `brew list` to find which
    #      packages are still missing, then one `brew install` per straggler so
    #      the error message is attributable to a single package.
    #
    # Step 3 is what makes batching safe to use here. `brew install` signals
    # failure inconsistently depending on how a package fails:
    #
    #   - A name it cannot resolve (typo, renamed formula, moved tap) aborts
    #     the entire command *before installing anything*, and names only the
    #     first bad entry even if several are bad.
    #   - A download or checksum error skips that package but carries on with
    #     the rest, then exits non-zero at the end.
    #   - A cask error is caught per-cask and the rest still proceed.
    #
    # Rather than trying to parse which case occurred, we re-check against
    # `brew list`: whatever is still missing is what actually failed, however
    # Homebrew chose to report it. Reinstalling just those one at a time costs
    # little in practice, because those packages had to be installed anyway —
    # we only lose the shared-process saving for the ones that broke.
    class BrewInstallStep < Core::Step
      private

      def perform_step
        installed = Hash.new { |hash, key| hash[key] = [] }
        skipped = Hash.new { |hash, key| hash[key] = [] }
        failed = Hash.new { |hash, key| hash[key] = [] }

        present = installed_item_names

        # Split every category into "already there" and "still needed", keeping
        # each pending item paired with its category so failures can be
        # reported under the right heading later.
        pending = []
        items_to_install.each do |category, item_list|
          item_list.each do |item|
            if present.include?(short_name(item))
              skipped[category] << item
            else
              pending << [category, item]
            end
          end
        end

        # `brew list` only reports canonical names, so anything it did not match
        # may still be installed under an alias or a former name — "gpg" is
        # really "gnupg", "openssl" is "openssl@3", "htop-osx" was renamed to
        # "htop". Ask Homebrew about those few directly rather than reinstalling
        # them on every run. Only the leftovers cost a process here, not the
        # whole list.
        pending.reject! do |category, item|
          next false unless item_installed?(item)

          skipped[category] << item
          true
        end

        if pending.empty?
          puts "  All #{item_noun} are already installed."
          return build_result(installed, failed, skipped)
        end

        pending_items = pending.map(&:last)
        puts "  Installing #{pending_items.size} #{item_noun} in one batch..."
        puts "    #{pending_items.join(", ")}"

        batch_ok, batch_error = run_brew_install(pending_items)

        if batch_ok
          pending.each { |category, item| installed[category] << item }
        else
          resolve_batch_failure(pending, batch_error, installed, failed)
        end

        build_result(installed, failed, skipped)
      end

      # The batch reported a failure, but that tells us nothing about *which*
      # packages are affected. Re-read the installed list and treat anything
      # missing as a casualty, retrying it alone to capture its own error.
      def resolve_batch_failure(pending, batch_error, installed, failed)
        puts "  Batch install failed, working out which #{item_noun} are affected..."
        present_after = installed_item_names

        pending.each do |category, item|
          if present_after.include?(short_name(item))
            installed[category] << item
            next
          end

          puts "    Retrying #{item} on its own..."
          ok, error = run_brew_install([item])

          if ok
            installed[category] << item
          else
            # Fall back to the batch error when the retry says nothing useful.
            message = error.strip
            message = batch_error.strip if message.empty?
            failed[category] << {name: item, error: message}
            puts "      ✗ Failed to install #{item}: #{message.lines.first&.strip}"
          end
        end
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

      # Arguments are passed to Open3 as a list rather than one string so no
      # shell is involved and names never need quoting.
      def install_flags
        cask? ? ["--cask"] : []
      end

      # `brew list` with no type flag returns formulae *and* casks, so always
      # ask for the kind this step deals with.
      def list_flags
        cask? ? ["--cask"] : ["--formula"]
      end

      def run_brew_install(items)
        _, stderr, status = Open3.capture3("brew", "install", *install_flags, *items)
        [status.success?, stderr]
      end

      # Every installed formula/cask name, in a single call.
      def installed_item_names
        stdout, _, status = Open3.capture3("brew", "list", *list_flags, "-1")
        return Set.new unless status.success?

        stdout.split("\n").map(&:strip).reject(&:empty?).to_set
      rescue
        Set.new
      end

      # Ask Homebrew whether one specific package is installed. Unlike the bulk
      # listing this resolves aliases and renamed formulae, but it costs a
      # process per call, so it is only used for the few packages the bulk
      # listing could not account for.
      def item_installed?(item)
        _, _, status = Open3.capture3("brew", "list", *list_flags, item)
        status.success?
      rescue
        false
      end

      # `brew list` prints bare names, so a tap-qualified entry such as
      # "asmvik/formulae/yabai" has to be compared as "yabai".
      def short_name(item)
        item.split("/").last
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
