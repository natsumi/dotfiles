# Irb Configuration
#
# Add all gems in the global gemset to the $LOAD_PATH so they can be used even
# in places like 'rails console'.

IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 2000

if defined?(::Bundler)
  global_gemset = Gem.dir
  $LOAD_PATH.concat(Dir.glob("#{global_gemset}/gems/*/lib")) if global_gemset
end


# Use fzf for history search
# it is required to
# gem install rb-readline
require 'readline'
require 'rb-readline'
if defined?(RbReadline)
  def RbReadline.rl_reverse_search_history(sign, key)
    # tac reverses the history to preserve latest first
    # awk is used to make sure the history contains only
    # uniqs (non adjacent)
    # first awk command trims leading and trailing whitespace to reduce matches
    # tiebreak gives precedence to the most recent history
    rl_insert_text `tac  ~/.irb_history | awk '{$1=$1};1' | awk '!x[$0]++' | fzf --tiebreak=index |  tr '\n' ' '`
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
