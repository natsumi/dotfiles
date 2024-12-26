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

## Set hostname

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

## Install Brew packages

```bash
brew bundle --file=homebrew/Brewfile
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

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`

## Programming Dev setup

### [asdf](https://github.com/asdf-vm/asdf)

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0
```

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

[Yabai Window Manager](https://github.com/koekeishiya/yabai)

[Simple Keyboard Hot Keys](https://github.com/koekeishiya/skhd)

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

# Desktop Applications

These applications are installed via the `bin/install_desktop_apps` script.

## Productivity Applications

- [Alfred](https://www.alfredapp.com/) - Spotlight replacement with powerful workflows and snippets
- [ForkLift](https://binarynights.com/) - Advanced dual pane file manager
- [Google Chrome](https://www.google.com/chrome/) - Web browser from Google
- [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/) - Firefox browser with developer tools
- [Shottr](https://shottr.cc/) - Feature-rich screenshot and annotation tool

## Development Applications

- [Cursor](https://cursor.sh/) - AI-first code editor
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Fast, feature-rich, GPU-based terminal emulator
- [Postman](https://www.postman.com/) - API development and testing platform
- [Sublime Merge](https://www.sublimemerge.com/) - Git client from the makers of Sublime Text
- [TablePlus](https://tableplus.com/) - Modern database management tool
- [Visual Studio Code](https://code.visualstudio.com/) - Popular code editor with extensive plugin support

## Media Applications

- [Spotify](https://www.spotify.com/) - Music streaming service
- [SpotMenu](https://github.com/kmikiy/SpotMenu) - Spotify and iTunes in your menu bar
- [VLC](https://www.videolan.org/vlc/) - Free and open source cross-platform multimedia player

## Social Applications

- [Discord](https://discord.com/) - Voice, video, and text chat platform
- [Google Chat](https://workspace.google.com/products/chat/) - Team messaging from Google
- [Google Meet](https://meet.google.com/) - Video conferencing from Google
- [Google Voice](https://voice.google.com/) - Voice calls and messaging service
- [Slack](https://slack.com/) - Team communication and collaboration platform
- [Telegram](https://telegram.org/) - Cloud-based messaging app

## Utility Applications

- [BetterDisplay](https://github.com/waydabber/BetterDisplay) - Advanced display management for MacOS
- [LocalSend](https://localsend.org/) - Open source file sharing across devices
- [Mounty](https://mounty.app/) - Re-mounts write-protected NTFS volumes in read-write mode
- [SaneSideButtons](https://github.com/thealpa/SaneSideButtons) - Fix mouse side buttons for MacOS
- [Stats](https://github.com/exelban/stats) - System monitor in your menu bar
- [The Unarchiver](https://theunarchiver.com/) - Data compression and archive tool
- [TRex](https://github.com/amebalabs/TRex) - Easy-to-use text extraction tool
