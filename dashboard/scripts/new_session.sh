#!/bin/bash
# Claude new session status updater
# Updates dashboard.json to show this instance started a new session
# Called by SessionStart hook (startup/clear)

DASHBOARD_FILE="$HOME/.claude/dashboard.json"

# Use directory name as project ID
PROJECT_ID=$(basename "$PWD")

# Create dashboard file if it doesn't exist
if [[ ! -f "$DASHBOARD_FILE" ]]; then
  echo '{"instances":{}}' > "$DASHBOARD_FILE"
fi

# Get current timestamp in ISO format
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update dashboard using jq
if command -v jq &> /dev/null; then
  TMP_FILE=$(mktemp)
  jq --arg id "$PROJECT_ID" \
     --arg status "new_session" \
     --arg message "New session" \
     --arg timestamp "$TIMESTAMP" \
     --arg cwd "$PWD" \
     '.instances[$id] = {status: $status, message: $message, timestamp: $timestamp, cwd: $cwd}' \
     "$DASHBOARD_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$DASHBOARD_FILE"
fi
