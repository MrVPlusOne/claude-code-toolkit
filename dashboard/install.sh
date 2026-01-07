#!/bin/bash
# Claude Dashboard Installer
# Installs dashboard scripts and configures hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
DASHBOARD_FILE="$CLAUDE_DIR/dashboard.json"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "Claude Dashboard Installer"
echo "=========================="
echo

# Create directories
echo "Creating directories..."
mkdir -p "$SCRIPTS_DIR"

# Copy scripts
echo "Installing scripts to $SCRIPTS_DIR..."
cp "$SCRIPT_DIR/scripts/"*.sh "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/"*.sh

# Initialize dashboard.json if it doesn't exist
if [[ ! -f "$DASHBOARD_FILE" ]]; then
  echo "Creating dashboard.json..."
  echo '{"instances":{}}' > "$DASHBOARD_FILE"
else
  echo "dashboard.json already exists, skipping..."
fi

# Handle settings.json
if [[ -f "$SETTINGS_FILE" ]]; then
  echo
  echo "WARNING: $SETTINGS_FILE already exists."
  echo "You need to manually merge the hooks from settings.json.example"
  echo "into your existing settings.json file."
  echo
  echo "Example file: $SCRIPT_DIR/settings.json.example"
else
  echo "Installing settings.json..."
  cp "$SCRIPT_DIR/settings.json.example" "$SETTINGS_FILE"
fi

echo
echo "Installation complete!"
echo
echo "Next steps:"
echo "1. For Pushover notifications, set these environment variables:"
echo "   export PUSHOVER_API_TOKEN='your-api-token'"
echo "   export PUSHOVER_USER_KEY='your-user-key'"
echo
echo "2. To view the dashboard, run:"
echo "   ~/.claude/scripts/monitor_dashboard.sh"
echo "   or: watch -n 1 ~/.claude/scripts/dashboard.sh"
echo
echo "3. (Optional) Install VS Code extension 'jiayiwei.uri-notifier'"
echo "   for in-editor notifications"
