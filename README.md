A collection of dotfile configuration scripts

## 1. Install Homebrew

[Brew](http://brew.sh/)

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Git

```bash
brew install git
sh bin/apply_git_settings
```

# Usage

## Apply Basic System Settings

```bash
sh bin/apply_basic_settings
```

## Apply System Defaults

```bash
sh bin/apply_default_settings
```

## Install Desktop Applications

```bash
sh bin/install_homebrew_casks
```

## Install Brew base packages

```bash
brew bundle --file=~/dev/dotfiles/homebrew/Brewfile
brew bundle --file=~/dev/dotfiles/homebrew/Brewfile_fonts
```

# Software Configuration

## Apply Software Symlink

```bash
sh bin/apply_symlinks
```

## ZSH Setup

### Set Default Shell

```bash
echo $(which zsh) | sudo tee -a /etc/shells
chsh -s $(which zsh)
```

### Zplug

[Zplug](https://github.com/zplug/zplug)

```bash
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

```bash
git clone --recursive --depth 1 https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
git clone --recursive --depth 1 https://github.com/belak/prezto-contrib  "${ZDOTDIR:-$HOME}/.zprezto/contrib"
```

### [FZF](https://github.com/junegunn/fzf#installation)

$(brew --prefix)/opt/fzf/install

````

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`

## Programming Dev setup

### [asdf](https://github.com/asdf-vm/asdf)

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
````

Restart Shell

```shell
sh bin/install_dev_env
```

### Alfred Integration

```shell
ln -s $(which node) /usr/local/bin/node
```

## Bat

To pickup the Nord theme.

```shell
bat cache --build
```

## Tmux

    mkdir -p ~/.tmux/plugins

### Install Plugins

run tmux ctrl-s shift-i

## Yabai Window Manager

This is experimental.

[Yabai Window Manager](https://github.com/koekeishiya/yabai)

[Simple Keyboard Hot Keys](https://github.com/koekeishiya/skhd)

```bash
stow -v --target=$HOME --dir=$DOTFILE_DIR yabai
```

- Disable Sip
  `csrutil disable --with kext --with dtrace --with nvram --with basesystem`

- Install SA
  `sudo yabai install-sa`
  `sudo yabai load-sa`

# Post Install Settings

### Visual Studio Code

Enable key repeat

```bash
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
```

# Tools Included

- awk
- [bat](https://github.com/sharkdp/bat)

  A better cat

- [delta](https://github.com/dandavison/delta)

  Better git diff

- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)

  Better git diff

- [exa](https://github.com/ogham/exa)

  A modern ls

- [fd](https://github.com/sharkdp/fd)

  A better find

- [fzf](https://github.com/junegunn/fzf)

  CLI Fuzzy Finder

- [jq](https://github.com/stedolan/jq)

  JSON parsing

- [ripgrep](https://github.com/BurntSushi/ripgrep)

  Super fast search

- [scm-puff](https://github.com/mroth/scmpuff)

  Easier git file actions

- [silver searcher](https://github.com/ggreer/the_silver_searcher)

  Super fast search

- stow

  Symlink manager

- [tig](https://github.com/jonas/tig)

  Ncurses git logs

- tmux

  Terminal multiplexer

- tree
