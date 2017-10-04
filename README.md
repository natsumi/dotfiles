
# Table of Contents

1.  [OS X Options](#org3f0cfe8)
    1.  [Hostname](#orga26acc7)
    2.  [File Dialogs](#org71a5ece)
    3.  [Mouse](#org794cebe)
    4.  [Keyboard](#orgad78dc6)
2.  [Software](#org5512bd8)
    1.  [Xcode](#orgb0df728)
    2.  [Homebrew](#orgfcedb54)
    3.  [Git](#org2ab03d1)
    4.  [Github](#orgd9be324)
        1.  [Generate ssh key](#orgc2728dc)
        2.  [Spacemacs Github Integration](#orgae77d78)
    5.  [Dotfile Setup](#org9d66a0b)
    6.  [ZSH Setup](#org4aac9b5)
        1.  [Set Default Shell](#org2db791b)
        2.  [Prezto](#org403f02e)
        3.  [Setup Symlinks](#org08f5838)
        4.  [Custom configurations](#org2031ec1)
        5.  [Restart your terminal](#orgc9773d9)
    7.  [Ruby](#org8699d61)
        1.  [Rbenv](#org0165ef9)
        2.  [Symlink](#org639c630)
        3.  [Linters](#orge95c8a7)
        4.  [Restart your terminal here](#orgc7d0b7b)
    8.  [Poewrline Fonts](#orgef1ccb4)
    9.  [Brew Bundle](#orgebbbfa8)
    10. [Python](#org7437369)
    11. [Elixir](#org98bd002)
    12. [Node](#orga6bc686)
        1.  [Node Version Manager](#orgb1687b1)
        2.  [Bower](#org8bebb5f)
        3.  [React Generator](#org490fc4d)
        4.  [Yarn](#org3f47026)
        5.  [Linters](#org386b397)
    13. [Vim](#org3cd7748)
        1.  [Prerequiste](#org24f0dd7)
        2.  [Symlinks](#org2f56cdb)
        3.  [Plugin Installs](#org96c7462)
    14. [SpaceMacs](#org2b1ae3e)
        1.  [Markdown Support](#orgfaf85c1)
    15. [Tmux](#orgb3b5280)
        1.  [Install Plugins](#orgdec9f55)
    16. [Tig](#orgc59d0cb)
    17. [Silver Searcher](#orgd3ce23c)
    18. [Youtube-dl](#orgc377bf1)
    19. [Livestream](#orge63e38a)
    20. [KWM / KHD (Tilling Window Manager)](#orge4913a3)


<a id="org3f0cfe8"></a>

# OS X Options


<a id="orga26acc7"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="org71a5ece"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="org794cebe"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="orgad78dc6"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="org5512bd8"></a>

# Software


<a id="orgb0df728"></a>

## Xcode

    xcode-select --install


<a id="orgfcedb54"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="org2ab03d1"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="orgd9be324"></a>

## Github


<a id="orgc2728dc"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="orgae77d78"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="org9d66a0b"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/dev/dotfiles
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="org4aac9b5"></a>

## ZSH Setup


<a id="org2db791b"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="org403f02e"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"


<a id="org08f5838"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/dev/dotfiles
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org2031ec1"></a>

### Custom configurations

edit ~/.zshenv and set your own DEV<sub>DIR</sub> and DOTFILE<sub>DIR</sub>


<a id="orgc9773d9"></a>

### Restart your terminal


<a id="org8699d61"></a>

## Ruby


<a id="org0165ef9"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.4.1
    rbenv local 2.4.1
    rbenv global 2.4.1
    gem install bundle
    rbenv rehash


<a id="org639c630"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="orge95c8a7"></a>

### Linters

    gem install rufo ruby-lint rubocop scss_lint scss_lint_reporter_checkstyle


<a id="orgc7d0b7b"></a>

### Restart your terminal here


<a id="orgef1ccb4"></a>

## Poewrline Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)


<a id="orgebbbfa8"></a>

## Brew Bundle

    brew bundle


<a id="org7437369"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org98bd002"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs


<a id="orga6bc686"></a>

## Node


<a id="orgb1687b1"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="org8bebb5f"></a>

### Bower

    npm install -g bower


<a id="org490fc4d"></a>

### React Generator

    npm install -g create-react-app


<a id="org3f47026"></a>

### Yarn

    npm install -g yarn


<a id="org386b397"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint
    
    export PKG=eslint-config-airbnb;
    npm info "$PKG@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install -g "$PKG@latest"
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    
    yarn global add prettier


<a id="org3cd7748"></a>

## Vim


<a id="org24f0dd7"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="org2f56cdb"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="org96c7462"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="org2b1ae3e"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="orgfaf85c1"></a>

### Markdown Support

    npm install -g vmd


<a id="orgb3b5280"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="orgdec9f55"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="orgc59d0cb"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="orgd3ce23c"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="orgc377bf1"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="orge63e38a"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="orge4913a3"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

-   [KWM](<https://github.com/koekeishiya/chunkwm>)
-   [KHD](<https://github.com/koekeishiya/khd>)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

