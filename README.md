
# Table of Contents

1.  [OS X Options](#orgbda08a4)
    1.  [Hostname](#org9fabc96)
    2.  [File Dialogs](#orgf5fe206)
    3.  [Mouse](#org27d2966)
    4.  [Keyboard](#orgef09854)
2.  [Software](#org2cda36e)
    1.  [Xcode](#orgf53c582)
    2.  [Homebrew](#org6b35542)
    3.  [Git](#org4d81ade)
    4.  [Github](#org82284f2)
        1.  [Generate ssh key](#orgb0824d3)
        2.  [Spacemacs Github Integration](#org2590dd0)
    5.  [Dotfile Setup](#orge58f1d7)
    6.  [ZSH Setup](#orgbe74232)
        1.  [Set Default Shell](#org79b0605)
        2.  [Prezto](#orgf61abb2)
        3.  [Setup Symlinks](#org1b51c2d)
        4.  [Custom configurations](#org2dff592)
        5.  [Restart your terminal](#orgd3406d9)
    7.  [Ruby](#org79d6944)
        1.  [Rbenv](#org65a5abc)
        2.  [Symlink](#org807866d)
        3.  [Linters / Dev gems](#orgdfc70ce)
        4.  [Restart your terminal here](#orgd1fee7d)
    8.  [Fonts](#org26c0758)
    9.  [Brew Bundle](#org35fb0c7)
    10. [Python](#org6caeb6b)
    11. [Elixir](#org752e4ab)
    12. [Node](#orgb0b1b19)
        1.  [Node Version Manager](#org7893292)
        2.  [Bower](#org4a33e08)
        3.  [React Generator](#org7d44010)
        4.  [Yarn](#org94bc9a0)
        5.  [Linters](#org1b3bfd3)
    13. [Vim](#org07e111a)
        1.  [Prerequiste](#orgf2ea571)
        2.  [Symlinks](#orgcdad603)
        3.  [Plugin Installs](#org2599d85)
    14. [SpaceMacs](#orgcb162e4)
        1.  [Gtag](#org1e3636f)
        2.  [Markdown Support](#org3bd07bf)
    15. [Tmux](#org7d3aaeb)
        1.  [Install Plugins](#org89cbafb)
    16. [Tig](#org9342994)
    17. [Silver Searcher](#orgba3eb60)
    18. [Youtube-dl](#org64176f4)
    19. [Livestream](#orgf7b1088)
    20. [KWM / KHD (Tilling Window Manager)](#org910d951)


<a id="orgbda08a4"></a>

# OS X Options


<a id="org9fabc96"></a>

## Hostname

Change Hostname:

    sudo scutil --set HostName


<a id="orgf5fe206"></a>

## File Dialogs

Set OSX Save dialog to always be expanded

    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


<a id="org27d2966"></a>

## Mouse

Set mouse to a faster track speed
Uncheck "Scroll direction: Natural"


<a id="orgef09854"></a>

## Keyboard

Set repeat speed fast
Set repeat delay low


<a id="org2cda36e"></a>

# Software


<a id="orgf53c582"></a>

## Xcode

    xcode-select --install


<a id="org6b35542"></a>

## Homebrew

[Brew](http://brew.sh/)


<a id="org4d81ade"></a>

## Git

    brew install git
    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple


<a id="org82284f2"></a>

## Github


<a id="orgb0824d3"></a>

### Generate ssh key

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub | pbcopy

Paste into github's ssh setting


<a id="org2590dd0"></a>

### Spacemacs Github Integration

Grant access to repo and gist
[Set Access Tokens](https://github.com/settings/tokens)

    git config --global github.oauth-token <token>


<a id="orge58f1d7"></a>

## Dotfile Setup

    export DOTFILE_DIR=~/path/to/dotfile
    git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR


<a id="orgbe74232"></a>

## ZSH Setup


<a id="org79b0605"></a>

### Set Default Shell

    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s $(which zsh)


<a id="orgf61abb2"></a>

### Prezto

[Prezto](https://github.com/sorin-ionescu/prezto.git)

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    git clone --recursive https://github.com/belak/prezto-contrib  "${ZDOTDIR:-$HOME}/.zprezto/contrib"


<a id="org1b51c2d"></a>

### Setup Symlinks

    export DOTFILE_DIR=~/path/to/dotfile
    ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
    ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
    ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
    ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
    ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
    ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases


<a id="org2dff592"></a>

### Custom configurations

edit `~/.zshenv` and set your own `$DEV_DIR` and `$DOTFILE_DIR`


<a id="orgd3406d9"></a>

### Restart your terminal


<a id="org79d6944"></a>

## Ruby


<a id="org65a5abc"></a>

### Rbenv

    brew install ruby-build rbenv
    rbenv install -l # find which is the latest ruby version
    rbenv install 2.5.0
    rbenv local 2.5.0
    rbenv global 2.5.0
    gem install bundle
    rbenv rehash


<a id="org807866d"></a>

### Symlink

    ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc


<a id="orgdfc70ce"></a>

### Linters / Dev gems

    gem install pry pry-doc pry-bloodline ruby_parser rufo rubocop scss_lint scss_lint_reporter_checkstyle


<a id="orgd1fee7d"></a>

### Restart your terminal here


<a id="org26c0758"></a>

## Fonts

[Powerline Fonts Repo](https://github.com/powerline/fonts)

[Input Mono](http://input.fontbureau.com/download/)


<a id="org35fb0c7"></a>

## Brew Bundle

    brew bundle


<a id="org6caeb6b"></a>

## Python

    mkdir -p $DEV_DIR/.virtualenv
    brew install python
    pip install virtualenv virtualenvwrapper powerline-status flake8 pygments


<a id="org752e4ab"></a>

## Elixir

    ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs
    mix local.hex
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez


<a id="orgb0b1b19"></a>

## Node


<a id="org7893292"></a>

### Node Version Manager

    nvm ls-remote # lists available versions to install
    nvm install --lts
    nvm use --lts
    npm install -g npm
    nvm alias default node


<a id="org4a33e08"></a>

### Bower

    npm install -g bower


<a id="org7d44010"></a>

### React Generator

    npm install -g create-react-app


<a id="org94bc9a0"></a>

### Yarn

    npm install -g yarn


<a id="org1b3bfd3"></a>

### Linters

    npm install -g tern js-beautify
    npm install -g eslint babel-eslint eslint-plugin-react
    npm install -g prettier
    
    ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc
    ln -s $DOTFILE_DIR/prettierrc.symlink ~/.prettierrc


<a id="org07e111a"></a>

## Vim


<a id="orgf2ea571"></a>

### Prerequiste

    mkdir -p ~/.vim/autoload


<a id="orgcdad603"></a>

### Symlinks

    ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
    ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
    ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
    ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
    ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
    ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags


<a id="org2599d85"></a>

### Plugin Installs

Run vim
:PlugInstall


<a id="orgcb162e4"></a>

## SpaceMacs

    mkdir -p ~/.spacemacs.d
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el
    ln -s $DOTFILE_DIR/gtags.symlink ~/.gtags.conf

User develop branch

    cd ~/.emacs.d
    git fetch
    git checkout develop
    git pull


<a id="org1e3636f"></a>

### Gtag

[Download Global](https://www.gnu.org/software/global/download.html)

    tar xvzf <filenamee>
    cd <global_dir>
    ./configure --with-universal-ctags --with-sqlite3
    ./make install


<a id="org3bd07bf"></a>

### Markdown Support

    npm install -g vmd


<a id="org7d3aaeb"></a>

## Tmux

    mkdir -p ~/.tmux/plugins
    ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


<a id="org89cbafb"></a>

### Install Plugins

run tmux
ctrl-s shift-i


<a id="org9342994"></a>

## Tig

    ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc


<a id="orgba3eb60"></a>

## Silver Searcher

    ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore


<a id="org64176f4"></a>

## Youtube-dl

    mkdir -p ~/.config/youtube-dl
    ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config


<a id="orgf7b1088"></a>

## Livestream

Configure Twitch Oauth

    livestreamer --twitch-oauth-authenticate

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc


<a id="org910d951"></a>

## KWM / KHD (Tilling Window Manager)

This is experimental.

[Chunkwmrc Window Manager](https://github.com/koekeishiya/chunkwm)

[Keyboard Hot Keys](https://github.com/koekeishiya/khd)

    ln -s $DOTFILE_DIR/chunkwm/chunkwmrc ~/.chunkwmrc
    ln -s $DOTFILE_DIR/chunkwm/khdrc ~/.khdrc

