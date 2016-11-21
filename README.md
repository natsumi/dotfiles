### Initial System Conf
Change Hostname:

  sudo scutil --set HostName

Set OSX Save dialog to always be expanded
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

### Vim-Plug

  After vim is installed run :PlugInstall

### Git Config

    git config --global user.name <user_name>
    git config --global user.email <email>
    git config --global push.default simple

### Synastic Setup

    npm install -g jshint && \
    npm install -g jsonlint
    npm install -g eslint && \
    npm install -g babel-eslint && \
    npm install -g eslint-plugin-react &&\
    npm install -g eslint-config-airbnb

### Poewrline Fonts
[Poerline Fonts](https://github.com/powerline/fonts)

### Notes
====
  1. Make sure you edit the vimrc file and update the powerline paths
