# frozen_string_literal: true

module Dotfiles
  module Core
    class Step
      attr_reader :name, :description, :status, :dependencies, :start_time, :end_time

      def initialize(name:, description:, dependencies: [])
        @name = name
        @description = description
        @dependencies = dependencies
        @status = :pending
        @start_time = nil
        @end_time = nil
      end

      def execute
        return skip_result if should_skip?

        @status = :running
        @start_time = Time.now

        begin
          pre_execute
          result = perform_step
          post_execute(result)
          
          @status = result.success? ? :completed : :failed
          @end_time = Time.now
          result
        rescue StandardError => e
          @status = :failed
          @end_time = Time.now
          StepResult.new(
            success: false,
            output: '',
            error: e.message,
            step_name: @name,
            duration: execution_duration
          )
        end
      end

      def execution_duration
        return 0 unless @start_time && @end_time
        @end_time - @start_time
      end

      def completed?
        @status == :completed
      end

      def failed?
        @status == :failed
      end

      def pending?
        @status == :pending
      end

      def running?
        @status == :running
      end

      def skipped?
        @status == :skipped
      end

      private

      def should_skip?
        false
      end

      def pre_execute
      end

      def perform_step
        raise NotImplementedError, "#{self.class} must implement #perform_step"
      end

      def post_execute(result)
      end

      def skip_result
        @status = :skipped
        StepResult.new(
          success: true,
          output: "Step skipped",
          step_name: @name,
          skipped: true
        )
      end
    end
  end
end