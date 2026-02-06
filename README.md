My very opinated configuration and setup scripts for new and existing Macs.

## Setup a new Mac

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/bin/bootstrap.sh)"
```

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
- [Ghostty](https://ghostty.org/) - Fast, feature-rich, GPU-based terminal emulator
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
- [croc](https://github.com/schollz/croc) - Easily and securely send things from one computer to another / Magic Wormhole
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

# Default Language Packages

When setting up a new development environment, mise automatically installs default packages for each programming language. These packages provide essential development tools, language servers, and utilities.

## Node.js Packages

| Package                           | Description                                                          | Homepage                                                                                                                                     |
| --------------------------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| yarn                              | Fast, reliable, and secure dependency management                     | [yarnpkg.com](https://yarnpkg.com/)                                                                                                          |
| bash-language-server              | Language server for Bash                                             | [github.com/bash-lsp/bash-language-server](https://github.com/bash-lsp/bash-language-server)                                                 |
| ast-grep                          | Fast and polyglot tool for code searching, linting, rewriting        | [ast-grep.github.io](https://ast-grep.github.io/)                                                                                            |
| dockerfile-language-server-nodejs | Language server for Dockerfile                                       | [github.com/rcjsuen/dockerfile-language-server-nodejs](https://github.com/rcjsuen/dockerfile-language-server-nodejs)                         |
| @fsouza/prettierd                 | Prettier daemon for faster formatting                                | [github.com/fsouza/prettierd](https://github.com/fsouza/prettierd)                                                                           |
| @tailwindcss/language-server      | Tailwind CSS Language Server                                         | [github.com/tailwindlabs/tailwindcss-intellisense](https://github.com/tailwindlabs/tailwindcss-intellisense)                                 |
| typescript-language-server        | Language Server Protocol implementation for TypeScript               | [github.com/typescript-language-server/typescript-language-server](https://github.com/typescript-language-server/typescript-language-server) |
| vscode-langservers-extracted      | Language servers extracted from VS Code                              | [github.com/hrsh7th/vscode-langservers-extracted](https://github.com/hrsh7th/vscode-langservers-extracted)                                   |
| yaml-language-server              | Language Server for YAML Files                                       | [github.com/redhat-developer/yaml-language-server](https://github.com/redhat-developer/yaml-language-server)                                 |
| prettier                          | Opinionated code formatter                                           | [prettier.io](https://prettier.io/)                                                                                                          |
| standard                          | JavaScript Standard Style                                            | [standardjs.com](https://standardjs.com/)                                                                                                    |
| typescript                        | TypeScript language compiler                                         | [typescriptlang.org](https://www.typescriptlang.org/)                                                                                        |
| tern                              | Standalone code-analysis engine for JavaScript                       | [ternjs.net](https://ternjs.net/)                                                                                                            |
| js-beautify                       | Beautifier for JavaScript, HTML, CSS                                 | [github.com/beautifier/js-beautify](https://github.com/beautifier/js-beautify)                                                               |
| eslint                            | Pluggable JavaScript linter                                          | [eslint.org](https://eslint.org/)                                                                                                            |
| stylelint                         | Modern linter that helps avoid errors and enforce conventions in CSS | [stylelint.io](https://stylelint.io/)                                                                                                        |
| stylelint-scss                    | Collection of stylelint rules for SCSS syntax                        | [github.com/kristerkari/stylelint-scss](https://github.com/kristerkari/stylelint-scss)                                                       |
| stylelint-config-recommended-scss | Recommended shareable SCSS config for stylelint                      | [github.com/kristerkari/stylelint-config-recommended-scss](https://github.com/kristerkari/stylelint-config-recommended-scss)                 |
| fkill                             | Fabulously kill processes                                            | [github.com/sindresorhus/fkill](https://github.com/sindresorhus/fkill)                                                                       |
| fkill-cli                         | Interactive process killer for the command line                      | [github.com/sindresorhus/fkill-cli](https://github.com/sindresorhus/fkill-cli)                                                               |
| neovim                            | Neovim Node.js client and plugin host                                | [github.com/neovim/node-client](https://github.com/neovim/node-client)                                                                       |
| tmux-mem                          | Memory usage monitor for tmux status bar                             | [github.com/zaiste/tmuxinator](https://github.com/zaiste/tmuxinator)                                                                         |
| tmux-cpu                          | CPU usage monitor for tmux status bar                                | [github.com/tmux-plugins/tmux-cpu](https://github.com/tmux-plugins/tmux-cpu)                                                                 |

## Python Packages

| Package           | Description                                      | Homepage                                                                                   |
| ----------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| flake8            | Python tool for style guide enforcement          | [flake8.pycqa.org](https://flake8.pycqa.org/)                                              |
| powerline-status  | Statusline plugin for vim, zsh, bash, tmux       | [powerline.readthedocs.io](https://powerline.readthedocs.io/)                              |
| pygments          | Python syntax highlighter                        | [pygments.org](https://pygments.org/)                                                      |
| pylint            | Python static code analysis tool                 | [pylint.pycqa.org](https://pylint.pycqa.org/)                                              |
| pynvim            | Python client and plugin host for Neovim         | [github.com/neovim/pynvim](https://github.com/neovim/pynvim)                               |
| pyright           | Static type checker for Python                   | [github.com/microsoft/pyright](https://github.com/microsoft/pyright)                       |
| python-lsp-black  | Black plugin for python-lsp-server               | [github.com/python-lsp/python-lsp-black](https://github.com/python-lsp/python-lsp-black)   |
| python-lsp-server | Python Language Server Protocol implementation   | [github.com/python-lsp/python-lsp-server](https://github.com/python-lsp/python-lsp-server) |
| streamlink        | CLI for extracting streams from various websites | [streamlink.github.io](https://streamlink.github.io/)                                      |
| yt-dlp            | Feature-rich command-line audio/video downloader | [github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)                               |

## Ruby Gems

| Package               | Description                                            | Homepage                                                                                               |
| --------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| amazing_print         | Pretty print Ruby objects with formatting and colors   | [github.com/amazing-print/amazing_print](https://github.com/amazing-print/amazing_print)               |
| bundler               | Ruby dependency manager and project bootstrapping tool | [bundler.io](https://bundler.io/)                                                                      |
| byebug                | Debugger for Ruby                                      | [github.com/deivid-rodriguez/byebug](https://github.com/deivid-rodriguez/byebug)                       |
| debug                 | Modern Ruby debugger                                   | [github.com/ruby/debug](https://github.com/ruby/debug)                                                 |
| fastri                | Fast Ruby Interface tool for ri documentation          | [github.com/rdp/fastri](https://github.com/rdp/fastri)                                                 |
| neovim                | Ruby support for Neovim editor                         | [github.com/alexgenco/neovim-ruby](https://github.com/alexgenco/neovim-ruby)                           |
| pry                   | Interactive REPL for Ruby                              | [pryrepl.org](https://pryrepl.org/)                                                                    |
| pry-byebug            | Adds debugging commands to pry                         | [github.com/deivid-rodriguez/pry-byebug](https://github.com/deivid-rodriguez/pry-byebug)               |
| pry-clipboard         | Adds clipboard integration to pry                      | [github.com/hotchpotch/pry-clipboard](https://github.com/hotchpotch/pry-clipboard)                     |
| pry-doc               | Adds documentation support to pry                      | [github.com/pry/pry-doc](https://github.com/pry/pry-doc)                                               |
| pry-macro             | Adds macro capabilities to pry                         | [github.com/baweaver/pry-macro](https://github.com/baweaver/pry-macro)                                 |
| pry-stack_explorer    | Browse call-stack in pry sessions                      | [github.com/pry/pry-stack_explorer](https://github.com/pry/pry-stack_explorer)                         |
| pry-state             | Shows variable states in pry sessions                  | [github.com/SudhagarS/pry-state](https://github.com/SudhagarS/pry-state)                               |
| pry-toys              | Collection of fun pry commands                         | [github.com/ariabov/pry-toys](https://github.com/ariabov/pry-toys)                                     |
| rb-readline           | Pure Ruby readline implementation                      | [github.com/ConnorAtherton/rb-readline](https://github.com/ConnorAtherton/rb-readline)                 |
| rcodetools            | Collection of Ruby development tools                   | [github.com/seattlerb/rcodetools](https://github.com/seattlerb/rcodetools)                             |
| rubocop               | Ruby static code analyzer and formatter                | [rubocop.org](https://rubocop.org/)                                                                    |
| ruby-debug-ide        | Ruby debugger IDE protocol implementation              | [github.com/ruby-debug/ruby-debug-ide](https://github.com/ruby-debug/ruby-debug-ide)                   |
| ruby_parser           | Ruby parser written in Ruby                            | [github.com/seattlerb/ruby_parser](https://github.com/seattlerb/ruby_parser)                           |
| ruby-lsp              | Language Server Protocol implementation for Ruby       | [shopify.github.io/ruby-lsp](https://shopify.github.io/ruby-lsp/)                                      |
| rufo                  | Fast Ruby formatter                                    | [github.com/ruby-formatter/rufo](https://github.com/ruby-formatter/rufo)                               |
| solargraph            | Ruby code completion and documentation tool            | [solargraph.org](https://solargraph.org/)                                                              |
| solargraph-rails      | Rails integration for Solargraph                       | [github.com/iftheshoefitsteal/solargraph-rails](https://github.com/iftheshoefitsteal/solargraph-rails) |
| solargraph-standardrb | StandardRB integration for Solargraph                  | [github.com/testdouble/solargraph-standardrb](https://github.com/testdouble/solargraph-standardrb)     |
| standard              | Ruby style guide, linter, and formatter                | [github.com/testdouble/standard](https://github.com/testdouble/standard)                               |

## Go Packages

| Package                  | Description        | Homepage                                                                           |
| ------------------------ | ------------------ | ---------------------------------------------------------------------------------- |
| golang.org/x/tools/gopls | Go language server | [pkg.go.dev/golang.org/x/tools/gopls](https://pkg.go.dev/golang.org/x/tools/gopls) |
