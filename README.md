My very opinated configuration and setup scripts for new and existing Macs.

## Setup a new Mac

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/bin/bootstrap.sh)"
```

## Tmux

```bash
mkdir -p ~/.tmux/plugins
```

### Install Plugins
run tmux  then press `ctrl-s shift-i`

## Yabai Window Manager

[Yabai Window Manager](https://github.com/koekeishiya/yabai)

[Simple Keyboard Hot Keys](https://github.com/koekeishiya/skhd)

# Desktop Applications

These applications are installed via the `bin/install_desktop_apps` script.

## Productivity Applications

- [Alfred](https://www.alfredapp.com/) - Spotlight replacement with powerful workflows and snippets
- [ForkLift](https://binarynights.com/) - Advanced dual pane file manager
- [Google Chrome](https://www.google.com/chrome/) - Web browser from Google
- [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/) - Firefox browser with developer tools
- [Itsycal](https://www.mowglii.com/itsycal/) - Simple menu bar calendar
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
- [Slack](https://slack.com/) - Team communication and collaboration platform
- [Telegram](https://telegram.org/) - Cloud-based messaging app

## Utility Applications

- [BetterDisplay](https://github.com/waydabber/BetterDisplay) - Advanced display management for MacOS
- [LocalSend](https://localsend.org/) - Open source file sharing across devices
- [Ice](https://github.com/jordanbaird/Ice) - Menu bar application for managing menu bar items
- [Mounty](https://mounty.app/) - Re-mounts write-protected NTFS volumes in read-write mode
- [SaneSideButtons](https://github.com/thealpa/SaneSideButtons) - Fix mouse side buttons for MacOS
- [Stats](https://github.com/exelban/stats) - System monitor in your menu bar
- [QLVideo](https://github.com/Marginal/QLVideo) - QuickLook Finder plugin for video files
- [The Unarchiver](https://theunarchiver.com/) - Data compression and archive tool
- [TRex](https://github.com/amebalabs/TRex) - Easy-to-use text extraction tool

# Tools Included

These are tools that are installed via `brew bundle --file=homebrew/Brewfile`

## Development Tools
- [awk](https://www.gnu.org/software/gawk/) - Pattern scanning and text processing language
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) - Better git diff output
- [difftastic](https://github.com/Wilfred/difftastic) - Structural diff tool that understands syntax
- [fx](https://github.com/antonmedv/fx) - Terminal JSON viewer and processor
- [git](https://git-scm.com/) - Distributed version control system
- [git-delta](https://github.com/dandavison/delta) - Syntax-highlighting pager for git
- [jq](https://stedolan.github.io/jq/) - Lightweight command-line JSON processor
- [mise](https://github.com/jdx/mise) - Development environment manager
- [overmind](https://github.com/DarthSim/overmind) - Process manager for Procfile-based applications
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Extremely fast text search tool
- [scmpuff](https://github.com/mroth/scmpuff) - Numeric shortcuts for common git commands
- [sqlite](https://www.sqlite.org/) - Self-contained, serverless SQL database engine
- [tig](https://jonas.github.io/tig/) - Text-mode interface for Git

## Utilities
- [aria2](https://aria2.github.io/) - Lightweight multi-protocol download utility
- [bat](https://github.com/sharkdp/bat) - Cat clone with syntax highlighting
- [brew-cask-upgrade](https://github.com/buo/brew-cask-upgrade) - Command line tool for upgrading outdated Homebrew Casks

- [broot](https://github.com/Canop/broot) - Better way to navigate directories
- [eza](https://github.com/eza-community/eza) - Modern replacement for ls
- [fd](https://github.com/sharkdp/fd) - Simple, fast and user-friendly alternative to find
- [ffmpeg](https://ffmpeg.org/) - Complete solution for recording, converting, and streaming audio/video
- [fzf](https://github.com/junegunn/fzf) - Command-line fuzzy finder
- [htop-osx](https://htop.dev/) - Interactive process viewer for Unix systems
- [mas](https://github.com/mas-cli/mas) - Mac App Store command line interface

- [ncdu](https://dev.yorhel.nl/ncdu) - NCurses disk usage analyzer
- [stow](https://www.gnu.org/software/stow/) - Symlink farm manager
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) - Send macOS notifications from the terminal
- [tmate](https://tmate.io/) - Instant terminal sharing
- [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load) - CPU, RAM memory, and load monitor for tmux
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [tree](https://mama.indstate.edu/users/ice/tree/) - Directory listing in tree format
- [wget](https://www.gnu.org/software/wget/) - Internet file retriever
- [zsh](https://www.zsh.org/) - Extended Bourne shell with many improvements

## Desktop Managers
- [skhd](https://github.com/koekeishiya/skhd) - Simple hotkey daemon for macOS
- [yabai](https://github.com/koekeishiya/yabai) - Tiling window manager for macOS
