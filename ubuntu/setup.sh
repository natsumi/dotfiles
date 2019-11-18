DOTFILES_DIR=$HOME/dev/dotfiles
umask 022
sudo apt update
sudo apt upgrade

# Build tools
sudo apt install -y \
  automake autoconf libreadline-dev \
  libncurses-dev libssl-dev libyaml-dev \
  libxslt-dev libffi-dev libtool unixodbc-dev \
  build-essential openssl libssl-dev

# Python Build Tools
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
  xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
# Utils
sudo apt install -y \
  htop stow \
  tig tmux \
  wget unzip curl \
  zsh

echo 'Installing asdf'
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"

echo 'Installing bat'
curl -sL https://api.github.com/repos/sharkdp/bat/releases/latest  | jq -r '.assets[].browser_download_url' | grep amd | tail -n 1 | xargs wget
ls *.deb | sudo xargs dpkg -i

echo 'Installing diff-so-fancy'
wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
chmod +x /usr/local/bin/diff-so-fancy
sudo mv diff-so-fancy /usr/local/bin

echo 'Installing fzf'
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo 'Installing ripgrep'
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
sudo dpkg -i ripgrep_11.0.2_amd64.deb
rm ripgrep_11.0.2_amd64.deb

echo 'Installing scmpuff'
curl -sL https://api.github.com/repos/mroth/scmpuff/releases/latest  | jq -r '.assets[].browser_download_url' | grep linux | xargs -I % wget % -O - |  tar xvz scmpuff
chmod +x /usr/local/bin/scmpuff
sudo mv scmpuff /usr/local/bin

# Clone dotfiles dir
mkdir ~/dev
git clone https://github.com/natsumi/dotfiles.git $DOTFILES_DIR

# apply symlinks
bash $DOTFILES_DIR/bin/apply_symlinks
bash $DOTFILES_DIR/bin/apply_git_settings

echo 'Installing Prezto'
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
git clone --recursive https://github.com/belak/prezto-contrib  "${ZDOTDIR:-$HOME}/.zprezto/contrib"

echo 'Installing Zplug'
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# set default shell
echo 'Setting default shell'
chsh -s $(which zsh)

echo 'Restart Terminal'