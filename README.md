
# Table of Contents

1.  [OS X Options](#orge650395)
    1.  [Hostname](#org24c1624)
    2.  [File Dialogs](#org27bdf63)
    3.  [Mouse](#org240daa0)
    4.  [Keyboard](#org51d47ff)
2.  [Software](#org65caf3d)
    1.  [Xcode](#org35b3c43)
    2.  [Homebrew](#org16901f4)
    3.  [Git](#orgf630440)
    4.  [Github](#orgde49eb7)
        1.  [Generate ssh key](#org4e46cb8)
        2.  [Spacemacs Github Integration](#org088a686)
    5.  [Dotfile Setup](#org1085e41)
    6.  [ZSH Setup](#org5430a29)
        1.  [Set Default Shell](#org45f63d4)
        2.  [Prezto](#orgf800d70)
        3.  [Setup Symlinks](#org628be8c)
        4.  [Custom configurations](#org2ee6e0a)
        5.  [Restart your terminal](#orgf4c85e9)
    7.  [Ruby](#org138b753)
        1.  [Rbenv](#orgddd028d)
        2.  [Symlink](#org6b87888)
        3.  [Linters / Dev gems](#org321c664)
        4.  [Restart your terminal here](#orgbf6f115)
    8.  [Fonts](#orge886556)
    9.  [Brew Bundle](#org8fb257c)
    10. [Python](#org5d7aaa4)
    11. [Elixir](#org32339fd)
    12. [Node](#org72f7bda)
        1.  [Node Version Manager](#org42bc299)
        2.  [Bower](#orgbb7662a)
        3.  [React Generator](#orge95b8c0)
        4.  [Yarn](#orgf1ac289)
        5.  [Linters](#org111ed2a)
    13. [Vim](#org018e654)
        1.  [Prerequiste](#orge6eb3ab)
        2.  [Symlinks](#org6991386)
        3.  [Plugin Installs](#org085c8eb)
    14. [SpaceMacs](#orgb04efd6)
        1.  [Markdown Support](#orgea1a7ae)
    15. [Tmux](#org73b5584)
        1.  [Install Plugins](#org6f5e4d9)
    16. [Tig](#orgcd9f16c)
    17. [Silver Searcher](#org31cfa50)
    18. [Youtube-dl](#org493a692)
    19. [Livestream](#orgaee4eb5)
    20. [KWM / KHD (Tilling Window Manager)](#org3fab8b9)


<a id="orge650395"></a>

# OS X Options


<a id="org24c1624"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="org27bdf63"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="org240daa0"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="org51d47ff"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="org65caf3d"></a>

# Software


<a id="org35b3c43"></a>

## Xcode

    xcode-select --install


<a id="org16901f4"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="orgf630440"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="orgde49eb7"></a>

## Github


<a id="org4e46cb8"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="org088a686"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="org1085e41"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/path/to/dotfile
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="org5430a29"></a>

## ZSH Setup


<a id="org45f63d4"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="orgf800d70"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"


<a id="org628be8c"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/path/to/dotfile
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org2ee6e0a"></a>

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`


<a id="orgf4c85e9"></a>

### Restart your terminal


<a id="org138b753"></a>

## Ruby


<a id="orgddd028d"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.4.1
    rbenv local 2.4.1
    rbenv global 2.4.1
    gem install bundle
    rbenv rehash


<a id="org6b87888"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="org321c664"></a>

### Linters / Dev gems

    gem install pry pry-doc ruby_parser rufo rubocop scss_lint scss_lint_reporter_checkstyle


<a id="orgbf6f115"></a>

### Restart your terminal here


<a id="orge886556"></a>

## Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)


<a id="org8fb257c"></a>

## Brew Bundle

    brew bundle


<a id="org5d7aaa4"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org32339fd"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs


<a id="org72f7bda"></a>

## Node


<a id="org42bc299"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="orgbb7662a"></a>

### Bower

    npm install -g bower


<a id="orge95b8c0"></a>

### React Generator

    npm install -g create-react-app


<a id="orgf1ac289"></a>

### Yarn

    npm install -g yarn


<a id="org111ed2a"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint
    
    export PKG=eslint-config-airbnb;
    npm info "$PKG@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install -g "$PKG@latest"
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    
    yarn global add prettier


<a id="org018e654"></a>

## Vim


<a id="orge6eb3ab"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="org6991386"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="org085c8eb"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="orgb04efd6"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="orgea1a7ae"></a>

### Markdown Support

    npm install -g vmd


<a id="org73b5584"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="org6f5e4d9"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="orgcd9f16c"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="org31cfa50"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="org493a692"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="orgaee4eb5"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="org3fab8b9"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Keyboard Hot Keys](https://github.com/koekeishiya/khd)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

