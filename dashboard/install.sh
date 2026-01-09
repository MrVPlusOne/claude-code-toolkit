#!/bin/bash
# Claude Dashboard Installer
# Installs dashboard scripts and configures hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
DASHBOARD_FILE="$CLAUDE_DIR/dashboard.json"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CONFIG_FILE="$CLAUDE_DIR/dashboard_config.json"

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

# Ask about VS Code notifications
echo
read -rp "Enable VS Code notifications? (requires jiayiwei.uri-notifier extension) [y/N]: " ENABLE_VSCODE
ENABLE_VSCODE=${ENABLE_VSCODE:-n}

if [[ "$ENABLE_VSCODE" =~ ^[Yy]$ ]]; then
  echo '{"vscode_notify": true}' > "$CONFIG_FILE"
  VSCODE_ENABLED=true
else
  echo '{"vscode_notify": false}' > "$CONFIG_FILE"
  VSCODE_ENABLED=false
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

STEP=1
if [[ "$NEEDS_MANUAL_SETTINGS" == true ]]; then
  echo "$STEP. Add the hooks above to your settings.json"
  echo
  ((STEP++))
fi

echo "$STEP. For Pushover notifications, set these environment variables:"
echo "   export PUSHOVER_API_TOKEN='your-api-token'"
echo "   export PUSHOVER_USER_KEY='your-user-key'"
echo
((STEP++))

echo "$STEP. To view the dashboard, run:"
echo "   ~/.claude/scripts/dashboard.sh          # one-time view"
echo "   ~/.claude/scripts/dashboard.sh --watch  # live refresh"

if [[ "$VSCODE_ENABLED" == true ]]; then
  echo
  ((STEP++))
  echo "$STEP. Install VS Code extension: jiayiwei.uri-notifier"
fi
echo
