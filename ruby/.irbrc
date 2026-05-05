# Project-local IRB configuration. Loaded automatically when IRB is launched
# from the repo root. Additive over ~/.irbrc — do not clobber personal settings.

# Pretty-print return values via amazing_print.
begin
  require "amazing_print"
  AmazingPrint.irb!
  AmazingPrint.defaults = {indent: -2, sort_keys: true}
rescue LoadError
  # amazing_print is in the Gemfile; LoadError only happens outside Bundler.
end

# Type-aware autocomplete via repl_type_completor. Switches IRB's completion
# engine from regex matching to Ruby type analysis — far more accurate
# suggestions for chained method calls.
begin
  require "repl_type_completor"
  IRB.conf[:COMPLETOR] = :type
rescue LoadError
  # repl_type_completor is in the Gemfile; LoadError only happens outside Bundler.
end

# Env-aware colored prompt: [development] in green, [test] in cyan, [production]
# in bold red, anything else (e.g. staging) in magenta. ANSI escape sequences
# are wrapped in \1...\2 markers so Reline does not count them when measuring
# prompt width.
if defined?(Rails)
  env = Rails.env
  color = case env
  when "production" then "\e[1;31m"
  when "test" then "\e[36m"
  when "development" then "\e[32m"
  else "\e[35m"
  end
  reset = "\e[0m"
  prefix = "\1#{color}\2[#{env}]\1#{reset}\2"

  IRB.conf[:PROMPT][:RAILS_ENV] = {
    AUTO_INDENT: true,
    PROMPT_I: "#{prefix} %N(%m):%03n> ",
    PROMPT_S: "#{prefix} %N(%m):%03n%l ",
    PROMPT_C: "#{prefix} %N(%m):%03n* ",
    RETURN: "=> %s\n"
  }
  IRB.conf[:PROMPT_MODE] = :RAILS_ENV
end

# Shared fuzzy-history picker used by both the `fzf` IRB command and the
# Ctrl-R Reline binding below. Returns the selected line, or nil if the
# history file is missing, empty, or the user cancelled fzf.
module FzfHistoryPicker
  module_function

  def history_file
    IRB.conf[:HISTORY_FILE] || File.expand_path("~/.irb_history")
  end

  def pick
    return nil unless File.exist?(history_file)

    # Feed fzf newest-first and de-duplicated. #reverse puts the most recent
    # commands first; #uniq then keeps the first occurrence of each duplicate
    # (i.e. the most recent run). --tiebreak=index preserves that ordering
    # when fzf would otherwise tie-break by line length.
    choices = File.readlines(history_file, chomp: true).reverse.uniq.join("\n")
    selected = IO.popen("fzf --tiebreak=index", "r+") { |io|
      io.write(choices)
      io.close_write
      io.read
    }.chomp
    selected.empty? ? nil : selected
  end
end

# fzf history search. Type `fzf` at the IRB prompt to fuzzy-search the IRB
# history file. Selected line is inserted into the current input buffer.
begin
  require "irb/command"

  class FzfHistory < IRB::Command::Base
    category "History"
    description "Fuzzy-search IRB history with fzf"

    def execute(*)
      unless File.exist?(FzfHistoryPicker.history_file)
        puts "No history file at #{FzfHistoryPicker.history_file} yet."
        return
      end
      selected = FzfHistoryPicker.pick
      return if selected.nil?
      if Reline.respond_to?(:insert_text)
        Reline.insert_text(selected)
      else
        puts selected
      end
    end
  end

  IRB::Command.register(:fzf, FzfHistory)
rescue LoadError, NameError
  # IRB::Command API not available — fzf command silently disabled.
end

# Ctrl-R -> fzf history picker. Reline dispatches bindings by calling
# method(symbol) on Reline::LineEditor, so the action must be defined there.
# If Reline's API changes, the rescue keeps .irbrc loading and Ctrl-R falls
# back to Reline's default incremental search.
begin
  class Reline::LineEditor
    def fzf_history_search(_key)
      selected = FzfHistoryPicker.pick
      return if selected.nil?

      Reline.insert_text(selected)
      rerender
    end
  end

  Reline.core.config.add_default_key_binding([0x12], :fzf_history_search)
rescue NameError
  # Reline's binding API not as expected — type `fzf` at the prompt instead.
end
