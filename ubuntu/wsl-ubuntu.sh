DOTFILES_DIR=$HOME/dev/dotfiles
umask 022

# for neovim
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo add-apt-repository ppa:wslutilities/wslu

sudo apt update
sudo apt upgrade

# Build tools
sudo apt install -y \
	automake autoconf libreadline-dev \
	libncurses-dev libssl-dev libyaml-dev \
	libxslt-dev libffi-dev libtool unixodbc-dev \
	build-essential openssl libssl-dev libpq-dev

# Build Tools
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
	xz-utils tk-dev libffi-dev liblzma-dev git

# Utils
sudo apt install -y \
	htop jq fd-find fzf stow \
	tig tmux ripgrep tree \
	wget unzip curl vim neovim \
	zsh wslu ffmpeg bat

echo 'Installing mise'
curl https://mise.run | sh

# echo 'Installing bat'
curl -sL https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[].browser_download_url' | grep amd | tail -n 1 | xargs wget
ls *.deb | sudo xargs dpkg -i

echo 'Installing diff-so-fancy'
curl -sL https://api.github.com/repos/so-fancy/diff-so-fancy/releases/latest | jq -r '.assets[].browser_download_url' | xargs wget
chmod +x diff-so-fancy
sudo mv diff-so-fancy /usr/local/bin

echo 'Installing scmpuff'
curl -sL https://api.github.com/repos/mroth/scmpuff/releases/latest | jq -r '.assets[].browser_download_url' | grep linux_x64 | xargs -I % wget % -O - | tar xvz scmpuff
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
git clone --recursive https://github.com/belak/prezto-contrib "${ZDOTDIR:-$HOME}/.zprezto/contrib"

echo 'Installing Zplug'
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# set default shell
echo 'Setting default shell'
chsh -s $(which zsh)

echo 'Restart Terminal'
