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
NEEDS_MANUAL_SETTINGS=false
if [[ -f "$SETTINGS_FILE" ]]; then
  NEEDS_MANUAL_SETTINGS=true
  echo
  echo "WARNING: $SETTINGS_FILE already exists."
  echo "Please add the following hooks section to your settings.json:"
  echo
  echo "─────────────────────────────────────────────────────────"
  cat "$SCRIPT_DIR/settings.json.example"
  echo "─────────────────────────────────────────────────────────"
else
  echo "Installing settings.json..."
  cp "$SCRIPT_DIR/settings.json.example" "$SETTINGS_FILE"
fi

echo
if [[ "$NEEDS_MANUAL_SETTINGS" == true ]]; then
  echo "Scripts installed. Please update your settings.json to complete setup."
else
  echo "Installation complete!"
fi
echo
echo "Next steps:"
if [[ "$NEEDS_MANUAL_SETTINGS" == true ]]; then
  echo "1. Add the hooks above to your settings.json"
  echo
  echo "2. For Pushover notifications, set these environment variables:"
else
  echo "1. For Pushover notifications, set these environment variables:"
fi
echo "   export PUSHOVER_API_TOKEN='your-api-token'"
echo "   export PUSHOVER_USER_KEY='your-user-key'"
echo
if [[ "$NEEDS_MANUAL_SETTINGS" == true ]]; then
  echo "3. To view the dashboard, run:"
else
  echo "2. To view the dashboard, run:"
fi
echo "   ~/.claude/scripts/dashboard.sh          # one-time view"
echo "   ~/.claude/scripts/dashboard.sh --watch  # live refresh"
echo
if [[ "$NEEDS_MANUAL_SETTINGS" == true ]]; then
  echo "4. (Optional) Install VS Code extension 'jiayiwei.uri-notifier'"
else
  echo "3. (Optional) Install VS Code extension 'jiayiwei.uri-notifier'"
fi
echo "   for in-editor notifications"
