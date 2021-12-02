# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Fix umask bug in WSL where it is always set to 000
if [[ ! -z "$WSL_DISTRO_NAME" ]]; then
  umask 022
fi

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

################
# THEME SETTINGS
################
# Theme loaded in .zprezto


# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1
export GREP_COLOR="00;38;5;61"
export GREP_COLORS="00;38;5;61"

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

# load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)

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
source ${ZPLUG_HOME}/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug ' zdharma-continuum/fast-syntax-highlighting'
# Forgit options
forgit_stash_show=gsf
forgit_diff=gdf

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi


# Then, source plugins and add commands to $PATH
zplug load

# Remove aliases
unalias gls #git log conflicts with dircolors gls

# Load other program settings
# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load fzf commands
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/.fzf_commands.zsh ]] && source ~/.fzf_commands.zsh

# Load FZF key bindings and completion
# ARM M1
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
# x86 FZF
[[ -f ~/usr/local/opt/fzf/shell/key-bindings.zsh ]] && source ~/usr/local/opt/fzf/shell/key-bindings.zsh ]]
[[ -f ~/usr/local/opt/fzf/shell/completion.zsh ]] && source ~/usr/local/opt/fzf/shell/completion.zsh ]]

# Linux / WSL FZF
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh

[[ -f ~/.asdf/asdf.sh ]] && source ~/.asdf/asdf.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
#
# Dir colors
# eval $(gdircolors ~/.dircolors)

# SCMPuff
eval "$(scmpuff init -s)"
