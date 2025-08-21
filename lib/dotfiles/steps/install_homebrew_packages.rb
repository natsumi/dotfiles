# frozen_string_literal: true

require_relative '../core/step'
require_relative '../core/step_result'
require 'open3'

module Dotfiles
  module Steps
    class InstallHomebrewPackages < Core::Step
      name "install_homebrew_packages"
      description "Install Homebrew packages from Brewfile"

      private

      def perform_step
        start_time = Time.now
        packages = packages_to_install

        installed_packages = {}
        failed_packages = {}
        skipped_packages = {}

        packages.each do |category, package_list|
          puts "  Installing #{category} packages..."

          installed_packages[category] = []
          failed_packages[category] = []
          skipped_packages[category] = []

          package_list.each do |package|
            if package_installed?(package)
              skipped_packages[category] << package
              next
            end

            puts "    Installing #{package}..."
            stdout, stderr, status = Open3.capture3("brew install #{package}")

            if status.success?
              installed_packages[category] << package
            else
              failed_packages[category] << { package: package, error: stderr.strip }
              puts "      ✗ Failed to install #{package}: #{stderr.lines.first&.strip}"
            end
          end
        end

        duration = Time.now - start_time
        build_result(installed_packages, failed_packages, skipped_packages, duration)
      end

      def packages_to_install
        {
          "Build Tools" => %w[
            autoconf
            automake
            coreutils
            gpg
            jemalloc
            libffi
            libtool
            libxslt
            libyaml
            openssl
            readline
            unixodbc
            xz
            zlib
          ],
          "Development Tools" => %w[
            awk
            diff-so-fancy
            difftastic
            fx
            git
            git-delta
            jq
            mise
            overmind
            ripgrep
            scmpuff
            sqlite
            tig
          ],
          "Formatters" => %w[
            lua-language-server
            shfmt
            stylua
          ],
          "Utilities" => %w[
            aria2
            bat
            broot
            eza
            fd
            ffmpeg
            fzf
            htop-osx
            mas
            ncdu
            reattach-to-user-namespace
            rtmpdump
            stow
            terminal-notifier
            tmate
            tmux
            tmux-mem-cpu-load
            tree
            wget
            zsh
          ],
          "Desktop Managers" => %w[
            koekeishiya/formulae/skhd
            yabai
          ]
        }
      end

      def package_installed?(package)
        stdout, _, status = Open3.capture3("brew list #{package}")
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
          output_lines << "Successfully installed #{total_installed} packages:"
          installed.each do |category, packages|
            next if packages.empty?
            output_lines << "  #{category}: #{packages.join(', ')}"
          end
        end

        if total_skipped > 0
          output_lines << "\nSkipped #{total_skipped} already installed packages:"
          skipped.each do |category, packages|
            next if packages.empty?
            output_lines << "  #{category}: #{packages.join(', ')}"
          end
        end

        output_lines.join("\n")
      end

      def build_error_output(failed, total_failed)
        output_lines = ["Failed to install #{total_failed} packages:"]

        failed.each do |category, failures|
          next if failures.empty?
          output_lines << "  #{category}:"
          failures.each do |failure|
            error_msg = failure[:error].lines.first&.strip || "Unknown error"
            output_lines << "    #{failure[:package]}: #{error_msg}"
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

        "Package installation summary - #{output_parts.join(', ')}"
      end
    end
  end
end
