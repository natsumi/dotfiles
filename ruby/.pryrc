Pry.config.history_file = "~/.pry_history"

# pry-clipboard configuration

# Pry Configuration
#
# Add all gems in the global gemset to the $LOAD_PATH so they can be used even
# in places like 'rails console'.
if defined?(::Bundler)
  global_gemset = Gem.dir
  $LOAD_PATH.concat(Dir.glob("#{global_gemset}/gems/*/lib")) if global_gemset
end

# Pry-rails sometimes doesn't load pry-doc, explicitly load it
# if defined?(Rails::Railtie)
require 'pry-doc'
# end

# Use fzf for history search
# it is required to
# gem install rb-readline
require 'rb-readline'
if defined?(RbReadline)
  def RbReadline.rl_reverse_search_history(sign, key)
    # tac reverses the history to preserve latest first
    # awk is used to make sure the history contains only
    # uniqs (non adjacent)
    # first awk command trims leading and trailing whitespace to reduce matches
    # tiebreak gives precedence to the most recent history
    rl_insert_text `tac  ~/.pry_history | awk '{$1=$1};1' | awk '!x[$0]++' | fzf --tiebreak=index |  tr '\n' ' '`
  end
end

# amazing_print configuration
begin
  require 'amazing_print'
  # User awesome print by default
  AmazingPrint.pry!
  AmazingPrint.defaults = {
    indent: -2,
    sort_keys: true,
  }
rescue LoadError => e
  warn "AmazingPrint gem missing.  Install with gem install amazing_print can't load amazing_print"
end

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

begin
  require 'pry-clipboard'
  # aliases
  # Pry.config.commands.alias_command 'ch', 'copy-history'
  Pry.config.commands.alias_command 'cr', 'copy-result'
rescue LoadError => e
  warn "can't load pry-clipboard"
end

# Hit Enter to repeat last command
Pry::Commands.command /^$/, 'repeat last command' do
  pry_instance.run_command Pry.history.to_a.last
end

# Set the current theme
# needs the pry-theme gem
Pry.config.theme = 'zenburn'
