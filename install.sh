mkdir -p ~/.config/nvim/autoload
mkdir -p ~/.tmux/plugins
mkdir -p ~/dev/.virtualenv

ln -s $PWD/rails/pryrc.symlink ~/.pryrc

ln -s $PWD/eslint/eslintrc.symlink ~/.eslintrc
ln -s $PWD/ctags.symlink ~/.ctags
ln -s $PWD/ctags.symlink ~/.gtags

ln -s $PWD/elixir/iex.exs.symlink ~/.iex.exs

ln -s $PWD/tmux/.tmux.conf ~/
ln -s $PWD/tmux/plugins/tpm ~/.tmux/plugins/tpm


ln -s $PWD/git/gitconfig.symlink ~/.gitconfig
ln -s $PWD/git/gitignore_global.symlink ~/.gitignore_global
ln -s $PWD/tigrc.symlink ~/.tigrc

ln -s $PWD/thymerc.symlink ~/.thymerc

pip install -r pip-requirements.txt

# TMux TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Node Install
nvm install 6.9.1
nvm use 6.9.1
npm install -g npm
nvm alias default node

# Javascript linters
npm install -g tern js-beautify
npm install -g eslint babel-eslint
export PKG=eslint-config-airbnb;
npm info "$PKG@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install -g "$PKG@latest"

# Install offical react project generator
npm install -g create-react-app
