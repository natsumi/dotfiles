# frozen_string_literal: true

module Dotfiles
  module Core
    class Logger
      LEVELS = {
        silent: 0,
        error: 1,
        warn: 2,
        info: 3,
        debug: 4
      }.freeze

      COLORS = {
        red: "\033[31m",
        green: "\033[32m",
        yellow: "\033[33m",
        blue: "\033[34m",
        magenta: "\033[35m",
        cyan: "\033[36m",
        white: "\033[37m",
        reset: "\033[0m"
      }.freeze

      ICONS = {
        error: "✗",
        warn: "⚠",
        info: "ℹ",
        success: "✓",
        debug: "🔍"
      }.freeze

      attr_reader :level, :use_color

      def initialize(level: :info, use_color: true, output: $stdout)
        @level = level
        @use_color = use_color && output.tty?
        @output = output
        @mutex = Mutex.new
      end

      def error(message, context: {})
        log(:error, message, context: context, color: :red, icon: :error)
      end

      def warn(message, context: {})
        log(:warn, message, context: context, color: :yellow, icon: :warn)
      end

      def info(message, context: {})
        log(:info, message, context: context, color: :blue, icon: :info)
      end

      def success(message, context: {})
        log(:info, message, context: context, color: :green, icon: :success)
      end

      def debug(message, context: {})
        log(:debug, message, context: context, color: :magenta, icon: :debug)
      end

      def step_start(step_name, description: nil)
        message = description || step_name
        info("Starting: #{message}")
      end

      def step_complete(step_name, duration: nil)
        duration_text = duration ? " (#{format_duration(duration)})" : ""
        success("Completed: #{step_name}#{duration_text}")
      end

      def step_failed(step_name, error_message, duration: nil)
        duration_text = duration ? " (#{format_duration(duration)})" : ""
        error("Failed: #{step_name}#{duration_text}")
        error("Error: #{error_message}") if error_message && !error_message.empty?
      end

      def step_skipped(step_name, reason: nil)
        reason_text = reason ? " (#{reason})" : ""
        warn("Skipped: #{step_name}#{reason_text}")
      end

      def progress(current, total, description: nil)
        return unless should_log?(:info)
        
        percentage = (current.to_f / total * 100).round(1)
        progress_bar = build_progress_bar(current, total)
        desc_text = description ? " #{description}" : ""
        
        message = "[#{current}/#{total}] #{progress_bar} #{percentage}%#{desc_text}"
        log_raw(message)
      end

      def set_level(new_level)
        @level = new_level if LEVELS.key?(new_level)
      end

      def silent?
        @level == :silent
      end

      private

      def log(level, message, context: {}, color: :white, icon: nil)
        return unless should_log?(level)

        @mutex.synchronize do
          formatted_message = format_message(level, message, context: context, color: color, icon: icon)
          @output.puts(formatted_message)
          @output.flush
        end
      end

      def log_raw(message)
        @mutex.synchronize do
          @output.print("\r#{message}")
          @output.flush
        end
      end

      def should_log?(level)
        LEVELS[level] <= LEVELS[@level]
      end

      def format_message(level, message, context: {}, color: :white, icon: nil)
        timestamp = Time.now.strftime("%H:%M:%S")
        level_text = level.to_s.upcase.ljust(5)
        icon_text = @use_color && icon ? "#{ICONS[icon]} " : ""
        
        formatted = "[#{timestamp}] #{level_text} #{icon_text}#{message}"
        
        if context.any?
          context_text = context.map { |k, v| "#{k}=#{v}" }.join(" ")
          formatted += " (#{context_text})"
        end

        @use_color ? colorize(formatted, color) : formatted
      end

      def colorize(text, color)
        "#{COLORS[color]}#{text}#{COLORS[:reset]}"
      end

      def format_duration(duration)
        if duration < 1
          "#{(duration * 1000).round}ms"
        else
          "#{duration.round(2)}s"
        end
      end

      def build_progress_bar(current, total, width: 20)
        completed = (current.to_f / total * width).round
        remaining = width - completed
        
        bar = "█" * completed + "░" * remaining
        @use_color ? colorize(bar, :cyan) : bar
      end
    end
  end
end