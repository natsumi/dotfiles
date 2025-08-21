# frozen_string_literal: true

require_relative '../core/step'
require_relative '../core/step_result'
require 'open3'

module Dotfiles
  module Steps
    class ConfigureGit < Core::Step
      name "configure_git"
      description "Configure Git user information and settings"

      private

      def should_skip?
        git_already_configured?
      end

      def perform_step
        start_time = Time.now

        # Get user information
        git_name = prompt_for_git_name
        git_email = prompt_for_git_email

        puts "  Setting Git user information..."

        # Set user configuration
        name_result = execute_git_command("git config --global user.name \"#{git_name}\"")
        unless name_result[:success]
          duration = Time.now - start_time
          return Core::StepResult.failure(
            error: "Failed to set Git user name: #{name_result[:error]}",
            output: "Git configuration failed",
            step_name: @name,
            duration: duration
          )
        end

        email_result = execute_git_command("git config --global user.email #{git_email}")
        unless email_result[:success]
          duration = Time.now - start_time
          return Core::StepResult.failure(
            error: "Failed to set Git user email: #{email_result[:error]}",
            output: "Git configuration failed",
            step_name: @name,
            duration: duration
          )
        end

        puts "  Applying Git settings..."

        # Apply additional Git settings
        git_settings.each do |setting, value|
          result = execute_git_command("git config --global #{setting} \"#{value}\"")
          unless result[:success]
            puts "    Warning: Failed to set #{setting}: #{result[:error]}"
          end
        end

        duration = Time.now - start_time
        Core::StepResult.success(
          output: "Successfully configured Git with user: #{git_name} <#{git_email}>",
          step_name: @name,
          duration: duration,
          context: {
            git_name: git_name,
            git_email: git_email,
            settings_applied: git_settings.keys
          }
        )
      end

      def git_already_configured?
        name_result = execute_git_command("git config --global user.name")
        email_result = execute_git_command("git config --global user.email")

        name_result[:success] && email_result[:success] &&
          !name_result[:output].strip.empty? && !email_result[:output].strip.empty?
      end

      def prompt_for_git_name
        print "  What is your full name used by Git? "
        name = $stdin.gets.chomp

        if name.strip.empty?
          puts "  ERROR: Invalid Git user name."
          exit 1
        end

        name
      end

      def prompt_for_git_email
        print "  What is your Git user email? "
        email = $stdin.gets.chomp

        if email.strip.empty?
          puts "  ERROR: Invalid Git email."
          exit 1
        end

        email
      end

      def git_settings
        {
          "push.default" => "simple",
          "core.pager" => "diff-so-fancy | less --tabs=4 -RFX",
          "color.ui" => "true",
          "color.diff-highlight.oldNormal" => "red bold",
          "color.diff-highlight.oldHighlight" => "red bold 52",
          "color.diff-highlight.newNormal" => "green bold",
          "color.diff-highlight.newHighlight" => "green bold 22",
          "color.diff.meta" => "yellow",
          "color.diff.frag" => "magenta bold",
          "color.diff.commit" => "yellow bold",
          "color.diff.old" => "red bold",
          "color.diff.new" => "green bold",
          "color.diff.whitespace" => "red reverse"
        }
      end

      def execute_git_command(command)
        stdout, stderr, status = Open3.capture3(command)
        {
          success: status.success?,
          output: stdout,
          error: stderr.strip
        }
      end
    end
  end
end
