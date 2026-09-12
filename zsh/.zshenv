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

# Elixir IEX History
export ERL_AFLAGS="-kernel shell_history enabled shell_history_file_bytes 20240000"

######################
# CLI Env
######################
#
# Ripgrep
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# FZF Settings
# set default file search to be ripgrep
export FZF_DEFAULT_COMMAND='rg --files --hidden'
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Kitty Terminal
export KITTY_CONFIG_DIRECTORY="${HOME}/.config/kitty"

# Bundle - install gems in parallel, one job per CPU (works on macOS and Linux)
export BUNDLE_JOBS=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)

# Github CLI - opt out of telemetry
export GH_TELEMETRY=false

# Local config
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
