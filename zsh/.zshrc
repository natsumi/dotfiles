# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Our own completion functions. Must be on fpath before prezto runs compinit.
fpath=(~/.zsh/completion /opt/homebrew/share/zsh/site-functions $fpath)

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

################
# THEME SETTINGS
################
# Theme loaded in .zprezto

# enable truecolor support
export COLORTERM=truecolor

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1
export GREP_COLORS="mt=00;38;5;61"

# History is configured by prezto's history module (~/.zhistory, 10000 lines,
# shared between shells, duplicates ignored).

# Beep on errors and notify on background task completion
setopt beep nomatch notify

# Vim Bindings
bindkey -v

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
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word
# ^R and ^T are bound by fzf below.

# Remove aliases
unalias gls 2>/dev/null # git log conflicts with dircolors gls

# Load other program settings
# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load fzf commands
[[ -f ~/.fzf_commands.zsh ]] && source ~/.fzf_commands.zsh

# Mise
[[ -f ~/.local/bin/mise ]] && eval "$(~/.local/bin/mise activate zsh)"

# FZF key bindings and completion. fzf is a mise tool (on PATH via the shims
# dir added in .zprofile), so use its built-in shell integration.
command -v fzf > /dev/null && eval "$(fzf --zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# SCMPuff
command -v scmpuff > /dev/null && eval "$(scmpuff init -s)"
