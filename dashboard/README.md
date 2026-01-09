# Claude Dashboard

A real-time monitoring system for multiple Claude Code instances. Track status across projects with a terminal dashboard and optional push notifications.

## Features

- **Multi-instance tracking** - See all running Claude sessions at a glance
- **Real-time status** - Working, awaiting input, permission needed, completed
- **Push notifications** - Get notified when Claude needs attention (Pushover)
- **VS Code integration** - In-editor notifications (optional extension)
- **Terminal dashboard** - Clean, color-coded status display

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Hooks                        │
├─────────────────────────────────────────────────────────────┤
│  SessionStart  │  PreToolUse  │  Notification  │  SessionEnd│
└───────┬────────┴──────┬───────┴───────┬────────┴─────┬──────┘
        │               │               │              │
        ▼               ▼               ▼              ▼
┌───────────────┐ ┌───────────┐ ┌────────────┐ ┌─────────────┐
│new_session.sh │ │working.sh │ │ notify.sh  │ │session_end.sh│
└───────┬───────┘ └─────┬─────┘ └──────┬─────┘ └──────┬──────┘
        │               │              │              │
        └───────────────┼──────────────┼──────────────┘
                        ▼              │
              ┌─────────────────┐      │
              │ dashboard.json  │      │
              └────────┬────────┘      │
                       │               │
                       ▼               ▼
              ┌─────────────────┐ ┌─────────────┐
              │  dashboard.sh   │ │  Pushover   │
              │  (terminal UI)  │ │  VS Code    │
              └─────────────────┘ └─────────────┘
```

## Installation

### Quick Install

```bash
./install.sh
```

### Manual Install

1. Copy scripts to `~/.claude/scripts/`:
   ```bash
   mkdir -p ~/.claude/scripts
   cp scripts/*.sh ~/.claude/scripts/
   chmod +x ~/.claude/scripts/*.sh
   ```

2. Create dashboard data file:
   ```bash
   echo '{"instances":{}}' > ~/.claude/dashboard.json
   ```

3. Configure hooks in `~/.claude/settings.json`:
   ```bash
   cp settings.json.example ~/.claude/settings.json
   # Or merge into existing settings.json
   ```

## Configuration

### Pushover Notifications (Optional)

1. Create a Pushover account at https://pushover.net
2. Create an application to get an API token
3. Set environment variables:
   ```bash
   export PUSHOVER_API_TOKEN='your-api-token'
   export PUSHOVER_USER_KEY='your-user-key'
   ```

Add these to your `~/.bashrc` or `~/.zshrc` for persistence.

### VS Code Notifications (Optional)

During installation, you'll be asked if you want VS Code notifications. If enabled:

1. Install the `jiayiwei.uri-notifier` VS Code extension
2. The setting is stored in `~/.claude/dashboard_config.json`

To change later, edit `~/.claude/dashboard_config.json`:
```json
{"vscode_notify": true}
```

## Usage

### View Dashboard

Live monitoring (refreshes every second):
```bash
~/.claude/scripts/dashboard.sh --watch
```

One-time display:
```bash
~/.claude/scripts/dashboard.sh
```

### Dashboard Display

```
╔════════════════════════════════════════════════════════════════╗
║  Claude Dashboard (hostname)                                   ║
╠════════════════════════════════════════════════════════════════╣
║  ● MyProject             Awaiting input            2m ago ║
║  ● OtherProject          Working...                5s ago ║
║  ★ NewProject            New session              10s ago ║
╚════════════════════════════════════════════════════════════════╝
```

Status indicators:
- 🟢 `●` Working - Claude is processing
- 🟡 `●` Awaiting input - Waiting for your response
- 🔴 `●` Permission needed - Requires approval
- ⚪ `○` Completed - Task finished
- ⭐ `★` New session - Just started

## Scripts Reference

| Script | Trigger | Purpose |
|--------|---------|---------|
| `new_session.sh` | SessionStart | Mark instance as new session |
| `working.sh` | PreToolUse | Update status to "working" |
| `notify.sh` | Notification, Stop | Send notifications + update dashboard |
| `session_end.sh` | SessionEnd | Remove instance from dashboard |
| `dashboard.sh` | Manual | Display dashboard (`--watch` for live refresh) |

## Prerequisites

- **jq** - JSON processor (required)
  ```bash
  # Ubuntu/Debian
  sudo apt install jq

  # macOS
  brew install jq
  ```

- **curl** - For Pushover notifications (usually pre-installed)

## Troubleshooting

**Dashboard shows no instances:**
- Ensure hooks are configured in `~/.claude/settings.json`
- Check that `~/.claude/dashboard.json` exists
- Verify scripts are executable: `chmod +x ~/.claude/scripts/*.sh`

**Notifications not working:**
- Verify Pushover environment variables are set
- Test manually: `~/.claude/scripts/notify.sh "Test message"`

**Permission errors:**
- Run `chmod +x ~/.claude/scripts/*.sh`
