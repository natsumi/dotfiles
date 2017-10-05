
# Table of Contents

1.  [OS X Options](#org420aab6)
    1.  [Hostname](#org27b9797)
    2.  [File Dialogs](#org8b14a71)
    3.  [Mouse](#orge75b569)
    4.  [Keyboard](#org4f4a6d9)
2.  [Software](#orgf360eeb)
    1.  [Xcode](#orgfa2e38a)
    2.  [Homebrew](#org81bce58)
    3.  [Git](#orgb34feec)
    4.  [Github](#orgff7d147)
        1.  [Generate ssh key](#org8834b14)
        2.  [Spacemacs Github Integration](#org4c04a23)
    5.  [Dotfile Setup](#org612b0cf)
    6.  [ZSH Setup](#org4581117)
        1.  [Set Default Shell](#orgf458fb9)
        2.  [Prezto](#org985f30d)
        3.  [Setup Symlinks](#org8a3f801)
        4.  [Custom configurations](#org9b56880)
        5.  [Restart your terminal](#orgcddef6a)
    7.  [Ruby](#orgdc29b04)
        1.  [Rbenv](#org98536dd)
        2.  [Symlink](#orgc43a8c8)
        3.  [Linters](#org2a93063)
        4.  [Restart your terminal here](#org0bb1c8d)
    8.  [Fonts](#org43728ba)
    9.  [Brew Bundle](#orga859ab9)
    10. [Python](#org7637fac)
    11. [Elixir](#org282369b)
    12. [Node](#org2d6a658)
        1.  [Node Version Manager](#orge8d98c8)
        2.  [Bower](#org0965cf3)
        3.  [React Generator](#orge49db18)
        4.  [Yarn](#org56e4f02)
        5.  [Linters](#orgf7b314e)
    13. [Vim](#org2747a8a)
        1.  [Prerequiste](#org3bf3b90)
        2.  [Symlinks](#org3474f84)
        3.  [Plugin Installs](#orgebc93c3)
    14. [SpaceMacs](#org87edb39)
        1.  [Markdown Support](#orge775c8d)
    15. [Tmux](#orgeddfb02)
        1.  [Install Plugins](#orgcb6f7aa)
    16. [Tig](#org2783f58)
    17. [Silver Searcher](#org062b9dd)
    18. [Youtube-dl](#org71fd999)
    19. [Livestream](#orgfa37396)
    20. [KWM / KHD (Tilling Window Manager)](#orgb6f7fea)


<a id="org420aab6"></a>

# OS X Options


<a id="org27b9797"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="org8b14a71"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="orge75b569"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="org4f4a6d9"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="orgf360eeb"></a>

# Software


<a id="orgfa2e38a"></a>

## Xcode

    xcode-select --install


<a id="org81bce58"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="orgb34feec"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="orgff7d147"></a>

## Github


<a id="org8834b14"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="org4c04a23"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="org612b0cf"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/path/to/dotfile
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="org4581117"></a>

## ZSH Setup


<a id="orgf458fb9"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="org985f30d"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"


<a id="org8a3f801"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/path/to/dotfile
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org9b56880"></a>

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`


<a id="orgcddef6a"></a>

### Restart your terminal


<a id="orgdc29b04"></a>

## Ruby


<a id="org98536dd"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.4.1
    rbenv local 2.4.1
    rbenv global 2.4.1
    gem install bundle
    rbenv rehash


<a id="orgc43a8c8"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="org2a93063"></a>

### Linters

    gem install rufo rubocop scss_lint scss_lint_reporter_checkstyle


<a id="org0bb1c8d"></a>

### Restart your terminal here


<a id="org43728ba"></a>

## Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)


<a id="orga859ab9"></a>

## Brew Bundle

    brew bundle


<a id="org7637fac"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org282369b"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs


<a id="org2d6a658"></a>

## Node


<a id="orge8d98c8"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="org0965cf3"></a>

### Bower

    npm install -g bower


<a id="orge49db18"></a>

### React Generator

    npm install -g create-react-app


<a id="org56e4f02"></a>

### Yarn

    npm install -g yarn


<a id="orgf7b314e"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint
    
    export PKG=eslint-config-airbnb;
    npm info "$PKG@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install -g "$PKG@latest"
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    
    yarn global add prettier


<a id="org2747a8a"></a>

## Vim


<a id="org3bf3b90"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="org3474f84"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="orgebc93c3"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="org87edb39"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="orge775c8d"></a>

### Markdown Support

    npm install -g vmd


<a id="orgeddfb02"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="orgcb6f7aa"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="org2783f58"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="org062b9dd"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="org71fd999"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="orgfa37396"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="orgb6f7fea"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Keyboard Hot Keys](https://github.com/koekeishiya/khd)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

