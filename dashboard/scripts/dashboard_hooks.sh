#!/bin/bash
# Claude Code dashboard hook handler
# Usage: dashboard_hooks.sh <status> [--notify [priority] [sound]]
#
# Statuses: working, waiting, permission, new_session, remove

set -e

DASHBOARD_FILE="$HOME/.claude/dashboard.json"
CONFIG_FILE="$HOME/.claude/dashboard_config.json"
MACHINE=$(hostname -s)
PROJECT_ID=$(basename "$PWD")

# Check if VS Code notifications are enabled in config
vscode_notify_enabled() {
  if [[ -f "$CONFIG_FILE" ]] && command -v jq &> /dev/null; then
    [[ $(jq -r '.vscode_notify // false' "$CONFIG_FILE") == "true" ]]
  else
    false
  fi
}

# Initialize dashboard file if needed
init_dashboard() {
  if [[ ! -f "$DASHBOARD_FILE" ]]; then
    echo '{"instances":{}}' > "$DASHBOARD_FILE"
  fi
}

# Update dashboard entry
update_dashboard() {
  local status="$1"
  local message="$2"

  init_dashboard

  if command -v jq &> /dev/null; then
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local tmp_file=$(mktemp)
    jq --arg id "$PROJECT_ID" \
       --arg status "$status" \
       --arg message "$message" \
       --arg timestamp "$timestamp" \
       --arg cwd "$PWD" \
       '.instances[$id] = {status: $status, message: $message, timestamp: $timestamp, cwd: $cwd}' \
       "$DASHBOARD_FILE" > "$tmp_file" && mv "$tmp_file" "$DASHBOARD_FILE"
  fi
}

# Remove dashboard entry
remove_dashboard() {
  if [[ -f "$DASHBOARD_FILE" ]] && command -v jq &> /dev/null; then
    local tmp_file=$(mktemp)
    jq --arg id "$PROJECT_ID" 'del(.instances[$id])' "$DASHBOARD_FILE" > "$tmp_file" && mv "$tmp_file" "$DASHBOARD_FILE"
  fi
}

# URL-encode a string
urlencode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))"
}

# Send notifications (VS Code + Pushover)
send_notifications() {
  local message="$1"
  local priority="${2:-0}"
  local sound="${3:-pushover}"

  local title="Claude Code ($PROJECT_ID@$MACHINE)"

  # VS Code notification via URI handler (enabled via install.sh)
  if vscode_notify_enabled; then
    local encoded_title=$(urlencode "$title")
    local encoded_msg=$(urlencode "$message")
    local uri="vscode://jiayiwei.uri-notifier?title=${encoded_title}&msg=${encoded_msg}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      open "$uri" 2>/dev/null &
    else
      xdg-open "$uri" 2>/dev/null &
    fi
  fi

  # Pushover notification
  if [[ -n "$PUSHOVER_API_TOKEN" && -n "$PUSHOVER_USER_KEY" ]]; then
    curl -s -X POST https://api.pushover.net/1/messages.json \
      -d "token=${PUSHOVER_API_TOKEN}" \
      -d "user=${PUSHOVER_USER_KEY}" \
      -d "title=${title}" \
      -d "message=${message}" \
      -d "priority=${priority}" \
      -d "sound=${sound}" > /dev/null
  fi
}

# --- Main ---

STATUS="$1"
shift || true

# Parse --notify flag
NOTIFY=false
PRIORITY=0
SOUND="pushover"
if [[ "$1" == "--notify" ]]; then
  NOTIFY=true
  PRIORITY="${2:-0}"
  SOUND="${3:-pushover}"
fi

# Status → message mapping
case "$STATUS" in
  working)
    MESSAGE="Processing..."
    ;;
  waiting)
    MESSAGE="Awaiting your input"
    ;;
  permission)
    MESSAGE="Permission required"
    ;;
  new_session)
    MESSAGE="New session"
    ;;
  remove)
    remove_dashboard
    exit 0
    ;;
  *)
    echo "Usage: dashboard_hooks.sh <status> [--notify [priority] [sound]]"
    echo "Statuses: working, waiting, permission, new_session, remove"
    exit 1
    ;;
esac

update_dashboard "$STATUS" "$MESSAGE"

if [[ "$NOTIFY" == true ]]; then
  send_notifications "$MESSAGE" "$PRIORITY" "$SOUND"
fi
