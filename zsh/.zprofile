#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#
export PATH="/usr/local/opt/openssl/bin:$PATH"

# mise shims: resolve mise-managed tools (hk, etc.) in non-interactive
# subprocesses like git hooks. `mise activate` (in .zshrc) only sets PATH for
# interactive shells, so hooks couldn't find hk without this.
#
# The shims live under mise's data dir, which defaults to ~/.local/share/mise
# on both macOS and Linux — Homebrew installs only the mise binary, not the
# data dir, so the path is the same there. Honor MISE_DATA_DIR if set, and
# only prepend when the dir actually exists.
mise_shims="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims"
[[ -d "$mise_shims" ]] && export PATH="$mise_shims:$PATH"
unset mise_shims

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

# Apple Silicon support
[[ -f /opt/homebrew/bin/brew ]] &&  eval $(/opt/homebrew/bin/brew shellenv)