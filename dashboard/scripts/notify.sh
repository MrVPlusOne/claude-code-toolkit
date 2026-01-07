#!/bin/bash
# Claude Code notification script (Dashboard + VS Code + Pushover)
# Usage: notify.sh "Message" [priority] [sound]

DASHBOARD_FILE="$HOME/.claude/dashboard.json"

# URL-encode a string
urlencode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))"
}

# Get machine hostname
MACHINE=$(hostname -s)

# Use directory name as project ID
PROJECT_ID=$(basename "$PWD")

# Build title: "Claude Code (Copy1@hostname)"
TITLE="Claude Code"
if [[ -n "$PROJECT_ID" ]]; then
  TITLE="$TITLE ($PROJECT_ID@$MACHINE)"
else
  TITLE="$TITLE (@$MACHINE)"
fi

MESSAGE="${1:-Notification}"

# Determine status based on message content
STATUS="waiting"
if [[ "$MESSAGE" == *"Permission"* ]]; then
  STATUS="permission"
elif [[ "$MESSAGE" == *"completed"* ]] || [[ "$MESSAGE" == *"stopped"* ]]; then
  STATUS="stopped"
fi

# Update dashboard.json
if [[ -f "$DASHBOARD_FILE" ]] && command -v jq &> /dev/null; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  TMP_FILE=$(mktemp)
  jq --arg id "$PROJECT_ID" \
     --arg status "$STATUS" \
     --arg message "$MESSAGE" \
     --arg timestamp "$TIMESTAMP" \
     --arg cwd "$PWD" \
     '.instances[$id] = {status: $status, message: $message, timestamp: $timestamp, cwd: $cwd}' \
     "$DASHBOARD_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$DASHBOARD_FILE"
fi

# VS Code notification via URI handler (fails silently if extension not installed)
ENCODED_TITLE=$(urlencode "$TITLE")
ENCODED_MSG=$(urlencode "$MESSAGE")
xdg-open "vscode://jiayiwei.uri-notifier?title=${ENCODED_TITLE}&msg=${ENCODED_MSG}" 2>/dev/null &

# Remote Pushover notification
curl -s -X POST https://api.pushover.net/1/messages.json \
  -d "token=${PUSHOVER_API_TOKEN}" \
  -d "user=${PUSHOVER_USER_KEY}" \
  -d "title=${TITLE}" \
  -d "message=${MESSAGE}" \
  -d "priority=${2:-0}" \
  -d "sound=${3:-pushover}" > /dev/null
