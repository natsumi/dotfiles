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

# fzf history search. Type `fzf` at the IRB prompt to fuzzy-search ~/.irb_history.
# Selected line is inserted into the current input buffer.
begin
  require "irb/command"

  class FzfHistory < IRB::Command::Base
    category "History"
    description "Fuzzy-search IRB history with fzf"

    def execute(*)
      history_file = File.expand_path("~/.irb_history")
      unless File.exist?(history_file)
        puts "No history file at #{history_file} yet."
        return
      end
      selected = `tac #{history_file} | awk '!seen[$0]++' | fzf --tiebreak=index`.chomp
      return if selected.empty?
      if Reline.respond_to?(:line_buffer=)
        Reline.line_buffer = selected
      else
        puts selected
      end
    end
  end

  IRB::Command.register(:fzf, FzfHistory)
rescue LoadError, NameError
  # IRB::Command API not available — fzf command silently disabled.
end

# Best-effort: rebind Ctrl-R to the same fzf flow. Reline's keymap API has
# shifted across versions; if the constant or method we expect isn't present,
# the rescue keeps IRB loading cleanly and Ctrl-R falls back to Reline's
# default incremental search.
begin
  Reline::KeyActor::Emacs::DEFAULT_KEY_BINDINGS[[0x12]] = ->(_) {
    IRB::Command.execute(:fzf)
  }
rescue
  # Keymap rebind unavailable on this Reline version — type `fzf` instead.
end
