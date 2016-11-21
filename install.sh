mkdir -p ~/.config/nvim/autoload

ln -s $PWD/eslint/eslintrc.symlink ~/.eslintrc
ln -s $PWD/ctags.symlink ~/.gtags

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
