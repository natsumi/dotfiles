#!/usr/bin/env bash

# Guard hook: block file edits on main/master branch.
# Allows edits in linked worktrees or non-main branches.
# Allows edits outside of git repos.

# Not in a git repo? Allow.
git rev-parse --git-dir &>/dev/null || exit 0

# In a linked worktree? Allow.
git_dir=$(git rev-parse --git-dir 2>/dev/null)
common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
if [ "$git_dir" != "$common_dir" ]; then
  exit 0
fi

# On a non-main/master branch? Allow.
branch=$(git branch --show-current 2>/dev/null)
if [ -n "$branch" ] && [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
  exit 0
fi

echo "Edits must be made in a branch or worktree, not on main/master." >&2
exit 2
