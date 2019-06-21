# Source PreztoV
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

################
# THEME SETTINGS
################
[[ -f  ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ -f  ~/.purepower ]] && source ~/.purepower

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1
export GREP_COLOR="00;38;5;61"
export GREP_COLORS="00;38;5;61"

# Dir colors
eval $(gdircolors ~/.dircolors)

# SCMPuff
eval "$(scmpuff init -s)"

################
# HISTORY SETTINGS
################
setopt hist_ignore_all_dups inc_append_history
HISTFILE=~/.histfile
HISTSIZE=4096
SAVEHIST=4096

# Beep on errors and notify on background task completion
setopt beep nomatch notify

# Vim Bindings
bindkey -v
zstyle :compinstall filename '/Users/aseng/.zshrc'

# load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)

# completion
autoload -U compinit
compinit

###################
# TERMINAL SETTINGS
###################

# Disable flow control
setopt NO_FLOW_CONTROL

# awesome cd movements from zshkit
# setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
# DIRSTACKSIZE=5

# handy keybindings
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^U" backward-kill-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word
bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"

##############
# ZPLUG SETTING
###################
# Install plugins if there are plugins that have not been installed
# if ! zplug check --verbose; then
#     printf "Install? [y/N]: "
#     if read -q; then
#         echo; zplug install
#     fi
# fi

# Then, source plugins and add commands to $PATH
# zplug load

# Configure online help
unalias run-help
autoload run-help
HELPDIR=/usr/local/share/zsh/help

# Remove aliases
unalias gls #git log conflicts with dircolors gls

# Load other program settings
# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

[[ -f /usr/local/opt/asdf/asdf.sh ]] && source /usr/local/opt/asdf/asdf.sh
[[ -f /usr/local/opt/asdf/asdf.sh ]] && source /usr/local/etc/bash_completion.d/asdf.bash