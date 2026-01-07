#!/bin/bash
# Claude Code unified hook handler
# Usage: dashboard_hooks.sh <action> [args...]
#   actions: new_session, working, notify, session_end

set -e

DASHBOARD_FILE="$HOME/.claude/dashboard.json"
MACHINE=$(hostname -s)
PROJECT_ID=$(basename "$PWD")

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
  local title="$1"
  local message="$2"
  local priority="${3:-0}"
  local sound="${4:-pushover}"

  # VS Code notification via URI handler
  local encoded_title=$(urlencode "$title")
  local encoded_msg=$(urlencode "$message")
  xdg-open "vscode://jiayiwei.uri-notifier?title=${encoded_title}&msg=${encoded_msg}" 2>/dev/null &

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

# --- Action handlers ---

action_new_session() {
  update_dashboard "new_session" "New session"
}

action_working() {
  update_dashboard "working" "Processing..."
}

action_notify() {
  local message="${1:-Notification}"
  local priority="${2:-0}"
  local sound="${3:-pushover}"

  # Determine status based on message content
  local status="waiting"
  if [[ "$message" == *"Permission"* ]]; then
    status="permission"
  elif [[ "$message" == *"completed"* ]] || [[ "$message" == *"stopped"* ]]; then
    status="stopped"
  fi

  update_dashboard "$status" "$message"

  # Build title
  local title="Claude Code ($PROJECT_ID@$MACHINE)"
  send_notifications "$title" "$message" "$priority" "$sound"
}

action_session_end() {
  # Read hook input from stdin to get the reason
  local input=$(cat)
  local reason=$(echo "$input" | jq -r '.reason // "other"' 2>/dev/null)

  # Don't remove on "clear" - new_session will update it
  if [[ "$reason" != "clear" ]]; then
    remove_dashboard
  fi
}

# --- Main ---

ACTION="$1"
shift || true

case "$ACTION" in
  new_session)
    action_new_session
    ;;
  working)
    action_working
    ;;
  notify)
    action_notify "$@"
    ;;
  session_end)
    action_session_end
    ;;
  *)
    echo "Usage: dashboard_hooks.sh <action> [args...]"
    echo "Actions: new_session, working, notify, session_end"
    exit 1
    ;;
esac
