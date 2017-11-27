
# Table of Contents

1.  [OS X Options](#org20ae46a)
    1.  [Hostname](#orge822f5c)
    2.  [File Dialogs](#orgc6ba064)
    3.  [Mouse](#org07f8f82)
    4.  [Keyboard](#org88d8346)
2.  [Software](#orgfb0e3d0)
    1.  [Xcode](#org23e8e02)
    2.  [Homebrew](#orge9005a4)
    3.  [Git](#orge700207)
    4.  [Github](#org9f031f0)
        1.  [Generate ssh key](#orge71375f)
        2.  [Spacemacs Github Integration](#orgd193db8)
    5.  [Dotfile Setup](#orgbe8c736)
    6.  [ZSH Setup](#orgfa9655b)
        1.  [Set Default Shell](#org882c1d1)
        2.  [Prezto](#org471b2c0)
        3.  [Setup Symlinks](#org4ede2de)
        4.  [Custom configurations](#org6aba8f8)
        5.  [Restart your terminal](#org2fc0c75)
    7.  [Ruby](#org4335e8c)
        1.  [Rbenv](#org7d18193)
        2.  [Symlink](#org3ee2f53)
        3.  [Linters / Dev gems](#org807a576)
        4.  [Restart your terminal here](#org09ff8c8)
    8.  [Fonts](#orgdfb0008)
    9.  [Brew Bundle](#org275b0ff)
    10. [Python](#orgac37ccb)
    11. [Elixir](#org8d397a6)
    12. [Node](#orge297dd0)
        1.  [Node Version Manager](#orgbbb0932)
        2.  [Bower](#org8d743c7)
        3.  [React Generator](#orgd152c8d)
        4.  [Yarn](#org254ec4f)
        5.  [Linters](#org7806e1a)
    13. [Vim](#org1026e79)
        1.  [Prerequiste](#orgbd1fe28)
        2.  [Symlinks](#org0ebe184)
        3.  [Plugin Installs](#org0d643ec)
    14. [SpaceMacs](#org392f7f8)
        1.  [Markdown Support](#org39262d4)
    15. [Tmux](#org864cacc)
        1.  [Install Plugins](#orgb0c460b)
    16. [Tig](#orgeaba7c0)
    17. [Silver Searcher](#org85ea0fb)
    18. [Youtube-dl](#org30fae41)
    19. [Livestream](#orgc4c2224)
    20. [KWM / KHD (Tilling Window Manager)](#orgc21cb4b)


<a id="org20ae46a"></a>

# OS X Options


<a id="orge822f5c"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="orgc6ba064"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="org07f8f82"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="org88d8346"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="orgfb0e3d0"></a>

# Software


<a id="org23e8e02"></a>

## Xcode

    xcode-select --install


<a id="orge9005a4"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="orge700207"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="org9f031f0"></a>

## Github


<a id="orge71375f"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="orgd193db8"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="orgbe8c736"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/path/to/dotfile
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="orgfa9655b"></a>

## ZSH Setup


<a id="org882c1d1"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="org471b2c0"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"


<a id="org4ede2de"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/path/to/dotfile
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org6aba8f8"></a>

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`


<a id="org2fc0c75"></a>

### Restart your terminal


<a id="org4335e8c"></a>

## Ruby


<a id="org7d18193"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.4.1
    rbenv local 2.4.1
    rbenv global 2.4.1
    gem install bundle
    rbenv rehash


<a id="org3ee2f53"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="org807a576"></a>

### Linters / Dev gems

    gem install pry pry-doc pry-bloodline ruby_parser rufo rubocop scss_lint scss_lint_reporter_checkstyle


<a id="org09ff8c8"></a>

### Restart your terminal here


<a id="orgdfb0008"></a>

## Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)


<a id="org275b0ff"></a>

## Brew Bundle

    brew bundle


<a id="orgac37ccb"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org8d397a6"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs
    mix local.hex
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez


<a id="orge297dd0"></a>

## Node


<a id="orgbbb0932"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="org8d743c7"></a>

### Bower

    npm install -g bower


<a id="orgd152c8d"></a>

### React Generator

    npm install -g create-react-app


<a id="org254ec4f"></a>

### Yarn

    npm install -g yarn


<a id="org7806e1a"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint
    
    export PKG=eslint-config-airbnb;
    npm info "$PKG@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install -g "$PKG@latest"
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    
    npm install -g prettier


<a id="org1026e79"></a>

## Vim


<a id="orgbd1fe28"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="org0ebe184"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="org0d643ec"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="org392f7f8"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="org39262d4"></a>

### Markdown Support

    npm install -g vmd


<a id="org864cacc"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="orgb0c460b"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="orgeaba7c0"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="org85ea0fb"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="org30fae41"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="orgc4c2224"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="orgc21cb4b"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Keyboard Hot Keys](https://github.com/koekeishiya/khd)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

