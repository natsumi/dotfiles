# Software Prerequiste

## Xcode

``` bash
xcode-select --install
```

## Homebrew

[Brew](http://brew.sh/)

## Git

``` bash
brew install git
sh bin/apply_git_settings
```

# Usage

## Apply Basic System Settings

``` bash
sh bin/apply_basic_settings
```

## Apply System Defaults

``` bash
sh bin/apply_default_settings
```

## Install Desktop Applications

``` bash
sh bin/install_homebrew_casks
```

## Install Brew base packages

``` bash
brew bundle --file=~/dev/dotfiles/homebrew/Brewfile
```

# Software Configuration

## Apply Software Symlink

``` bash
sh bin/apply_symlinks
```

## ZSH Setup

### Set Default Shell

``` bash
echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
chsh -s $(which zsh)
```

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

``` bash
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
git clone --recursive https://github.com/belak/prezto-contrib  "${ZDOTDIR:-$HOME}/.zprezto/contrib"
```

### Zplug

[Zplug](https://github.com/zplug/zplug)

``` bash
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`

### Spacemacs Github Integration

Grant access to repo and gist [Set Access
Tokens](https://github.com/settings/tokens)

``` bash
git config --global github.oauth-token <token>
```

## Programming Dev setup

### Fonts

```bash
sh bin/install_fonts
```

### asdf

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.5

```

Restart Shell

``` shell
sh bin/install_dev_env
```

### Alfred Integration

``` shell
ln -s $(which node) /usr/local/bin/node
```

## Editors

```bash
brew install vim neovim
```

## SpaceMacs

``` bash
mkdir -p ~/.spacemacs.d
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
stow -v --target=$HOME/.spacemacs.d --dir=$DOTFILE_DIR spacemacs
stow -v --target=$HOME --dir=$DOTFILE_DIR gtags
```

User develop branch

``` bash
cd ~/.emacs.d
git fetch
git checkout develop
git pull
```

### Gtag

[Download Global](https://www.gnu.org/software/global/download.html)

``` bash
tar xvzf <filenamee>
cd <global_dir>
./configure --with-universal-ctags=/usr/local/bin/ctags --with-sqlite3
./make install
```

### Markdown Support

``` bash
npm install -g vmd
```

## Tmux

    mkdir -p ~/.tmux/plugins

### Install Plugins

run tmux ctrl-s shift-i

## Livestream

Configure Twitch Oauth

``` bash
livestreamer --twitch-oauth-authenticate
```

Copy the access<sub>token</sub> in URL to \~/.livestreamerrc

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Simple Keyboard Hot Keys](https://github.com/koekeishiya/skhd)

``` bash
stow -v --target=$HOME --dir=$DOTFILE_DIR chunkwmrc
```

# Post Install Settings

## OS X Options

### Fonts

```bash
sh bin/install_fonts
```

### Deprecated
[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)

### Mouse

Set mouse to a faster track speed

Uncheck "Scroll direction: Natural"

## iTerm 2

Font: Fira Mono 12pt / Iosevka Term Slab [Night Owl
Theme](https://github.com/jsit/night-owl-iterm2-theme)
