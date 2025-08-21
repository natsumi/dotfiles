# frozen_string_literal: true

module Dotfiles
  module Core
    class StepResult
      attr_reader :success, :output, :error, :step_name, :duration, :skipped, :context

      def initialize(success:, output: '', error: nil, step_name: nil, duration: 0, skipped: false, context: {})
        @success = success
        @output = output
        @error = error
        @step_name = step_name
        @duration = duration
        @skipped = skipped
        @context = context
      end

      def success?
        @success
      end

      def failure?
        !@success
      end

      def skipped?
        @skipped
      end

      def has_error?
        !@error.nil? && !@error.empty?
      end

      def error_message
        @error || ''
      end

      def formatted_duration
        if @duration < 1
          "#{(@duration * 1000).round}ms"
        else
          "#{@duration.round(2)}s"
        end
      end

      def to_h
        {
          success: @success,
          output: @output,
          error: @error,
          step_name: @step_name,
          duration: @duration,
          skipped: @skipped,
          context: @context
        }
      end

      def self.success(output: '', step_name: nil, duration: 0, context: {})
        new(
          success: true,
          output: output,
          step_name: step_name,
          duration: duration,
          context: context
        )
      end

      def self.failure(error:, output: '', step_name: nil, duration: 0, context: {})
        new(
          success: false,
          output: output,
          error: error,
          step_name: step_name,
          duration: duration,
          context: context
        )
      end

      def self.skipped(step_name: nil, context: {})
        new(
          success: true,
          output: 'Step skipped',
          step_name: step_name,
          skipped: true,
          context: context
        )
      end
    end
  end
end