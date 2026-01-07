#!/bin/bash
# Monitor Claude Dashboard - refreshes every second
# Usage: monitor_dashboard.sh

watch -n 1 -c ~/.claude/scripts/dashboard.sh
