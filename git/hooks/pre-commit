#!/bin/sh
FILES='(js|css|rb)'
FORBIDDEN='(binding.pry|console.log|\!important)'
GREP_COLOR='4;5;37;41'

if [[ $(git diff --cached --name-only | grep -E $FILES) ]]; then
  git diff --cached --name-only | grep -E $FILES | \
  xargs grep --color --with-filename -n -E $FORBIDDEN && \
  echo "Looks like you are trying to commit something you shouldn't.  Please fix your diff, or run 'git commit --no-verify' to skip this check, if you must." && \
  exit 1
fi

exit 0
