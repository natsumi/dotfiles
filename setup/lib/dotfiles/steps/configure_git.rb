# frozen_string_literal: true

require_relative "../core/step"
require_relative "../core/step_result"
require "open3"

module Dotfiles
  module Steps
    class ConfigureGit < Core::Step
      name "configure_git"
      description "Configure Git user information and settings"
      depends_on "install_homebrew_packages"

      private

      def should_skip?
        git_already_configured?
      end

      def perform_step
        git_name = prompt_for_input("What is your full name used by Git?")
        return Core::StepResult.failure(error: "Git user name is required", step_name: @name) if git_name.nil?

        git_email = prompt_for_input("What is your Git user email?")
        return Core::StepResult.failure(error: "Git user email is required", step_name: @name) if git_email.nil?

        puts "  Setting Git user information..."

        name_result = execute_git_command("git config --global user.name \"#{git_name}\"")
        unless name_result[:success]
          return Core::StepResult.failure(
            error: "Failed to set Git user name: #{name_result[:error]}",
            step_name: @name
          )
        end

        email_result = execute_git_command("git config --global user.email #{git_email}")
        unless email_result[:success]
          return Core::StepResult.failure(
            error: "Failed to set Git user email: #{email_result[:error]}",
            step_name: @name
          )
        end

        puts "  Applying Git settings..."

        git_settings.each do |setting, value|
          result = execute_git_command("git config --global #{setting} \"#{value}\"")
          unless result[:success]
            puts "    Warning: Failed to set #{setting}: #{result[:error]}"
          end
        end

        Core::StepResult.success(
          output: "Successfully configured Git with user: #{git_name} <#{git_email}>",
          step_name: @name,
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

      def prompt_for_input(prompt_text)
        print "  #{prompt_text} "
        value = $stdin.gets.chomp
        value.strip.empty? ? nil : value
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
