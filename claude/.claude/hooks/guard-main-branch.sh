#!/usr/bin/env bash

# Guard hook: block file edits on the main/master branch.
# Allows edits in linked worktrees or on any non-main branch.
# Allows edits outside of git repos.
#
# The decision is keyed on the *target file's* repository and branch
# (read from tool_input.file_path / tool_input.notebook_path on stdin),
# not on the hook process's own cwd. This matters for subagents: their
# cwd is the harness root even when they're editing a file inside a
# linked worktree, so a cwd-based check would block edits the user
# clearly intends to allow.

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')

# No path in the payload? Fall back to the hook's own cwd.
if [ -z "$file" ]; then
  target_dir="."
else
  # The file may not exist yet (Write creating a new file). Walk up to
  # the first directory that does exist so `git -C` has something real.
  target_dir=$(dirname -- "$file")
  while [ ! -d "$target_dir" ] && [ "$target_dir" != "/" ] && [ "$target_dir" != "." ]; do
    target_dir=$(dirname -- "$target_dir")
  done
fi

# Not in a git repo? Allow.
git -C "$target_dir" rev-parse --git-dir &>/dev/null || exit 0

# Inside a linked worktree (git-dir differs from the common dir)? Allow.
git_dir=$(git -C "$target_dir" rev-parse --git-dir)
common_dir=$(git -C "$target_dir" rev-parse --git-common-dir)
if [ "$git_dir" != "$common_dir" ]; then
  exit 0
fi

# On a non-main/master branch? Allow.
branch=$(git -C "$target_dir" branch --show-current 2>/dev/null)
if [ -n "$branch" ] && [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
  exit 0
fi

echo "Edits must be made in a branch or worktree, not on main/master." >&2
exit 2
