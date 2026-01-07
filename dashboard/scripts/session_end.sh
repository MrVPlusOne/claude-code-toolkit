#!/bin/bash
# Claude session end handler
# Removes entry from dashboard when session exits (except on /clear)
# Called by SessionEnd hook

DASHBOARD_FILE="$HOME/.claude/dashboard.json"

# Use directory name as project ID
PROJECT_ID=$(basename "$PWD")

# Read hook input from stdin to get the reason
INPUT=$(cat)
REASON=$(echo "$INPUT" | jq -r '.reason // "other"' 2>/dev/null)

# Don't remove on "clear" - new_session.sh will update it
if [[ "$REASON" == "clear" ]]; then
  exit 0
fi

# Remove entry from dashboard
if [[ -f "$DASHBOARD_FILE" ]] && command -v jq &> /dev/null; then
  TMP_FILE=$(mktemp)
  jq --arg id "$PROJECT_ID" 'del(.instances[$id])' "$DASHBOARD_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$DASHBOARD_FILE"
fi
