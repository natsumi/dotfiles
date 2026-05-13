#!/usr/bin/env bash
# Forward Claude Code hook events to ntfy.sh.
# Topic comes from $NTFY_CLAUDE_TOPIC (set in ~/.zshrc.local, gitignored).
# No-ops silently if unset. Reads hook payload JSON from stdin.

set -u

topic="${NTFY_CLAUDE_TOPIC:-}"
[ -z "$topic" ] && exit 0

payload="$(cat)"

extract() {
  printf '%s' "$payload" | jq -r --arg k "$1" '.[$k] // empty'
}

event=$(extract hook_event_name)
message=$(extract message)
cwd=$(extract cwd)

project=$(basename "${cwd:-claude}")
host=$(hostname -s 2>/dev/null || echo claude)

case "$event" in
  Notification)
    title="Claude waiting · $host · $project"
    body="${message:-Waiting for input}"
    tags="bell"
    priority="4"
    ;;
  Stop)
    title="Claude done · $host · $project"
    body="Turn complete"
    tags="heavy_check_mark"
    priority="2"
    ;;
  *)
    title="Claude · $host · $project"
    body="${event:-event}"
    tags="robot"
    priority="3"
    ;;
esac

curl -fsS \
  -H "Title: $title" \
  -H "Tags: $tags" \
  -H "Priority: $priority" \
  -d "$body" \
  "https://ntfy.sh/$topic" >/dev/null 2>&1 || true

exit 0
