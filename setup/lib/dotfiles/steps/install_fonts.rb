# frozen_string_literal: true

require_relative "brew_install_step"

module Dotfiles
  module Steps
    class InstallFonts < BrewInstallStep
      name "install_fonts"
      description "Install fonts via Homebrew casks"

      private

      def item_noun
        "fonts"
      end

      def cask?
        true
      end

      def items_to_install
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
    end
  end
end
