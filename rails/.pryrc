# pry-clipboard configuration
begin
  require 'pry-clipboard'
  # aliases
  Pry.config.commands.alias_command 'ch', 'copy-history'
  Pry.config.commands.alias_command 'cr', 'copy-result'
rescue LoadError => e
  warn "can't load pry-clipboard"
end

# awesome_print configuration
begin
  require "awesome_print"
  # User awesome print by default
  AwesomePrint.pry!
  AwesomePrint.defaults = { indent: -2 }
rescue LoadError => e
  warn "can't load awesome_print"
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


require 'pry-bloodline'
#
# PryBloodline.configure do |c|
#   c.line_color = :red
#   c.name_color = :white
#   c.path_color = :blue
#   c.separator_color = :light_black
# end
PryBloodline.setup!

# Set the current theme
# needs the pry-theme gem
Pry.config.theme = "zenburn"
