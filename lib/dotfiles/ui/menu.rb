# frozen_string_literal: true

require 'io/console'

module Dotfiles
  module UI
    class Menu
      KEYS = {
        up: "\e[A",
        down: "\e[B", 
        enter: "\r",
        space: " ",
        escape: "\e",
        quit: "q",
        help: "h",
        all: "a",
        clear: "c"
      }.freeze

      attr_reader :steps, :selected_steps, :current_index

      def initialize(steps = [], formatter: nil)
        @steps = steps
        @selected_steps = Set.new
        @current_index = 0
        @formatter = formatter || Dotfiles::UI::Formatter.new
        @show_help = false
      end

      def show
        system('clear')
        display_header
        display_help if @show_help
        display_steps
        display_footer
        display_prompt
      end

      def run
        loop do
          show
          input = get_input
          action = handle_input(input)
          
          case action
          when :quit
            break
          when :execute
            return execute_selected_steps
          when :execute_all
            select_all_steps
            return execute_selected_steps
          end
        end
        
        nil
      end

      def add_step(step)
        @steps << step
      end

      def add_steps(steps)
        @steps.concat(steps)
      end

      def select_step(index)
        return unless valid_index?(index)
        step = @steps[index]
        
        if @selected_steps.include?(step)
          @selected_steps.delete(step)
        else
          @selected_steps.add(step)
        end
      end

      def select_all_steps
        @selected_steps = Set.new(@steps)
      end

      def clear_selection
        @selected_steps.clear
      end

      def execute_selected_steps
        return [] if @selected_steps.empty?
        
        selected_array = @selected_steps.to_a
        @selected_steps.clear
        selected_array
      end

      private

      def display_header
        puts @formatter.header("Dotfiles Setup Menu")
        puts
        puts @formatter.info("Use ↑/↓ to navigate, Space to select, Enter to execute selected")
        puts @formatter.info("Commands: (a)ll, (c)lear, (h)elp, (q)uit")
        puts
      end

      def display_help
        puts @formatter.section("Help")
        puts "  Navigation:"
        puts "    ↑/↓  - Move cursor up/down"
        puts "    Space - Toggle step selection"
        puts "    Enter - Execute selected steps"
        puts
        puts "  Commands:"
        puts "    a - Select all steps"
        puts "    c - Clear all selections"
        puts "    h - Toggle this help"
        puts "    q - Quit menu"
        puts
        puts "  Step Status:"
        puts "    #{@formatter.status_icon(:pending)} - Not executed"
        puts "    #{@formatter.status_icon(:completed)} - Completed successfully"
        puts "    #{@formatter.status_icon(:failed)} - Failed"
        puts "    #{@formatter.status_icon(:skipped)} - Skipped"
        puts "    #{@formatter.status_icon(:running)} - Currently running"
        puts
      end

      def display_steps
        puts @formatter.section("Available Steps (#{@steps.length})")
        
        if @steps.empty?
          puts @formatter.warning("No steps available")
          return
        end

        @steps.each_with_index do |step, index|
          is_current = index == @current_index
          is_selected = @selected_steps.include?(step)
          
          cursor = is_current ? ">" : " "
          checkbox = is_selected ? "✓" : " "
          status_icon = @formatter.status_icon(step.status)
          
          line = sprintf("%s [%s] %s %s - %s", 
            cursor, checkbox, status_icon, step.name, step.description)
          
          if is_current
            puts @formatter.highlight(line)
          else
            puts line
          end
          
          # Show dependencies if any
          if step.dependencies.any?
            dep_text = "    Dependencies: #{step.dependencies.join(', ')}"
            puts @formatter.muted(dep_text)
          end
        end
        puts
      end

      def display_footer
        selected_count = @selected_steps.size
        if selected_count > 0
          puts @formatter.success("#{selected_count} step(s) selected")
        else
          puts @formatter.muted("No steps selected")
        end
        puts
      end

      def display_prompt
        print @formatter.prompt("Menu > ")
      end

      def get_input
        $stdin.getch
      end

      def handle_input(input)
        case input
        when KEYS[:up]
          move_cursor(-1)
        when KEYS[:down]
          move_cursor(1)
        when KEYS[:space]
          select_step(@current_index)
        when KEYS[:enter]
          return :execute if @selected_steps.any?
        when KEYS[:quit], KEYS[:escape]
          return :quit
        when KEYS[:help]
          @show_help = !@show_help
        when KEYS[:all]
          return :execute_all
        when KEYS[:clear]
          clear_selection
        when /\d/
          # Allow number selection
          index = input.to_i - 1
          if valid_index?(index)
            @current_index = index
            select_step(index)
          end
        end
        
        nil
      end

      def move_cursor(direction)
        return if @steps.empty?
        
        new_index = @current_index + direction
        @current_index = new_index.clamp(0, @steps.length - 1)
      end

      def valid_index?(index)
        index >= 0 && index < @steps.length
      end
    end
  end
end