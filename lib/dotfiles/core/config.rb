# frozen_string_literal: true

module Dotfiles
  module Core
    class Config
      CONFIG = {
        log_level: :info,
        use_color: true,
        dry_run: false,
        dotfiles_dir: '~/dev/dotfiles',
        target_dir: '~'
      }.freeze

      def initialize
        @data = CONFIG
      end

      def log_level
        @data[:log_level]
      end

      def use_color?
        @data[:use_color]
      end

      def dry_run?
        @data[:dry_run]
      end

      def dotfiles_dir
        File.expand_path(@data[:dotfiles_dir])
      end

      def target_dir
        File.expand_path(@data[:target_dir])
      end

      def to_h
        @data.dup
      end
    end
  end
end
