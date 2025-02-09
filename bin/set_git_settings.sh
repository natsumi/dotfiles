#! /usr/bin/env bash

# DESCRIPTION
# Applies GIT configuration

read -p "What is your git user name? " git_name
if [[ -z "$git_name" ]]; then
  printf "ERROR: Invalid Git user name.\n"
  exit 1
fi

read -p "What is your git user email? " git_email
if [[ -z "$git_email" ]]; then
  printf "ERROR: Invalid Git email.\n"
  exit 1
fi
printf "Setting git user informaiton config. \n"
git config --global user.name "$git_name"
git config --global user.email $git_email

printf "Setting git default push to simple.\n"
git config --global push.default simple

printf "Setting git diff-so-fancy configuration.\n"
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

git config --global color.ui true
git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta       "yellow"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"
