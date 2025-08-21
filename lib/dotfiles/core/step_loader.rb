# frozen_string_literal: true

require 'yaml'

module Dotfiles
  module Core
    class StepLoader
      class MissingStepError < StandardError; end
      class InvalidConfigError < StandardError; end

      class << self
        def load_all_steps
          load_step_files
          Core::Step.subclasses
        end

        def load_ordered_steps(config_path = nil)
          config_path ||= default_config_path
          
          unless File.exist?(config_path)
            raise InvalidConfigError, "Step order config not found: #{config_path}"
          end

          config = YAML.load_file(config_path)
          validate_config(config)
          
          all_step_classes = load_all_steps
          ordered_steps = []

          config['categories'].each do |category|
            category['steps'].each do |step_name|
              step_class = find_step_class(step_name, all_step_classes)
              
              unless step_class
                raise MissingStepError, "Step '#{step_name}' listed in config but not implemented. Available steps: #{available_step_names(all_step_classes).join(', ')}"
              end

              ordered_steps << step_class.create_instance
            end
          end

          ordered_steps
        end

        def available_steps
          load_all_steps.map do |step_class|
            {
              class: step_class,
              name: step_class.step_name || step_class.send(:default_step_name),
              description: step_class.step_description || "Execute #{step_class.step_name || step_class.send(:default_step_name)}"
            }
          end
        end

        private

        def load_step_files
          steps_dir = File.join(__dir__, '..', 'steps')
          return unless Dir.exist?(steps_dir)

          Dir[File.join(steps_dir, '*.rb')].each do |file|
            require file
          end
        end

        def default_config_path
          File.join(__dir__, '..', '..', '..', 'config', 'step_order.yml')
        end

        def validate_config(config)
          unless config.is_a?(Hash) && config['categories']
            raise InvalidConfigError, "Config must have 'categories' key"
          end

          unless config['categories'].is_a?(Array)
            raise InvalidConfigError, "'categories' must be an array"
          end

          config['categories'].each_with_index do |category, index|
            unless category.is_a?(Hash) && category['name'] && category['steps']
              raise InvalidConfigError, "Category at index #{index} must have 'name' and 'steps' keys"
            end

            unless category['steps'].is_a?(Array)
              raise InvalidConfigError, "Steps in category '#{category['name']}' must be an array"
            end
          end
        end

        def find_step_class(step_name, step_classes)
          step_classes.find do |klass|
            class_step_name = klass.step_name || klass.send(:default_step_name)
            class_step_name == step_name
          end
        end

        def available_step_names(step_classes)
          step_classes.map do |klass|
            klass.step_name || klass.send(:default_step_name)
          end
        end
      end
    end
  end
end