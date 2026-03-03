# frozen_string_literal: true

require_relative "brew_install_step"

module Dotfiles
  module Steps
    class InstallHomebrewPackages < BrewInstallStep
      name "install_homebrew_packages"
      description "Install Homebrew packages from Brewfile"

      private

      def item_noun
        "packages"
      end

      def items_to_install
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
            croc
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
    end
  end
end
