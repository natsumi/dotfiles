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
session_id=$(extract session_id)
transcript_path=$(extract transcript_path)

project=$(basename "${cwd:-claude}")
host=$(hostname -s 2>/dev/null || echo claude)

last_assistant_text() {
  [ -f "$transcript_path" ] || return
  jq -nr '
    reduce inputs as $e (null;
      if $e.type == "assistant"
        and any($e.message.content[]?; .type == "text")
      then $e else . end)
    | (.message.content // [])
    | map(select(.type == "text") | .text)
    | join(" ")
  ' "$transcript_path" 2>/dev/null | tr -s '[:space:]' ' ' | head -c 200
}

click_url=""
if [ -n "$session_id" ]; then
  bridge_id=$(jq -r --arg s "$session_id" \
    'select(.sessionId == $s) | .bridgeSessionId // empty' \
    "$HOME"/.claude/sessions/*.json 2>/dev/null \
    | grep -m1 '^session_')
  [ -n "$bridge_id" ] && click_url="https://claude.ai/code/$bridge_id"
fi

case "$event" in
  Notification)
    title="Claude waiting · $host · $project"
    body="${message:-Waiting for input}"
    preview=$(last_assistant_text)
    [ -n "$preview" ] && body="$body — $preview"
    tags="bell"
    priority="4"
    ;;
  Stop)
    title="Claude done · $host · $project"
    body="$(last_assistant_text)"
    body="${body:-Turn complete}"
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

click_header=()
[ -n "$click_url" ] && click_header=(-H "Click: $click_url")

curl -fsS \
  -H "Title: $title" \
  -H "Tags: $tags" \
  -H "Priority: $priority" \
  ${click_header[@]+"${click_header[@]}"} \
  -d "$body" \
  "https://ntfy.sh/$topic" >/dev/null 2>&1 || true

exit 0
