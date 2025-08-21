# frozen_string_literal: true

module Dotfiles
  module Core
    class Step
      attr_reader :name, :description, :status, :dependencies, :start_time, :end_time

      class << self
        attr_accessor :step_name, :step_description, :step_dependencies

        def name(value)
          @step_name = value
        end

        def description(value)
          @step_description = value
        end

        def depends_on(*deps)
          @step_dependencies = deps
        end

        def create_instance
          instance = new
          instance.instance_variable_set(:@name, @step_name || default_step_name)
          instance.instance_variable_set(:@description, @step_description || "Execute #{@step_name || default_step_name}")
          instance.instance_variable_set(:@dependencies, resolve_dependencies(@step_dependencies || []))
          instance.instance_variable_set(:@status, :pending)
          instance.instance_variable_set(:@start_time, nil)
          instance.instance_variable_set(:@end_time, nil)
          instance
        end

        def execute
          create_instance.execute
        end

        private

        def default_step_name
          name.split('::').last.gsub(/([A-Z])/, '_\1').downcase.gsub(/^_/, '')
        end

        def resolve_dependencies(deps)
          deps.map do |dep|
            case dep
            when Class
              dep.step_name || dep.send(:default_step_name)
            when Symbol, String
              dep.to_s
            else
              dep.to_s
            end
          end
        end
      end

      def initialize
        # Instance variables set by create_instance
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
        rescue => e
          @status = :failed
          @end_time = Time.now
          StepResult.new(
            success: false,
            output: "",
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
