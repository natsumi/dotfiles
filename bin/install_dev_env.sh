#! /usr/bin/env bash

# DESCRIPTION
# Installs the dev environment

# EXECUTION

# RUBY_CONFIGURE_OPTS=--"with-readline-dir="$(brew --prefix readline)" --with-jemalloc"

languages=(
  # "elixir"
  # "erlang"
  # "golang"
  "node"
  "python"
  "ruby"
  # "rust"
)

for language in "${languages[@]}"; do
  echo "Installing $language"
  mise use --global "$language"
done

echo "Restart your terminal"
