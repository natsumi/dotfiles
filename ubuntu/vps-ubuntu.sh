DOTFILES_DIR=$HOME/dotfiles

sudo apt update
sudo apt upgrade

# Build tools
sudo apt install -y \
  automake autoconf libreadline-dev \
  libncurses-dev libssl-dev libyaml-dev \
  libxslt-dev libffi-dev libtool unixodbc-dev \
  build-essential openssl libssl-dev

# Utils
sudo apt install -y \
  htop jq fd-find fzf stow \
  tig tmux ripgrep\
  wget unzip curl vim neovim \
  zsh git fail2ban

# Docker
echo 'Installing Docker'
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install docker-ce
sudo usermod -aG docker $USER
systemctl start docker
systemctl enable docker


echo 'Installing asdf'
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0

echo 'Installing bat'
curl -sL https://api.github.com/repos/sharkdp/bat/releases/latest  | jq -r '.assets[].browser_download_url' | grep amd | tail -n 1 | xargs wget
ls *.deb | sudo xargs dpkg -i

echo 'Installing diff-so-fancy'
wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
chmod +x diff-so-fancy
sudo mv diff-so-fancy /usr/local/bin

echo 'Installing scmpuff'
curl -sL https://api.github.com/repos/mroth/scmpuff/releases/latest  | jq -r '.assets[].browser_download_url' | grep linux | xargs -I % wget % -O - |  tar xvz scmpuff
chmod +x scmpuff
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
