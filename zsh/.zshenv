# ZPlug
export ZPLUG_HOME=~/.zplug

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export HOMEBREW_NO_ANALYTICS=1

# use nvim as the visual editor
export VISUAL=nvim
export EDITOR=$VISUAL

######################
# Programming Env
######################
# Dev Dirs
export DEV_DIR=$HOME/dev
export WORKON_HOME=$DEV_DIR
export DOTFILE_DIR=$DEV_DIR/dotfiles
# export GOTPATH=$DEV_DIR/go

# setup gtags to use a ctag backend
export GTAGSCONF=$HOME/.gtags.conf
export GTAGSLABEL=pygments

# Elixir IEX History
export ERL_AFLAGS="-kernel shell_history enabled shell_history_file_bytes 20240000"

######################
# CLI Env
######################
#
# Bat
export BAT_THEME="nord"

# Ripgrep
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# FZF Settings
# set default file search to be ripgrep
export FZF_DEFAULT_COMMAND='rg --files --hidden'
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Kitty Terminal
export KITTY_CONFIG_DIRECTORY="${HOME}/.config/kitty"

# Bundle - Allow mulitple gems to be installed at once
export BUNDLE_JOBS="$(/usr/local/bin/nproc)"

# Local config
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
