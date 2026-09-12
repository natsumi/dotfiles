My very opinionated configuration and setup for new and existing Macs and Linux boxes.

Machine setup is declarative, driven by [mise bootstrap](https://mise.jdx.dev/bootstrap.html):

| File | Loaded | Declares |
|---|---|---|
| `mise.toml` | always | git repos (prezto), `[dotfiles]` symlinks, login shell, git identity prompt |
| `mise.linux.toml` | on Linux, automatically (`auto_env` in `.miserc.toml`) | apt packages, SSH hardening, firewall, fail2ban, unattended upgrades, sysctl, swap |
| `mise.macos.toml` | on macOS, automatically | brew packages, casks, fonts, macOS defaults |
| `mise.docker.toml` | `mise -E docker` | Docker Engine (Linux) |
| `mise/.config/mise/config.toml` | symlinked to `~/.config/mise/config.toml` | languages and cross-platform CLI tools (`[tools]`) |

Sources for the Linux system files live under `linux/etc/`, mirroring their
target paths.

## Setup a new Mac

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/bin/bootstrap.sh)"
```

The script installs only what mise cannot install for itself - the Xcode
command line tools and mise via <https://mise.run> - clones this repo to
`~/dev/dotfiles`, then runs `mise bootstrap --yes`. Any extra arguments are
passed straight through, so `bootstrap.sh --dry-run` previews the whole thing.

`mise bootstrap` then runs these phases in order:

1. **Packages** - `brew:` / `brew-cask:` from `mise.macos.toml`. macOS is
   Homebrew-free: mise's built-in brew manager pours bottles and casks into
   `/opt/homebrew` without Homebrew being installed.
2. **Repos** - prezto and prezto-contrib are cloned into `~`, then a
   `post-repos` hook initialises prezto's submodules.
3. **Dotfiles** - every symlink in the `[dotfiles]` section of `mise.toml`, plus
   the managed block in `~/.gitconfig`.
4. **macOS defaults** - the `[bootstrap.macos.*]` preferences, followed by a
   `post-defaults` hook that restarts Dock, Finder and SystemUIServer.
5. **Login shell** - `chsh -s /bin/zsh`.
6. **Tools** - `[tools]` from the global mise config.
7. **Bootstrap task** - prompts for the git identity if this machine has none.
8. **Final hook** - `mise install --yes`, which picks up the freshly linked
   global config in a new process.

Open a new shell afterwards so the new login shell, PATH and mise activation
take effect. A few system settings need root and are not managed by mise; run
them by hand once:

```bash
bin/apply_sudo_defaults
```

## Setup a new Linux box (Ubuntu 26.04)

Every Linux box gets the server treatment: SSH on port **2222** with keys only,
a default-deny firewall, fail2ban, unattended security upgrades, kernel
hardening, a swap file and the `America/Los_Angeles` timezone. Only Ubuntu
26.04 is supported.

mise runs as the admin user and uses `sudo` where a step needs it, so a fresh
box that only has `root` needs the user first. In the root session:

```bash
adduser --gecos "" natsumi     # prompts for the password
usermod -aG sudo natsumi
install -d -m 700 -o natsumi -g natsumi /home/natsumi/.ssh
install -m 600 -o natsumi -g natsumi /root/.ssh/authorized_keys /home/natsumi/.ssh/authorized_keys
```

**Keep that root session open.** From a second terminal log in as the user
(still on port 22) and run the same command as on a Mac:

```bash
ssh natsumi@HOST
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/natsumi/dotfiles/main/bin/bootstrap.sh)"
```

`sudo` asks for the password when a step needs it. On top of the shared phases
above, Linux runs these before the repos phase:

1. **Pre-packages hook** - sets the timezone and creates `/swapfile` when the
   box has no swap at all.
2. **Packages** - `apt:` packages from `mise.linux.toml`.
3. **System files** - the sshd drop-in (port 2222, no passwords, root by key
   only), `/etc/issue.net`, the fail2ban jail, the unattended-upgrades
   drop-in and the sysctl hardening. cloud-init's sshd drop-in is removed
   because it re-enables password auth.
4. **Services** - `ssh.socket` is restarted so sshd listens on 2222; fail2ban
   and unattended-upgrades are enabled and running.
5. **Firewall** - ufw with incoming denied and a rate-limited rule for
   2222/tcp only. mise tags its rules and leaves any others alone.

When it finishes:

1. From a third terminal, confirm the new port works:

   ```bash
   ssh -p 2222 natsumi@HOST
   ```

   Only then close the root session. If it does not work, fix it from the
   root session (or the provider's console): `sudo sshd -t` shows config
   errors, `sudo ufw status` the firewall.
2. Reboot if the final hook says a reboot is required: `sudo reboot`.
3. Open a new shell for zsh and mise activation.

### Docker (optional)

```bash
cd ~/dev/dotfiles
mise -E docker bootstrap --update
```

Adds Docker's apt repository (key committed in `linux/etc/apt/keyrings/`),
installs Docker Engine with the compose and buildx plugins, writes
`/etc/docker/daemon.json` and adds you to the `docker` group (log out and back
in for that to take effect). `--update` is needed because mise does not
refresh apt metadata on its own after writing the repository file.

**Docker bypasses ufw.** A published port (`-p 80:80`) is reachable from the
internet regardless of `ufw status`. Bind containers to `127.0.0.1` and put a
reverse proxy on the host in front of them.

### Skipping the root session with cloud-init

Providers that accept user-data can create the admin user at boot, so the box
never arrives root-only and only the bootstrap command is needed:

```yaml
#cloud-config
users:
  - name: natsumi
    groups: [sudo]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-ed25519 AAAA... you@laptop
```

Set a password afterwards with `sudo passwd natsumi` if you want one.

## Day-to-day

Run these from the repo directory (or pass `mise -C ~/dev/dotfiles ...`), since
`mise.toml` is a project config:

```bash
mise bootstrap status                   # everything mise knows about, in one list
mise bootstrap plan                     # what a run would change (needs sudo on Linux)
mise bootstrap --dry-run                # preview the whole workflow
mise bootstrap --only dotfiles          # re-apply just the symlinks
mise bootstrap dotfiles status          # per-entry: applied / missing / differs
mise bootstrap dotfiles diff            # what apply would change
mise bootstrap dotfiles apply           # apply the symlinks and the gitconfig block
mise bootstrap packages status          # which host packages are missing
mise bootstrap packages apply           # install the missing ones
mise bootstrap packages upgrade --manager apt   # upgrade the installed apt packages
mise bootstrap files status             # Linux: /etc drop-ins, applied / update
mise bootstrap services status          # Linux: sshd, fail2ban, unattended-upgrades
mise bootstrap firewall status          # Linux: ufw policy and rules (needs sudo)
mise bootstrap macos defaults status    # macOS preference drift (skipped on Linux)
mise bootstrap --skip tools,task        # setup without touching language versions
```

mise refuses to update a declared repo (`~/.zprezto`, `~/.zprezto/contrib`)
that has local changes. Add `--skip-dirty` (or `--skip repos`) if that ever
happens.

## Adding a new dotfile

1. Put the file under its tool's directory in this repo, mirroring the path it
   has in `$HOME` - e.g. `zsh/.zshrc` for `~/.zshrc`, or
   `helix/.config/helix/config.toml` for `~/.config/helix/config.toml`.
2. Add a `[dotfiles]` entry to `mise.toml`. Sources are relative to the repo
   root.

   A single file:

   ```toml
   [dotfiles]
   "~/.gemrc" = { source = "ruby/.gemrc", mode = "symlink" }
   ```

   A whole directory we own outright:

   ```toml
   [dotfiles]
   "~/.config/helix" = { source = "helix/.config/helix", mode = "symlink" }
   ```

   macOS only:

   ```toml
   [dotfiles."~/.aerospace.toml"]
   source = "aerospace/.aerospace.toml"
   mode = "symlink"
   variants = [{ os = "macos" }]
   ```

   Use `mode = "symlink-each"` (as `~/.claude` does) when the target directory
   also holds files mise should leave alone.
3. Preview and apply:

   ```bash
   mise bootstrap dotfiles apply --dry-run
   mise bootstrap dotfiles apply
   ```

## Adding a package or tool

**Host packages** (native libraries, GUI apps, things with no mise registry
entry) go in the platform file, so no `os` selectors are needed:

```toml
# mise.linux.toml
[bootstrap.packages]
"apt:foo" = "latest"

# mise.macos.toml
[bootstrap.packages]
"brew:foo" = "latest"
"brew-cask:foo" = "latest"
```

Then `mise bootstrap packages apply`.

**Versioned tools** (anything in the mise registry, plus `npm:` / `ubi:`
backends) go in `[tools]` in `mise/.config/mise/config.toml`, then:

```bash
mise install
```

## Adding a Linux system file

1. Put the file under `linux/etc/`, mirroring its target path - e.g.
   `linux/etc/sysctl.d/99-vps-hardening.conf` for
   `/etc/sysctl.d/99-vps-hardening.conf`.
2. Declare it in `mise.linux.toml`, naming the service to restart when it
   changes:

   ```toml
   [bootstrap.files."/etc/fail2ban/jail.d/vps.local"]
   source = "linux/etc/fail2ban/jail.d/vps.local"
   owner = "root"
   group = "root"
   mode = "0644"
   notify = ["fail2ban"]
   ```
3. Preview and apply:

   ```bash
   mise bootstrap files apply --dry-run
   mise bootstrap files apply
   ```

## Migrating an existing machine

mise reads the existing stow symlinks as already applied, so there is very
little to do:

```bash
cd ~/dev/dotfiles
mise trust
mise bootstrap dotfiles apply --dry-run
mise bootstrap dotfiles apply
```

The one thing that conflicts is a pre-existing *real* `~/.config/mise/config.toml`,
since this repo now owns that path. Either move it aside first:

```bash
mv ~/.config/mise/config.toml ~/.config/mise/config.toml.bak
```

or let mise replace it with `mise bootstrap dotfiles apply --force`. Merge
anything machine-specific from the backup into
`mise/.config/mise/config.toml` (or into `~/.config/mise/config.local.toml`).

A Linux box set up by the old `vps/` scripts already has the same `/etc`
drop-ins, so mise adopts them. The one content change is the SSH port moving
to 2222; check `mise bootstrap files status` first, and after the run delete
the old ufw rule for port 22 by hand (`sudo ufw delete allow 22/tcp`).

GNU Stow and the `vps/` scripts are no longer used.

# Desktop Applications

These applications are declared as `brew-cask:` entries in `mise.macos.toml`
and installed by `mise bootstrap packages apply` on macOS.

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
- [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal emulator and multiplexer
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

Cross-platform CLI tools are `[tools]` in the global mise config
(`mise/.config/mise/config.toml`). Everything else - native libraries, build
dependencies and anything without a mise registry entry - is declared in
`[bootstrap.packages]` as `brew:` in `mise.macos.toml` or `apt:` in
`mise.linux.toml`.

## Development Tools
- [awk](https://www.gnu.org/software/gawk/) - Pattern scanning and text processing language
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) - Better git diff output
- [difftastic](https://github.com/Wilfred/difftastic) - Structural diff tool that understands syntax
- [fx](https://github.com/antonmedv/fx) - Terminal JSON viewer and processor
- [gh](https://cli.github.com/) - GitHub CLI
- [git](https://git-scm.com/) - Distributed version control system
- [git-delta](https://github.com/dandavison/delta) - Syntax-highlighting pager for git
- [jq](https://stedolan.github.io/jq/) - Lightweight command-line JSON processor
- [lazydocker](https://github.com/jesseduffield/lazydocker) - Terminal UI for Docker (Linux)
- [mise](https://github.com/jdx/mise) - Development environment manager
- [neovim](https://neovim.io/) - Hyperextensible Vim-based text editor
- [overmind](https://github.com/DarthSim/overmind) - Process manager for Procfile-based applications
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Extremely fast text search tool
- [scmpuff](https://github.com/mroth/scmpuff) - Numeric shortcuts for common git commands
- [sqlite](https://www.sqlite.org/) - Self-contained, serverless SQL database engine
- [tig](https://jonas.github.io/tig/) - Text-mode interface for Git

## Utilities
- [aria2](https://aria2.github.io/) - Lightweight multi-protocol download utility
- [broot](https://github.com/Canop/broot) - Better way to navigate directories
- [btop](https://github.com/aristocratos/btop) - Resource monitor (Linux)
- [croc](https://github.com/schollz/croc) - Easily and securely send things from one computer to another / Magic Wormhole
- [eza](https://github.com/eza-community/eza) - Modern replacement for ls
- [fd](https://github.com/sharkdp/fd) - Simple, fast and user-friendly alternative to find
- [ffmpeg](https://ffmpeg.org/) - Complete solution for recording, converting, and streaming audio/video
- [fzf](https://github.com/junegunn/fzf) - Command-line fuzzy finder
- [htop](https://htop.dev/) - Interactive process viewer for Unix systems
- [mas](https://github.com/mas-cli/mas) - Mac App Store command line interface
- [ncdu](https://dev.yorhel.nl/ncdu) - NCurses disk usage analyzer
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) - Send macOS notifications from the terminal
- [tmate](https://tmate.io/) - Instant terminal sharing
- [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load) - CPU, RAM memory, and load monitor for tmux
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [tree](https://mama.indstate.edu/users/ice/tree/) - Directory listing in tree format
- [wget](https://www.gnu.org/software/wget/) - Internet file retriever
- [zsh](https://www.zsh.org/) - Extended Bourne shell with many improvements

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

| Package             | Description                                                              | Homepage                                                                                 |
| ------------------- | ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| amazing_print       | Pretty print Ruby objects with formatting and colors                     | [github.com/amazing-print/amazing_print](https://github.com/amazing-print/amazing_print) |
| bundler             | Ruby dependency manager and project bootstrapping tool                   | [bundler.io](https://bundler.io/)                                                        |
| debug               | Modern Ruby debugger (stdlib, replaces pry/byebug)                       | [github.com/ruby/debug](https://github.com/ruby/debug)                                   |
| neovim              | Ruby support for Neovim editor                                           | [github.com/alexgenco/neovim-ruby](https://github.com/alexgenco/neovim-ruby)             |
| repl_type_completor | Type-aware autocomplete for IRB (Ruby type analysis vs. regex matching)  | [github.com/ruby/repl_type_completor](https://github.com/ruby/repl_type_completor)       |
| rubocop             | Ruby static code analyzer and formatter                                  | [rubocop.org](https://rubocop.org/)                                                      |
| ruby-lsp            | Language Server Protocol implementation for Ruby                         | [shopify.github.io/ruby-lsp](https://shopify.github.io/ruby-lsp/)                        |
| ruby_parser         | Ruby parser written in Ruby                                              | [github.com/seattlerb/ruby_parser](https://github.com/seattlerb/ruby_parser)             |
| rufo                | Fast Ruby formatter                                                      | [github.com/ruby-formatter/rufo](https://github.com/ruby-formatter/rufo)                 |
| standard            | Ruby style guide, linter, and formatter                                  | [github.com/testdouble/standard](https://github.com/testdouble/standard)                 |

## Go Packages

| Package                  | Description        | Homepage                                                                           |
| ------------------------ | ------------------ | ---------------------------------------------------------------------------------- |
| golang.org/x/tools/gopls | Go language server | [pkg.go.dev/golang.org/x/tools/gopls](https://pkg.go.dev/golang.org/x/tools/gopls) |
