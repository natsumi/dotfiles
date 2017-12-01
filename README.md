
# Table of Contents

1.  [OS X Options](#org9599ace)
    1.  [Hostname](#orgfa71e11)
    2.  [File Dialogs](#org65f273a)
    3.  [Mouse](#org0d4e692)
    4.  [Keyboard](#org3c83d7c)
2.  [Software](#orgf7f6a1d)
    1.  [Xcode](#org487ee45)
    2.  [Homebrew](#org17d430d)
    3.  [Git](#org669b44a)
    4.  [Github](#org029b529)
        1.  [Generate ssh key](#org503da8d)
        2.  [Spacemacs Github Integration](#orgf3209fb)
    5.  [Dotfile Setup](#org274564d)
    6.  [ZSH Setup](#org48b8d62)
        1.  [Set Default Shell](#org3628394)
        2.  [Prezto](#org675d800)
        3.  [Setup Symlinks](#org3be8330)
        4.  [Custom configurations](#org93d3c80)
        5.  [Restart your terminal](#org66dffba)
    7.  [Ruby](#org011f325)
        1.  [Rbenv](#org5e98861)
        2.  [Symlink](#orgc5f9c73)
        3.  [Linters / Dev gems](#org7f6bb4d)
        4.  [Restart your terminal here](#org6d912f1)
    8.  [Fonts](#org4066bfe)
    9.  [Brew Bundle](#org1a64a72)
    10. [Python](#org9b526bb)
    11. [Elixir](#org9b9db25)
    12. [Node](#org31591de)
        1.  [Node Version Manager](#org30707eb)
        2.  [Bower](#org46b503d)
        3.  [React Generator](#orgb8f5b23)
        4.  [Yarn](#org648846d)
        5.  [Linters](#orgc413089)
    13. [Vim](#org0171958)
        1.  [Prerequiste](#org72fd54a)
        2.  [Symlinks](#org18cf580)
        3.  [Plugin Installs](#org1f2085e)
    14. [SpaceMacs](#orgf4f50a7)
        1.  [Markdown Support](#org73ec50d)
    15. [Tmux](#org00d8f06)
        1.  [Install Plugins](#org53114ee)
    16. [Tig](#orgae1d077)
    17. [Silver Searcher](#org1cd94e8)
    18. [Youtube-dl](#org79ce3d7)
    19. [Livestream](#orgb78ad57)
    20. [KWM / KHD (Tilling Window Manager)](#orgf15ba1e)


<a id="org9599ace"></a>

# OS X Options


<a id="orgfa71e11"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="org65f273a"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="org0d4e692"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="org3c83d7c"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="orgf7f6a1d"></a>

# Software


<a id="org487ee45"></a>

## Xcode

    xcode-select --install


<a id="org17d430d"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="org669b44a"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="org029b529"></a>

## Github


<a id="org503da8d"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="orgf3209fb"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="org274564d"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/path/to/dotfile
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="org48b8d62"></a>

## ZSH Setup


<a id="org3628394"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="org675d800"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"


<a id="org3be8330"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/path/to/dotfile
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org93d3c80"></a>

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`


<a id="org66dffba"></a>

### Restart your terminal


<a id="org011f325"></a>

## Ruby


<a id="org5e98861"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.4.1
    rbenv local 2.4.1
    rbenv global 2.4.1
    gem install bundle
    rbenv rehash


<a id="orgc5f9c73"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="org7f6bb4d"></a>

### Linters / Dev gems

    gem install pry pry-doc pry-bloodline ruby_parser rufo rubocop scss_lint scss_lint_reporter_checkstyle


<a id="org6d912f1"></a>

### Restart your terminal here


<a id="org4066bfe"></a>

## Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)


<a id="org1a64a72"></a>

## Brew Bundle

    brew bundle


<a id="org9b526bb"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org9b9db25"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs
    mix local.hex
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez


<a id="org31591de"></a>

## Node


<a id="org30707eb"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="org46b503d"></a>

### Bower

    npm install -g bower


<a id="orgb8f5b23"></a>

### React Generator

    npm install -g create-react-app


<a id="org648846d"></a>

### Yarn

    npm install -g yarn


<a id="orgc413089"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint eslint-plugin-react
    npm install -g prettier
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    ln -s $DOTFILE_DIR/prettierrc.symlink ~/.prettierrc


<a id="org0171958"></a>

## Vim


<a id="org72fd54a"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="org18cf580"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="org1f2085e"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="orgf4f50a7"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="org73ec50d"></a>

### Markdown Support

    npm install -g vmd


<a id="org00d8f06"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="org53114ee"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="orgae1d077"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="org1cd94e8"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="org79ce3d7"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="orgb78ad57"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="orgf15ba1e"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Keyboard Hot Keys](https://github.com/koekeishiya/khd)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

