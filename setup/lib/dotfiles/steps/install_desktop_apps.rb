# frozen_string_literal: true

require_relative "brew_install_step"

module Dotfiles
  module Steps
    class InstallDesktopApps < BrewInstallStep
      name "install_desktop_apps"
      description "Install desktop applications via Homebrew casks"

      private

      def item_noun
        "applications"
      end

      def cask?
        true
      end

      def items_to_install
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
    end
  end
end
