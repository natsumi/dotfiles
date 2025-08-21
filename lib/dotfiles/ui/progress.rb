# frozen_string_literal: true

module Dotfiles
  module UI
    class Progress
      attr_reader :current, :total, :start_time, :step_times

      def initialize(total:, width: 40)
        @total = total
        @current = 0
        @width = width
        @start_time = Time.now
        @step_times = []
        @last_update = Time.now
        @formatter = Dotfiles::UI::Formatter.new
      end

      def update(current, description: nil, force: false)
        @current = current
        @step_times << Time.now - @last_update unless @current == 0
        @last_update = Time.now
        
        # Only update display if enough time has passed or forced
        return unless force || should_update?
        
        display_progress(description)
      end

      def increment(description: nil)
        update(@current + 1, description: description)
      end

      def complete(description: "Completed!")
        @current = @total
        display_progress(description, final: true)
        puts # Add newline after completion
      end

      def display_progress(description = nil, final: false)
        percentage = (@current.to_f / @total * 100).round(1)
        
        # Build progress bar
        filled = (@current.to_f / @total * @width).round
        bar = "█" * filled + "░" * (@width - filled)
        
        # Calculate timing
        elapsed = Time.now - @start_time
        eta = calculate_eta(elapsed)
        
        # Format progress line
        progress_line = sprintf("[%s] %d/%d (%s%%) %s %s",
          @formatter.colorize(bar, :cyan),
          @current,
          @total, 
          percentage,
          format_time(elapsed),
          eta ? "ETA: #{format_time(eta)}" : ""
        )
        
        # Clear line and print progress
        print "\r\033[K#{progress_line}"
        
        # Add description on new line if provided
        if description
          puts
          puts @formatter.info("#{description}")
          print progress_line unless final
        end
        
        $stdout.flush
      end

      def step_start(step_name, step_number = nil)
        num = step_number || @current + 1
        puts
        puts @formatter.step_start("Step #{num}/#{@total}: #{step_name}")
        update(num, force: true)
      end

      def step_complete(step_name, duration = nil)
        duration_text = duration ? " (#{format_duration(duration)})" : ""
        puts
        puts @formatter.step_complete("✓ #{step_name}#{duration_text}")
      end

      def step_failed(step_name, error = nil, duration = nil)
        duration_text = duration ? " (#{format_duration(duration)})" : ""
        puts
        puts @formatter.step_failed("✗ #{step_name}#{duration_text}")
        puts @formatter.error("  Error: #{error}") if error
      end

      def step_skipped(step_name, reason = nil)
        reason_text = reason ? " (#{reason})" : ""
        puts
        puts @formatter.step_skipped("⊝ #{step_name}#{reason_text}")
      end

      def summary(results)
        puts
        puts @formatter.section("Execution Summary")
        
        total = results.length
        successful = results.count(&:success?)
        failed = results.count(&:failure?)
        skipped = results.count(&:skipped?)
        total_duration = results.sum(&:duration)
        
        puts sprintf("  Total steps: %s", @formatter.highlight(total.to_s))
        puts sprintf("  Successful:  %s", @formatter.success(successful.to_s))
        puts sprintf("  Failed:      %s", failed > 0 ? @formatter.error(failed.to_s) : @formatter.muted("0"))
        puts sprintf("  Skipped:     %s", skipped > 0 ? @formatter.warning(skipped.to_s) : @formatter.muted("0"))
        puts sprintf("  Duration:    %s", @formatter.info(format_duration(total_duration)))
        
        if failed > 0
          puts
          puts @formatter.error("Failed Steps:")
          results.select(&:failure?).each do |result|
            puts @formatter.error("  ✗ #{result.step_name}: #{result.error_message}")
          end
        end
        
        if skipped > 0
          puts
          puts @formatter.warning("Skipped Steps:")
          results.select(&:skipped?).each do |result|
            puts @formatter.warning("  ⊝ #{result.step_name}")
          end
        end
        
        puts
      end

      private

      def should_update?
        # Update at most 10 times per second
        Time.now - @last_update >= 0.1
      end

      def calculate_eta(elapsed)
        return nil if @current == 0 || @step_times.empty?
        
        avg_step_time = @step_times.sum.to_f / @step_times.length
        remaining_steps = @total - @current
        remaining_steps * avg_step_time
      end

      def format_time(seconds)
        return "0s" if seconds <= 0
        
        if seconds < 60
          "#{seconds.round}s"
        elsif seconds < 3600
          minutes = seconds / 60
          "#{minutes.round}m"
        else
          hours = seconds / 3600
          minutes = (seconds % 3600) / 60
          "#{hours.round}h #{minutes.round}m"
        end
      end

      def format_duration(duration)
        if duration < 1
          "#{(duration * 1000).round}ms"
        elsif duration < 60
          "#{duration.round(2)}s"
        else
          minutes = (duration / 60).floor
          seconds = (duration % 60).round
          "#{minutes}m #{seconds}s"
        end
      end
    end
  end
end