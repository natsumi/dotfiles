# frozen_string_literal: true

module Dotfiles
  module UI
    class Formatter
      COLORS = {
        black: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        white: 37,
        bright_black: 90,
        bright_red: 91,
        bright_green: 92,
        bright_yellow: 93,
        bright_blue: 94,
        bright_magenta: 95,
        bright_cyan: 96,
        bright_white: 97
      }.freeze

      STYLES = {
        bold: 1,
        dim: 2,
        italic: 3,
        underline: 4,
        blink: 5,
        reverse: 7,
        strikethrough: 9
      }.freeze

      STATUS_ICONS = {
        pending: "⏳",
        running: "⟳",
        completed: "✓",
        failed: "✗",
        skipped: "⊝",
        warning: "⚠",
        info: "ℹ",
        success: "✓",
        error: "✗"
      }.freeze

      STATUS_COLORS = {
        pending: :yellow,
        running: :cyan,
        completed: :green,
        failed: :red,
        skipped: :bright_black,
        warning: :yellow,
        info: :blue,
        success: :green,
        error: :red
      }.freeze

      def initialize(use_color: true)
        @use_color = use_color && $stdout.tty?
      end

      # Basic color methods
      def colorize(text, color, style: nil)
        return text.to_s unless @use_color

        codes = []
        codes << COLORS[color] if color && COLORS[color]
        codes << STYLES[style] if style && STYLES[style]

        return text.to_s if codes.empty?

        "\033[#{codes.join(";")}m#{text}\033[0m"
      end

      # Status-based formatting
      def success(text)
        colorize("#{STATUS_ICONS[:success]} #{text}", :green, style: :bold)
      end

      def error(text)
        colorize("#{STATUS_ICONS[:error]} #{text}", :red, style: :bold)
      end

      def warning(text)
        colorize("#{STATUS_ICONS[:warning]} #{text}", :yellow)
      end

      def info(text)
        colorize("#{STATUS_ICONS[:info]} #{text}", :blue)
      end

      def muted(text)
        colorize(text, :bright_black)
      end

      def highlight(text)
        colorize(text, :white, style: :bold)
      end

      def prompt(text)
        colorize(text, :cyan, style: :bold)
      end

      # Step formatting
      def step_start(text)
        colorize(text, :blue, style: :bold)
      end

      def step_complete(text)
        colorize(text, :green)
      end

      def step_failed(text)
        colorize(text, :red)
      end

      def step_skipped(text)
        colorize(text, :yellow)
      end

      # Status icons
      def status_icon(status)
        icon = STATUS_ICONS[status] || STATUS_ICONS[:pending]
        color = STATUS_COLORS[status] || :white
        colorize(icon, color)
      end

      # Section headers
      def header(text)
        border = "=" * [text.length, 50].max
        [
          colorize(border, :cyan, style: :bold),
          colorize(text.center(border.length), :cyan, style: :bold),
          colorize(border, :cyan, style: :bold)
        ].join("\n")
      end

      def section(text)
        colorize("#{text}", :cyan, style: :bold)
      end

      def subsection(text)
        colorize("  #{text}", :blue)
      end

      # Tables and lists
      def table_header(columns, widths = nil)
        formatted = if widths
          columns.map.with_index { |col, i| col.ljust(widths[i] || 20) }.join(" | ")
        else
          columns.join(" | ")
        end

        header_line = colorize(formatted, :cyan, style: :bold)
        separator = colorize("-" * formatted.length, :cyan)

        "#{header_line}\n#{separator}"
      end

      def table_row(columns, widths = nil, status: nil)
        formatted = if widths
          columns.map.with_index { |col, i| col.to_s.ljust(widths[i] || 20) }.join(" | ")
        else
          columns.join(" | ")
        end

        if status && STATUS_COLORS[status]
          colorize(formatted, STATUS_COLORS[status])
        else
          formatted
        end
      end

      # Progress and loading
      def spinner(text, frame = 0)
        frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        spinner_char = frames[frame % frames.length]
        colorize("#{spinner_char} #{text}", :cyan)
      end

      def progress_bar(current, total, width: 30, char: "█", bg_char: "░")
        return "" if total <= 0

        filled = (current.to_f / total * width).round
        empty = width - filled

        bar = char * filled + bg_char * empty
        colorize(bar, :cyan)
      end

      # Error formatting with suggestions
      def error_with_suggestion(error_msg, suggestion = nil)
        lines = [error(error_msg)]

        if suggestion
          lines << ""
          lines << colorize("💡 Suggestion:", :yellow, style: :bold)
          lines << colorize("   #{suggestion}", :yellow)
        end

        lines.join("\n")
      end

      # Command formatting
      def command(cmd)
        colorize("$ #{cmd}", :bright_black, style: :italic)
      end

      def output(text, type: :stdout)
        case type
        when :stdout
          muted(text)
        when :stderr
          colorize(text, :red)
        when :debug
          colorize(text, :magenta)
        else
          text
        end
      end

      # File and path formatting
      def file_path(path)
        colorize(path, :cyan, style: :underline)
      end

      def directory(path)
        colorize(path, :blue, style: :bold)
      end

      # Duration and timing
      def duration(seconds)
        if seconds < 1
          colorize("#{(seconds * 1000).round}ms", :bright_black)
        elsif seconds < 60
          colorize("#{seconds.round(2)}s", :green)
        else
          minutes = (seconds / 60).floor
          secs = (seconds % 60).round
          colorize("#{minutes}m #{secs}s", :green)
        end
      end

      # Box drawing
      def box(content, title: nil, width: 60)
        lines = content.split("\n")
        max_width = [lines.map(&:length).max || 0, title&.length || 0, width - 4].max

        top = "┌─" + (title ? "[ #{title} ]".ljust(max_width, "─") : "─" * max_width) + "─┐"
        bottom = "└─" + "─" * max_width + "─┘"

        body = lines.map { |line| "│ #{line.ljust(max_width)} │" }

        ([top] + body + [bottom]).join("\n")
      end
    end
  end
end
