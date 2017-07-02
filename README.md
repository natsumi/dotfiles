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
    - [Generate ssh key](#sec-2-4-1)
    - [Spacemacs Github Integration](#sec-2-4-2)
  - [Dotfile Setup](#sec-2-5)
  - [ZSH Setup](#sec-2-6)
    - [Set Default Shell](#sec-2-6-1)
    - [Prezto](#sec-2-6-2)
    - [Setup Symlinks](#sec-2-6-3)
    - [Custom configurations](#sec-2-6-4)
    - [Restart your terminal](#sec-2-6-5)
  - [Ruby](#sec-2-7)
    - [Rbenv](#sec-2-7-1)
    - [Symlink](#sec-2-7-2)
    - [Linters](#sec-2-7-3)
    - [Restart your terminal here](#sec-2-7-4)
  - [Poewrline Fonts](#sec-2-8)
  - [Brew Bundle](#sec-2-9)
  - [Python](#sec-2-10)
  - [Elixir](#sec-2-11)
    - [IEx History](#sec-2-11-1)
  - [Node](#sec-2-12)
    - [Node Version Manager](#sec-2-12-1)
    - [Bower](#sec-2-12-2)
    - [React Generator](#sec-2-12-3)
    - [Yarn](#sec-2-12-4)
    - [Linters](#sec-2-12-5)
  - [Vim](#sec-2-13)
    - [Prerequiste](#sec-2-13-1)
    - [Symlinks](#sec-2-13-2)
    - [Plugin Installs](#sec-2-13-3)
  - [SpaceMacs](#sec-2-14)
    - [Markdown Support](#sec-2-14-1)
  - [Tmux](#sec-2-15)
    - [Install Plugins](#sec-2-15-1)
  - [Tig](#sec-2-16)
  - [Silver Searcher](#sec-2-17)
  - [Youtube-dl](#sec-2-18)
  - [Livestream](#sec-2-19)

# OS X Options<a id="sec-1"></a>

## Hostname<a id="sec-1-1"></a>

Change Hostname:

```bash
sudo scutil --set HostName
```

## File Dialogs<a id="sec-1-2"></a>

Set OSX Save dialog to always be expanded

```bash
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
```

## Mouse<a id="sec-1-3"></a>

Set mouse to a faster track speed Uncheck "Scroll direction: Natural"

## Keyboard<a id="sec-1-4"></a>

Set repeat speed fast Set repeat delay low

# Software<a id="sec-2"></a>

## Xcode<a id="sec-2-1"></a>

```bash
xcode-select --install
```

## Homebrew<a id="sec-2-2"></a>

[Brew](http://brew.sh/)

## Git<a id="sec-2-3"></a>

```bash
brew install git
git config --global user.name <user_name>
git config --global user.email <email>
git config --global push.default simple
```

## Github<a id="sec-2-4"></a>

### Generate ssh key<a id="sec-2-4-1"></a>

```bash
ssh-keygen
cat ~/.ssh/id_rsa.pub | pbcopy
```

Paste into github's ssh setting

### Spacemacs Github Integration<a id="sec-2-4-2"></a>

Grant access to repo and gist [Set Access Tokens](https://github.com/settings/tokens)

```bash
git config --global github.oauth-token <token>
```

## Dotfile Setup<a id="sec-2-5"></a>

```bash
export DOTFILE_DIR=~/dev/dotfiles
git clone https://github.com/natsumi/dotfiles $DOTFILE_DIR
```

## ZSH Setup<a id="sec-2-6"></a>

### Set Default Shell<a id="sec-2-6-1"></a>

```bash
echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
chsh -s $(which zsh)
```

### Prezto<a id="sec-2-6-2"></a>

[Prezto](https://github.com/sorin-ionescu/prezto.git)

```bash
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
```

### Setup Symlinks<a id="sec-2-6-3"></a>

```bash
export DOTFILE_DIR=~/dev/dotfiles
ln -s $DOTFILE_DIR/zsh/zshrc.symlink ~/.zshrc
ln -s $DOTFILE_DIR/zsh/zshenv.symlink ~/.zshenv
ln -s $DOTFILE_DIR/zsh/zpreztorc.symlink ~/.zpreztorc
ln -s $DOTFILE_DIR/zsh/zprofile.symlink ~/.zprofile
ln -s $DOTFILE_DIR/zsh/dircolors.symlink ~/.dircolors
ln -s $DOTFILE_DIR/zsh/aliases.symlink ~/.aliases
```

### Custom configurations<a id="sec-2-6-4"></a>

edit ~/.zshenv and set your own DEV<sub>DIR</sub> and DOTFILE<sub>DIR</sub>

### Restart your terminal<a id="sec-2-6-5"></a>

## Ruby<a id="sec-2-7"></a>

### Rbenv<a id="sec-2-7-1"></a>

```shell
brew install ruby-build rbenv
rbenv install -l # find which is the latest ruby version
rbenv install 2.4.1
rbenv local 2.4.1
rbenv global 2.4.1
gem install bundle
rbenv rehash
```

### Symlink<a id="sec-2-7-2"></a>

```shell
ln -s $DOTFILE_DIR/rails/pryrc.symlink ~/.pryrc
```

### Linters<a id="sec-2-7-3"></a>

```shell
gem install rufo ruby-lint rubocop scss_lint scss_lint_reporter_checkstyle
```

### Restart your terminal here<a id="sec-2-7-4"></a>

## Poewrline Fonts<a id="sec-2-8"></a>

[Powerline Fonts Repo](https://github.com/powerline/fonts)

## Brew Bundle<a id="sec-2-9"></a>

```shell
brew bundle
```

## Python<a id="sec-2-10"></a>

```shell
mkdir -p $DOTFILE_DIR/.virtualenv
brew install python
pip install easy_setup
pip install virtualenv virtualenvwrapper powerline-status flake8 pygments
```

## Elixir<a id="sec-2-11"></a>

```shell
ln -s $DOTFILE_DIR/elixir/iex.exs.symlink ~/.iex.exs
```

### IEx History<a id="sec-2-11-1"></a>

[Erlang History](http://www.github.com/ferd/erlang-history.git)

```bash
git clone git@github.com:ferd/erlang-history.git
cd erlang-history
sudo make install
```

## Node<a id="sec-2-12"></a>

### Node Version Manager<a id="sec-2-12-1"></a>

```shell
nvm ls-remote # lists available versions to install
nvm install --lts
nvm use --lts
npm install -g npm
nvm alias default node
```

### Bower<a id="sec-2-12-2"></a>

```shell
npm install -g bower
```

### React Generator<a id="sec-2-12-3"></a>

```shell
npm install -g create-react-app
```

### Yarn<a id="sec-2-12-4"></a>

```
brew install yarn
```

### Linters<a id="sec-2-12-5"></a>

```shell
npm install -g tern js-beautify
npm install -g eslint babel-eslint

export PKG=eslint-config-airbnb;
npm info "$PKG@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install -g "$PKG@latest"

ln -s $DOTFILE_DIR/eslint/eslintrc.symlink ~/.eslintrc

yarn global add prettier
```

## Vim<a id="sec-2-13"></a>

### Prerequiste<a id="sec-2-13-1"></a>

```shell
mkdir -p ~/.vim/autoload
```

### Symlinks<a id="sec-2-13-2"></a>

```bash
ln -s $DOTFILE_DIR/vim/snippets ~/.vim/
ln -s $DOTFILE_DIR/vim/functions ~/.vim/functions
ln -s $DOTFILE_DIR/vim/plugins ~/.vim/plugins
ln -s $DOTFILE_DIR/vim/vimrc.symlink ~/.vimrc
ln -s $DOTFILE_DIR/vim/ignore.vim.symlink ~/.vim/ignore.vim
ln -s $DOTFILE_DIR/ctags.symlink ~/.ctags
```

### Plugin Installs<a id="sec-2-13-3"></a>

Run vim :PlugInstall

## SpaceMacs<a id="sec-2-14"></a>

```sh
mkdir -p ~/.spacemacs.d
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
ln -s $DOTFILE_DIR/spacemacs/init.el.symlink ~/.spacemacs.d/init.el
```

### Markdown Support<a id="sec-2-14-1"></a>

```bash
npm install -g vmd
```

## Tmux<a id="sec-2-15"></a>

```
mkdir -p ~/.tmux/plugins
ln -s $DOTFILE_DIR/tmux/tmux.conf.symlink ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Install Plugins<a id="sec-2-15-1"></a>

run tmux ctrl-s shift-i

## Tig<a id="sec-2-16"></a>

```
ln -s $DOTFILE_DIR/tigrc.symlink ~/.tigrc
```

## Silver Searcher<a id="sec-2-17"></a>

```
ln -s $DOTFILE_DIR/agignore.symlink ~/.agignore
```

## Youtube-dl<a id="sec-2-18"></a>

```
mkdir -p ~/.config/youtube-dl
ln -s $DOTFILE_DIR/youtube-dl.conf.symlink ~/.config/youtube-dl/config
```

## Livestream<a id="sec-2-19"></a>

Configure Twitch Oauth

```bash
livestreamer --twitch-oauth-authenticate
```

Copy the access<sub>token</sub> in URL to ~/.livestreamerrc
