# frozen_string_literal: true

require_relative 'step'
require_relative 'step_result'

module Dotfiles
  module Core
    class Executor
      attr_reader :steps, :results, :dry_run

      def initialize(dry_run: false)
        @steps = []
        @results = []
        @dry_run = dry_run
      end

      def add_step(step)
        unless step.is_a?(Step)
          raise ArgumentError, "Expected Step instance, got #{step.class}"
        end
        @steps << step
      end

      def execute_all
        ordered_steps = resolve_dependencies
        total_steps = ordered_steps.length
        
        ordered_steps.each_with_index do |step, index|
          puts "[#{index + 1}/#{total_steps}] Executing: #{step.name}"
          
          result = if @dry_run
            dry_run_step(step)
          else
            step.execute
          end
          
          @results << result
          
          if result.failure? && !step_is_optional?(step)
            puts "Critical step failed: #{step.name}"
            break
          end
        end
        
        execution_summary
      end

      def execute_step(step_name)
        step = find_step(step_name)
        return nil unless step

        dependencies = resolve_step_dependencies(step)
        
        dependencies.each do |dep_step|
          next if dep_step.completed?
          
          puts "Executing dependency: #{dep_step.name}"
          result = @dry_run ? dry_run_step(dep_step) : dep_step.execute
          @results << result
          
          if result.failure?
            puts "Dependency failed: #{dep_step.name}"
            return result
          end
        end

        puts "Executing: #{step.name}"
        result = @dry_run ? dry_run_step(step) : step.execute
        @results << result
        result
      end

      def clear_results
        @results.clear
      end

      def successful_steps
        @results.select(&:success?)
      end

      def failed_steps
        @results.select(&:failure?)
      end

      def skipped_steps
        @results.select(&:skipped?)
      end

      def execution_summary
        {
          total: @results.length,
          successful: successful_steps.length,
          failed: failed_steps.length,
          skipped: skipped_steps.length,
          total_duration: @results.sum(&:duration)
        }
      end

      private

      def resolve_dependencies
        visited = Set.new
        temp_visited = Set.new
        ordered = []

        @steps.each do |step|
          visit_step(step, visited, temp_visited, ordered)
        end

        ordered
      end

      def visit_step(step, visited, temp_visited, ordered)
        return if visited.include?(step)
        
        if temp_visited.include?(step)
          raise "Circular dependency detected involving step: #{step.name}"
        end

        temp_visited.add(step)

        step.dependencies.each do |dep_name|
          dep_step = find_step(dep_name)
          if dep_step
            visit_step(dep_step, visited, temp_visited, ordered)
          else
            puts "Warning: Dependency '#{dep_name}' not found for step '#{step.name}'"
          end
        end

        temp_visited.delete(step)
        visited.add(step)
        ordered << step
      end

      def resolve_step_dependencies(step)
        dependencies = []
        step.dependencies.each do |dep_name|
          dep_step = find_step(dep_name)
          dependencies << dep_step if dep_step
        end
        dependencies
      end

      def find_step(step_name)
        @steps.find { |step| step.name == step_name }
      end

      def step_is_optional?(step)
        step.respond_to?(:optional?) && step.optional?
      end

      def dry_run_step(step)
        StepResult.new(
          success: true,
          output: "[DRY RUN] Would execute: #{step.description}",
          step_name: step.name,
          context: { dry_run: true }
        )
      end
    end
  end
end