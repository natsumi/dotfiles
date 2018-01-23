
# Table of Contents

1.  [OS X Options](#org4af5246)
    1.  [Hostname](#org2c25b20)
    2.  [File Dialogs](#org89c44c0)
    3.  [Mouse](#org0643c26)
    4.  [Keyboard](#org1bd20dd)
2.  [Software](#orgd3bda41)
    1.  [Xcode](#orgf03a6ca)
    2.  [Homebrew](#org41ccfb0)
    3.  [Git](#org24ea121)
    4.  [Github](#orgcb35f70)
        1.  [Generate ssh key](#orgc91eeb7)
        2.  [Spacemacs Github Integration](#org5de24ee)
    5.  [Dotfile Setup](#org1cfc90c)
    6.  [ZSH Setup](#org46b7693)
        1.  [Set Default Shell](#org44266e1)
        2.  [Prezto](#org2d8c64b)
        3.  [Setup Symlinks](#org52c68fa)
        4.  [Custom configurations](#org30142d0)
        5.  [Restart your terminal](#org8361313)
    7.  [Ruby](#orgb5373d5)
        1.  [Rbenv](#orgee4587a)
        2.  [Symlink](#orgbc6bd37)
        3.  [Linters / Dev gems](#org36f407f)
        4.  [Restart your terminal here](#orga72bc7d)
    8.  [Fonts](#orgd925c67)
    9.  [Brew Bundle](#org7ebaadc)
    10. [Python](#org158b7af)
    11. [Elixir](#org35e616e)
    12. [Node](#org1998a99)
        1.  [Node Version Manager](#org8f9d33f)
        2.  [Bower](#org7e1240a)
        3.  [React Generator](#org23d4758)
        4.  [Yarn](#org2dcdc3a)
        5.  [Linters](#orgaaba20a)
    13. [Vim](#orgdb09759)
        1.  [Prerequiste](#org6cd33c6)
        2.  [Symlinks](#org542e5f1)
        3.  [Plugin Installs](#orgf2519fa)
    14. [SpaceMacs](#org7eb2fb5)
        1.  [Gtag](#org67f1f4c)
        2.  [Markdown Support](#orgd70d3d3)
    15. [Tmux](#orgcf9111c)
        1.  [Install Plugins](#orgdc572c9)
    16. [Tig](#org86a6a63)
    17. [Silver Searcher](#org324bef4)
    18. [Youtube-dl](#org9d1b127)
    19. [Livestream](#org1d44b7f)
    20. [KWM / KHD (Tilling Window Manager)](#org43cd2ec)


<a id="org4af5246"></a>

# OS X Options


<a id="org2c25b20"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="org89c44c0"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="org0643c26"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="org1bd20dd"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="orgd3bda41"></a>

# Software


<a id="orgf03a6ca"></a>

## Xcode

    xcode-select --install


<a id="org41ccfb0"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="org24ea121"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="orgcb35f70"></a>

## Github


<a id="orgc91eeb7"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="org5de24ee"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="org1cfc90c"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/path/to/dotfile
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="org46b7693"></a>

## ZSH Setup


<a id="org44266e1"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="org2d8c64b"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    git clone --recursive https://github.com/belak/prezto-contrib  "${ZDOTDIR:-$HOME}/.zprezto/contrib"


<a id="org52c68fa"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/path/to/dotfile
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org30142d0"></a>

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`


<a id="org8361313"></a>

### Restart your terminal


<a id="orgb5373d5"></a>

## Ruby


<a id="orgee4587a"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.5.0
    rbenv local 2.5.0
    rbenv global 2.5.0
    gem install bundle
    rbenv rehash


<a id="orgbc6bd37"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="org36f407f"></a>

### Linters / Dev gems

    gem install pry pry-doc pry-bloodline ruby_parser rufo rubocop scss_lint scss_lint_reporter_checkstyle


<a id="orga72bc7d"></a>

### Restart your terminal here


<a id="orgd925c67"></a>

## Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)


<a id="org7ebaadc"></a>

## Brew Bundle

    brew bundle


<a id="org158b7af"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org35e616e"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs
    mix local.hex
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez


<a id="org1998a99"></a>

## Node


<a id="org8f9d33f"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="org7e1240a"></a>

### Bower

    npm install -g bower


<a id="org23d4758"></a>

### React Generator

    npm install -g create-react-app


<a id="org2dcdc3a"></a>

### Yarn

    npm install -g yarn


<a id="orgaaba20a"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint eslint-plugin-react
    npm install -g prettier
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    ln -s $DOTFILE_DIR/prettierrc.symlink ~/.prettierrc


<a id="orgdb09759"></a>

## Vim


<a id="org6cd33c6"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="org542e5f1"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="orgf2519fa"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="org7eb2fb5"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el
    ln -s $DOTFILE_DIR/gtags.conf.symlink ~/.gtags.conf

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="org67f1f4c"></a>

### Gtag

[Download Global](https://www.gnu.org/software/global/download.html)

    tar xvzf <filenamee>
    cd <global_dir>
    ./configure --with-universal-ctags=/usr/local/bin/ctags --with-sqlite3
    ./make install


<a id="orgd70d3d3"></a>

### Markdown Support

    npm install -g vmd


<a id="orgcf9111c"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="orgdc572c9"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="org86a6a63"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="org324bef4"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="org9d1b127"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="org1d44b7f"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="org43cd2ec"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Keyboard Hot Keys](https://github.com/koekeishiya/khd)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

