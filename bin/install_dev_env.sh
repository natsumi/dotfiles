#! /usr/bin/env bash

# DESCRIPTION
# Installs the dev environment

# EXECUTION

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
