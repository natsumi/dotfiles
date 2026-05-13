#!/usr/bin/env bash

# Guard hook: block file edits and mutating Bash commands on main/master.
# Allows operations in linked worktrees, on non-main branches, or outside git.
#
# The decision is keyed on the *target file's* repository and branch
# (read from tool_input.file_path / tool_input.notebook_path on stdin),
# not on the hook process's own cwd. This matters for subagents: their
# cwd is the harness root even when they're editing a file inside a
# linked worktree, so a cwd-based check would block edits the user
# clearly intends to allow.
#
# For Bash, there's no file_path to key on, so we fall back to the hook's
# cwd. Most Bash invocations are read-only and exit fast (no git calls).

payload=$(cat)
tool=$(printf '%s' "$payload" | jq -r '.tool_name // empty')

case "$tool" in
  Bash)
    cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')
    # Cheap early-exit: only proceed for known-mutating commands.
    case "$cmd" in
      *"git commit"*|*"git merge"*|*"git rebase"*|*"git reset --hard"*|\
      *"git push"*|*"git am "*|*"git cherry-pick"*|*"git revert"*) ;;
      *) exit 0 ;;
    esac
    target_dir="."
    ;;
  *)
    file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
    if [ -z "$file" ]; then
      target_dir="."
    else
      # File may not exist yet (Write creating a new file). Walk up to
      # the first directory that does exist so `git -C` has something real.
      target_dir=$(dirname -- "$file")
      while [ ! -d "$target_dir" ] && [ "$target_dir" != "/" ] && [ "$target_dir" != "." ]; do
        target_dir=$(dirname -- "$target_dir")
      done
    fi
    ;;
esac

# Not in a git repo? Allow.
git -C "$target_dir" rev-parse --git-dir &>/dev/null || exit 0

# Linked worktrees have a `commondir` file inside their git-dir pointing
# back to the main repo's git-dir. Main checkouts do not.
git_dir=$(git -C "$target_dir" rev-parse --git-dir)
case "$git_dir" in
  /*) ;;
  *) git_dir="$target_dir/$git_dir" ;;
esac
[ -f "$git_dir/commondir" ] && exit 0

# On a non-main/master branch? Allow.
branch=$(git -C "$target_dir" branch --show-current 2>/dev/null)
if [ -n "$branch" ] && [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
  exit 0
fi

if [ "$tool" = "Bash" ]; then
  echo "Mutating Bash command blocked on $branch. Switch to a feature branch or worktree." >&2
else
  echo "Edits must be made in a branch or worktree, not on $branch." >&2
fi
exit 2
