- [OS X Options](#sec-1)
  - [Hostname](#sec-1-1)
  - [File Dialogs](#sec-1-2)
  - [Mouse](#sec-1-3)
  - [Keyboard](#sec-1-4)
- [Software](#sec-2)
  - [Xcode](#sec-2-1)
  - [Homebrew](#sec-2-2)
  - [Git](#sec-2-3)
  - [Github](#sec-2-4)
  - [Dotfile Setup](#sec-2-5)
  - [ZSH Setup](#sec-2-6)
    - [Set Default Shell](#sec-2-6-1)
    - [Setup Prezto](#sec-2-6-2)
    - [Setup Symlinks](#sec-2-6-3)
    - [Custom configurations](#sec-2-6-4)
    - [Restart your terminal](#sec-2-6-5)
  - [Ruby](#sec-2-7)
    - [Rbenv](#sec-2-7-1)
    - [Symlink](#sec-2-7-2)
    - [Restart your terminal here](#sec-2-7-3)
  - [Poewrline Fonts](#sec-2-8)
  - [Brew Bundle](#sec-2-9)
  - [Python](#sec-2-10)
  - [Elixir](#sec-2-11)
  - [Vim](#sec-2-12)
    - [Prerequiste](#sec-2-12-1)
    - [Symlinks](#sec-2-12-2)
    - [Plugin Installs](#sec-2-12-3)
  - [SpaceMacs](#sec-2-13)
  - [Tmux](#sec-2-14)
    - [Install Plugins](#sec-2-14-1)
  - [Tig](#sec-2-15)
  - [Syntastic Linter](#sec-2-16)

# OS X Options<a id="sec-1"></a>

## Hostname<a id="sec-1-1"></a>

Change Hostname:

sudo scutil &#x2013;set HostName

## File Dialogs<a id="sec-1-2"></a>

Set OSX Save dialog to always be expanded defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

## Mouse<a id="sec-1-3"></a>

Set mouse to a faster track speed Uncheck "Scroll direction: Natural"

## Keyboard<a id="sec-1-4"></a>

Set repeat speed fast Set repeat delay low

# Software<a id="sec-2"></a>

## Xcode<a id="sec-2-1"></a>

## Homebrew<a id="sec-2-2"></a>

Install from: <http://brew.sh/>

## Git<a id="sec-2-3"></a>

brew install git git config &#x2013;global user.name <user<sub>name</sub>> git config &#x2013;global user.email <email> git config &#x2013;global push.default simple

## Github<a id="sec-2-4"></a>

Generate ssh key ssh-keygen cat ~/.ssh/id<sub>rsa.pub</sub> | pbcopy Paste into github's ssh setting

## Dotfile Setup<a id="sec-2-5"></a>

export DOTFILE<sub>DIR</sub>=~/dev/dotfiles git clone <https://github.com/natsumi/dotfiles> $DOTFILE<sub>DIR</sub>

## ZSH Setup<a id="sec-2-6"></a>

### Set Default Shell<a id="sec-2-6-1"></a>

echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells chsh -s $(which zsh)

### Setup Prezto<a id="sec-2-6-2"></a>

git clone &#x2013;recursive <https://github.com/sorin-ionescu/prezto.git> "${ZDOTDIR:-$HOME}/.zprezto"

### Setup Symlinks<a id="sec-2-6-3"></a>

export DOTFILE<sub>DIR</sub>=~/dev/dotfiles ln -s $DOTFILE<sub>DIR</sub>/zsh/zshrc.symlink ~/.zshrc ln -s $DOTFILE<sub>DIR</sub>/zsh/zshenv.symlink ~/.zshenv ln -s $DOTFILE<sub>DIR</sub>/zsh/zpreztorc.symlink ~/.zpreztorc ln -s $DOTFILE<sub>DIR</sub>/zsh/zprofile.symlink ~/.zprofile ln -s $DOTFILE<sub>DIR</sub>/zsh/dircolors.symlink ~/.dircolors ln -s $DOTFILE<sub>DIR</sub>/zsh/aliases.symlink ~/.aliases

### Custom configurations<a id="sec-2-6-4"></a>

edit ~/.zshenv and set your own DEV<sub>DIR</sub> and DOTFILE<sub>DIR</sub>

### Restart your terminal<a id="sec-2-6-5"></a>

## Ruby<a id="sec-2-7"></a>

### Rbenv<a id="sec-2-7-1"></a>

brew install ruby-build rbenv rbenv install -l # find which is the latest ruby version rbenv install 2.3.0 rbenv local 2.3.0 rbenv global 2.3.0 gem install bundle rbenv rehash

### Symlink<a id="sec-2-7-2"></a>

ln -s $DOTFILE<sub>DIR</sub>/rails/pryrc.symlink ~/.pryrc

### Restart your terminal here<a id="sec-2-7-3"></a>

## Poewrline Fonts<a id="sec-2-8"></a>

(<https://github.com/powerline/fonts>)

## Brew Bundle<a id="sec-2-9"></a>

brew bundle

## Python<a id="sec-2-10"></a>

mkdir -p $DOTFILE<sub>DIR</sub>/.virtualenv brew install python pip install easy<sub>setup</sub> pip install virtualenv virtualenvwrapper powerline-status flake8 pygments

## Elixir<a id="sec-2-11"></a>

ln -s $DOTFILE<sub>DIR</sub>/elixir/iex.exs.symlink ~/.iex.exs

## Vim<a id="sec-2-12"></a>

### Prerequiste<a id="sec-2-12-1"></a>

mkdir -p ~/.vim/autoload

### Symlinks<a id="sec-2-12-2"></a>

ln -s $DOTFILE<sub>DIR</sub>/vim/snippets ~/.vim/ ln -s $DOTFILE<sub>DIR</sub>/vim/functions ~/.vim/functions ln -s $DOTFILE<sub>DIR</sub>/vim/plugins ~/.vim/plugins ln -s $DOTFILE<sub>DIR</sub>/vim/vimrc.symlink ~/.vimrc ln -s $DOTFILE<sub>DIR</sub>/vim/ignore.vim.symlink ~/.vim/ignore.vim ln -s $DOTFILE<sub>DIR</sub>/ctags.symlink ~/.ctags

### Plugin Installs<a id="sec-2-12-3"></a>

Run vim :PlugInstall

## SpaceMacs<a id="sec-2-13"></a>

mkdir -p ~/.spacemacs.d git clone <https://github.com/syl20bnr/spacemacs> ~/.emacs.d ln -s $DOTFILE<sub>DIR</sub>/spacemacs/init.el.symlink ~/.spacemacs.d/init.el

## Tmux<a id="sec-2-14"></a>

mkdir -p ~/.tmux/plugins ln -s $DOTFILE<sub>DIR</sub>/tmux/tmux.conf.symlink ~/.tmux.conf git clone <https://github.com/tmux-plugins/tpm> ~/.tmux/plugins/tpm

### Install Plugins<a id="sec-2-14-1"></a>

run tmux ctrl-s shift-i

## Tig<a id="sec-2-15"></a>

ln -s $DOTFILE<sub>DIR</sub>/tigrc.symlink ~/.tigrc

## Syntastic Linter<a id="sec-2-16"></a>

npm install -g jshint && \\ npm install -g jsonlint npm install -g eslint && \\ npm install -g babel-eslint && \\ npm install -g eslint-plugin-react &&\\ npm install -g eslint-config-airbnb
