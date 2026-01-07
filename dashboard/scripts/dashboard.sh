#!/bin/bash
# Claude Dashboard - displays status of all Claude instances
# Usage: dashboard.sh           # Show once
#        dashboard.sh --watch   # Live refresh every second

# Handle --watch / -w flag
if [[ "$1" == "--watch" || "$1" == "-w" ]]; then
  exec watch -n 1 -c "$0"
fi

DASHBOARD_FILE="$HOME/.claude/dashboard.json"
MACHINE=$(hostname -s)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Check if dashboard file exists
if [[ ! -f "$DASHBOARD_FILE" ]]; then
  echo "No dashboard data found."
  exit 0
fi

# Get current timestamp
NOW=$(date +%s)

# Print header
echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Claude Dashboard (${MACHINE})$(printf '%*s' $((36 - ${#MACHINE})) '')║${NC}"
echo -e "${BOLD}╠════════════════════════════════════════════════════════════════╣${NC}"

# Parse JSON and display each instance
# Using jq if available, otherwise basic parsing
if command -v jq &> /dev/null; then
  # Sort by status priority (permission=0, waiting=1, working=2, stopped=3) then by recency
  SORTED_INSTANCES=$(jq -r '
    .instances | to_entries |
    map({
      id: .key,
      status: .value.status,
      message: .value.message,
      timestamp: .value.timestamp,
      priority: (
        if .value.status == "permission" then 0
        elif .value.status == "waiting" then 1
        elif .value.status == "stopped" then 2
        elif .value.status == "working" then 3
        elif .value.status == "new_session" then 4
        else 5 end
      )
    }) |
    sort_by(.priority, .timestamp) |
    reverse |
    sort_by(.priority) |
    .[] | [.id, .status, .message, .timestamp] | @tsv
  ' "$DASHBOARD_FILE" 2>/dev/null)

  if [[ -z "$SORTED_INSTANCES" ]]; then
    echo -e "${BOLD}║${NC}  No active instances$(printf '%*s' 44 '')${BOLD}║${NC}"
  else
    while IFS=$'\t' read -r ID STATUS MESSAGE TIMESTAMP; do

      # Calculate time ago
      if [[ -n "$TIMESTAMP" ]]; then
        TS_EPOCH=$(date -d "$TIMESTAMP" +%s 2>/dev/null || echo "$NOW")
        DIFF=$((NOW - TS_EPOCH))
        if [[ $DIFF -lt 60 ]]; then
          TIME_AGO="${DIFF}s ago"
        elif [[ $DIFF -lt 3600 ]]; then
          TIME_AGO="$((DIFF / 60))m ago"
        else
          TIME_AGO="$((DIFF / 3600))h ago"
        fi
      else
        TIME_AGO="unknown"
      fi

      # Status indicator
      case "$STATUS" in
        "working")
          ICON="${GREEN}●${NC}"
          STATUS_TEXT="Working..."
          ;;
        "waiting")
          ICON="${YELLOW}●${NC}"
          STATUS_TEXT="Awaiting input"
          ;;
        "permission")
          ICON="${RED}●${NC}"
          STATUS_TEXT="Permission needed"
          ;;
        "stopped")
          ICON="${WHITE}○${NC}"
          STATUS_TEXT="Completed"
          ;;
        "new_session")
          ICON="${BOLD}★${NC}"
          STATUS_TEXT="New session"
          ;;
        *)
          ICON="${WHITE}?${NC}"
          STATUS_TEXT="Unknown"
          ;;
      esac

      # Format display (truncate long names to 20 chars)
      DISPLAY_ID=$(printf '%-20s' "${ID:0:20}")
      DISPLAY_STATUS=$(printf '%-18s' "$STATUS_TEXT")
      DISPLAY_TIME=$(printf '%8s' "$TIME_AGO")

      echo -e "${BOLD}║${NC}  $ICON ${DISPLAY_ID} ${DISPLAY_STATUS} ${DISPLAY_TIME} ${BOLD}║${NC}"
    done <<< "$SORTED_INSTANCES"
  fi
else
  echo -e "${BOLD}║${NC}  jq not installed - install for dashboard$(printf '%*s' 21 '')${BOLD}║${NC}"
fi

echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
