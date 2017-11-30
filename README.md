
# Table of Contents

1.  [OS X Options](#org34a7611)
    1.  [Hostname](#org905b898)
    2.  [File Dialogs](#org9d6d08e)
    3.  [Mouse](#org5f05ae8)
    4.  [Keyboard](#orgcc32ea0)
2.  [Software](#org1de0e92)
    1.  [Xcode](#org4f8609e)
    2.  [Homebrew](#org1b5df95)
    3.  [Git](#orgd850b23)
    4.  [Github](#org6e6049d)
        1.  [Generate ssh key](#org505ccaf)
        2.  [Spacemacs Github Integration](#orgc9f20fa)
    5.  [Dotfile Setup](#orgbc3c58e)
    6.  [ZSH Setup](#orgc9d6e23)
        1.  [Set Default Shell](#orge84f034)
        2.  [Prezto](#orgf2661b2)
        3.  [Setup Symlinks](#orgc07843e)
        4.  [Custom configurations](#org99fcad9)
        5.  [Restart your terminal](#orgf379e01)
    7.  [Ruby](#org7c1ba6d)
        1.  [Rbenv](#orga532da9)
        2.  [Symlink](#org86dabc3)
        3.  [Linters / Dev gems](#orgadca88e)
        4.  [Restart your terminal here](#org811dc58)
    8.  [Fonts](#orgf7abae9)
    9.  [Brew Bundle](#org9d36d97)
    10. [Python](#orga89e521)
    11. [Elixir](#org1a5fb61)
    12. [Node](#org7b0e825)
        1.  [Node Version Manager](#org684932f)
        2.  [Bower](#orgd439cd0)
        3.  [React Generator](#org92b2d19)
        4.  [Yarn](#org49e9761)
        5.  [Linters](#org4461d8c)
    13. [Vim](#orga9ac809)
        1.  [Prerequiste](#orgd7cfc39)
        2.  [Symlinks](#orge033627)
        3.  [Plugin Installs](#orgfacc505)
    14. [SpaceMacs](#org8419bf3)
        1.  [Markdown Support](#org74e70ad)
    15. [Tmux](#org4c38f7e)
        1.  [Install Plugins](#org51b5079)
    16. [Tig](#orgace7844)
    17. [Silver Searcher](#orgecb5514)
    18. [Youtube-dl](#org89620c6)
    19. [Livestream](#orgde10ce1)
    20. [KWM / KHD (Tilling Window Manager)](#org84d3af3)


<a id="org34a7611"></a>

# OS X Options


<a id="org905b898"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="org9d6d08e"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="org5f05ae8"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="orgcc32ea0"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="org1de0e92"></a>

# Software


<a id="org4f8609e"></a>

## Xcode

    xcode-select --install


<a id="org1b5df95"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="orgd850b23"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="org6e6049d"></a>

## Github


<a id="org505ccaf"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="orgc9f20fa"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="orgbc3c58e"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/path/to/dotfile
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="orgc9d6e23"></a>

## ZSH Setup


<a id="orge84f034"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="orgf2661b2"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"


<a id="orgc07843e"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/path/to/dotfile
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org99fcad9"></a>

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`


<a id="orgf379e01"></a>

### Restart your terminal


<a id="org7c1ba6d"></a>

## Ruby


<a id="orga532da9"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.4.1
    rbenv local 2.4.1
    rbenv global 2.4.1
    gem install bundle
    rbenv rehash


<a id="org86dabc3"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="orgadca88e"></a>

### Linters / Dev gems

    gem install pry pry-doc pry-bloodline ruby_parser rufo rubocop scss_lint scss_lint_reporter_checkstyle


<a id="org811dc58"></a>

### Restart your terminal here


<a id="orgf7abae9"></a>

## Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)


<a id="org9d36d97"></a>

## Brew Bundle

    brew bundle


<a id="orga89e521"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org1a5fb61"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs
    mix local.hex
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez


<a id="org7b0e825"></a>

## Node


<a id="org684932f"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="orgd439cd0"></a>

### Bower

    npm install -g bower


<a id="org92b2d19"></a>

### React Generator

    npm install -g create-react-app


<a id="org49e9761"></a>

### Yarn

    npm install -g yarn


<a id="org4461d8c"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint
    npm install -g prettier
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    ln -s $DOTFILE_DIR/prettierrc.symlink ~/.prettierrc


<a id="orga9ac809"></a>

## Vim


<a id="orgd7cfc39"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="orge033627"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="orgfacc505"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="org8419bf3"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="org74e70ad"></a>

### Markdown Support

    npm install -g vmd


<a id="org4c38f7e"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="org51b5079"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="orgace7844"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="orgecb5514"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="org89620c6"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="orgde10ce1"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="org84d3af3"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Keyboard Hot Keys](https://github.com/koekeishiya/khd)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

