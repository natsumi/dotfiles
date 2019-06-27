# ZPlug
export ZPLUG_HOME=/usr/local/opt/zplug

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# use nvim as the visual editor
export VISUAL=nvim
export EDITOR=$VISUAL

export DEV_DIR=$HOME/dev
export WORKON_HOME=$DEV_DIR
export DOTFILE_DIR=$DEV_DIR/dotfiles

# setup gtags to use a ctag backend
export GTAGSCONF=$HOME/.gtags.conf
export GTAGSLABEL=pygments

# Elixir IEX History
export ERL_AFLAGS="-kernel shell_history enabled shell_history_file_bytes 20240000"

# Init Zplug
# [[ -f $ZPLUG_HOME/init.zsh ]] && source $ZPLUG_HOME/init.zsh

# Local config
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
