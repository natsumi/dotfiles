#!/usr/bin/env bash

# Guard hook: block file edits on main/master.
# Allows edits in linked worktrees, on non-main branches, or outside git.
#
# The decision is keyed on the *target file's* repository and branch
# (read from tool_input.file_path / tool_input.notebook_path on stdin),
# not on the hook process's own cwd. This matters for subagents: their
# cwd is the harness root even when they're editing a file inside a
# linked worktree, so a cwd-based check would block edits the user
# clearly intends to allow.
#
# Bash is intentionally not guarded: the harness cwd is unreliable
# for inferring which repo/branch a command targets (subagents often
# `cd /path/to/worktree && ...` from the harness root), and false
# positives on git commands were the primary failure mode.

payload=$(cat)
tool=$(printf '%s' "$payload" | jq -r '.tool_name // empty')

# Don't guard Bash — see header.
[ "$tool" = "Bash" ] && exit 0

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

# Gitignored files aren't tracked source — editing them on main can never
# produce an unwanted commit. This covers throwaway tool state (e.g.
# .claude/codex-review/ workflow artifacts) that an engine writes via Bash
# but a skill writes via the guarded Write tool.
if [ -n "$file" ] && git -C "$target_dir" check-ignore -q "$file" 2>/dev/null; then
  exit 0
fi

# On a non-main/master branch? Allow.
branch=$(git -C "$target_dir" branch --show-current 2>/dev/null)
if [ -n "$branch" ] && [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
  exit 0
fi

echo "Edits must be made in a branch or worktree, not on $branch." >&2
exit 2
