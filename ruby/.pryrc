# pry-clipboard configuration
# awesome_print configuration
begin
  require "awesome_print"
  # User awesome print by default
  AwesomePrint.pry!
  AwesomePrint.defaults = {
  indent: -2,
  sort_keys: true,
  }
rescue LoadError => e
  warn "AwesomePrint gem missing.  Install with gem install awesome_printcan't load awesome_print"
end

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

# Hit Enter to repeat last command
Pry::Commands.command /^$/, "repeat last command" do
_pry_.run_command Pry.history.to_a.last
end

# Set the current theme
# needs the pry-theme gem
Pry.config.theme = "zenburn"
