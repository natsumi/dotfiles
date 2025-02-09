#! /usr/bin/env bash

# DESCRIPTION
# Installs the dev environment

# EXECUTION
printf "Adding plguins\n"
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add python
asdf plugin add erlang
asdf plugin add elixir
asdf plugin add golang
asdf plugin add rust https://github.com/asdf-community/asdf-rust.git

# asdf plugin update --all

# Get latest Ruby version matching x.y.z format
RUBY_VERSION=$(asdf list all ruby | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -n 1)
# RUBY_CONFIGURE_OPTS=--"with-readline-dir="$(brew --prefix readline)" --with-jemalloc"

echo "Installing Ruby $RUBY_VERSION"
asdf install ruby "$RUBY_VERSION"
asdf set -u ruby "$RUBY_VERSION"

# NODEJS_LTS_VERSION=$(asdf nodejs resolve lts)
# echo "Installing Node $NODEJS_LTS_VERSION\n"
# asdf install nodejs "$NODEJS_LTS_VERSION"
# asdf set -u nodejs "$NODEJS_LTS_VERSION"

NODEJS_LTS_VERSION=22.13.1
echo "Installing Node $NODEJS_LTS_VERSION"
asdf install nodejs "$NODEJS_LTS_VERSION"
asdf set -u nodejs "$NODEJS_LTS_VERSION"

PYTHON_VERSION=$(asdf list all python | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -n 1)
echo "Installing Python $PYTHON_VERSION"
asdf install python "$PYTHON_VERSION"
asdf set -u python "$PYTHON_VERSION"

echo "Restart your terminal"
